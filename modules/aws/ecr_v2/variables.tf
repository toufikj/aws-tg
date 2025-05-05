variable "counts" {
  description = "Number of ECR repositories to create"
}

variable "names" {
  description = "List of names for ECR repositories"
  type        = list(string)
}
