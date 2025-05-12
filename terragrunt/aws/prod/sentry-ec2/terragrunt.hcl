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
  key_name                    = "ac799"
  subnet_id                   = "subnet-0a8f45edcb26833cb"
  instance_name               = "sentry"
  environment                 = "prod"
  organization                = "toufik"
  service                     = "sentry"
  vpc_id                      = "vpc-08537c3ca047ee074"
  subnet_type                = "application"
  instance_count              = 1
  associate_public_ip_address = true
  create_tg                   = true
  host_based_routing_rule     = true
  traffic_port                = 9000
  tg_protocol                 = "HTTP"
  tg_target_type              = "instance"
  tg_listener_arn             = "arn:aws:elasticloadbalancing:ap-south-1:783764579443:listener/app/sentry-lb/c2c21d4bb50c8407/261cfe406af6359c"
  tg_rule_priority            = 40
  host_headers                = ["sentry.toufik.online"]
  path                        = "/api/v1"
  unhealthy_threshold         = 10
  lb_arn_suffix               = "app/sentry-lb/c2c21d4bb50c8407"
  }

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/sentry-instance"
}