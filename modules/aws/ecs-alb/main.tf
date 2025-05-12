resource "aws_lb" "ecs_alb" {
  name               = "${var.env}-${var.product}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_sg
  subnets            = var.private_subnets
}

# ALB Listener
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Listener created, no target group yet"
      status_code  = "200"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Create Listener on Port 443 (HTTPS)
resource "aws_lb_listener" "https_listener" {
  
  load_balancer_arn = aws_lb.ecs_alb.arn  # Use the existing Load Balancer ARN
  port              = 443
  protocol          = "HTTPS"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"     # Define SSL policy
  certificate_arn   = var.ssl_certificate_arn         # SSL Certificate ARN

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "HTTPS listener created, no target group yet"
      status_code  = "200"
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}

