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

data "aws_s3_bucket" "my_lab_bucket" {
  bucket = var.target_bucket_name #Variable value hard coded in tfvars
}

module "my_iam_role" {
  source = "./modules/iam-role"
  role_name = "my-s3-access-role"
  #create_instance_profile = true
    # We take the ARN from the data source and pass it in
  s3_bucket_arn = data.aws_s3_bucket.my_lab_bucket.arn

}

output "aws_iam_role_arn" {
  value       = module.my_iam_role.instance_profile_arn   # module.<MODULE_NAME>.<OUTPUT_NAME>
  description = "The ARN of the instance profile"
}

output "module_confirmed_arn" {
  value       = module.my_iam_role.bucket_arn_received   # module.<MODULE_NAME>.<OUTPUT_NAME>
  description = "The ARN of the bucket"
}

module "lambda_role" {
  source          = "./modules/iam-role"
  role_name       = "my-lambda-s3-role"
  trusted_service = "lambda.amazonaws.com"  # <-- Overriding the default
  s3_bucket_arn   = data.aws_s3_bucket.my_lab_bucket.arn
}

/* # 1. Find the Default VPC
data "aws_vpc" "default" {
  default = true
}

# 2. Find all Subnets inside that Default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id" #This is the specific attribute AWS uses to identify which VPC a subnet belongs to.
    values = [data.aws_vpc.default.id] #This is a list of values you want to match.e.g., vpc-0a1b2c3d...
  }
} */
/* 
module "my_ec2_instance" {
  source               = "./modules/ec2-instance"
  instance_name        = "Terraform-Lab-Server"
  instance_type        = var.ec2_instance_type # Passed from root variables
  iam_instance_profile = module.my_iam_role.instance_profile_name
  subnet_id            = data.aws_subnets.default.ids[0]
}

output "debug_profile_name" {
  value = module.my_iam_role.instance_profile_name
} */


module "my_network" {
  source           = "./modules/networking"
  environment_name = "Lab"
  public_subnets = var.public_subnets
  vpc_cidr         = "10.0.0.0/16"
}

module "my_security_group" {
  source               = "./modules/security"
  environment_name = "Lab"
  vpc_id = module.my_network.vpc_id
}

module "my_ec2_instance" {
  source               = "./modules/ec2-instance"
  for_each                = var.public_subnets
  instance_name        = "Custom-VPC-Server-${each.key}"
  instance_type        = var.ec2_instance_type # Get the value from terraform.tfvars and hand it over to ec2-instance
  iam_instance_profile = module.my_iam_role.instance_profile_name
  
  # Now we use the ID from our OWN module!
  #subnet_id            = module.my_network.public_subnet_id 

  # Find the specific subnet ID created by the networking module
  # that matches the current key (e.g., "public-1")
  subnet_id = module.my_network.public_subnet_ids_map[each.key]
  vpc_security_group_ids = [module.my_security_group.security_group_id] # hand over data to ec2-instance module
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from my Custom VPC at $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
}

output "final_instance_ids" {
  value = [for instance in module.my_ec2_instance : instance.instance_id]  # module.my_ec2_instance is a Map
}

  module "my_alb" {
  source             = "./modules/alb"        # Path to your ALB code
  vpc_id             = module.my_network.vpc_id
  alb_sg_id         = [module.my_security_group.alb_security_group_id]
  
  # Pass the list of subnet IDs from your networking loop
  public_subnet_ids  = module.my_network.public_subnet_ids
  # This creates the list: ["i-123", "i-456"]# This creates the list: ["i-123", "i-456"]
  # Pass the list of EC2 IDs so they can be added to the Target Group
  # We use 'values' to convert the map of instances into a list of IDs
  
  instance_ids       = [for instance in module.my_ec2_instance : instance.instance_id]
  
} 
