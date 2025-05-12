resource "aws_lb_listener" "http_to_https_redirect" {
  for_each          = var.http_to_https_redirect == true ? toset(["1"]) : []
  load_balancer_arn = var.lb_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_fixed_response" {
  for_each          = var.https_fixed_response == true ? toset(["1"]) : []
  load_balancer_arn = var.lb_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No Matching DNS"
      status_code  = "205"
    }
  }
}
