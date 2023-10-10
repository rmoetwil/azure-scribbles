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
  project_name = "exam-prep-webapp"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}

data "azurerm_container_registry" "acr" {
  name                = "examprep"
  resource_group_name = "exam-prep-gen-rg"
}

data "azurerm_storage_account" "exam-prep-gen-sa" {
  name                = "examprepgensa"
  resource_group_name = "exam-prep-gen-rg"
}

resource "azurerm_resource_group" "exam-prep-webapp-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_service_plan" "exam-prep-webapp-sp" {
  name                = "exam-prep-webapp-sp"
  resource_group_name = azurerm_resource_group.exam-prep-webapp-rg.name
  location            = azurerm_resource_group.exam-prep-webapp-rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "exam-prep-webapp-docker-app" {
  name                = "exam-prep-webapp-docker-app"
  resource_group_name = azurerm_resource_group.exam-prep-webapp-rg.name
  location            = azurerm_resource_group.exam-prep-webapp-rg.location
  service_plan_id     = azurerm_service_plan.exam-prep-webapp-sp.id

  site_config {
    always_on        = true
    application_stack {
      docker_image_name = "${data.azurerm_container_registry.acr.login_server}/neo4j:5.12.0"
    }
  }

  app_settings = {
    "WEBSITES_PORT" = "7474"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = data.azurerm_container_registry.acr.admin_password
  }
}
#
# TODO
#  - Add Web App NodeJs
