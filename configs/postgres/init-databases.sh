#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE "pangolin-dialogue-db";
    CREATE DATABASE "pangolin-identity-db";
    CREATE DATABASE "pangolin-pulse-db";

    GRANT ALL PRIVILEGES ON DATABASE "pangolin-dialogue-db" TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE "pangolin-identity-db" TO $POSTGRES_USER;
    GRANT ALL PRIVILEGES ON DATABASE "pangolin-pulse-db" TO $POSTGRES_USER;
EOSQL
