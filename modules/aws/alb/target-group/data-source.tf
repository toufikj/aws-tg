data "aws_sns_topic" "notification" {
    name = "${var.environment}-${var.organization}-alerts-sns-01"
  }