terraform {
cloud {
    organization = "Qubiz"

    workspaces {
      name = "AWS-Intro"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 1.1.0"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

resource "aws_ecr_repository" "main" {
  name                 = "workshop-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "main" {
  name = "workshop-cluster"
}

module "vpc" {
  source = "./vpc"
  lb_id = module.lb.lb_id
}

module "lb" {
  source = "./lb"
  public_subnets_ids =  module.vpc.public_subnets_ids
  vpc_id = module.vpc.vpc_id
  security_group_id = module.vpc.lb_security_group
}

module "iam" {
  source = "./iam"
}

# module "raoul-services" {
#   source = "./raoul-services"
#   ecs_cluster_id = aws_ecs_cluster.main.id
#   subnets = module.vpc.private_subnets_ids
#   target_group_arn = module.lb.target_group_arn
# }