# env/poc/network/main.tf

data "azurerm_subnet" "mgmt" {
  name                 = "sn-mgmt"
  virtual_network_name = "vnet-atc-poc"
  resource_group_name  = "rg-atc-poc-network"
}

module "resource_group_mgmt" {
  source   = "../../../modules/resource_group"
  name     = "rg-atc-poc-mgmt"
  location = var.location
  tags     = var.tags
}

# Management VM
module "compute_management" {
  source                = "../../../modules/compute"
  resource_group_name   = module.resource_group_mgmt.name
  location              = module.resource_group_mgmt.location
  vm_name               = "vm-atc-poc-mgmt1"
  subnet_id             = data.azurerm_subnet.mgmt.id
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  install_apache        = false
  availability_set_id   = null
  depends_on            = [
    data.azurerm_subnet.mgmt,
    module.resource_group_mgmt
  ]
}

# EOF