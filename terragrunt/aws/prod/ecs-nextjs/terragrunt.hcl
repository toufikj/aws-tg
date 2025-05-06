



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
  version = "= 5.70.0"
}
EOF
}

#############################################################################################
inputs = {
  region                = "ap-south-1"
  stage                 = "stage"
  vpc_id                = "vpc-0ad6200d4d2e30291"
  cluster_id            = "arn:aws:ecs:ap-south-1:778152842232:cluster/stg-babymd-ecs-cluster-01"
  product               = "nextjs-strapi-ecs-bymd"
  network_mode          = "awsvpc"
  container_name        = "nextjs-strapi-svc-bymd"
  
  container_port        = 3000
  container_protocol    = "tcp"

  target_group_port     = 3000
  target_group_protocol = "HTTP"
  health_check_protocol = "HTTP"
  health_check_interval = 10
  health_check_timeout  = 5
  healthy_threshold     = 2
  unhealthy_threshold   = 3
  domain                = "stage-strapi-nextjs.babymd.in"
  cpu                   = "1024"
  memory                = "2048"
  container_image_uri       = "778152842232.dkr.ecr.ap-south-1.amazonaws.com/stage-nextjs-babymd:1"
  environment_variables = {
    SERViCE = "babymd-nextjs"
  }
  desired_count         = 2
  existing_load_balancer_arn = "arn:aws:elasticloadbalancing:ap-south-1:778152842232:loadbalancer/app/stg-babymd-ecs-alb-public/867f9639d89a10f5"
  private_subnets       = ["subnet-012d2faacf9d66b4f", "subnet-03bf9f8857add3e2d", "subnet-09ec84f673dbfaf7d"]
  security_group        = "sg-0aec348c554b8264a"
  existing_listener_arn = "arn:aws:elasticloadbalancing:ap-south-1:778152842232:listener/app/stg-babymd-ecs-alb-public/867f9639d89a10f5/a7f8aafb548c0db4"
  existing_ecs_task_execution_role_arn = "arn:aws:iam::778152842232:role/ecsTaskExecutionRole"
  ssl_certificate_arn = "arn:aws:acm:ap-south-1:778152842232:certificate/15a4911f-d959-41d3-b1fa-76cc41e8e696"
  listener_priority     = 45  # Listener priority
}

terraform {
  source = "${get_parent_terragrunt_dir("root")}../../..//modules/aws/ecs_v3"  # Correct relative path to the Strapi module
}
