# modules/compute/variables.tf

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type        = string
  sensitive   = true
}

variable "install_apache" {
  type        = bool
  default     = false
}

variable "availability_set_id" {
  type        = string
  default     = null
}

# EOF