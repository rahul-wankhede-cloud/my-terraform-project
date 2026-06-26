data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  create = var.create
}

resource "aws_instance" "this" {
  #count = local.create ? var.instance_count : 0
  for_each = local.create ? toset(var.subnet_ids) : toset([])
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  #iam_instance_profile = var.iam_instance_profile
  # Find the specific subnet ID created by the networking module
  # that matches the current key (e.g., "public-1")
  subnet_id = each.value

  #subnet_id            = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = var.user_data
  

  tags = {
    Name = var.instance_name
    PatchGroup = var.patch_group
  }
}

