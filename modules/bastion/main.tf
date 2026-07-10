data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.amazon_linux_2023.id
  instance_type        = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.bastion_profile.id

  # Find the specific subnet ID created by the networking module
  # that matches the current key (e.g., "public-1")
  subnet_id = var.subnet_id

  #subnet_id            = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_tokens = "required"
  }


  tags = {
    Name       = var.instance_name
    PatchGroup = var.patch_group
  }
}

# 1. IAM Identity (The SSM "Passport")
resource "aws_iam_role" "bastion_role" {
  name = "bastion_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

# 2. Security Group (The "Shield")
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSM and outbound to RDS"
  vpc_id      = var.vpc_id

  # Inbound: NONE (SSM doesn't need open ports!)

  # Outbound: Talk to RDS
  egress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.security_groups] # Or your specific RDS Subnet
  }

  # Outbound: HTTPS for SSM Agent to talk to AWS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
