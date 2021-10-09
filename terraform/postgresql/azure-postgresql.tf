terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.70.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  project_name = "exam-prep-gen"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "exam-prep-gen-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_postgresql_server" "exam-prep-gen-db" {
  name                = format("%s-db", local.project_name)
  resource_group_name = azurerm_resource_group.exam-prep-gen-rg.name
  location            = azurerm_resource_group.exam-prep-gen-rg.location

  administrator_login          = "ronaldo"
  administrator_login_password = "ohsosecret-3"

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = false
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"
}