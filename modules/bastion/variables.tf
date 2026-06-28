variable "instance_name" {
  type        = string
  description = "The Name tag for the Bastion EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The size of the instance (e.g., t2.micro)"
}

variable "iam_instance_profile" {
  type        = string
  description = "The name of the IAM instance profile to attach"
  default     = null
}

variable "subnet_id" {
  type        = string
  description = "The subnet to launch the instance in"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "List of security group IDs to associate with the instance"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "The ID of the custom VPC"
}

variable "patch_group" {
  type        = string
  description = "The size of the instance (e.g., t2.micro)"
}