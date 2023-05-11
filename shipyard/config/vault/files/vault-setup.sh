#!/usr/bin/env bash

vault auth enable userpass

vault secrets enable database

vault write database/config/profiles \
    plugin_name="postgresql-database-plugin" \
    allowed_roles="profiles" \
    connection_url="postgresql://{{username}}:{{password}}@timescaledb.container.shipyard.run:5432/profiles" \
    username="vaultuser" \
    password="vaultpass"

vault write database/roles/profiles \
    db_name="profiles" \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

vault secrets enable transit

vault write -f transit/keys/demoapp

vault policy write demoapp-encryptor /files/encryptor.hcl

vault policy write demoapp-decryptor /files/decryptor.hcl

vault policy write db-creds /files/db-creds.hcl

vault write auth/userpass/users/demoapp \
    password=password \
    policies=demoapp-encryptor,db-creds

vault write auth/userpass/users/decryptor \
    password=password \
    policies=demoapp-decryptor
