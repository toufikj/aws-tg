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
    # On-Demand node group with custom launch template
    stage-eks-ng-1 = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      capacity_type  = "ON_DEMAND"  # On-demand capacity
      key_name = "account78"
      subnet_ids     = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      iam_role_name = "toufik-eks-node-group-1-role"
      launch_template = {
        user_data = <<EOF
#!/bin/bash
set -o xtrace

KUBELET_CONFIG=/etc/kubernetes/kubelet/kubelet-config.json

# Inject imageGCHighThresholdPercent value unless it has already been set.
if ! grep -q imageGCHighThresholdPercent $KUBELET_CONFIG;
then
echo "$(jq ".imageGCHighThresholdPercent=60" $KUBELET_CONFIG)" > $KUBELET_CONFIG
fi

# Inject imageGCLowThresholdPercent value unless it has already been set.
if ! grep -q imageGCLowThresholdPercent $KUBELET_CONFIG;
then
echo "$(jq ".imageGCLowThresholdPercent=60" $KUBELET_CONFIG)" > $KUBELET_CONFIG
fi

/etc/eks/bootstrap.sh toufik-eks
EOF
      }
      tags = {
        "NodeGroup" = "on-demand"
      }
    }

    # Spot instance node group with different launch template
    stage-eks-spot-1 = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium", "t3a.medium", "m5.large"]  # Multiple instance types for spot flexibility
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      capacity_type  = "SPOT"  # Spot instances
      spot_max_price = null    # Use current spot price (set a specific price if needed)
      key_name = "account78"
      subnet_ids     = ["subnet-0d705b32c047fcc2d", "subnet-074bfdddbd0a97c59", "subnet-0c36554e3f44b70e6" ]
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
      iam_role_name = "toufik-eks-spot-node-group-1-role"
      launch_template = {
        user_data = <<EOF
#!/bin/bash
set -o xtrace

KUBELET_CONFIG=/etc/kubernetes/kubelet/kubelet-config.json

# Spot-optimized kubelet settings
if ! grep -q imageGCHighThresholdPercent $KUBELET_CONFIG;
then
echo "$(jq ".imageGCHighThresholdPercent=70" $KUBELET_CONFIG)" > $KUBELET_CONFIG
fi

if ! grep -q imageGCLowThresholdPercent $KUBELET_CONFIG;
then
echo "$(jq ".imageGCLowThresholdPercent=50" $KUBELET_CONFIG)" > $KUBELET_CONFIG
fi

/etc/eks/bootstrap.sh toufik-eks
EOF
      }
      tags = {
        "NodeGroup" = "spot"
        "CostOptimized" = "true"
      }
    }

    # Another spot instance node group for different workloads (commented out as example)
    # stage-eks-spot-compute = {
    #   ami_type       = "AL2023_x86_64_STANDARD"
    #   instance_types = ["c5.xlarge", "c5a.xlarge", "c6i.xlarge"]
    #   min_size       = 0
    #   max_size       = 5
    #   desired_size   = 2
    #   capacity_type  = "SPOT"
    #   spot_max_price = "0.10"  # Set max price for cost control
    #   tags = {
    #     "NodeGroup" = "spot-compute"
    #     "Workload" = "cpu-intensive"
    #   }
    # }
  }

  tags                        = local.tags
  }

terraform {
  source = "${get_parent_terragrunt_dir("root")}/../modules/aws/eks_spot"
}