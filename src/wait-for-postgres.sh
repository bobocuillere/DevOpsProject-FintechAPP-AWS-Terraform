#!/bin/bash

# LOCAL ONLY : this script waits for the PostgreSQL database to become available before executing a command.
# It takes the host as the first argument and the command to execute as the remaining arguments.

set -e

host="$1"
shift
cmd="$@"

# Environment variable to indicate if the app is using AWS RDS
if [ "$USE_AWS_RDS" = "true" ]; then
    >&2 echo "Using AWS RDS for PostgreSQL. Skipping wait-for-postgres script."
else
    until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -U "$POSTGRES_USER" -c '\q'; do
        >&2 echo "Postgres is unavailable - sleeping"
        sleep 1
    done
    >&2 echo "Postgres is up - executing command"
fi

# Execute the command (Flask application)
exec $cmd

