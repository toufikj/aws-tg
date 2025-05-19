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
  ami_id                      = "ami-0f58b397bc5c1f2e8"
  instance_type               = "t3.medium"
  key_name                    = "account799"
  subnet_id                   = "subnet-0a8f45edcb26833cb"
  instance_name               = "login"
  vpc_id                      = "vpc-08537c3ca047ee074"
  volume_size                 = 10
  allowed_cidr_blocks         = ["0.0.0.0/0"]
  iam_instance_profile        = dependency.iam_role.outputs.instance_profile_name
  # Tags
  tags                        = local.tags
}
dependency "iam_role" {
  config_path = "../ssm-iam-role"
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ec2"
}