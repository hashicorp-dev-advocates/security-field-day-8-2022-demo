output "boundary_worker_ip_addr" {
  value = azurerm_public_ip.boundary.ip_address
}

output "bastion_ip_addr" {
  value = azurerm_public_ip.bastion.ip_address
}

output "database_fqdn" {
  value = azurerm_postgresql_server.psql.fqdn
}