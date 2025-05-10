variable "env" {
  type        = string
}

variable "product" {
  type        = string
}

variable "alb_sg" {
  type        = string
}

variable "private_subnets" {
  type        = list(string)
}

variable "ssl_certificate_arn" {
  type        = string
  default = ""
}







