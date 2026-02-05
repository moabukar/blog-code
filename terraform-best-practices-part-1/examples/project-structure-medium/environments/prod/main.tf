# environments/prod/main.tf
# Production environment configuration

terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "terraform"
      Project     = var.project_name
    }
  }
}

module "networking" {
  source = "../../modules/networking"

  environment = "prod"
  vpc_cidr    = var.vpc_cidr
  azs         = var.availability_zones
}

module "compute" {
  source = "../../modules/compute"

  environment    = "prod"
  vpc_id         = module.networking.vpc_id
  subnet_ids     = module.networking.private_subnet_ids
  instance_type  = var.instance_type
  instance_count = var.instance_count
}
