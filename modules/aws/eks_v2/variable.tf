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

# variable "instance_types" {
#   description = "A list of instance types for the EKS worker nodes"
#   type        = list(string)
#   default     = [""]
# }

# variable "node_group_instance_type" {
#   description = "The instance type for the EKS managed node group"
#   type        = string
#   default     = "m5.xlarge"
# }

# variable "node_group_min_size" {
#   description = "Minimum size of the node group"
#   type        = number
#   default     = 2
# }

# variable "node_group_max_size" {
#   description = "Maximum size of the node group"
#   type        = number
#   default     = 4
# }

# variable "node_group_desired_size" {
#   description = "Desired size of the node group"
#   type        = number
#   default     = 3
# }


variable "cidr_blocks" {
  type = list(string)
}

variable "node_groups" {
  description = "Configuration for EKS managed node groups"
  type = map(object({
    ami_type       = optional(string, "AL2023_x86_64_STANDARD")
    instance_types = optional(list(string), [""])
    min_size       = optional(number, 3)
    max_size       = optional(number, 5)
    desired_size   = optional(number, 3)
    subnet_ids     = optional(list(string), [])
    tags           = optional(map(string), {})
    key_name      = optional(string, null)
    iam_role_name  = optional(string, null)
    iam_role_additional_policies = optional(map(string), {})
  }))
  default = {}
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Terraform   = "true"
  }
}


#-----Cluster-Autoscaling variables----------
# variable "additional_role_mappings" {
#   description = "Additional role mappings for aws-auth ConfigMap"
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))
#   default = []
# }

# variable "additional_user_mappings" {
#   description = "Additional user mappings for aws-auth ConfigMap"
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))
#   default = []
# }

# variable "additional_launch_template_tags" {
#   description = "Additional tags to apply to the launch template"
#   type = map(string)
#   default = {}
# }