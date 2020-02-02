provider "azurerm" {
  version = "=1.42.0"
}

locals {
  project_name = "exam-prep"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}

# Create a resource group
resource "azurerm_resource_group" "exam-prep-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_container_registry" "acr" {
  name                = "examprep"
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  sku                 = "Standard"
  admin_enabled       = false
}