resource "aws_lb" "alb" {
  name               = var.lb_name
  internal           = var.is_internal
  load_balancer_type = var.lb_type
  security_groups    = var.lb_sg_ids
  subnets            = data.aws_subnets.lb_subnet.ids

  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = var.lb_log_bucket == "" ? [] : [1]
    content {
      bucket  = var.lb_log_bucket
      prefix  = "${var.environment}/alb/${var.lb_name}"
      enabled = true
    }
  }

  tags = {
    name         = var.lb_name
    service      = var.service
    environment  = var.environment
    organization = var.organization
  }
}



# resource "aws_cloudwatch_metric_alarm" "_4xx_error_alarm" {
#   alarm_name          = format("%s-%s-%s-alb-high-4xx-%s", var.environment, var.organization, var.service, aws_lb.alb.name)
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.evaluation_periods
#   metric_name         = "HTTPCode_ELB_4XX_Count"
#   namespace           = "AWS/ApplicationELB"
#   period              = var.period
#   statistic           = "Sum"
#   threshold           = var.alb_4xx_threshold
#   alarm_description   = "4xx Error Alarm for the ALB"
#   treat_missing_data  = var.treat_missing_data
#   alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
#   #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
#   dimensions = {
#     LoadBalancer = aws_lb.alb.arn_suffix
#   }
# }

resource "aws_cloudwatch_metric_alarm" "_5xx_error_alarm" {
  alarm_name          = format("%s-%s-%s-alb-high-5xx-%s", var.environment, var.organization, var.service, aws_lb.alb.name)
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold
  alarm_description   = "5xx Error Alarm for the ALB"
  treat_missing_data  = var.treat_missing_data
  alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
  #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
  }
}

# resource "aws_cloudwatch_metric_alarm" "latency_alarm" {
#   alarm_name          = format("%s-%s-%s-alb-latency-exceeding-%s", var.environment, var.organization, var.service, aws_lb.alb.name)
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = var.evaluation_periods
#   metric_name         = "TargetResponseTime"
#   namespace           = "AWS/ApplicationELB"
#   period              = var.period
#   statistic           = "Average"
#   threshold           = var.latency_threshold
#   alarm_description   = "Alarm for ELB latency exceeding"
#   treat_missing_data  = var.treat_missing_data
#   alarm_actions       = ["${data.aws_sns_topic.notification.arn}"]
#   #ok_actions          = ["${data.aws_sns_topic.notification.arn}"]
#   dimensions = {
#     LoadBalancer = aws_lb.alb.arn_suffix
#   }
# }
