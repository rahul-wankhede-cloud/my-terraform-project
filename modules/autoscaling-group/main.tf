locals {
  asg_tags = merge(var.tags, { Name = var.app_name })
}

resource "aws_autoscaling_group" "this" {

  name                = "${var.app_name}-asg"
  desired_capacity    = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns

  launch_template {

    id      = var.launch_template_id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.asg_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

}