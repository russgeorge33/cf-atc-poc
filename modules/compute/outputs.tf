# modules/compute/output.tf

output "nic_id" {
  value = azurerm_network_interface.vm.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

# EOF