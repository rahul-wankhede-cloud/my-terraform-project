
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.asg_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 5
  alarm_actions       = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }
  tags = merge(var.tags, { "Name" = "${var.asg_name}-high-cpu" })
}