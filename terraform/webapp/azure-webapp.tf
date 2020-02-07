provider "azurerm" {
  version = "=1.42.0"
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

resource "azurerm_resource_group" "exam-prep-webapp-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_app_service_plan" "exam-prep-webapp-sp" {
  name                = "exam-prep-webapp-sp"
  resource_group_name = azurerm_resource_group.exam-prep-webapp-rg.name
  location            = azurerm_resource_group.exam-prep-webapp-rg.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "exam-prep-webapp-docker-app" {
  name                = "exam-prep-webapp-docker-app"
  resource_group_name = azurerm_resource_group.exam-prep-webapp-rg.name
  location            = azurerm_resource_group.exam-prep-webapp-rg.location
  app_service_plan_id = azurerm_app_service_plan.exam-prep-webapp-sp.id

  site_config {
    always_on        = true
    linux_fx_version = "DOCKER|${data.azurerm_container_registry.acr.login_server}/neo4j:4.0.0"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "DOCKER_REGISTRY_SERVER_URL"          = "https://${data.azurerm_container_registry.acr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME"     = data.azurerm_container_registry.acr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD"     = data.azurerm_container_registry.acr.admin_password
  }
}
#
# TODO
#  - Add Web App NodeJs
