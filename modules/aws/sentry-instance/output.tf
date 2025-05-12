output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.ec2.id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.ec2.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.ec2.private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.sg.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = var.create_target_group ? aws_lb_target_group.tg[0].arn : null
}