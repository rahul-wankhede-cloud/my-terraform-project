variable "topic_name" {
  type = string
}

variable "email_endpoint" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}