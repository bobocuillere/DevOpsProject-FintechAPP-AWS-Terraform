#!/bin/bash

# This script waits for the PostgreSQL database to become available before executing a command.
# It takes the host as the first argument and the command to execute as the remaining arguments.

set -e

host="$1"
shift
cmd="$@"

until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
    >&2 echo "Postgres is unavailable - sleeping"
    sleep 1
done


>&2 echo "Postgres is up - The web server is starting"
exec $cmd
