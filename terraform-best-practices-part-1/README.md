# Terraform Best Practices (Part 1)

Project structure, state management, and module design patterns.

📖 **Blog Post:** [Terraform Best Practices Part 1](https://moabukar.co.uk/blog/terraform-best-practices-part-1)

## Contents

```
terraform-best-practices-part-1/
├── examples/
│   ├── versions.tf                           # Version pinning
│   └── project-structure-medium/
│       └── environments/prod/                # Environment-based structure
├── modules/
│   └── vpc/
│       └── main.tf                           # Reusable VPC module
└── README.md
```

## Project Structures

### Small Projects (Flat)

```
terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
└── versions.tf
```

### Medium Projects (Environment Directories)

```
terraform/
├── modules/
│   ├── networking/
│   ├── compute/
│   └── database/
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── README.md
```

### Large Projects (Component-Based)

```
infrastructure/
├── _modules/           # Shared modules
├── networking/         # Network team
├── platform/           # Platform team
├── data/               # Data team
└── applications/       # App teams
```

## Key Practices

### 1. Version Pinning

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

### 2. Remote State with Locking

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### 3. Use Modules for Reusability

```hcl
module "networking" {
  source = "../../modules/networking"
  
  environment = "prod"
  vpc_cidr    = var.vpc_cidr
}
```

### 4. Default Tags

```hcl
provider "aws" {
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

## License

MIT
