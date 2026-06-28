# 1. Define the Policy (This stays the same)
resource "aws_iam_policy" "ssm_tunnel_policy" {
  name        = "SSMTunnelAccess-Dynamic"
  description = "SSM Tunnel Policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "ssm:StartSession"
        Resource = [
          var.target_instance_arn,
          "arn:aws:ssm:${var.aws_region}::document/AWS-StartPortForwardingSessionToRemoteHost"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "ssm:TerminateSession"
        Resource = "arn:aws:ssm:*:*:session/$${aws:username}-*"
      }
    ]
  })
}

# 2. Attach to User (Only if target_user is provided)
resource "aws_iam_user_policy_attachment" "user_attach" {
  for_each   = toset(var.users)
  user       = each.value
  policy_arn = aws_iam_policy.ssm_tunnel_policy.arn
}

# 3. Attach to Group (Only if target_group is provided)
resource "aws_iam_group_policy_attachment" "group_attach" {
  for_each   = toset(var.groups)
  group      = each.value
  policy_arn = aws_iam_policy.ssm_tunnel_policy.arn
}
