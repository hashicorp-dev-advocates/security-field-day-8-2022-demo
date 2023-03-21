container_ingress "consul-http" {
  target  = "container.consul"

  port {
    local  = 8500
    remote = 8500
    host   = 18500
  }

  network  {
    name = "network.cloud"
  }
}

nomad_ingress "database" {
  cluster  = "nomad_cluster.dev"
  job = "database"
  group = "database"
  task = "database"

  port {
    local  = 5432
    remote = 5432
    host   = 5432
  }

  network  {
    name = "network.cloud"
  }
}

nomad_ingress "profile_api" {
  cluster  = "nomad_cluster.dev"
  job = "profile-api"
  group = "profile-api"
  task = "profile-api"

  port {
    local  = 8080
    remote = "http"
    host   = 8080
  }

  network  {
    name = "network.cloud"
  }
}

nomad_ingress "admin_api" {
  cluster  = "nomad_cluster.dev"
  job = "admin-api"
  group = "admin-api"
  task = "admin-api"

  port {
    local  = 8081
    remote = "http"
    host   = 8081
  }

  network  {
    name = "network.cloud"
  }
}

nomad_ingress "maliious_service" {
  cluster  = "nomad_cluster.dev"
  job = "malicious-service"
  group = "malicious-service"
  task = "malicious-service"

  port {
    local  = 9090
    remote = "http"
    host   = 9090
  }

  network  {
    name = "network.cloud"
  }
}