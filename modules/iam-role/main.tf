

resource "aws_iam_role" "this" {
  name = var.role_name

  # The "Trust Policy" - Allows EC2 to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = var.trusted_service
        }
      },
    ]
  })
}


# Create an instance profile to associate with EC2 instances

resource "aws_iam_instance_profile" "this" {
  # Logic: If true, create 1. If false, create 0.
  # count = var.create_instance_profile ? 1 : 0
  count = var.trusted_service == "ec2.amazonaws.com" ? 1 : 0
  name  = "${var.role_name}-profile"
  role  = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "managed" {

  for_each = toset(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = each.value
}