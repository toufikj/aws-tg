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
  ami_id                      = "ami-06b6e5225d1db5f46"
  instance_type               = "t2.micro"
  key_name                    = "account799"
  subnet_id                   = "subnet-094555e147f68ef71"
  instance_name               = "login-demo"
  vpc_id                      = "vpc-08537c3ca047ee074"
  volume_size                 = 10
  allowed_cidr_blocks         = ["0.0.0.0/0"]
  # Tags
  tags                        = local.tags
  s3_bucket_name            = "buc-2025-5"
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ec2"
}