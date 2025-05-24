locals {
  region = "ap-south-1"

  version_terraform    = ">=1.8.0"
  version_terragrunt   = ">=0.59.1"
  version_provider_aws = ">=5.45.0"

  root_tags = {
    Brand = "Toufik"
  }
}

terraform {
  after_hook "after_hook_plan" {
      commands     = ["plan"]
      execute      = ["sh", "-c", "terraform show -json tfplan.binary | jq > ${get_parent_terragrunt_dir("root")}/plan.json"]
      # execute      = ["sh", "-c", "terraform show -json tfplan.binary > ${get_parent_terragrunt_dir("root")}/plan.json"]
  }
}


remote_state {
  backend = "s3"
  config = {
    bucket         = "aws-terragrunt"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    encrypt        = true
    region         = local.region
  }
}