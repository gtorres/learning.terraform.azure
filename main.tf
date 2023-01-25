terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name = "rg-learn-terraform"
  location = "westus"
}

resource "azurerm_virtual_network" "main" {
  name = "vnet-learn-terraform"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
  name = "subnet-learn-terraform"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name = azurerm_resource_group.main.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_network_interface" "internal" {
  name = "nic1-learn-terraform"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name = "internal"
	subnet_id = azurerm_subnet.main.id
	private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "main" {
  name = "vm-learn-tf"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size = "Standard_D2s_v3"
  admin_username = "user.admin"
  admin_password = "Enter-password1"

  network_interface_ids = [
    azurerm_network_interface.internal.id
  ]

  os_disk {
    caching = "ReadWrite"
	storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftwindowsServer"
	offer = "WindowsServer"
	sku = "2016-DataCenter"
	version = "latest"
  }
}
