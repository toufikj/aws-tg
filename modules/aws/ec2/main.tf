resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  
  root_block_device {
    volume_size = var.volume_size
  }
  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    github_token      = var.github_token
    s3_bucket_name    = var.s3_bucket_name
    static_repo_url   = var.static_repo_url
    static_repo_dir   = var.static_repo_dir
    package_repo_url  = var.package_repo_url
    package_repo_dir  = var.package_repo_dir
    aws_region        = var.aws_region
  }))
  tags = merge(
    {
      Name = var.instance_name
    },
    var.tags
  )
}

resource "aws_security_group" "sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for ${var.instance_name} EC2 instance"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.inbound_ports
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.allowed_cidr_blocks
      description = ingress.value.description
    }
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    {
      Name = "${var.instance_name}-sg"
    },
    var.tags
  )
}

# IAM Role
resource "aws_iam_role" "ec2_s3_role" {
  name = "EC2S3ACCESSROLE"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# IAM Policy
resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "${var.instance_name}-s3-policy"
  description = "Policy for EC2 to access S3 logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:*"
        ]
        Resource = [
          "arn:aws:s3:::*"
        ]
      }
    ]
  })
}

# IAM Role attachment
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.ec2_s3_policy.arn
}

# Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2S3ACCESSROLE"
  role = aws_iam_role.ec2_s3_role.name
}