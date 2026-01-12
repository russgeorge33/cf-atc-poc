# env/poc/network/main.tf

data "azurerm_subnet" "web" {
  name                 = "sn-web"
  virtual_network_name = "vnet-atc-poc"
  resource_group_name  = "rg-atc-poc-network"
}

module "resource_group_web" {
  source   = "../../../modules/resource_group"
  name     = "rg-atc-poc-web"
  location = var.location
  tags     = var.tags
}

# Create a single availability set for the web VMs using Coalfire's Availability Set Public Code
module "availability_set_web" {
  source                = "github.com/Coalfire-CF/ACE-Azure-VM-AvailabilitySet"
  availability_set_name = "as-atc-poc-web"
  location              = var.location
  resource_group_name   = module.resource_group_web.name
  regional_tags         = var.tags
  global_tags           = var.tags
  depends_on            = [module.resource_group_web]
}

# Web VM 1
module "compute_web1" {
  source                = "../../../modules/compute"
  resource_group_name   = module.resource_group_web.name
  location              = module.resource_group_web.location
  vm_name               = "vm-atc-poc-web1"
  subnet_id             = data.azurerm_subnet.web.id
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  install_apache        = true
  availability_set_id   = module.availability_set_web.availability_set_id
  depends_on            = [
    module.resource_group_web,
    module.availability_set_web
  ]
}

# Web VM 2
module "compute_web2" {
  source                = "../../../modules/compute"
  resource_group_name   = module.resource_group_web.name
  location              = module.resource_group_web.location
  vm_name               = "vm-atc-poc-web2"
  subnet_id             = data.azurerm_subnet.web.id
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  install_apache        = true
  availability_set_id   = module.availability_set_web.availability_set_id
  depends_on            = [
    module.resource_group_web,
    module.availability_set_web
  ]
}

# Web VM Load Balancer
module "load_balancer" {
  source              = "../../../modules/load_balancer"
  name                = "lb-atc-poc1"
  resource_group_name = module.resource_group_web.name
  location            = module.resource_group_web.location
  web_nic_ids         = [
    module.compute_web1.nic_id,
    module.compute_web2.nic_id
  ]
  depends_on            = [
    module.resource_group_web,
    module.availability_set_web,
    module.compute_web1,
    module.compute_web2
  ]
}

# EOF