path "transit/decrypt/demoapp" {
  capabilities = ["create", "update"]
}

path "transit/*" {
  capabilities = ["read", "list"]
}