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

inputs = {
  vpc_subnet_module = {
    name                 = "prod-vpc"
    cidr_block           = "10.0.0.0/16"
    azs                  = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    private_subnets      = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
    public_subnets       = ["10.0.100.0/24", "10.0.101.0/24", "10.0.102.0/24"]
    enable_ipv6          = false
    enable_nat_gateway   = true
    enable_vpn_gateway   = false
    enable_dns_hostnames = true
    enable_dns_support   = true
  }
  tags = local.tags
}

terraform {

  source = "${get_parent_terragrunt_dir("root")}/../../modules/aws/vpc_v2"
}
