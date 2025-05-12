locals {
  tg_name = "${var.environment}-${var.service}-tg-01"
}
module "ecs_tg" {
  source                  = "./../alb/target-group/"
  create_tg               = var.create_tg
  tg_name                 = local.tg_name
  traffic_port            = var.traffic_port
  protocol                = var.tg_protocol
  target_type             = var.tg_target_type
  vpc_id                  = var.vpc_id
  host_based_routing_rule = var.host_based_routing_rule
  listener_arn            = var.tg_listener_arn
  priority                = var.tg_rule_priority
  host_headers            = var.host_headers
  service                 = var.service
  environment             = var.environment
  organization            = var.organization
  unhealthy_threshold     = var.unhealthy_threshold
  lb_arn_suffix           = var.lb_arn_suffix
}
