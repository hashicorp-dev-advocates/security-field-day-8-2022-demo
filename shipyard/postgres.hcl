container "timescaledb" {
  image {
    name = "timescale/timescaledb:latest-pg14"
  }

  port {
    local  = 5432
    host   = 5432
    remote = 5432
  }

  env {
    key   = "POSTGRES_USER"
    value = "postgres"
  }

  env {
    key   = "POSTGRES_PASSWORD"
    value = "postgres"
  }

  env {
    key   = "POSTGRES_DB"
    value = "profiles"
  }

  volume {
    source      = "./config/postgres/files"
    destination = "/files"
  }

  network {
    name       = "network.cloud"
    ip_address = "10.5.0.203"
  }

}

exec_remote "psql_checker" {

  target = "container.timescaledb"

  cmd = "sh"
  args = [
    "./files/psql-checker.sh"

  ]
  depends_on = [
    "container.timescaledb"
  ]
}

exec_remote "psql_setup" {

  target = "container.timescaledb"

  cmd = "sh"
  args = [
    "./files/psql-setup.sh"

  ]
  depends_on = [
    "container.timescaledb",
    "exec_remote.psql_checker"
  ]
}