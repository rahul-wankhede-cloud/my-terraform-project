variable "app_name" {
  description = "App name"
  type        = string
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
}

variable "instance_type" {
  description = "Instance type like t3.mciro"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "User data"
  type        = string
}

variable "environment" { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}

variable "instance_profile_name" {
  type = string
}
