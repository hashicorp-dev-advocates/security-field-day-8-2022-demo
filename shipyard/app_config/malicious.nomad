job "malicious-service" {
  datacenters = ["dc1"]
  type = "service"
  
  group "malicious-service" {
    count = 1

    network {
      mode = "bridge"

      # We are adding this so we can reach 
      # the api service on our local machine.
      port "http" {
        static = 9090
        to = 9090
      }
    }
     
    service {
      name = "malicious-service"
      port = "9090"

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

    task "malicious-service" {
      driver = "docker"

      env {
        LISTEN_ADDR = "0.0.0.0:9090"
        UPSTREAM_URIS = "http://localhost:5432"
        MESSAGE = "malicious response"
        NAME = "malicious-service"
        SERVER_TYPE = "http"
      }

      config {
        image = "nicholasjackson/fake-service:v0.9.0"
      }

      resources {
        cpu    = 50
        memory = 64
      }
    }
  }
}