variable "environment" {

}
variable "organization" {

}
variable "service" {

}

variable "log_retention_period" {

}

variable "container_definitions" {

}

variable "cluster_id" {

}

variable "desired_count" {

}

variable "max_percent" {

}

variable "min_healthy_percent" {

}

variable "tg_arn" {
  default = ""
}

variable "container_name" {

}

variable "container_port" {

}
variable "network_mode" {
  default = "awsvpc"
}

variable "task_subnets" {

}

# variable "task_security_groups" {

# }

variable "assign_public_ip" {
  default = false

}

variable "vpc_cidr" {

}

variable "vpc_id" {

}

variable "capacity_provider" {

}

variable "weight" {
  default = 1
}
variable "base" {
  default = 0
}

variable "execution_role_arn" {
  description = "The name of IAM which will be assumed by docker daemon & ECS task for performaing pre-task operations"
  default     = ""
}
