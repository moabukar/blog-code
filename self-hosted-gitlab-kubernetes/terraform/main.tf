# main.tf - Azure infrastructure for GitLab on AKS

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "gitlab" {
  name     = "rg-gitlab-prod"
  location = "uksouth"
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "gitlab" {
  name                   = "gitlab-postgres-prod"
  resource_group_name    = azurerm_resource_group.gitlab.name
  location               = azurerm_resource_group.gitlab.location
  version                = "14"
  administrator_login    = "gitlabadmin"
  administrator_password = var.postgres_password
  
  storage_mb = 262144  # 256 GB
  sku_name   = "GP_Standard_D4s_v3"
  
  high_availability {
    mode = "ZoneRedundant"
  }
}

resource "azurerm_postgresql_flexible_server_database" "gitlab" {
  name      = "gitlab_production"
  server_id = azurerm_postgresql_flexible_server.gitlab.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# Redis Cache
resource "azurerm_redis_cache" "gitlab" {
  name                = "gitlab-redis-prod"
  location            = azurerm_resource_group.gitlab.location
  resource_group_name = azurerm_resource_group.gitlab.name
  capacity            = 2
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
  
  redis_configuration {
    maxmemory_policy = "volatile-lru"
  }
}

# Storage Account for object storage
resource "azurerm_storage_account" "gitlab" {
  name                     = "gitlabstorageprod"
  resource_group_name      = azurerm_resource_group.gitlab.name
  location                 = azurerm_resource_group.gitlab.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
}

# Blob containers
locals {
  containers = ["gitlab-lfs", "gitlab-artifacts", "gitlab-uploads", "gitlab-packages", "gitlab-backups", "gitlab-tmp"]
}

resource "azurerm_storage_container" "gitlab" {
  for_each              = toset(local.containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

# Outputs
output "postgres_host" {
  value = azurerm_postgresql_flexible_server.gitlab.fqdn
}

output "redis_host" {
  value = azurerm_redis_cache.gitlab.hostname
}

output "storage_account_name" {
  value = azurerm_storage_account.gitlab.name
}

variable "postgres_password" {
  type      = string
  sensitive = true
}
