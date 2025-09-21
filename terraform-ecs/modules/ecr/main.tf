resource "aws_ecr_repository" "repo" {
  name         = var.repo_name
  force_delete = true
  image_tag_mutability = "IMMUTABLE"
}
