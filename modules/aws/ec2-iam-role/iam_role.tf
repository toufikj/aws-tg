resource "aws_iam_role" "ec2_iam_role" {
  name = var.name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge({
    Name         = var.name
    environment  = var.environment
    organization = var.organization
    service      = var.service
  }, var.tags)
}

# resource "aws_iam_role_policy" "ec2_instance_role_policy" {
#   name   = "${var.name}-policy"
#   role   = aws_iam_role.ec2_iam_role.id
#   policy = var.ec2_instance_policy
# }

resource "aws_iam_instance_profile" "ec2_instance_role_profile" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ec2_iam_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_policy" "ec2_instance_role_policy" {
  name        = "${var.name}-policy"
  description = "IAM policy for EC2 instances"
  policy      = var.ec2_instance_policy
}

resource "aws_iam_role_policy_attachment" "ec2_instance_role_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.ec2_instance_role_policy.arn
}

