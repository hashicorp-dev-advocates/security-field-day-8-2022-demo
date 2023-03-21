# Security Field Day

## Vault

address:
`https://vault-public-vault-776466ca.915a5767.z1.hashicorp.cloud:8200`

username: `demoapp`

### Useful SQL commands for demo

Create table

```sh
psql "host=security-field-day-psql.postgres.database.azure.com port=5432 dbname=profiles user=<USERNAME>@security-field-day-psql password=<PASSWORD> sslmode=disable" \
  -c 'CREATE TABLE IF NOT EXISTS profiles (
        username VARCHAR (50) PRIMARY KEY,
        first_name VARCHAR (50) NOT NULL,
        surname VARCHAR (50) NOT NULL,
        email VARCHAR (255) UNIQUE NOT NULL,
        password VARCHAR (255) NOT NULL
);'
```

Drain connections

```sh
psql "host=security-field-day-psql.postgres.database.azure.com port=5432 dbname=profiles user=psqladmin@security-field-day-psql password=ProfilesPassword123 sslmode=disable" \
 -c 'REVOKE CONNECT ON DATABASE profiles FROM public;'

psql "host=security-field-day-psql.postgres.database.azure.com port=5432 dbname=profiles user=psqladmin@security-field-day-psql password=ProfilesPassword123 sslmode=disable" \
 -c 'SELECT pid, pg_terminate_backend(pid)
     FROM pg_stat_activity
     WHERE datname = current_database() AND pid <> pg_backend_pid();'
```

## Boundary

address:
`https://096d153a-6ebc-4ed7-bfc7-46c6afaa8309.boundary.hashicorp.cloud`

Authenticate command

```sh
boundary authenticate password -auth-method-id=$BOUNDARY_AUTH_METHOD_ID -login-name=frontend
```

Boundary connect Frontend

```sh
boundary connect ssh -target-id $FRONTEND_TARGET_ID --username=targetadmin
```

Boundary connect Backend

```sh
boundary connect ssh -target-id $BACKEND_TARGET_ID --username=targetadmin
```
