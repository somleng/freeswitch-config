output "app_ecr_repository" {
  value = aws_ecrpublic_repository.app.repository_uri
}
