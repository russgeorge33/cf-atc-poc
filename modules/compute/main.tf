# modules/compute/main.tf

resource "azurerm_network_interface" "vm" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = "Standard_B2ls_v2"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm.id]
  availability_set_id   = var.availability_set_id  # Can be null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  disable_password_authentication = false
  depends_on  = [azurerm_network_interface.vm]
}

resource "azurerm_virtual_machine_extension" "apache" {
  count                = var.install_apache ? 1 : 0
  name                 = "install-apache"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
      "script": "${base64encode("#!/bin/bash\napt-get update -y\napt-get install -y apache2\necho 'Hello from ${var.vm_name}' > /var/www/html/index.html")}"
    }
  SETTINGS
  depends_on           = [azurerm_linux_virtual_machine.vm]
}

# EOF