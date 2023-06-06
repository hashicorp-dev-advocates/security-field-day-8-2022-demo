#!/usr/bin/env bash

psql "host=localhost port=5432 dbname=profiles user=postgres password=postgres sslmode=disable" \
  -c "CREATE USER vaultuser WITH SUPERUSER PASSWORD 'vaultpass';"

psql "host=localhost port=5432 dbname=profiles user=postgres password=postgres sslmode=disable" \
  -c 'CREATE TABLE IF NOT EXISTS profiles (
        id SERIAL PRIMARY KEY,
        username VARCHAR (255) NOT NULL,
        first_name VARCHAR (255) NOT NULL,
        surname VARCHAR (255) NOT NULL,
        email VARCHAR (255) UNIQUE NOT NULL,
        password VARCHAR (255) NOT NULL
);'