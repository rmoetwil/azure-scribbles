provider "azurerm" {
  version = "=1.42.0"
}

locals {
  project_name = "exam-prep"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}

data "azurerm_container_registry" "acr" {
  name                = "examprep"
  resource_group_name = "exam-prep-gen-rg"
}

# Create a resource group
resource "azurerm_resource_group" "exam-prep-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_container_group" "exam-prep-cont-grp" {
  name                = "exam-prep-cont-grp"
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  ip_address_type     = "public"
  os_type             = "Linux"

  image_registry_credential {
    username = data.azurerm_container_registry.acr.admin_username
    password = data.azurerm_container_registry.acr.admin_password
    server   = "examprep.azurecr.io"
  }

  container {
    name   = "neo4j"
    image  = "examprep.azurecr.io/neo4j:4.0.0"
    cpu    = "1"
    memory = "1"

    ports {
      port     = 7474
      protocol = "TCP"
    }

    ports {
      port     = 7687
      protocol = "TCP"
    }
  }

}
