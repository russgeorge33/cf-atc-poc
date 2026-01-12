# modules/load_balancer/main.tf

resource "azurerm_public_ip" "lb" {
  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
  name                   = var.name
  location               = var.location
  resource_group_name    = var.resource_group_name
  sku                    = "Standard"

  frontend_ip_configuration {
    name                 = "public-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
  depends_on             = [azurerm_public_ip.lb]
}

resource "azurerm_lb_backend_address_pool" "lb" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backend-pool"
  depends_on      = [azurerm_lb.lb]
}

resource "azurerm_network_interface_backend_address_pool_association" "web_vm1" {
  network_interface_id    = var.web_nic_ids[0]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
  depends_on              = [azurerm_lb_backend_address_pool.lb]
}

resource "azurerm_network_interface_backend_address_pool_association" "web_vm2" {
  network_interface_id    = var.web_nic_ids[1]
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb.id
  depends_on              = [azurerm_lb_backend_address_pool.lb]
}

resource "azurerm_lb_probe" "lb" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "http-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
  depends_on      = [azurerm_lb.lb]
}

resource "azurerm_lb_rule" "lb" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.lb.id]
  probe_id                       = azurerm_lb_probe.lb.id
  depends_on                     = [
    azurerm_lb.lb,
    azurerm_lb_probe.lb,
    azurerm_lb_backend_address_pool.lb
  ]
}

# EOF