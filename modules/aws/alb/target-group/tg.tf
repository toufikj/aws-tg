resource "aws_lb_target_group" "lb_tg" {
  count       = var.create_tg == true ? 1 : 0
  name        = var.tg_name
  port        = var.traffic_port
  protocol    = var.protocol
  target_type = var.target_type
  vpc_id      = var.vpc_id
  health_check {
    enabled             = true
    healthy_threshold   = var.healthy_threshold
    interval            = var.interval
    matcher             = var.matcher
    path                = var.path
    port                = var.health_check_port
    protocol            = var.protocol
    timeout             = var.timeout
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_lb_listener_rule" "host_based_routing" {
  count        = var.host_based_routing_rule == true ? 1 : 0
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg[0].arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }
}


# resource "aws_cloudwatch_metric_alarm" "http_4xx_alarm" {
#   alarm_name          = format("%s-%s-%s-tg-high-4xx-%s", var.environment, var.organization, var.service, aws_lb_target_group.lb_tg[0].name)
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.evaluation_periods
#   metric_name         = "HTTPCode_Target_4XX_Count"
#   namespace           = "AWS/ApplicationELB"
#   period              = var.period
#   statistic           = "Sum"
#   threshold           = var.tg_4xx_threshold
#   alarm_description   = "http 4xx alarm for ${var.environment} ${var.organization} ${var.service} target group"
#   treat_missing_data  = var.treat_missing_data
#   alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
#   #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
#   dimensions = {
#     TargetGroup = aws_lb_target_group.lb_tg[0].arn_suffix
#     LoadBalancer = var.lb_arn_suffix
#   }
# }

resource "aws_cloudwatch_metric_alarm" "http_5xx_alarm" {
  alarm_name          = format("%s-%s-%s-tg-high-5xx-%s", var.environment, var.organization, var.service, aws_lb_target_group.lb_tg[0].name)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.tg_5xx_threshold
  alarm_description   = "http 5xx alarm for ${var.environment} ${var.organization} ${var.service} target group"
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
  #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
  dimensions = {
    TargetGroup  = aws_lb_target_group.lb_tg[0].arn_suffix
    LoadBalancer = var.lb_arn_suffix
  }
}

# resource "aws_cloudwatch_metric_alarm" "latency_alarm" {
#   alarm_name          = format("%s-%s-%s-tg-high-latency-%s", var.environment, var.organization, var.service, aws_lb_target_group.lb_tg[0].name)
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.evaluation_periods
#   metric_name         = "TargetResponseTime"
#   namespace           = "AWS/ApplicationELB"
#   period              = var.period
#   statistic           = "Average"
#   threshold           = var.latency_threshold
#   alarm_description   = "latency alarm for ${var.environment} ${var.organization} ${var.service} target group"
#   treat_missing_data  = var.treat_missing_data
#   alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
#   #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
#   dimensions = {
#     TargetGroup = aws_lb_target_group.lb_tg[0].arn_suffix
#     LoadBalancer = var.lb_arn_suffix
#   }
# }
