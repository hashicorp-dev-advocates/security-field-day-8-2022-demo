resource "azurerm_virtual_network" "security_field_day" {
  name                = azurerm_resource_group.security-field-day.name
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5", "8.8.8.8"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
  }

  #  subnet {
  #    address_prefix = "10.0.3.224/27"
  #    name           = "AzureBastionSubnet"
  #  }

  tags = {
    DoNotDelete = true
  }
}

resource "azurerm_public_ip" "bastion" {
  name                = "bastionPublicIp1"
  resource_group_name = azurerm_resource_group.security-field-day.name
  location            = azurerm_resource_group.security-field-day.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    DoNotDelete = true
  }
}

resource "azurerm_network_interface" "bastion" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name

  dns_servers = ["8.8.8.8"]
  ip_configuration {
    name                          = "boundaryworkerconfig"
    subnet_id                     = tolist(azurerm_virtual_network.security_field_day.subnet[*].id)[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id

  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_virtual_machine" "bastion" {
  name                  = "bastion"
  location              = azurerm_resource_group.security-field-day.location
  resource_group_name   = azurerm_resource_group.security-field-day.name
  network_interface_ids = [azurerm_network_interface.bastion.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "bastiondisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "bastion"
    admin_username = "bastion"
    admin_password = "BastionPassword123!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    DoNotDelete = true
  }

}
