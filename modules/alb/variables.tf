/* variable "public_subnet_ids" {
  type        = list(string)
  description = "The subnets provided by the networking module"
} */
variable "subnets" {
  type        = list(string)
  description = "The subnets provided by the networking module"
}
/* variable "instance_ids" {
  type        = list(string)
  description = "List of EC2 instance IDs to attach to the Target Group"
} */

variable "vpc_id" {
  type        = string
  description = "The ID of the custom VPC"
}

variable "load_balancer_type" {
  type        = string
  description = "Load balance type"
}

variable "alb_sg_id" {
  description = "List of security group IDs to associate with the instance"
  type        = list(string)
  default     = []
}
variable "create" {
  type        = bool
  default = false
}

variable "instance_ids" {
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "name" {
  type        = string
  description = "Name of ALB"
  }