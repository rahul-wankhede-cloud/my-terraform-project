variable "username" {
  type        = string
  description = "username login for the database"
}

variable "password" {
  type        = string
  description = "username login for the database"
}

variable "identifier" {
  type        = string
  description = "Identifier for the database"
}
variable "instance_class" {
  type        = string
  description = "Instance class for the database"
}

variable "subnet_ids" {
  description = "Subnet IDs for the database"
    type = list(string)
}

variable "vpc_security_group_ids" {
  description = "Subnet IDs for the database"
    type = list(string)
    default     = []
}

variable "security_group_ids" {
  description = "Subnet IDs for the database"
    type = list(string)
    default     = []
}