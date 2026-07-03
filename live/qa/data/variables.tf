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

variable "region" { type = string }
variable "environment" { type = string }
variable "project" { type = string }
