# modules/load_balancer/variables.tf

variable "resource_group_name" {
  type = string
}

variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "web_nic_ids" {
  type = list(string)
}

# EOF