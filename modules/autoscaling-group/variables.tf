variable "launch_template_id" {
  description = "Launch template ID"
  type        = string
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}
variable "max_size" {
  type    = number
  default = 4
}

variable "app_name" {
  description = "App name"
  type        = string
}

variable "subnet_ids" {
  description = "Private subnet IDs used by the ASG"
  type        = list(string)
}

variable "target_group_arns" {
  description = "Target groups associated with the ASG"
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}