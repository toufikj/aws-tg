
data "aws_subnets" "lb_subnet" {
  filter {
    name   = "tag:usage"
    values = ["${var.subnet_type}"]
  }

  filter {
    name   = "tag:environment"
    values = ["${var.environment}"]
  }
}
data "aws_sns_topic" "notification" {
    name = "${var.environment}-${var.organization}-alerts-sns-01"
  }
  