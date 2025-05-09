
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
  version = "= 5.70.0"
}
EOF
}

#############################################################################################
inputs = {
  region                = "ap-south-1"
  stage                 = "prod"
  vpc_id                = dependency.vpc.outputs.vpc_id
  cluster_id            = "arn:aws:ecs:ap-south-1:783764579443:cluster/demo"
  product               = "metabase"
  network_mode          = "awsvpc"
  container_name        = "metabase"
  
  container_port        = 3000
  container_protocol    = "tcp"

  target_group_port     = 3000
  target_group_protocol = "HTTP"
  health_check_protocol = "HTTP"
  health_check_interval = 10
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 3
  domain                = "metabase.toufik.online"
  cpu                   = "1024"
  memory                = "2048"
  container_image_uri       = "metabase/metabase"
  environment_variables = {
    SERViCE = "metabase"
  }
  desired_count         = 1
  existing_load_balancer_arn = "arn:aws:elasticloadbalancing:ap-south-1:783764579443:loadbalancer/app/metabase-lb/f423fe3ee886fa36"
  private_subnets       = dependency.vpc.outputs.vpc_private_subnets_ids
  security_group        = "sg-0fded28c698264956"
  existing_listener_arn = "arn:aws:elasticloadbalancing:ap-south-1:783764579443:listener/app/metabase-lb/f423fe3ee886fa36/11b981557bb8dbac"
  existing_ecs_task_execution_role_arn = "arn:aws:iam::783764579443:role/ecsTaskExecutionRole"
  ssl_certificate_arn = "arn:aws:acm:ap-south-1:783764579443:certificate/12ebb5ea-86be-4988-8947-891dd0316625"
  listener_priority     = 5  # Listener priority
}
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "vpc-06ca03987c7dd56da"
    vpc_private_subnets_ids = ["subnet-09d937d08b4abc98b", "subnet-08dbd9a33cf4ac5c9", "subnet-06e93c4dbff5f1934"]
  }
} 

terraform {
  source = "${get_parent_terragrunt_dir("root")}}/../modules/aws/ecs_v3"  # Correct relative path to the Strapi module
}
