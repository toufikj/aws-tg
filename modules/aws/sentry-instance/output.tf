output "instance_public_ip" {
  value = aws_instance.sentry_instance.public_ip
}
