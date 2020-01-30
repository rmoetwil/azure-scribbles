provider "azurerm" {
  version = "=1.42.0"
}

locals {
  project_name = "exam-prep"
  location     = "West Europe"
  username     = "ronald"
}


# Create a resource group
resource "azurerm_resource_group" "exam-prep-rg" {
  name     = format("%s-rg", local.project_name)
  location = local.location
}

resource "azurerm_virtual_network" "exam-prep-vnet" {
  name                = format("%s-vnet", local.project_name)
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  address_space       = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "exam-prep-sbn" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.exam-prep-rg.name
  address_prefix       = "10.0.0.0/24"
  virtual_network_name = azurerm_virtual_network.exam-prep-vnet.name
}

resource "azurerm_network_security_group" "exam-prep-nsg" {
  name                = format("%s-nsg", local.project_name)
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

resource "azurerm_subnet_network_security_group_association" "exam-prep-nsg-sbn" {
  subnet_id                 = azurerm_subnet.exam-prep-sbn.id
  network_security_group_id = azurerm_network_security_group.exam-prep-nsg.id
}

resource "azurerm_public_ip" "exam-prep-pub-ip" {
  name                = format("%s-pub-ip", local.project_name)
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "exam-prep-nic" {
  name                = format("%s-nic", local.project_name)
  resource_group_name = azurerm_resource_group.exam-prep-rg.name
  location            = azurerm_resource_group.exam-prep-rg.location

  ip_configuration {
    name                          = "ip-config-1"
    subnet_id                     = azurerm_subnet.exam-prep-sbn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.exam-prep-pub-ip.id
  }
}

resource "azurerm_virtual_machine" "exam-prep-vm" {
  name                  = format("%s-vm", local.project_name)
  resource_group_name   = azurerm_resource_group.exam-prep-rg.name
  location              = azurerm_resource_group.exam-prep-rg.location
  network_interface_ids = [azurerm_network_interface.exam-prep-nic.id]
  vm_size               = "Standard_B2ms"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = format("%s-vm-os-disk", local.project_name)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = format("%s-vm", local.project_name)
    admin_username = local.username
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDn+JUp3bgPSP0/67Eu5iYouCRbD9D8DHXNCFdzf2ExcILLrCrgzsXE7M2OSdPaF5z6uu/hPL9DfNkE3oxHfKLVh+AFuHJA8ugqav3PiIXThwgYyNiGtAFvpeTp1IRGC+7rag69ID2XinBAHDMSBLJYZUnokwGuwIRvnuC/XVUy/IASxC8Z6KVBMEPkskdyMVzD/T0sELGrXq9wnqQTL26rH2nh/fk0dbOmQRsZRxo/GRMWu5EX5gD2TgBs9Ix3kUu7xlA22sjkYbZVOgvuZ/t8SPB9KcWKqYkuZJifkJFJakfrB73T0tzFLWqB7ZvMOrvXB2HWJG9vTAU62ruoAGBFTIXi67yIV2XxQKXeQtVcB6Y3fvj+VMqNhL1mfSBYfbPnJjElXxoWOMlqYH9gWT51JieaovegDfxnBKoFeClpJOUc00v2R6gVqr6+gXBOHb9at4rg0bq0UsGxfIFcocpxoIGtCCWSij2eE53TusPPW+HFtmCoxdt2tJqgrF1rEm/sBwiHp3CZnb55CmbYEKXM+SrvpDNzJys9YmwTn9FE27VLkefWhH0Hq6brVc94/igFU80LQBrzNfCUvlXMQX61nAEyxcYRvjWp36W+oMX6SM0e9VKhJ6k1Jp8U8RuJBNhJWi7xcoV9BFdkMwAu/HFppXDsK5Suc50ibSljyRzDwQ== ronald.moetwil@gmail.com"
      path     = format("/home/%s/.ssh/authorized_keys", local.username)
    }
  }
}


#
# TODO Do not see a way yet to connect this kind of schedule to a regular vm.

#
# resource "azurerm_dev_test_lab" "dev_test_lab" {
#   name                = "MyDevTestLab"
#   resource_group_name = azurerm_resource_group.exam-prep-rg.name
#   location            = azurerm_resource_group.exam-prep-rg.location
# }

# resource "azurerm_dev_test_schedule" "vm_shutdown_schedule" {
#   name                = "ComputeVmShutdown"
#   resource_group_name = azurerm_resource_group.exam-prep-rg.name
#   location            = azurerm_resource_group.exam-prep-rg.location
#   lab_name            = azurerm_dev_test_lab.dev_test_lab.name

#   daily_recurrence {
#     time = "1900"
#   }

#   time_zone_id = "W. Europe Standard Tim"
#   task_type    = "ComputeVmShutdownTask"

#   notification_settings {
#     status           = "Enabled"
#     time_in_minutes  = 30
#     emeail_recipient = "ronald.moetwil@gmail.com"
#   }
# }
