output "instance_id" {
  description = "The ID of the bastion host"
  value       = aws_instance.bastion.id # Make sure this matches your resource name
}

output "bastion_security_group_id" {
  value = aws_security_group.bastion_sg.id
}

output "instance_arn" {
  value = aws_instance.bastion.arn
}