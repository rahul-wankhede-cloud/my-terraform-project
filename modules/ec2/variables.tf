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

variable "subnet_id" {
  type        = string
  description = "The subnet to launch the instance in"
}