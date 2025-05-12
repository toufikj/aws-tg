output "tg_arn" {
  value = aws_lb_target_group.lb_tg[0].arn
}
