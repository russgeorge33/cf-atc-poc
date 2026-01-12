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
| <a name="module_compute_management"></a> [compute\_management](#module\_compute\_management) | ../../../modules/compute | n/a |
| <a name="module_resource_group_mgmt"></a> [resource\_group\_mgmt](#module\_resource\_group\_mgmt) | ../../../modules/resource_group | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_subnet.mgmt](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |

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