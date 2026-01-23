include "root" {
  path   = find_in_parent_folders("root-config.hcl")
  expose = true
}

locals {
  # merge tags
  local_tags = {
    "Developer" = "Toufik"
  }

  tags = merge(local.local_tags)
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

  cluster_name                = "toufik-eks"
  cluster_version             = "1.33"
  cidr_blocks                 =  [ "172.31.0.0/16" ]
  vpc_id                      = "vpc-0d1e39bb991fb35c7"
  subnet_ids                  = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
  control_plane_subnet_ids    = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]

  node_groups = {
    stage-eks-ng-1 = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      disk_size = 100
      key_name = "account78"
      subnet_ids     = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      iam_role_name = "toufik-eks-node-group-1-role"
      # launch_template_tags  = {
      #   "k8s.io/cluster-autoscaler/enabled" = "true"
      #   "k8s.io/cluster-autoscaler/stage-eks" = "owned"
      # }
    }
    # node-group-2 = {
    #   ami_type       = "AL2023_x86_64_STANDARD"
    #   instance_types = ["m6i.xlarge"]
    #   disk_size = 25
    #   min_size       = 2
    #   max_size       = 5
    #   desired_size   = 2
    #   subnet_ids     = ["subnet-026f4c7e4de0c52df", "subnet-0538b2dc1d554f9e7", "subnet-0e44b013425abacc0" ]
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #   }
    #   iam_role_name = "stage-eks-node-group-2-role"
    #   launch_template_tags  = {
    #     "k8s.io/cluster-autoscaler/enabled" = "true"
    #     "k8s.io/cluster-autoscaler/stage-eks" = "owned"
    #   }
    # }
  }

  tags                        = local.tags
  }

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/eks_v2"
}