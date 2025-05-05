output "repository_urls" {
  description = "List of URLs for the created ECR repositories"
  value       = [for repo in aws_ecr_repository.ecr : repo.repository_url]
}
