variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be launched"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "volume_size" {
  description = "Size of the root volume in GB"
  type        = number
  default     = 20
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "github_token" {
  description = "GitHub token for cloning private repositories"
  type        = string
  sensitive   = true
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket to use"
  type        = string
}

variable "static_repo_url" {
  description = "URL of the static assets repository"
  type        = string
}

variable "static_repo_dir" {
  description = "Directory name for static assets repo"
  type        = string
}

variable "project_repo_url" {
  description = "URL of the main project repository"
  type        = string
}

variable "project_repo_dir" {
  description = "Directory name for the main project repo"
  type        = string
}

variable "inbound_ports" {
  description = "List of inbound ports to allow in the security group. Each item should be a map with keys: from_port, to_port, protocol, description."
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
}