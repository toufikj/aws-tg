output "instance_profile_arn" {
  value = aws_iam_instance_profile.ec2_instance_role_profile.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_role_profile.name
}
