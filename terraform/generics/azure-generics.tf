provider "azurerm" {
  version = "=1.42.0"
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

resource "azurerm_container_registry" "acr" {
  name                = "examprep"
  resource_group_name = azurerm_resource_group.exam-prep-gen-rg.name
  location            = azurerm_resource_group.exam-prep-gen-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_key_vault" "exam-prep-gen-kv" {
  name                        = format("%s-kv", local.project_name)
  resource_group_name         = azurerm_resource_group.exam-prep-gen-rg.name
  location                    = azurerm_resource_group.exam-prep-gen-rg.location
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

    access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get", "create", "list", "delete"
    ]

    secret_permissions = [
      "get", "set", "list", "delete"
    ]

    storage_permissions = [
      "get", "set", "list", "delete"
    ]
  }
}
