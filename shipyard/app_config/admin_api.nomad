job "admin-api" {
  datacenters = ["dc1"]
  type = "service"
  
  group "admin-api" {
    count = 1

    network {
      mode = "bridge"

      # We are adding this so we can reach 
      # the api service on our local machine.
      port "http" {
        static = 8081
        to = 8081
      }
    }
     
    service {
      name = "admin-api"
      port = "8081"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "profile-api"
              local_bind_port = 8080
            }
          }
        }
      }
    }

    task "admin-api" {
      driver = "docker"

      env {
        LISTEN_ADDR = "0.0.0.0:8081"
        UPSTREAM_URIS = "http://localhost:8080"
        MESSAGE = "{'id': 'user-1', 'name': 'John Doe'}"
        NAME = "admin-api"
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