path "transit/encrypt/demoapp" {
  capabilities = ["create", "update", "list"]
}

path "transit/*" {
  capabilities = ["read", "list"]
}