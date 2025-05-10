

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
    "Developer" = "toufik"
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
  version = "= 5.70.0"
}
EOF
}

#############################################################################################
inputs = {
  env                  = "prod"
  product              = "metabase"
  
  private_subnets     = dependency.vpc.outputs.vpc_public_subnets_ids
  alb_sg              = ["sg-01074add945315fc2"]
  
  ssl_certificate_arn = "arn:aws:acm:ap-south-1:783764579443:certificate/12ebb5ea-86be-4988-8947-891dd0316625"
  
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-06ca03987c7dd56da"
    vpc_public_subnets_ids = ["subnet-09d937d08b4abc98b", "subnet-08dbd9a33cf4ac5c9", "subnet-06e93c4dbff5f1934"]
  }
} 

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/ecs-alb"  # Correct relative path to the Strapi module
}

