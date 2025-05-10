# Output ALB details to share with other modules
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.ecs_alb.arn
}

output "alb_dns_name" {
  description = "DNS Name of the Application Load Balancer"
  value       = aws_lb.ecs_alb.dns_name
}

output "https_listener" {
  description = "The ARN of the ALB Listener"
  value       = aws_lb_listener.https_listener.arn
}

output "alb_http_listener" {
  description = "value"
  value = aws_lb_listener.alb_http_listener.arn
}

output "alb_target_group_arn" {
  description = "Target group ARN for ALB"
  value       = aws_lb_listener.alb_http_listener.default_action[0].target_group_arn
}