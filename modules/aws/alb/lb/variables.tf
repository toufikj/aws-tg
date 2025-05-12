variable "lb_name" {
  description = "Name of loadbalancer"
}
variable "is_internal" {
  description = "set to true if lb is internal"
  default     = true
  type        = bool
}
variable "lb_type" {
  description = "LoadBalancer type, application, network or gateway"
  default     = "application"
}
variable "lb_sg_ids" {
  description = " A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application"
  type        = list(any)
}
variable "subnet_type" {}
variable "lb_log_bucket" {
  default = ""
}
variable "enable_deletion_protection" {
  description = "enable deletion protection for lb"
}
variable "period" {
  default = "300"
}
variable "treat_missing_data" {
  default = "missing"
}
variable "evaluation_periods" {
  default = "2"
}

variable "alb_4xx_threshold" {
  default = "20"
}

variable "alb_5xx_threshold" {
  default = "10"
}

variable "latency_threshold" {
  default = "10"
}

variable "service" {}
variable "environment" {}
variable "organization" {}

