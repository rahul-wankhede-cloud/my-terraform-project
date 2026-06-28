output "role_arn" {
  value = aws_iam_role.this.arn
}

output "role_name" {
  value = aws_iam_role.this.name
}

output "instance_profile_name" {
  #value       = aws_iam_instance_profile.this.name
  # This returns the first item if created, or null if not.
  value       = try(aws_iam_instance_profile.this[0].name, null)
  description = "The name of the instance profile to be used with EC2"
}
output "instance_profile_arn" {
  value       = try(aws_iam_instance_profile.this[0].arn, null)
  description = "The ARN of the instance profile"
}

output "bucket_arn_received" {
  value       = var.s3_bucket_arn
  description = "The ARN of the instance profile"
}


