variable "target_bucket_name" {
  description = "The name of our S3 bucket"
  type        = string
  default     = "rahulsfirst-bucket-2026"
}

variable "ec2_instance_type" {
  type        = string
  description = "The size of the instance passed to the child module"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
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

variable "db_username" {
  type        = string
  description = "username login for the database"
}

variable "db_password" {
  type        = string
  description = "username login for the database"
}
variable "db_instance_class" {
  type        = string
  description = "Instance class for the database"
}
variable "db_identifier" {
  type        = string
  description = "Identifier for the database"
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
variable "aws_region"     { type = string }