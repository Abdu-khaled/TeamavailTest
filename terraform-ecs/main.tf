provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "./modules/vpc"
  aws_region = var.aws_region
}

module "ecr" {
  source    = "./modules/ecr"
  repo_name = "availability-tracker"
}

module "alb" {
  source    = "./modules/alb"
  vpc_id    = module.vpc.vpc_id
  subnets   = module.vpc.public_subnets
  alb_sg_id = module.vpc.alb_sg_id
}

module "redis" {
  source     = "./modules/redis"
  subnets    = module.vpc.public_subnets
  redis_sg_id = module.vpc.redis_sg_id
}

module "ecs" {
  source               = "./modules/ecs"
  cluster_name         = var.cluster_name
  service_name         = var.service_name
  vpc_subnets          = module.vpc.public_subnets
  ecs_sg_id            = module.vpc.ecs_sg_id
  alb_target_group_arn = module.alb.target_group_arn
  ecr_repo_url         = module.ecr.repo_url
  image_tag            = var.image_tag
  redis_endpoint       = module.redis.redis_endpoint
  aws_region           = var.aws_region
}
