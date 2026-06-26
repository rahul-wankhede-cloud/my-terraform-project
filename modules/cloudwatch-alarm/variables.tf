variable "asg_name" {
  type = string
}
variable "alarm_actions" {
  type = list(string)
  default = []
}

variable "tags" {
  type = map(string)
  default = {}
}