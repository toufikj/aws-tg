module "ec2_role" {
#   source              = "../../../../modules/aws/ec2-iam-role"
  source              = "./../ec2-iam-role/"
  environment         = var.environment
  organization        = var.organization
  service             = var.service
  name                = "${var.environment}-${var.organization}-${var.service}-ec2-role-01"
  ec2_instance_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "SessionManagerAccess",
            "Effect": "Allow",
            "Action": [
                "ssm:StartSession"
            ],
            "Resource": "*"
        },
        {
            "Sid": "EC2InstanceInfo",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}
