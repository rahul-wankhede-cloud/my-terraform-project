variable "patch_group_name" {
  type        = string
  description = "The name of the patch group (must match the tag on the EC2 instance)"
}

variable "scan_schedule" {
  type    = string
  default = "cron(0 2 ? * SUN *)" # Defaults to Sunday at 2 AM
}

variable "environment" { type = string }
