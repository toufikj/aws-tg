include "root" {
  path   = find_in_parent_folders("root-config.hcl")
  expose = true
}

include "stage" {
  path   = find_in_parent_folders("stage.hcl")
  expose = true
}

locals {
  # merge tags
  local_tags = {
    "Developer" = "sandeep"
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
  counts = 3  # Number of ECR repositories to create
  names = ["stage-dagster-user-code", "stage-strapi", "stage-nextjs-strapi-babymd", "stage-api-personika"]  # Names of the ECR repositories
  tags = local.tags
}


terraform {
  source = "${get_parent_terragrunt_dir("root")}../../..//modules/aws/ecr_v2"
}