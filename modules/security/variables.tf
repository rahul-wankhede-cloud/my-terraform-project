
variable "vpc_id" {
  type        = string
  description = "The ID of the custom VPC"
}
variable "environment_name" {
  type = string
}

variable "bastion_security_group_id" {
  description = "List of security group IDs to associate with the instance"
 type        = string
}