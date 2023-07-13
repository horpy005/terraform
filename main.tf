resource "azurerm_resource_group" "myrg" {
  name     = "tst"
  location = "West Europe"
}

resource "azurerm_virtual_network" "myvnet" {
  name                = "tst-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "tst-subnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "tst-nsg"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "tst-nic${count.index}"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "tst-ipconfig${count.index}"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_machine" "main" {
  count               = var.vm_count
  name                = "main-vm${count.index}"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  vm_size         = var.vm_flavor
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"   
    offer = var.vm_image
    sku = "20_04-lts-gen2"
    version = "latest"
  }

  storage_os_disk {
    name = "osdisk${count.index}"
    create_option = "FromImage"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname${count.index}"
    admin_username = "adminuser"
    admin_password = random_password.vm_passwords[count.index].result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "dev"
  }
}

resource "random_password" "vm_passwords" {
  count           = var.vm_count
  length          = 16
  special         = true
  override_special = "_@%"
}