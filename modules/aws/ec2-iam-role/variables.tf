variable "name" {
  description = "name of the iam_role to be created"
  type        = string
}


variable "environment" {
  description = "name of environment"
  type        = string
}

variable "organization" {
  description = "Name of organization"
  type        = string
}

variable "service" {
  description = "Name of service or use-case or role of this s3 bucket"
  type        = string
}

variable "tags" {
  description = "Tags in form of key value pair"
  type        = map(any)
  default     = {}
}

variable "ec2_instance_policy" {
  description = "IAM role policy"
  type        = string
  # default     = {}
  default = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecs:CreateCluster",
        "ecs:DeregisterContainerInstance",
        "ecs:DiscoverPollEndpoint",
        "ecs:Poll",
        "ecs:RegisterContainerInstance",
        "ecs:StartTelemetrySession",
        "ecs:Submit*",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
