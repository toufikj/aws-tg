# output "cluster_endpoint" {
#   description = "Endpoint for your Kubernetes API server"
#   value       = module.eks.cluster_endpoint
# }

# output "cluster_security_group_id" {
#   description = "Security group ID for the cluster"
#   value       = aws_security_group.eks_cluster.id
# }

# output "node_security_group_id" {
#   description = "Security group ID for the node"
#   value       = aws_security_group.eks_node.id
# }

# output "eks_cluster_name" {
#   description = "Name of the EKS cluster"
#   value       = module.eks.cluster_id
# }

# output "eks_cluster_arn" {
#   description = "ARN of the EKS cluster"
#   value       = module.eks.cluster_arn
# }

# output "eks_cluster_version" {
#   description = "EKS cluster version"
#   value       = module.eks.cluster_version
# }

# # output "eks_managed_node_group_name" {
# #   description = "Name of the managed node group"
# #   value       = module.eks.managed_node_groups["example"].name
# # }

# # output "eks_managed_node_group_arn" {
# #   description = "ARN of the managed node group"
# #   value       = module.eks.managed_node_groups["example"].arn
# # }

output "alb_controller_role_arn" {
  description = "ARN of the ALB controller IAM role"
  value       = aws_iam_role.alb_controller.arn
}
