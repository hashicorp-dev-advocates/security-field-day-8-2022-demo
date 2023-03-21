resource "azurerm_postgresql_server" "psql" {
  name                = "security-field-day-psql"
  location            = azurerm_resource_group.security-field-day.location
  resource_group_name = azurerm_resource_group.security-field-day.name

  administrator_login          = "psqladmin"
  administrator_login_password = "ProfilesPassword123"

  sku_name   = "GP_Gen5_2"
  version    = "11"
  storage_mb = 640000

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled    = true
  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"

  tags = {
    DoNotDelete = true
  }

}

resource "azurerm_postgresql_database" "profiles" {
  name                = "profiles"
  resource_group_name = azurerm_resource_group.security-field-day.name
  server_name         = azurerm_postgresql_server.psql.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

resource "azurerm_postgresql_firewall_rule" "default" {
  name                = "default"
  resource_group_name = azurerm_resource_group.security-field-day.name
  server_name         = azurerm_postgresql_server.psql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}