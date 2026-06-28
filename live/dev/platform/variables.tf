variable "target_bucket_name" {
  description = "The name of our S3 bucket"
  type        = string
  default     = "rahulsfirst-bucket-2026"
}

variable "instance_type" {
  type        = string
  description = "The size of the instance passed to the child module"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "ami_id" {
  type        = string
  description = "The size of the instance passed to the child module"
}
variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "Map of public subnets defined in terraform.tfvars"
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
  description = "Map of private subnets defined in terraform.tfvars"
}

variable "bastion_instance_type" {
  type        = string
  description = "The size of the instance passed to the child module"
}

variable "target_users" {
  description = "List of IAM User names"
  type        = list(string)
  default     = []
}

variable "target_groups" {
  description = "List of IAM Group names"
  type        = list(string)
  default     = []
}
variable "aws_region" { type = string }
variable "environment" { type = string }
variable "project" { type = string }



variable "patch_groups" {
  type = map(object({
    schedule = string
  }))
  default = {
    "Web" = { schedule = "cron(0 2 ? * SUN *)" }
    "DB"  = { schedule = "cron(0 3 ? * SAT *)" }
  }
}

variable "instance_count" {
  type        = number
  description = "The number of ec2 servers"
}

variable "app_name" {
  type        = string
  description = "Name of application"
}

variable "notification_email" {
  type = string
}