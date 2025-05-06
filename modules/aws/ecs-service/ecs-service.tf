resource "aws_cloudwatch_log_group" "log_group" {
  name              = "${var.environment}-${var.service}"
  retention_in_days = var.log_retention_period
}

resource "aws_ecs_task_definition" "task_defination" {
  family                = "${var.environment}-${var.service}"
  container_definitions = var.container_definitions
  network_mode          = var.network_mode
  execution_role_arn    = var.execution_role_arn

  #   container_definitions = <<EOF
  # [
  #   {
  #     "name": "hello_world",
  #     "image": "hello-world",
  #     "cpu": 0,
  #     "memory": 128,
  #     "logConfiguration": {
  #       "logDriver": "awslogs",
  #       "options": {
  #         "awslogs-region": "eu-west-1",
  #         "awslogs-group": "hello_world",
  #         "awslogs-stream-prefix": "complete-ecs"
  #       }
  #     }
  #   }
  # ]
  # EOF
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.service
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task_defination.arn

  network_configuration {
    subnets          = var.task_subnets
    security_groups  = [aws_security_group.ecs_service_sg.id]
    assign_public_ip = var.assign_public_ip

  }

lifecycle {
    ignore_changes = ["task_definition"]
  }


  desired_count = var.desired_count

  deployment_maximum_percent         = var.max_percent
  deployment_minimum_healthy_percent = var.min_healthy_percent
  # load_balancer {
  #   target_group_arn = var.tg_arn
  #   container_name   = var.container_name
  #   container_port   = var.container_port
  # }

  dynamic "load_balancer" {
    for_each = var.tg_arn == "" ? [] : [1]
    content {
      target_group_arn = var.tg_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }
  capacity_provider_strategy {
    # capacity_provider = "Infra-ECS-Cluster-prod-nivaancare-ecs-cluster-01-b4d1fa8c-EC2CapacityProvider-UIpjxfjXR0mt"
    capacity_provider = var.capacity_provider
    weight            = var.weight
    base              = var.base
  }
}
