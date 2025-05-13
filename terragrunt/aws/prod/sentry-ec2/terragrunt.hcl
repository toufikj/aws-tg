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
    "Name" = "Sentry"
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
  environment                 = "prod"
  organization                = "toufik"
  service                     = "sentry"
  ami_id                      = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t3.medium"
  key_name                    = "ac799"
  subnet_id                   = "subnet-0a8f45edcb26833cb"
  instance_name               = "sentry"
  vpc_id                      = "vpc-08537c3ca047ee074"
  volume_size                 = 10
  allowed_cidr_blocks         = ["0.0.0.0/0"]
  
  # Target group configuration
  create_target_group         = true
  target_group_port           = 9000
  target_group_protocol       = "HTTP"
  health_check_path           = "/"
  health_check_interval       = 30
  health_check_timeout        = 5
  healthy_threshold           = 3
  unhealthy_threshold         = 10
  health_check_matcher        = "200-399"
  
  # Tags
  tags                        = local.tags
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ec2"
}