variable "instance_name" {
  type        = string
  description = "The Name tag for the EC2 instance"
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

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet to launch the instance in"
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}

variable "user_data" {
  description = "The script to run on boot"
  type        = string
  default     = null
}

variable "patch_group" {
  type        = string
  description = "The SSM Patch Group this instance should belong to"
  default     = "Unassigned" # Or a common default like "General"
}

variable "create" {
  type    = bool
  default = false
}

variable "instance_count" {
  type = number
}