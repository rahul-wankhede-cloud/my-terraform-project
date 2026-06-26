output "alb_arn" {
  value = try(aws_lb.main[0].arn, null)
}

output "target_group_arn" {
  value = aws_lb_target_group.main[0].arn
}