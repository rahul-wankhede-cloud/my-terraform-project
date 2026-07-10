resource "aws_launch_template" "this" {

  name_prefix = "${var.app_name}-"

  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data              = base64encode(var.user_data)
  update_default_version = true
  
  metadata_options {
    http_tokens = "required"
  }
  

  iam_instance_profile {
    name = var.instance_profile_name
  }
  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, { Name = var.app_name })
  }
}
