terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # This allows updates within version 5, but not 6.0
    }
  }
}

provider "aws" {
  region = "us-east-2" # Replace with your preferred region, e.g., us-west-2
  profile = var.aws_profile
}

locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = "Terraform"
  }
}

/* data "terraform_remote_state" "data" {

  backend = "s3"

  config = {
    bucket = "rahul999-terraform-state"
    key    = "qa/data/terraform.tfstate"
    region = "us-east-2"
  }
} */

terraform {
  backend "s3" {
    bucket = "rahul999-terraform-state"
    key    = "qa/platform/terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}

module "my_network" {
  source           = "../../../modules/networking"
  environment_name = "Lab"
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  vpc_cidr         = "10.0.0.0/16"
}

module "alb_sg" {
  source = "../../../modules/security-group"
  name   = "alb-sg"
  vpc_id = module.my_network.vpc_id
  tags = local.common_tags
}

module "app_sg" {
  source = "../../../modules/security-group"
  name   = "app-sg"
  vpc_id = module.my_network.vpc_id
  tags = local.common_tags
} 



## Rule for Internet to ALB

resource "aws_vpc_security_group_ingress_rule" "http_to_alb" {
  security_group_id = module.alb_sg.security_group_id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
  }

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = module.alb_sg.security_group_id
  referenced_security_group_id = module.app_sg.security_group_id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  }


resource "aws_vpc_security_group_ingress_rule" "alb_to_app" {
  security_group_id = module.app_sg.security_group_id
  referenced_security_group_id = module.alb_sg.security_group_id
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
  }

/* resource "aws_vpc_security_group_egress_rule" "app_to_db" { 
  security_group_id = module.app_sg.security_group_id 
  referenced_security_group_id = data.terraform_remote_state.data.outputs.db_sg_id 
  from_port = 3306 
  ip_protocol = "tcp" 
  to_port = 3306 
  } */

resource "aws_vpc_security_group_egress_rule" "app_all_outbound" {
  security_group_id = module.app_sg.security_group_id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}


  ### ALB module call
 module "alb" {
  source             = "../../../modules/alb"
  create = true
  name               = "main-alb-${var.environment}"
  vpc_id             = module.my_network.vpc_id
  alb_sg_id         = [module.alb_sg.security_group_id]
  subnets            = module.my_network.public_subnet_ids
  load_balancer_type = "application"
  tags = local.common_tags
  #instance_ids = flatten([for m in values(module.web_servers) : m.instance_ids])
  #instance_ids = module.web_servers.instance_ids
} 

## Creating EC2 instances
/* 
module "web_servers" {
  source               = "./modules/ec2"
  create = true
  instance_count = var.instance_count
  #for_each                = var.public_subnets
  #for_each                = var.public_subnets
  #instance_name        = "${var.app_name}-${each.key}"
  instance_name        = var.app_name
  instance_type        = var.ec2_instance_type # Get the value from terraform.tfvars and hand it over to ec2-instance
  #iam_instance_profile = module.my_iam_role.instance_profile_name
  #patch_group = "Web-${var.environment}"
    
  # Now we use the ID from our OWN module!
  #subnet_id            = module.my_network.public_subnet_id 

  # Find the specific subnet ID created by the networking module
  # that matches the current key (e.g., "public-1")
  #subnet_id = module.my_network.public_subnet_ids_map[each.key]
  subnet_ids = values(module.my_network.private_subnet_ids)
  vpc_security_group_ids = [module.app_sg.security_group_id] # hand over data to ec2-instance module
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from my Custom VPC at $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
}
 */
module "asg" {

  source = "../../../modules/autoscaling-group"
  app_name = var.app_name
  subnet_ids = values(module.my_network.private_subnet_ids)
  launch_template_id = module.launch_template.launch_template_id
  target_group_arns = [module.alb.target_group_arn ]
  desired_capacity = 2
  min_size = 2
  max_size = 4
  
  #tags = local.common_tags
}

module "launch_template" {

  source = "../../../modules/launch_template"
  app_name = var.app_name
  ami_id = var.ami_id
  instance_type = var.instance_type
  instance_profile_name = module.app_role.instance_profile_name
  vpc_security_group_ids = [module.app_sg.security_group_id]
  environment = var.environment
  user_data = <<-EOF
              #!/bin/bash
              # Update OS
              yum update -y

              # Install Apache
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd

              # Run journalctl to capture system logs
              journalctl -f > /var/log/system.log &

              # Create sample page
              echo "<h1>Hello from my Custom VPC at $(hostname -f)</h1>" > /var/www/html/index.html

              # Install CloudWatch Agent
              yum install -y amazon-cloudwatch-agent

              # Create CloudWatch Agent config
              cat <<CWCONFIG >/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              {
                "logs": {
                  "logs_collected": {
                    "files": {
                      "collect_list": [
                        {
                          "file_path": "/var/log/system.log",
                          "log_group_name": "/aws/ec2/system",
                          "log_stream_name": "{instance_id}"
                        },
                        {
                          "file_path": "/var/log/httpd/access_log",
                          "log_group_name": "/aws/ec2/apache",
                          "log_stream_name": "{instance_id}"
                        },
                        {
                          "file_path": "/var/log/httpd/error_log",
                          "log_group_name": "/aws/ec2/apache",
                          "log_stream_name": "{instance_id}"
                        }
                      ]
                    }
                  }
                }
              }
              CWCONFIG

              # Start CloudWatch Agent
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
              -a fetch-config \
              -m ec2 \
              -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
              -s
              EOF


  tags = local.common_tags
}

module "app_role" {
  source = "../../../modules/iam-role"
  role_name = "app-ec2-role"
  trusted_service = "ec2.amazonaws.com"
  policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore","arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]

}

module "system_logs" {

  source = "../../../modules/cloudwatch-logs"
  log_group_name = "/aws/ec2/system"
  retention_in_days = 30
  tags = local.common_tags

}

module "application_logs" {

  source = "../../../modules/cloudwatch-logs"
  log_group_name = "/aws/ec2/application"
  retention_in_days = 30
  tags = local.common_tags

}

/* module "route53" {

  source = "./modules/route53"
  domain_name = "example.com"
  app_subdomain = "app"
  alb_dns_name = module.alb.dns_name
  alb_zone_id = module.alb.zone_id
  tags = {
    Environment = "dev"
  }
} */

module "alarms" {

  source = "../../../modules/cloudwatch-alarm"
  asg_name = module.asg.asg_name
  alarm_actions = [ module.sns.sns_topic_arn ]
  tags = local.common_tags

}

module "sns" {

  source = "../../../modules/sns"
  topic_name = "infrastructure-alerts"
  email_endpoint = var.notification_email
  tags = local.common_tags

}