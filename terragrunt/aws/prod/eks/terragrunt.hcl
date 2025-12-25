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
    "Developer" = "Toufik"
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

  cluster_name                = "prod-eks"
  cluster_version             = "1.30"
  cidr_blocks                 =  [ "172.31.0.0/16" ]
  vpc_id                      = "vpc-0d1e39bb991fb35c7"
  subnet_ids                  = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
  control_plane_subnet_ids    = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
  instance_types              = ["t3.medium"]
  node_group_instance_type    = "t3.medium"
  node_group_min_size         = 1
  node_group_max_size         = 2
  node_group_desired_size     = 1
  tags                        = local.tags
  }

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/eks_v2"
}