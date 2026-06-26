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

data "terraform_remote_state" "platform" {

  backend = "s3"

  config = {
    bucket = "rahul999-terraform-state"
    key    = "dev/platform/terraform.tfstate"
    region = "us-east-2"
  }
}

terraform {
  backend "s3" {
    bucket = "rahul999-terraform-state"
    key    = "dev/data/terraform.tfstate"
    region = "us-east-2"
    use_lockfile = true
  }
}


module "db_sg" {
  source = "../../../modules/security-group"
  name   = "db-sg"
  vpc_id = data.terraform_remote_state.platform.outputs.vpc_id
  tags = local.common_tags
}


resource "aws_vpc_security_group_egress_rule" "db_all_outbound" {
  security_group_id = module.db_sg.security_group_id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "app_to_db" {
  security_group_id = module.db_sg.security_group_id
  referenced_security_group_id = data.terraform_remote_state.platform.outputs.app_sg_id
  from_port   = 3306
  ip_protocol = "tcp"
  to_port     = 3306
  }


  module "my_db_instance" {
  source               = "../../../modules/database"
  create = true
  instance_class = var.db_instance_class
  identifier = var.db_identifier  
  password = var.db_password
  username = var.db_username
  vpc_security_group_ids = [module.db_sg.security_group_id]
  #private_subnet_ids  = module.my_network.private_subnet_ids
  subnet_ids = data.terraform_remote_state.platform.outputs.private_subnet_ids
  tags = local.common_tags
  }
