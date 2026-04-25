
variable "aws_region" {
  type        = string
  description = "The name of the IAM role to create"
}

variable "users" {
  description = "List of IAM User names"
  type        = list(string)
  default     = []
}

variable "groups" {
  description = "List of IAM Group names"
  type        = list(string)
  default     = []
}

variable "target_instance_arn" {
  type        = string
  description = "The ARN of the Bastion host"
  default = null
}