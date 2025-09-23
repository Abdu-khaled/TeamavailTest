variable "cluster_name" {}
variable "service_name" {}
variable "vpc_subnets" { type = list(string) }
variable "ecs_sg_id" {}
variable "alb_target_group_arn" {}
variable "ecr_repo_url" {}
variable "redis_endpoint" {}
variable "aws_region" {}

variable "image_tag" {
  description = "Tag for the docker image"
  type        = string
  default     = "latest"
}
