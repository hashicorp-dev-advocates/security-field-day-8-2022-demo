# exec_remote "nomad_jobs" {
#     depends_on =["nomad_cluster.dev"]

#     target = "container.tools"
#     cmd = "nomad"
#     args = ["run", "/files/profile_api.nomad"]
# }