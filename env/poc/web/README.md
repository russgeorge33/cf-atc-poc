<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) |  = 1.5.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_availability_set_web"></a> [availability\_set\_web](#module\_availability\_set\_web) | github.com/Coalfire-CF/ACE-Azure-VM-AvailabilitySet | n/a |
| <a name="module_compute_web1"></a> [compute\_web1](#module\_compute\_web1) | ../../../modules/compute | n/a |
| <a name="module_compute_web2"></a> [compute\_web2](#module\_compute\_web2) | ../../../modules/compute | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../../modules/load_balancer | n/a |
| <a name="module_resource_group_web"></a> [resource\_group\_web](#module\_resource\_group\_web) | ../../../modules/resource_group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.web](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | n/a | `string` | n/a | yes |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for VMs | `string` | `"adminuser"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | `"westus2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource group | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->