locals {
  create = var.create
}

resource "aws_lb" "main" {
  count = local.create ? 1 : 0
  internal           = false
  load_balancer_type = var.load_balancer_type
  security_groups = var.alb_sg_id  ## Its defined as list in variables.tf, so dont put in [var.alb_sg_id] else it will create list of list and will throw erroraccess_logs {
  tags = merge(var.tags, { Name = var.name})
  name = var.name
  #security_groups    = var.alb_security_group_id
  # This uses the list of subnet IDs we created with the loop!
  subnets            = var.subnets
}

resource "aws_lb_target_group" "main" {
  count = local.create ? 1 : 0
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  count = local.create ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

/* resource "aws_lb_target_group_attachment" "web_attachment" {
  # 'count' tells Terraform to run this block once for every ID in the list
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = var.instance_ids[count.index]
  port             = 80
} */