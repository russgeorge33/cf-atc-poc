# modules/network/outputs.tf

output "subnet_ids" {
  value = {
    web         = azurerm_subnet.web.id
    application = azurerm_subnet.application.id
    management  = azurerm_subnet.management.id
    backend     = azurerm_subnet.backend.id
  }
}

# EOF