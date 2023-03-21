#!/bin/bash

json_pw_string=$(jq -n \
--arg pw "$VAULT_PW" \
'{"password": $pw}')

token=$(curl \
    -X POST \
    -H "X-Vault-Namespace: admin" \
    -d "$json_pw_string" \
    https://vault-public-vault-776466ca.915a5767.z1.hashicorp.cloud:8200/v1/auth/userpass/login/demoapp \
    | jq -r .auth.client_token)


#db_creds=$(curl \
#  -X GET \
#  -H "X-Vault-Namespace: admin" \
#  -H "X-Vault-Token: ${token}" \
#  https://vault-public-vault-776466ca.915a5767.z1.hashicorp.cloud:8200/v1/database/creds/demoapp)
#
#db_user=$(echo $db_creds | jq -r .data.username)
#db_password=$(echo $db_creds | jq -r .data.password)
#
#echo "${db_user}:${db_password}"

pw_json_string=$(jq -n \
--arg pwpl "pwpayload" \
'{"plaintext": $pwpl}')

encryptedpw=$(curl \
    -H "X-Vault-Token: ${token}" \
    -H "X-Vault-Namespace: admin" \
    -X POST \
    -d "${pw_json_string}" \
    https://vault-public-vault-776466ca.915a5767.z1.hashicorp.cloud:8200/v1/transit/encrypt/demoapp | jq -r .data.ciphertext)
