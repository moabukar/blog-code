# terraform/environments/staging/main.tf

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configure your backend
  # backend "s3" {
  #   bucket = "mycompany-terraform-state"
  #   key    = "staging/asg/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      Environment = "staging"
      ManagedBy   = "terraform"
      Project     = "myapp"
    }
  }
}

# Data sources for existing infrastructure
data "aws_vpc" "main" {
  tags = {
    Name = "staging-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  tags = {
    Tier = "private"
  }
}

# Reference existing ALB (or create one)
data "aws_lb" "main" {
  name = "staging-alb"
}

data "aws_lb_target_group" "app" {
  name = "staging-myapp-tg"
}

data "aws_security_group" "alb" {
  name = "staging-alb-sg"
}

# Deploy the ASG module
module "app_asg" {
  source = "../../modules/asg"

  app_name    = "myapp"
  environment = "staging"

  # Use latest AMI in staging for continuous deployment
  ami_version = "latest"

  instance_type    = "t3.medium"
  min_size         = 1
  max_size         = 5
  desired_capacity = 2

  vpc_id     = data.aws_vpc.main.id
  subnet_ids = data.aws_subnets.private.ids

  target_group_arns      = [data.aws_lb_target_group.app.arn]
  alb_security_group_ids = [data.aws_security_group.alb.id]
}

output "asg_name" {
  value = module.app_asg.asg_name
}
