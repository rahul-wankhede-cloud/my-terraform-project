resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = var.alb_sg_id  ## Its defined as list in variables.tf, so dont put in [var.alb_sg_id] else it will create list of list and will throw erroraccess_logs {
  
  #security_groups    = var.alb_security_group_id
  # This uses the list of subnet IDs we created with the loop!
  subnets            = var.public_subnet_ids 
}

resource "aws_lb_target_group" "main" {
  name     = "main-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
resource "aws_lb_target_group_attachment" "web_attachment" {
  # 'count' tells Terraform to run this block once for every ID in the list
  count            = length(var.instance_ids)
  #for_each         = module.my_ec2_instance # Loop through the instances you just created (from Root module)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = var.instance_ids[count.index]
  #target_id        = each.value.instance_id # This comes from your EC2 module output
  port             = 80
}