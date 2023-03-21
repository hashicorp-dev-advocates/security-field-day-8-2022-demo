locals {
  custom_data = templatefile("${path.module}/scripts/boundary-worker.sh", {
    BOUNDARY_IP_ADDR = azurerm_public_ip.boundary.ip_address
    BOUNDARY_CLUSTER_ID = var.boundary_cluster_id
  })
}

resource "azurerm_network_interface" "worker" {
  name                = "boundary-worker-nic"
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name

  dns_servers = ["8.8.8.8"]
  ip_configuration {
    name                          = "boundaryworkerconfig"
    subnet_id                     =  tolist(azurerm_virtual_network.security_field_day.subnet[*].id)[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.boundary.id

  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_virtual_machine" "worker" {
  name                  = "boundary-worker"
  location              = azurerm_resource_group.security-field-day.location
  resource_group_name   = azurerm_resource_group.security-field-day.name
  network_interface_ids = [azurerm_network_interface.worker.id]
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
    name              = "workerdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "boundary-worker"
    admin_username = "boundaryadmin"
    admin_password = "BoundaryPassword123!"
    custom_data    = base64encode(local.custom_data)
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_public_ip" "boundary" {
  name                = "boundaryWorkerPublicIp1"
  resource_group_name = azurerm_resource_group.security-field-day.name
  location            = azurerm_resource_group.security-field-day.location
  allocation_method   = "Static"

  tags = {
    DoNotDelete = true
  }
}





resource "azurerm_network_interface" "front_end" {
  name                = "front-end-nic"
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name

  dns_servers = ["8.8.8.8"]
  ip_configuration {
    name                          = "frontendconfig"
    subnet_id                     =  tolist(azurerm_virtual_network.security_field_day.subnet[*].id)[0]
    private_ip_address_allocation = "Dynamic"

  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_virtual_machine" "front_end" {
  name                  = "front-end"
  location              = azurerm_resource_group.security-field-day.location
  resource_group_name   = azurerm_resource_group.security-field-day.name
  network_interface_ids = [azurerm_network_interface.front_end.id]
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
    name              = "frontenddisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "front-end"
    admin_username = var.target_username
    admin_password = var.target_password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_network_interface" "back_end" {
  name                = "back-end-nic"
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name

  dns_servers = ["8.8.8.8"]
  ip_configuration {
    name                          = "backendconfig"
    subnet_id                     =  tolist(azurerm_virtual_network.security_field_day.subnet[*].id)[0]
    private_ip_address_allocation = "Dynamic"

  }

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_virtual_machine" "back_end" {
  name                  = "back-end"
  location              = azurerm_resource_group.security-field-day.location
  resource_group_name   = azurerm_resource_group.security-field-day.name
  network_interface_ids = [azurerm_network_interface.back_end.id]
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
    name              = "target2disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "back-end"
    admin_username = var.target_username
    admin_password = var.target_password

#    custom_data = base64encode(templatefile("${path.module}/scripts/frontend.sh", ))
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    DoNotDelete = true
  }

}
