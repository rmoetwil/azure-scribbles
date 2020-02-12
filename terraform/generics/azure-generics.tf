provider "azurerm" {
  version = "=1.42.0"
}

provider "azuread" {
  version = "=0.7.0"
}

variable "service_principal_pwd" {
  type = string
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
  admin_enabled       = true
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

resource "azurerm_storage_account" "exam-prep-gen-sa" {
  name                     = "examprepgensa"
  resource_group_name      = azurerm_resource_group.exam-prep-gen-rg.name
  location                 = azurerm_resource_group.exam-prep-gen-rg.location
  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
}

resource "azuread_application" "application" {
  name                       = "exam-prep-app"
}

resource "azuread_service_principal" "exam-spn" {
  application_id = azuread_application.application.application_id
}

resource "azuread_service_principal_password" "exam-spn-pwd" {
  service_principal_id = azuread_service_principal.exam-spn.id
  value                = var.service_principal_pwd
  end_date             = "2022-01-01T01:02:03Z"
}

output "service_principal_client_id" {
  value = azuread_service_principal.exam-spn.application_id
}
