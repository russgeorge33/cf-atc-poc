<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) |  = 1.5.7 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | ../../../modules/network | n/a |
| <a name="module_resource_group_network"></a> [resource\_group\_network](#module\_resource\_group\_network) | ../../../modules/resource_group | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_ip"></a> [admin\_ip](#input\_admin\_ip) | IP address or CIDR for SSH access to management VM | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | `"westus2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource group | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->