terraform {
  backend "s3" {
    bucket = "our-wordpress-1663407579"
    key    = "ecs_wp/terraform.tfstate"
    region = "eu-west-1"
  }

  required_version = ">= 1.1.9"
  required_providers {
    aws = "~> 4.00"

  }
}