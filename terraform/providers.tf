terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.29.1"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.30.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.47.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.10.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {
}


provider "boundary" {
  addr                            = var.boundary_addr
  auth_method_id                  = var.boundary_auth_method_id
  password_auth_method_login_name = var.boundary_login_name
  password_auth_method_password   = var.boundary_login_password
}

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "vault" {

  address   = var.vault_addr
  token     = var.vault_token
  namespace = "admin"
}