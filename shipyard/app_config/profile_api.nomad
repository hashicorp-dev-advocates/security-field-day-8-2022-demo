job "profile-api" {
  datacenters = ["dc1"]
  type = "service"
  
  group "profile-api" {
    count = 1

    network {
      mode = "bridge"

      # We are adding this so we can reach 
      # the api service on our local machine.
      port "http" {
        static = 8080
        to = 8080
      }
    }
     
    service {
      name = "profile-api"
      port = "8080"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "database"
              local_bind_port = 5432
            }
          }
        }
      }
    }

    task "profile-api" {
      driver = "docker"

      env {
        LISTEN_ADDR = "0.0.0.0:8080"
        UPSTREAM_URIS = "http://localhost:5432"
        MESSAGE = "{'id': 'user-1', 'name': 'John Doe'}"
        NAME = "api"
        SERVER_TYPE = "http"
      }

      config {
        image = "nicholasjackson/fake-service:v0.18.1"
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }
}