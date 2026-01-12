# env/poc/network/main.tf

module "resource_group_network" {
  source   = "../../../modules/resource_group"
  name     = "rg-atc-poc-network"
  location = var.location
  tags     = var.tags
}

module "network" {
    source              = "../../../modules/network"
    resource_group_name = module.resource_group_network.name
    location            = module.resource_group_network.location
    admin_ip            = var.admin_ip
    depends_on          = [module.resource_group_network]
}

# EOF