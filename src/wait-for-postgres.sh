#!/bin/bash

# LOCAL ONLY : this script waits for the PostgreSQL database to become available before executing a command.
# It takes the host as the first argument and the command to execute as the remaining arguments.

set -e

# Environment variable to indicate if the app is using AWS RDS
if [ "$USE_AWS_RDS" = "true" ]; then
    >&2 echo "Using AWS RDS for PostgreSQL. Skipping wait-for-postgres script."
else
    host="$1"
    shift
    cmd="$@"

    until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -U "$POSTGRES_USER" -c '\q'; do
        >&2 echo "Postgres is unavailable - sleeping"
        sleep 1
    done
fi

>&2 echo "Postgres is up - executing command"
exec $cmd
