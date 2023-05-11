terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "3.15.2"
    }
  }
}

provider "vault" {
  address   = "https://vault-public-vault-239b10a8.9c01e416.z1.hashicorp.cloud:8200"

  auth_login_userpass {
    namespace = "admin"
  }
}
