### TG variables
variable "create_tg" {
  description = "wheather to create target_group or not"
  default     = true
  type        = bool
}

variable "tg_name" {
  description = "Name of target group"
  type        = string
}

variable "traffic_port" {
  description = "Port number of instance or IP, where TG will send traffic"
  type        = number
}
variable "protocol" {
  description = "protocol of request between TG and target(ip/instance)"
  default     = "HTTP"
  type        = string
}

variable "target_type" {
  description = "type of target IP, lambda, alb, instance"
  type        = string
}

variable "vpc_id" {
  description = "vpc id, where tg will be created"
  type        = string
}

variable "healthy_threshold" {
  description = "healthy threashold"
  default     = 5
  type        = number
}

variable "interval" {
  description = "time gap b/w each health check req"
  default     = 30
  type        = number
}

variable "matcher" {
  description = "Response codes to use when checking for a healthy responses from a target"
  default     = "200-299"
  type        = string
}

variable "path" {
  description = "Destination for the health check request"
  default     = "/"
  type        = string
}

variable "timeout" {
  description = "Amount of time, in seconds, during which no response from a target means a failed health check"
  default     = 5
  type        = number
}

variable "unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy."
  default     = 3
  type        = number
}

variable "health_check_port" {
  description = "The port the load balancer uses when performing health checks on targets."
  default     = "traffic-port"
}

#### Listener variables
variable "host_based_routing_rule" {
  description = "wheather to create host base routing rule or not"
  default     = false
  type        = bool
}

variable "listener_arn" {
  description = "The ARN of listener where this rule will be created"
  type        = string
}

variable "priority" {
  description = "priority of rule, as there will be many rules in listener"
  type        = number
}

variable "host_headers" {
  description = "List of host headers, which will be added in rule"
  type        = list(string)
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

variable "tg_4xx_threshold" {
  default = "20"
}

variable "tg_5xx_threshold" {
  default = "10"
}

variable "latency_threshold" {
  default = "10"
}

variable "lb_arn_suffix" {
  description = "The ARN of the load balancer"
  type        = string
}




variable "service" {}
variable "environment" {}
variable "organization" {}
