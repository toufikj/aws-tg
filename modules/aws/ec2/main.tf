locals {
  error_bucket = var.s3_bucket_name == "" ? "Bucket name not provided. Set var.s3_bucket_name" : ""
}
resource "aws_s3_bucket" "my_bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  tags = merge(
    {
      Name = var.s3_bucket_name
    }
  )
}

resource "null_resource" "validate_bucket" {
  count = var.s3_bucket_name == "" ? 1 : 0

  provisioner "local-exec" {
    command = "echo '${local.error_bucket}' && exit 1"
  }
}

# IAM Role
resource "aws_iam_role" "ec2_s3_role" {
  name = "${var.instance_name}-ec2-s3-role"
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
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
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
  name = "${var.instance_name}-profile"
  role = aws_iam_role.ec2_s3_role.name
}


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
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    # Log file for user_data execution
    LOG_FILE="/var/log/user_data.log"
    exec > >(tee -a $LOG_FILE) 2>&1

    echo "[+] Starting user_data script"

    # Install Java
    sudo apt-get update -y
    sudo apt install openjdk-11-jre-headless unzip -y

    # Clone the repository
    git clone https://github.com/toufikj/login-deploy.git

    # Download and install Apache Tomcat 9
    wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.41/bin/apache-tomcat-10.1.41.zip 
    unzip apache-tomcat-10.1.41.zip 
    mv apache-tomcat-10.1.41 /opt/
    chmod +x /opt/apache-tomcat-10.1.41/bin/*.sh
    sed -i 's/port="8080"/port="80"/' /opt/apache-tomcat-10.1.41/conf/server.xml
    cp /login-deploy/LoginWebApp.war /opt/apache-tomcat-10.1.41/webapps/
    /opt/apache-tomcat-10.1.41/bin/startup.sh

    # Install AWS CLI
    apt install unzip curl -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    # Create the S3 bucket if it doesn't exist
    echo "[+] Creating S3 bucket if it doesn't exist"
    # aws s3api create-bucket --bucket ${var.s3_bucket_name} --region ap-south-1 --create-bucket-configuration LocationConstraint=ap-south-1  || echo "Bucket may already exist"

    # Configure shutdown script to upload logs
    echo "[+] Configuring shutdown script to upload logs"
    cat <<-SHUTDOWN > /etc/systemd/system/upload-logs.service
    [Unit]
    Description=Upload logs to S3 on shutdown
    DefaultDependencies=no
    Before=shutdown.target

    [Service]
    Type=oneshot
    ExecStart=/bin/bash -c 'aws s3 cp /var/log/cloud-init.log s3://${var.s3_bucket_name}/logs/cloud-init.log && aws s3 cp /var/log/user_data.log s3://${var.s3_bucket_name}/logs/user_data.log'

    [Install]
    WantedBy=shutdown.target
    SHUTDOWN

    chmod +x /etc/systemd/system/upload-logs.service
    systemctl enable upload-logs.service

    echo "[+] User_data script completed successfully"
  EOF
  )
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

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow HTTP traffic"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow HTTPS traffic"
  }

  # Port 9000
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow port 9000 traffic"
  }

  # Port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow port 3000 traffic"
  }

  # Port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow port 8080 traffic"
  }

  # Port 8000
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow port 8000 traffic"
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Allow SSH traffic"
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