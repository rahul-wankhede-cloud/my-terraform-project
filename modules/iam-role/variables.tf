variable "role_name" {
  type        = string
  description = "The name of the IAM role to create"
}

variable "s3_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket this role should access"
  default     = null
}

variable "trusted_service" {
  type        = string
  description = "The AWS service allowed to assume this role (e.g., ec2.amazonaws.com, lambda.amazonaws.com)"
  default     = "ec2.amazonaws.com"
}

variable "create_instance_profile" {
  type        = bool
  description = "Set to true only if this role is for an EC2 instance"
  default     = false
}

variable "policy_arns" {
  type    = list(string)
  default = []
}