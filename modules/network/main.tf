# modules/network/main.tf

resource "azurerm_virtual_network" "poc" {
  name                = "vnet-atc-poc"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

## Bastion ------------------------------------------------------------------------------

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on           = [azurerm_virtual_network.poc]
}

resource "azurerm_public_ip" "bastion_pip" {
  name                = "atc-poc-bas-pip"
  location            = azurerm_virtual_network.poc.location
  resource_group_name = azurerm_virtual_network.poc.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on          = [azurerm_subnet.bastion]
}

resource "azurerm_bastion_host" "bastion" {
  name                   = "atc-poc-bas"
  location               = azurerm_virtual_network.poc.location
  resource_group_name    = azurerm_virtual_network.poc.resource_group_name

  sku                    = "Basic"
  copy_paste_enabled     = true

  ip_configuration {
    name                 = "atc-poc-bas-ipconfig1"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
  depends_on             = [azurerm_public_ip.bastion_pip]
}

## Management ---------------------------------------------------------------------------

resource "azurerm_subnet" "management" {
  name                 = "sn-mgmt"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on           = [azurerm_virtual_network.poc]
}

resource "azurerm_network_security_group" "management" {
  name                         = "nsg-mgmt"
  location                     = var.location
  resource_group_name          = var.resource_group_name

  security_rule {
    name                       = "SSH-from-Admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ip
    destination_address_prefix = "*"
  }
  depends_on                   = [azurerm_subnet.management]
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
  depends_on                = [azurerm_network_security_group.management]
}

## Web ----------------------------------------------------------------------------------

resource "azurerm_subnet" "web" {
  name                 = "sn-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on           = [azurerm_virtual_network.poc]
}

resource "azurerm_network_security_group" "web" {
  name                         = "nsg-web"
  location                     = var.location
  resource_group_name          = var.resource_group_name

  security_rule {
    name                       = "SSH-from-Management"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.2.0/24"  # Management subnet
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP-from-Any"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "LB-Probe"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
  
  depends_on                   = [azurerm_subnet.web]
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
  depends_on                = [azurerm_network_security_group.web]
}

## App ----------------------------------------------------------------------------------

resource "azurerm_subnet" "application" {
  name                 = "sn-app"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.3.0/24"]
  depends_on           = [azurerm_virtual_network.poc]
}

resource "azurerm_network_security_group" "application" {
  name                = "nsg-app"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_subnet.application]
}

resource "azurerm_subnet_network_security_group_association" "application" {
  subnet_id                 = azurerm_subnet.application.id
  network_security_group_id = azurerm_network_security_group.application.id
  depends_on                = [azurerm_network_security_group.application]
}

## Backend ------------------------------------------------------------------------------

resource "azurerm_subnet" "backend" {
  name                 = "sn-be"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.poc.name
  address_prefixes     = ["10.0.4.0/24"]
  depends_on           = [azurerm_virtual_network.poc]
}

resource "azurerm_network_security_group" "backend" {
  name                = "nsg-be"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on          = [azurerm_subnet.backend]
}

resource "azurerm_subnet_network_security_group_association" "backend" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend.id
  depends_on                = [azurerm_network_security_group.backend]
}

# EOF