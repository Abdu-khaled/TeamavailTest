output "alb_dns" {
  value = module.alb.alb_dns_name
}

output "ecr_repo_url" {
  value = module.ecr.repo_url
}

output "redis_endpoint" {
  value = module.redis.redis_endpoint
}
