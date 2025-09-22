resource "aws_ecr_repository" "repo" {
  name         = "availability-tracker"
  force_delete = true
  image_tag_mutability = "IMMUTABLE"
}

provider "aws" {
  region = var.aws_region
}