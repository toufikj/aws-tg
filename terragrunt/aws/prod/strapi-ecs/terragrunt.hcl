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
    "Name" = "babymd"
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
  region                      = "ap-south-1"
  cluster_name                = "stg-babymd-ecs-cluster-01"
  logging                     = "OVERRIDE"
  cloud_watch_log_group_name  = "/aws/ecs/aws-ec2"
  service_name                = "ecsdemo-frontend"
  cpu                         = 1024
  memory                      = 4096

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  container_definitions = {
    fluent-bit = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"
      firelens_configuration = {
        type = "fluentbit"
      }
      memory_reservation = 50
    }

    ecs-sample = {
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "public.ecr.aws/aws-containers/ecsdemo-frontend:776fd50"
      port_mappings = [
        {
          name          = "ecs-sample"
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      readonly_root_filesystem = false
      dependencies = [{
        containerName = "fluent-bit"
        condition     = "START"
      }]
      enable_cloudwatch_logging = false
      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name                    = "firehose"
          region                  = "eu-west-1"
          delivery_stream         = "my-stream"
          log-driver-buffer-limit = "2097152"
        }
      }
      memory_reservation = 100
    }
  }

  service_connect_namespace  = "example"
  service_connect_port       = 80
  service_connect_dns_name   = "ecs-sample"
  service_connect_port_name  = "ecs-sample"
  service_connect_discovery_name = "ecs-sample"

  target_group_arn           = "arn:aws:elasticloadbalancing:eu-west-1:1234567890:targetgroup/bluegreentarget1/209a844cd01825a4"
  container_name             = "ecs-sample"
  container_port             = 80
  subnet_ids                 = ["subnet-abcde012", "subnet-bcde012a", "subnet-fghi345a"]
  security_group_rules = {
    alb_ingress_3000 = {
      type                     = "ingress"
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = "sg-12345678"
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}


terraform {
  source = "${get_parent_terragrunt_dir("root")}../../..//modules/aws/ecs_v2"
}