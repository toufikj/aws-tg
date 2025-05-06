

# AWS region where the resources will be created
variable "region" {
  description = "The AWS region to deploy resources."
  type        = string
}

# Stage (dev, prod, etc.)
variable "stage" {
  description = "The environment name, e.g., dev or prod."
  type        = string
}

variable "product" {
  description = "The family of the ECS task definition."
  type        = string
}

# VPC ID where the resources will be deployed
variable "vpc_id" {
  description = "The ID of the VPC where the resources will be deployed."
  type        = string
}

# ECS Cluster ID
variable "cluster_id" {
  description = "The ARN or name of the ECS cluster where the service will run."
  type        = string
}

# CPU allocation for the ECS Task
variable "cpu" {
  description = "CPU allocation for the ECS Task."
  type        = string
  
}

# Memory allocation for the ECS Task
variable "memory" {
  description = "Memory allocation for the ECS Task."
  type        = string
  
}

# Docker image for the Flowise container
variable "container_image_uri" {
  description = "The Docker image for the strapi container."
  type        = string
}

variable "container_port" {
  description = "The container port for strapi."
  type        = number
}

variable "container_protocol" {
  description = "The protocol used for the container (e.g., tcp)."
  type        = string
}


variable "target_group_port" {
  description = "The port for the target group (strapi running port)."
  type        = number
}

variable "target_group_protocol" {
  description = "The protocol for the target group (e.g., HTTP/HTTPS)."
  type        = string
}

variable "health_check_protocol" {
  description = "The protocol used for health checks (e.g., HTTP/HTTPS)."
  type        = string
}

variable "health_check_interval" {
  description = "The interval between health checks (in seconds)."
  type        = number
}

variable "health_check_timeout" {
  description = "The timeout for the health check (in seconds)."
  type        = number
}

variable "healthy_threshold" {
  description = "The number of successful health checks required before marking the target as healthy."
  type        = number
}

variable "unhealthy_threshold" {
  description = "The number of failed health checks before marking the target as unhealthy."
  type        = number
}

variable "domain" {
  description = "The domain name for strapi (host header)."
  type        = string
}

# Environment variables for the container
variable "environment_variables" {
  description = "Environment variables to be passed to the container."
  type        = map(string)
}

# Desired count for the ECS Service
variable "desired_count" {
  description = "The number of tasks desired for the ECS service."
  type        = number
}

# Load Balancer ARN
variable "existing_load_balancer_arn" {
  description = "The ARN of the existing load balancer to attach the ECS service to."
  type        = string
}

# List of private subnets for ECS
variable "private_subnets" {
  description = "List of private subnets for ECS tasks."
  type        = list(string)
}

# Security group for the ECS service
variable "security_group" {
  description = "The security group associated with the ECS service."
  type        = string
}

# Listener priority
variable "listener_priority" {
  description = "The priority for the load balancer listener rule."
  type        = number
}

variable "existing_listener_arn" {
  description = "The listener rule."
  type        = string
}

# Variable to pass the existing ECS task execution role ARN
variable "existing_ecs_task_execution_role_arn" {
  description = "The ARN of the existing ECS Task Execution Role"
  type        = string
}


variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate to use for HTTPS"
  type = string
}

variable "network_mode" {
  description = "The network mode for the ECS task definition (e.g., awsvpc)."
  type        = string
}


variable "container_name" {
  description = "The name of the container for strapi."
  type        = string
}
