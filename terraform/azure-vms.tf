provider "azurerm" {
  version = "=1.42.0"
}

locals {
  project_name        = "exam-prep"
  location            = "West Europe"
  resource_group_name = format("%s-rg", local.project_name)
  vnet_name           = format("%s-vnet", local.project_name)
  nsg_name            = format("%s-nsg", local.project_name)
}


# Create a resource group
resource "azurerm_resource_group" "exam-prep-rg" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "aexam-prep-vnet" {
  name                = local.vnet_name
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  address_space       = ["10.0.0.0/24"]

  subnet {
    name           = "default"
    address_prefix = "10.0.0.0/24"
    security_group = azurerm_network_security_group.exam-prep-nsg.id
  }
}

resource "azurerm_network_security_group" "exam-prep-nsg" {
  name                = local.nsg_name
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location

  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# TODO 
# nic
# vm
# public ip
# scheduler
