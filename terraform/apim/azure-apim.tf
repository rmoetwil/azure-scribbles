terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  project_name = "exam-prep-apim"
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

resource "azurerm_service_plan" "exam-prep-apim-sp" {
  name                = "exam-prep-apim-sp"
  resource_group_name = azurerm_resource_group.exam-prep-apim-rg.name
  location            = azurerm_resource_group.exam-prep-apim-rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}


resource "azurerm_linux_function_app" "exam-prep-apim-fa" {
  name                       = "exam-prep-apim-fa"
  resource_group_name        = azurerm_resource_group.exam-prep-apim-rg.name
  location                   = azurerm_resource_group.exam-prep-apim-rg.location
  service_plan_id            = azurerm_service_plan.exam-prep-apim-sp.id
  storage_account_name       = azurerm_storage_account.exam-prep-apim-sa.name
  storage_account_access_key = azurerm_storage_account.exam-prep-apim-sa.primary_access_key

  site_config {}
}

resource "azurerm_api_management" "exam-prep-apim-am" {
  name                = "exam-prep-apim-am"
  resource_group_name = azurerm_resource_group.exam-prep-apim-rg.name
  location            = azurerm_resource_group.exam-prep-apim-rg.location
  publisher_name      = "Wilron"
  publisher_email     = "ronald.moetwil@gmail.com"

  sku_name = "Developer_1"
}