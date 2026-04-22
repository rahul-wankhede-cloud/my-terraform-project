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