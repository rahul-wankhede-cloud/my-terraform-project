
output "security_group_id" {
  value = aws_security_group.allow_ssh.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}
