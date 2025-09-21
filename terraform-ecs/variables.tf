variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "image_tag" {
  description = "Docker image tag to deploy from ECR"
  type        = string
  default     = "latest"
}

variable "cluster_name" {
  type    = string
  default = "availability-cluster"
}

variable "service_name" {
  type    = string
  default = "availability-service"
}
