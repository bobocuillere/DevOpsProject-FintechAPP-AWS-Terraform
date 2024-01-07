#!/bin/bash

set -e

# Store the first argument in 'host' and then shift arguments to the left.
# 'host' is expected to be the database host. The remaining arguments are the command to start the Flask app.
host="$1"
shift
cmd="$@"

# Check if the app is using AWS RDS. The USE_AWS_RDS environment variable is set in your Kubernetes deployment.
if [ "$USE_AWS_RDS" = "true" ]; then
    # If using AWS RDS, output a message and skip the database waiting logic.
    >&2 echo "Using AWS RDS for PostgreSQL. Skipping wait-for-postgres.sh script."
else
    # If we are testing the app locally with docker-compose, wait for the PostgreSQL database to become ready.
    until PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$host" -U "$POSTGRES_USER" -c '\q'; do
        >&2 echo "Postgres is unavailable - sleeping"
        sleep 1
    done
    # Output a message once the database is ready.
    >&2 echo "Postgres is up and ready"
fi

# Execute the command to start the Flask application.
# This line is crucial as it ensures that your Flask app starts regardless of the USE_AWS_RDS setting.
exec $cmd
