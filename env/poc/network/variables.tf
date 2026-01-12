# env/poc/network/variables.tf

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westus2"
}

variable "admin_ip" {
  description = "IP address or CIDR for SSH access to management VM"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

# EOF