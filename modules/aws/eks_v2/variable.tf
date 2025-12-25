variable "vpc_id" {
  description = "The ID of the VPC where the EKS cluster will be created"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the EKS cluster will be created"
  type        = list(string)
}

variable "control_plane_subnet_ids" {
  description = "A list of subnet IDs for the control plane"
  type        = list(string)
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "my-cluster"
}

variable "cluster_version" {
  description = "The version of the EKS cluster"
  type        = string
  default     = "1.30"
}

variable "instance_types" {
  description = "A list of instance types for the EKS worker nodes"
  type        = list(string)
  default     = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
}

variable "node_group_instance_type" {
  description = "The instance type for the EKS managed node group"
  type        = string
  default     = "m5.xlarge"
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 4
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 3
}


variable "cidr_blocks" {
  type = list(string)
}
# variable "tags" {
#   description = "A map of tags to add to all resources"
#   type        = map(string)
#   default     = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }
