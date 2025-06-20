include "root" {
  path   = find_in_parent_folders("root-config.hcl")
  expose = true
}

include "stage" {
  path   = find_in_parent_folders("prod.hcl")
  expose = true
}

locals {
  # merge tags
  local_tags = {
    "Name" = "login"
  }

  tags = merge(include.root.locals.root_tags, include.stage.locals.tags, local.local_tags)
}

generate "provider_global" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  backend "s3" {}
  required_version = "${include.root.locals.version_terraform}"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "${include.root.locals.version_provider_aws}"
    }
  }
}

provider "aws" {
  region = "${include.root.locals.region}"
}
EOF
}

########################
inputs = {
  ami_id                      = "ami-0e35ddab05955cf57"
  instance_type               = "t2.micro"
  key_name                    = "account799"
  subnet_id                   = "subnet-094555e147f68ef71"
  instance_name               = "login-demo"
  vpc_id                      = "vpc-08537c3ca047ee074"
  volume_size                 = 10
  allowed_cidr_blocks         = ["0.0.0.0/0"]
  # Tags
  tags                        = local.tags
  s3_bucket_name              = "my-buc-2025-02"
  github_token                = "Put_Github_Token_Here" # SENSITIVE: Do not commit real tokens to version control
  static_repo_url             = "github.com/toufikj/docker-assignment.git"
  static_repo_dir             = "docker-assignment"
  project_repo_url            = "github.com/techeazy-consulting/techeazy-devops.git"
  project_repo_dir            = "techeazy-devops"
  aws_region                  = "ap-south-1"
  inbound_ports = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "Allow SSH traffic"
    }
  ]
  login_username = "toufik"
  login_password = "123"
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ec2"
}