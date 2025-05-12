variable "lb_arn" {
    description = "Load Balancer ARN"
}
variable "http_to_https_redirect" {
    description = "Create http listner with redirection from port 80 to 443"
    type = bool
    default = false
}
variable "https_fixed_response" {
    description = "Create https listner with fixed response"
    type = bool
    default = false
}
variable "certificate_arn" {
    description = "Certificate ARN to attach with Https listener"
    default = ""
}