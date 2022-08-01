terraform {
  cloud {
    organization = "qubiz-aws-2022"

    workspaces {
      name = "aws-workshop-summer"
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
  region  = "eu-west-2"
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}

resource "aws_ecr_repository" "main" {
  name                 = "workshop-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "${var.name}-ecr"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "workshop-cluster"

  tags = {
    Name = "${var.name}-cluster"
  }
}

module "vpc" {
  source = "./vpc"
  name = var.name
}

module "lb" {
  source = "./lb"
  public_subnets_ids =  module.vpc.public_subnets_ids
  vpc_id = module.vpc.vpc_id
  security_group_id = module.vpc.lb_security_group
  name = var.name
}

module "iam" {
  source = "./iam"
}

module "raoul-services" {
  source = "./raoul-services"
  ecs_cluster_id = aws_ecs_cluster.main.id
  public_subnets_ids = module.vpc.public_subnets_ids
  target_group_arn = module.lb.target_group_arn
  name = var.name
  ecs_task_execution_role = module.iam.ecs_task_execution_role_arn
  ecs_task_role = module.iam.ecs_task_execution_role_arn
  security_group_id = module.vpc.ecs_task_sg_id
  lb_listener = module.lb.lb_listener
  service_name = "hello-world-app"
}


module "john-services" {
  source = "./john"
  ecs_cluster_id = aws_ecs_cluster.main.id
  public_subnets_ids = module.vpc.public_subnets_ids
  target_group_arn = module.lb.target_group_arn
  name = var.name
  ecs_task_execution_role = module.iam.ecs_task_execution_role_arn
  ecs_task_role = module.iam.ecs_task_execution_role_arn
  security_group_id = module.vpc.ecs_task_sg_id
  lb_listener = module.lb.lb_listener
}


module "gandalf" {
  source = "./gandalf"
  ecs_cluster_id = aws_ecs_cluster.main.id
  public_subnets_ids = module.vpc.public_subnets_ids
  target_group_arn = module.lb.target_group_arn
  name = var.name
  ecs_task_execution_role = module.iam.ecs_task_execution_role_arn
  ecs_task_role = module.iam.ecs_task_execution_role_arn
  security_group_id = module.vpc.ecs_task_sg_id
  lb_listener = module.lb.lb_listener
  service_name = "hello-world-gandalf"
}

module "florin" {
  source = "./florin"
  ecs_cluster_id = aws_ecs_cluster.main.id
  public_subnets_ids = module.vpc.public_subnets_ids
  target_group_arn = module.lb.target_group_arn
  name = var.name
  ecs_task_execution_role = module.iam.ecs_task_execution_role_arn
  ecs_task_role = module.iam.ecs_task_execution_role_arn
  security_group_id = module.vpc.ecs_task_sg_id
  lb_listener = module.lb.lb_listener
  service_name = "hello-world-florin"
}

module "sauron" {
  source = "./sauron"
  ecs_cluster_id = aws_ecs_cluster.main.id
  public_subnets_ids = module.vpc.public_subnets_ids
  target_group_arn = module.lb.target_group_arn
  name = var.name
  ecs_task_execution_role = module.iam.ecs_task_execution_role_arn
  ecs_task_role = module.iam.ecs_task_execution_role_arn
  security_group_id = module.vpc.ecs_task_sg_id
  lb_listener = module.lb.lb_listener
  service_name = "hello-world-sauron"
}