# Azure infrastructure for GitLab on AKS

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

variable "resource_group_name" {
  default = "rg-gitlab-prod"
}

variable "location" {
  default = "uksouth"
}

# Resource Group
resource "azurerm_resource_group" "gitlab" {
  name     = var.resource_group_name
  location = var.location
}

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "gitlab" {
  name                   = "gitlab-postgres-prod"
  resource_group_name    = azurerm_resource_group.gitlab.name
  location               = azurerm_resource_group.gitlab.location
  version                = "14"
  administrator_login    = "gitlabadmin"
  administrator_password = var.db_admin_password
  storage_mb             = 262144  # 256 GB
  sku_name               = "GP_Standard_D4s_v3"
  zone                   = "1"

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
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
  resource_group_name = azurerm_resource_group.gitlab.name
  location            = azurerm_resource_group.gitlab.location
  capacity            = 1
  family              = "P"
  sku_name            = "Premium"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"
}

# Storage Account
resource "azurerm_storage_account" "gitlab" {
  name                     = "gitlabstorageprod"
  resource_group_name      = azurerm_resource_group.gitlab.name
  location                 = azurerm_resource_group.gitlab.location
  account_tier             = "Standard"
  account_replication_type = "ZRS"
  min_tls_version          = "TLS1_2"
}

# Storage Containers
resource "azurerm_storage_container" "artifacts" {
  name                  = "gitlab-artifacts"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "uploads" {
  name                  = "gitlab-uploads"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "lfs" {
  name                  = "gitlab-lfs"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "packages" {
  name                  = "gitlab-packages"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "backups" {
  name                  = "gitlab-backups"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "registry" {
  name                  = "gitlab-registry"
  storage_account_name  = azurerm_storage_account.gitlab.name
  container_access_type = "private"
}

# Outputs
output "postgresql_fqdn" {
  value = azurerm_postgresql_flexible_server.gitlab.fqdn
}

output "redis_hostname" {
  value = azurerm_redis_cache.gitlab.hostname
}

output "redis_primary_key" {
  value     = azurerm_redis_cache.gitlab.primary_access_key
  sensitive = true
}

output "storage_account_name" {
  value = azurerm_storage_account.gitlab.name
}

output "storage_account_key" {
  value     = azurerm_storage_account.gitlab.primary_access_key
  sensitive = true
}

variable "db_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
}
