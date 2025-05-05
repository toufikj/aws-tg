
# Create CloudWatch Log Group for Strapi
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.stage}/${var.product}"
  retention_in_days = 7
}

# Create ECS Task Definition for Strapi
resource "aws_ecs_task_definition" "ecs" {
  family                   = "${var.stage}-${var.product}-task"
  execution_role_arn       = var.existing_ecs_task_execution_role_arn
  network_mode             = var.network_mode
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory

  container_definitions = jsonencode([{
    name      = var.container_name
    image     = var.container_image_uri
    essential = true
    portMappings = [{
      containerPort = var.container_port
      protocol      = var.container_protocol
    }]
    environment = [
      {
        name  = "SERVICE"
        value = tostring(var.container_port)
      }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = var.stage
      }
    }
  }])
}

# Create Target Group for Flowise ECS Service
resource "aws_lb_target_group" "ecs" {
  name        = "${var.stage}-${var.product}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = var.health_check_protocol
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200-299"
  }
}


# Create Listener on Port 443 (HTTPS)
#resource "aws_lb_listener" "https_listener" {
#  load_balancer_arn = var.existing_load_balancer_arn  # Use the existing Load Balancer ARN
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"     # Define SSL policy
#  certificate_arn   = var.ssl_certificate_arn         # SSL Certificate ARN

#  default_action {
#    type             = "forward"
#    target_group_arn = aws_lb_target_group.flowise.arn
#  }
#}

# Create Listener Rule for Existing Listener (Attach to Strapi Target Group)
resource "aws_lb_listener_rule" "ecs" {
  listener_arn = var.existing_listener_arn # Use the ARN of the existing listener on port 443
  priority     = var.listener_priority     # Set a priority, e.g., 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }


# Add Host-Header Condition for domain
  condition {
    host_header {
      values = [var.domain]  # Add your custom domain here
    }
  }
}

# Create ECS Service for Strapi
resource "aws_ecs_service" "ecs" {
  name            = "${var.stage}-${var.product}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.ecs.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.security_group]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
