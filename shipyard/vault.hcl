variable "vault_version" {
  default = "1.13.2"
}

module "vault" {
  source = "github.com/devops-rob/shipyard-blueprints/modules//vault-oss"
}


exec_remote "vault_setup" {

  image {
    name = "vault:${var.vault_version}"
  }

  network {
    name       = "network.cloud"
  }

  cmd = "sh"
  args = [
    "./files/vault-setup.sh"
  ]

  volume {
    source = "./config/vault/files"
    destination = "/files"
  }

  env {
    key = "VAULT_ADDR"
    value = "http://vault.container.shipyard.run:8200"
  }

  env {
    key = "VAULT_TOKEN"
    value = "root"
  }

  depends_on = [
    "module.vault",
    "exec_remote.psql_checker",
    "exec_remote.psql_setup"
  ]

}