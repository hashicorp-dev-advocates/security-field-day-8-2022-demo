resource "boundary_host_catalog" "front_end" {
  name        = "front-end"
  description = "Demo VM target"
  type        = "static"
  scope_id    = var.boundary_project_id
}

resource "boundary_host" "front_end" {
  type            = "static"
  name            = "front-end"
  description     = "front-end"
  address         = azurerm_network_interface.front_end.private_ip_address
  host_catalog_id = boundary_host_catalog.front_end.id
}

resource "boundary_host_set" "front_end" {
  type            = "static"
  name            = "front_end"
  host_catalog_id = boundary_host_catalog.front_end.id

  host_ids = [
    boundary_host.front_end.id,
  ]
}

resource "boundary_target" "front-end" {
  name         = "front-end"
  description  = "front-end"
  type         = "tcp"
  default_port = "22"
  scope_id     = var.boundary_project_id
  host_source_ids = [
    boundary_host_set.front_end.id
  ]

  brokered_credential_source_ids = [
    boundary_credential_library_vault.target.id
  ]
}

resource "boundary_credential_store_vault" "hcp" {
  address   = var.vault_addr
  scope_id  = var.boundary_project_id
  token     = vault_token.boundary.client_token
  namespace = "admin"
}

resource "boundary_credential_library_vault" "target" {
  name                = "target-creds"
  description         = "target VM creds!"
  credential_store_id = boundary_credential_store_vault.hcp.id
  path                = "kvv2/data/target_creds"
  http_method         = "GET"
  #  credential_type     = "username_password"
  #  credential_mapping_overrides = {
  #    password_attribute = "alternative_password_label"
  #    username_attribute = "alternative_username_label"
  #  }
}

resource "boundary_account_password" "developer" {
  auth_method_id = var.boundary_org_auth_method_id
  type           = "password"
  login_name     = "frontend"
  password       = "password"

}
resource "boundary_user" "front_end" {
  scope_id = var.boundary_org_id
  name     = "front-end"
  account_ids = [
    boundary_account_password.developer.id
  ]
}

resource "boundary_role" "applications_project" {
  scope_id = var.boundary_project_id

  principal_ids = [
    boundary_user.front_end.id
  ]

  grant_strings = [
    "id=*;type=*;actions=*"
  ]
}

resource "boundary_role" "org_login" {
  scope_id = var.boundary_project_id

  principal_ids = [
    boundary_user.front_end.id
  ]

  grant_strings = [
    "id=*;type=*;actions=read"
  ]
}

####


resource "boundary_scope" "back_end_project" {
  scope_id = var.boundary_org_id
  name     = "backend"
}



resource "boundary_host_catalog" "back_end" {
  name        = "back-end"
  description = "Demo VM target"
  type        = "static"
  scope_id    = boundary_scope.back_end_project.id
}

resource "boundary_host" "back_end" {
  type            = "static"
  name            = "back-end"
  description     = "back-end"
  address         = azurerm_network_interface.back_end.private_ip_address
  host_catalog_id = boundary_host_catalog.back_end.id
}

resource "boundary_host_set" "back_end" {
  type            = "static"
  name            = "back_end"
  host_catalog_id = boundary_host_catalog.back_end.id

  host_ids = [
    boundary_host.back_end.id,
  ]
}

resource "boundary_target" "back_end" {
  name         = "back-end"
  description  = "back-end"
  type         = "tcp"
  default_port = "22"
  scope_id     = boundary_scope.back_end_project.id
  host_source_ids = [
    boundary_host_set.back_end.id
  ]

  brokered_credential_source_ids = [
    boundary_credential_library_vault.back_end.id
  ]
}

resource "boundary_credential_store_vault" "back_end_hcp" {
  address   = var.vault_addr
  scope_id  = boundary_scope.back_end_project.id
  token     = vault_token.boundary_backend.client_token
  namespace = "admin"
  name      = "hcp"
}

resource "boundary_credential_library_vault" "back_end" {
  name                = "back-creds"
  description         = "backend VM creds!"
  credential_store_id = boundary_credential_store_vault.back_end_hcp.id
  path                = "kvv2/data/target_creds"
  http_method         = "GET"
  #  credential_type     = "username_password"
  #  credential_mapping_overrides = {
  #    password_attribute = "alternative_password_label"
  #    username_attribute = "alternative_username_label"
  #  }
}

resource "boundary_account_password" "back_end" {
  auth_method_id = var.boundary_org_auth_method_id
  type           = "password"
  login_name     = "backend"
  password       = "password"

}
resource "boundary_user" "back_end" {
  scope_id = var.boundary_org_id
  name     = "back-end"
  account_ids = [
    boundary_account_password.back_end.id
  ]
}

resource "boundary_role" "back_end" {
  scope_id = boundary_scope.back_end_project.id

  principal_ids = [
    boundary_user.back_end.id
  ]

  grant_strings = [
    "id=*;type=*;actions=*"
  ]
}

#resource "boundary_role" "proj_login" {
#  scope_id = boundary_scope.back_end_project.id
#
#  principal_ids = [
#    boundary_user.back_end.id
#  ]
#
#  grant_strings = [
#    "id=*;type=*;actions=read"
#  ]
#}