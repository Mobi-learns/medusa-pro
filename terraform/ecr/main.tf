resource "aws_ecr_repository" "medusa_repo" {
  name = var.ecr_repository_name
}

output "repository_url" {
  value = aws_ecr_repository.medusa_repo.repository_url
}
