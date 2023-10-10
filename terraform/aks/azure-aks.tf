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

variable "service_principal_client_id" {
  type = string
}

variable "service_principal_client_secret" {
  type = string
}

locals {
  project_name = "exam-prep"
  location     = "West Europe"
}

data "azurerm_client_config" "current" {}

# data "azurerm_container_registry" "acr" {
#   name                = "examprep"
#   resource_group_name = "exam-prep-gen-rg"
# }

# Create a resource group
resource "azurerm_resource_group" "exam-prep-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = "exam-prep-aks"
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  dns_prefix          = "exam-prep-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  service_principal {
    client_id     = var.service_principal_client_id
    client_secret = var.service_principal_client_secret
  }

}
