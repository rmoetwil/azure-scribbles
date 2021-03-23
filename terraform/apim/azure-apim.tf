terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

locals {
  project_name = "exam-prep-webapp"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}


resource "azurerm_resource_group" "exam-prep-apim-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_storage_account" "exam-prep-apim-sa" {
  name                     = "examprepapimsa"
  resource_group_name      = azurerm_resource_group.exam-prep-apim-rg.name
  location                 = azurerm_resource_group.exam-prep-apim-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "exam-prep-apim-sp" {
  name                = "exam-prep-webapp-sp"
  resource_group_name = azurerm_resource_group.exam-prep-apim-rg.name
  location            = azurerm_resource_group.exam-prep-apim-rg.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "exam-prep-apim-fa" {
  name                       = "exam-prep-apim-fa"
  resource_group_name        = azurerm_resource_group.exam-prep-apim-rg.name
  location                   = azurerm_resource_group.exam-prep-apim-rg.location
  app_service_plan_id        = azurerm_app_service_plan.exam-prep-apim-sp.id
  storage_account_name       = azurerm_storage_account.exam-prep-apim-sa.name
  storage_account_access_key = azurerm_storage_account.exam-prep-apim-sa.primary_access_key
}

resource "azurerm_api_management" "exam-prep-apim-am" {
  name                = "exam-prep-apim-am"
  resource_group_name = azurerm_resource_group.exam-prep-apim-rg.name
  location            = azurerm_resource_group.exam-prep-apim-rg.location
  publisher_name      = "Wilron"
  publisher_email     = "ronald.moetwil@gmail.com"

  sku_name = "Developer_1"

}