#!/bin/bash

# This demo app takes inputs and write them to a database
# The goal is to create a user profile

postgres_user="psqladmin"
postgres_password=$POSTGRES_PASSWORD
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

# Upsert database table
psql "host=${postgres_addr} port=${postgres_port} dbname=${postgres_db_name} user=${postgres_user}@security-field-day-psql password=${postgres_password} sslmode=disable" \
  -c 'CREATE TABLE IF NOT EXISTS profiles (
        username VARCHAR (50) PRIMARY KEY,
        first_name VARCHAR (50) NOT NULL,
        surname VARCHAR (50) NOT NULL,
        email VARCHAR (255) UNIQUE NOT NULL,
        password VARCHAR (50) NOT NULL
);'


#Add new user to Database
psql "host=${postgres_addr} port=${postgres_port} dbname=${postgres_db_name} user=${postgres_user}@security-field-day-psql password=${postgres_password} sslmode=disable" \
  -c "INSERT INTO profiles(
        username,
        first_name,
        surname,
        email,
        password)
      VALUES ('${USERNAME}',
      '${FIRST_NAME}',
      '${SURNAME}',
      '${EMAIL_ADDR}',
      '${PASSWORD}')
      RETURNING *;"
