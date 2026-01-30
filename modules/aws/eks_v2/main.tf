module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "21.10.1"

  name    = var.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Make the API endpoint private
  endpoint_public_access  = true
  endpoint_private_access = true
  zonal_shift_config = {
    enabled = true
  }
  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn
    }
    # aws-ebs-csi-driver = {
    #   pod_identity_association = [{
    #     role_arn        = aws_iam_role.ebs_csi_driver_role.arn
    #     service_account = "ebs-csi-controller-sa"
    #   }]
    #   addon_version = "v1.30.0-eksbuild.1"
    #   resolve_conflicts = "OVERWRITE"
    # }
  }

  # eks_managed_node_group_defaults = {
  #   instance_types = var.instance_types
  # }

  eks_managed_node_groups = var.node_groups
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true

  access_entries = {
    example = {
      kubernetes_groups = []
      principal_arn     = aws_iam_role.eks_cluster.arn

      policy_associations = {
        example = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
          access_scope = {
            namespaces = ["default"]
            type       = "namespace"
          }
        }
      }
    }
  }
  tags = var.tags
  # depends_on = [
  #   aws_iam_role.eks_cluster
  # ]
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json

  # tags = var.tags
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster.name
}

resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks  # Update this to match your VPC CIDR block
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tags = var.tags
}

resource "aws_security_group" "eks_node" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks  # Update this to match your VPC CIDR block
    
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = var.cidr_blocks  # Update this to match your VPC CIDR block
  }

  # ingress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "-1"
  #   cidr_blocks = var.cidr_blocks  # Update this to match your VPC CIDR block
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # tags = var.tags
}

resource "aws_iam_instance_profile" "eks_node" {
  name = "${var.cluster_name}-node-instance-profile"
  role = aws_iam_role.eks_node.name

  # tags = var.tags
}

resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role_policy.json

  # tags = var.tags
}

data "aws_iam_policy_document" "eks_node_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node.name
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node.name
}
# Additional policies for EBS CSI Driver permissions
resource "aws_iam_role_policy_attachment" "eks_node_EBS_CSI_Policies" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node.name
}
resource "aws_iam_policy" "secrets_access" {
  name = "eks-secretsmanager-access-${var.cluster_name}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret"
      ]
      Resource = "arn:aws:secretsmanager:ap-south-1:*:*"
    }]
  })
}

############################################################################################################
### AUTOSCALING
############################################################################################################
data "aws_iam_policy_document" "cluster_autoscaler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }

    principals {
      identifiers = ["${module.eks.oidc_provider_arn}"]
      type        = "Federated"
    }
  }
}

# IAM Role for Cluster Autoscaler
resource "aws_iam_role" "cluster_autoscaler_role" {
  name               = "${var.cluster_name}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role_policy.json
}

# Custom policy for Cluster Autoscaler
data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler_policy" {
  name   = "${var.cluster_name}-cluster-autoscaler-policy"
  role   = aws_iam_role.cluster_autoscaler_role.id
  policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}



########################################################################################
#----------This is experiment branch changes for ebs-csi and alb-controller helm deployment
#############################################################################################
data "aws_iam_policy_document" "ebs_csi_driver_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = ["${module.eks.oidc_provider_arn}"]
      type        = "Federated"
    }
  }
}

data "aws_iam_policy_document" "alb_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      identifiers = ["${module.eks.oidc_provider_arn}"]
      type        = "Federated"
    }
  }
}

# Attach the EBS CSI Driver policy
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "${var.cluster_name}-ebs-csi-driver"

  assume_role_policy = data.aws_iam_policy_document.ebs_csi_driver_assume_role_policy.json
}

resource "aws_iam_role" "alb_controller" {
  name = "${var.cluster_name}-alb-controller"

  assume_role_policy = data.aws_iam_policy_document.alb_controller_assume_role_policy.json
}

resource "aws_iam_policy" "aws_lb_controller" {
  name = "${var.cluster_name}-aws-lb-controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "elasticloadbalancing.amazonaws.com"
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeVpcs",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeTags",
          "ec2:GetCoipPoolUsage",
          "ec2:DescribeCoipPools",
          "ec2:DescribeRouteTables",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeListenerAttributes",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection",
          "shield:DescribeSubscription",
          "shield:ListProtections",
          "shield:ListResourcesForWebACL",
          "shield:DescribeEmergencyContactSettings",
          "shield:ListTagsForResource",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:SetWebAcl",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "iam:GetRole",
          "iam:CreateServiceLinkedRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "ec2:AddTags",
          "ec2:DeleteTags",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_policy" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

# helm repo add eks https://aws.github.io/eks-charts
# helm repo update
# helm upgrade aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=toufik-eks --set serviceAccount.create=true --set serviceAccount.name=aws-load-balancer-controller --set region=ap-south-1 --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=arn:aws:iam::376572378342:role/<alb_controller_role_arn> --set vpcId=vpc-0d1e39bb991fb35c7