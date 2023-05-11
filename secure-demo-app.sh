#!/bin/bash

# This demo app takes inputs and write them to a database
# The goal is to create a user profile

postgres_addr=$POSTGRES_ADDR
postgres_port="5432"
postgres_db_name="profiles"

#Ask for User's first name
echo "What is your first name?"
read FIRST_NAME

#Ask for User's surname
echo "What is your surname?"
read SURNAME

#Ask for User's email address
echo "What is your email address?"
read EMAIL_ADDR

#Create a username
echo "Choose a username"
read USERNAME

#Create a password
echo "Choose a password"
read PASSWORD


echo Creating your user profile...

#login to Vault

json_pw_string=$(jq -n \
--arg pw "$VAULT_PW" \
'{"password": $pw}')

token=$(curl -s \
    -X POST \
    -d "$json_pw_string" \
    http://vault.container.shipyard.run:8200/v1/auth/userpass/login/demoapp \
    | jq -r .auth.client_token)


# generate database credentials

db_creds=$(curl -s \
  -X GET \
  -H "X-Vault-Token: ${token}" \
  http://vault.container.shipyard.run:8200/v1/database/creds/profiles)

db_user=$(echo $db_creds | jq -r .data.username)
db_password=$(echo $db_creds | jq -r .data.password)


#Encrypt email PII data

emailpayload=$(echo ${EMAIL_ADDR} | base64)

email_json_string=$(jq -n \
--arg epl "$emailpayload" \
'{"plaintext": $epl}')

encryptedemail=$(curl -s \
    -H "X-Vault-Token: ${token}" \
    -X POST \
    -d "${email_json_string}" \
    http://vault.container.shipyard.run:8200/v1/transit/encrypt/demoapp | jq -r .data.ciphertext)


# Encrypt password data

pwpayload=$(echo ${PASSWORD} | base64)

pw_json_string=$(jq -n \
--arg pwpl "${pwpayload}" \
'{"plaintext": $pwpl}')

encryptedpw=$(curl -s \
    -H "X-Vault-Token: ${token}" \
    -X POST \
    -d "${pw_json_string}" \
    http://vault.container.shipyard.run:8200/v1/transit/encrypt/demoapp | jq -r .data.ciphertext)


# Upsert database table
psql "host=${postgres_addr} port=${postgres_port} dbname=${postgres_db_name} user=${db_user} password=${db_password} sslmode=disable" \
  -c 'CREATE TABLE IF NOT EXISTS profiles (
        id SERIAL PRIMARY KEY,
        username VARCHAR (255) NOT NULL UNIQUE,
        first_name VARCHAR (255) NOT NULL,
        surname VARCHAR (255) NOT NULL,
        email VARCHAR (255) UNIQUE NOT NULL,
        password VARCHAR (255) NOT NULL
);'


#Add new user to Database
psql "host=${postgres_addr} port=${postgres_port} dbname=${postgres_db_name} user=${db_user} password=${db_password} sslmode=disable" \
  -c "INSERT INTO profiles(
        username,
        first_name,
        surname,
        email,
        password)
      VALUES ('${USERNAME}',
      '${FIRST_NAME}',
      '${SURNAME}',
      '${encryptedemail}',
      '${encryptedpw}')
      RETURNING *;"

