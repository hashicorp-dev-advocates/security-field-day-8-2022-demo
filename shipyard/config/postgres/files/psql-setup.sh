#!/usr/bin/env bash

psql "host=localhost port=5432 dbname=profiles user=postgres password=postgres sslmode=disable" \
  -c "CREATE USER vaultuser WITH SUPERUSER PASSWORD 'vaultpass';"
