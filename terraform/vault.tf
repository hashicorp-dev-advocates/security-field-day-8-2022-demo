resource "vault_mount" "kvv2" {
  path        = "kvv2"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "config" {
  mount                = vault_mount.kvv2.path
  max_versions         = 5
#  delete_version_after = 12600
  cas_required         = false
}

resource "vault_kv_secret_v2" "target_creds" {
  mount               = vault_mount.kvv2.path
  name                = "target_creds"
#  cas                 = 0
#  delete_all_versions = true
  data_json = jsonencode(
    {
      username = var.target_username,
      password = var.target_password
    }
  )

}

resource "vault_policy" "boundary_controller" {
  name   = "boundary-controller"
  policy = <<EOP
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

path "auth/token/renew-self" {
  capabilities = ["update"]
}

path "auth/token/revoke-self" {
  capabilities = ["update"]
}

path "sys/leases/renew" {
  capabilities = ["update"]
}

path "sys/leases/revoke" {
  capabilities = ["update"]
}

path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOP
}

resource "vault_policy" "target_creds" {
  name   = "target_creds"
  policy = <<EOP
path "kvv2/data/target_creds" {
  capabilities = ["read", "list"]
}
EOP
}
resource "vault_token" "boundary" {
  no_default_policy = true
  policies = [
    vault_policy.boundary_controller.name,
    vault_policy.target_creds.name
  ]
  renewable = true
  period    = "50d"
  no_parent = true
}

resource "vault_token" "boundary_backend" {
  no_default_policy = true
  policies = [
    vault_policy.boundary_controller.name,
    vault_policy.target_creds.name
  ]
  renewable = true
  period    = "50d"
  no_parent = true
}

resource "vault_auth_backend" "userpass" {
  type = "userpass"
}

resource "vault_generic_endpoint" "demoapp" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/demoapp"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["hcp-root"],
  "password": "password"
}
EOT
}

resource "vault_generic_endpoint" "rob" {
  depends_on           = [vault_auth_backend.userpass]
  path                 = "auth/userpass/users/devopsrob"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["hcp-root"],
  "password": "password"
}
EOT
}

resource "vault_database_secrets_mount" "database" {
  path = "database"

  postgresql {
    name              = "db2"
    username          = azurerm_postgresql_server.psql.administrator_login
    password          = azurerm_postgresql_server.psql.administrator_login_password
    connection_url    = "host=${azurerm_postgresql_server.psql.fqdn} port=5432 dbname=${azurerm_postgresql_database.profiles.name} user=${azurerm_postgresql_server.psql.administrator_login}@${azurerm_postgresql_server.psql.name} password=${azurerm_postgresql_server.psql.administrator_login_password} sslmode=disable"
    verify_connection = true
    allowed_roles = [
      "demoapp",
    ]
  }
}

resource "vault_database_secret_backend_role" "demoapp" {
  name    = "demoapp"
  backend = vault_database_secrets_mount.database.path
  db_name = vault_database_secrets_mount.database.postgresql[0].name
  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}';",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT INSERT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT UPDATE ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO \"{{name}}\";"
  ]
}

resource "vault_mount" "transit" {
  path                      = "transit"
  type                      = "transit"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_transit_secret_backend_key" "key" {
  backend = vault_mount.transit.path
  name    = "demoapp"
}