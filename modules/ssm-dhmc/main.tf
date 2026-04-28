# 1. Create the dedicated Management Role
resource "aws_iam_role" "dhmc_role" {
  name = "AWSSystemsManagerDefaultEC2InstanceManagementRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com" # Required so EC2 can "use" the role
        }
      }
    ]
  })
}

# 2. Attach the core policy
resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.dhmc_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3. The Final Global Switch
resource "aws_ssm_service_setting" "dhmc" {
  setting_id    = "/ssm/managed-instance/default-ec2-instance-management-role"
  setting_value = aws_iam_role.dhmc_role.name
}