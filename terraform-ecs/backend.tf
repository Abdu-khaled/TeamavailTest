terraform {
  backend "s3" {
    bucket         = "availability-tracker"
    key            = "ecs/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "tf-locks"
    encrypt        = true
  }
}
