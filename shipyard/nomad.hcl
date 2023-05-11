# template "nomad_config" {

#   source = <<-EOS
#   plugin "docker" {
#     config {
#       allow_privileged = true
#       volumes {
#         enabled = true
#         selinuxlabel = "z"
#       }
#     }
#   }
#   EOS

#   destination = "${data("nomad-config")}/user_config.hcl"
# }

# nomad_cluster "dev" {
#   client_nodes = "${var.client_nodes}"

#   nodes = 1

#   client_config = "${data("nomad-config")}/user_config.hcl"

#   network {
#     name = "network.cloud"
#   }

#   image {
#     name = "consul:1.10.1"
#   }

#   consul_config = "./consul_config/agent.hcl"

#   volume {
#     source      = "/tmp"
#     destination = "/files"
#   }
# }

# nomad_job "database" {
#   cluster = "nomad_cluster.dev"

#   paths = ["./app_config/database.nomad"]
#   health_check {
#     timeout    = "60s"
#     nomad_jobs = ["database"]
#   }
# }

# nomad_job "profile_api" {
#   cluster = "nomad_cluster.dev"

#   paths = ["./app_config/profile_api.nomad"]
#   health_check {
#     timeout    = "60s"
#     nomad_jobs = ["profile-api"]
#   }
# }

# nomad_job "admin_api" {
#   cluster = "nomad_cluster.dev"

#   paths = ["./app_config/admin_api.nomad"]
#   health_check {
#     timeout    = "60s"
#     nomad_jobs = ["admin-api"]
#   }
# }

# nomad_job "maliious_service" {
#   cluster = "nomad_cluster.dev"

#   paths = ["./app_config/malicious.nomad"]
#   health_check {
#     timeout    = "60s"
#     nomad_jobs = ["malicious-service"]
#   }
# }