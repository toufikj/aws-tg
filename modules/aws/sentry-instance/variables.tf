variable "ami_id" {
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
}

variable "key_name" {
  description = "SSH key pair name for accessing the EC2 instance"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "vpc_id" {
  description = "Name tag for the vpc instance"
}



###########################will be edited out ##################
### common variables
variable "environment" {
  description = "The name of environment"
}

variable "service" {
  description = "The name of service"
}

variable "organization" {
  description = "The name of organization"
}


## ec2 vars
variable "subnet_type" {}
variable "instance_count" {}
variable "associate_public_ip_address" {}

### tg & listener rule variables
variable "create_tg" {}
variable "host_based_routing_rule" {}
variable "traffic_port" {}
variable "tg_protocol" {}
variable "tg_target_type" {}
variable "tg_listener_arn" {}
variable "tg_rule_priority" {}

variable "host_headers" {
  type = list(string)
}
variable "path" {}
variable "unhealthy_threshold" {}
variable "lb_arn_suffix" {}