# env/poc/network/variables.tf

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "adminuser"
}

variable "admin_password" {
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

# EOF