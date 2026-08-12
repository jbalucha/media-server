#!/bin/bash
# Creates extra databases/users listed in POSTGRES_MULTIPLE_DATABASES.
# Runs only on first boot (empty data directory).
# NOTE: no `set -x` and no env dumps here - this script handles passwords
# and its output ends up in container logs (visible in Dozzle).
set -e

echo "=== Starting database initialization script ==="

# Create databases and users for each database
for db in $(echo "${POSTGRES_MULTIPLE_DATABASES}" | tr ',' ' '); do
  user_var="POSTGRES_USER_${db^^}"
  pass_var="POSTGRES_PASSWORD_${db^^}"

  # Default to database name as username if not specified
  user="${!user_var:-$db}"
  # Default to POSTGRES_PASSWORD if specific password not set
  pass="${!pass_var:-$POSTGRES_PASSWORD}"

  echo "Creating user and database for $db with user $user"

  # Create user if it doesn't exist
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    DO \$\$
    BEGIN
      IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = '$user') THEN
        CREATE ROLE "$user" WITH LOGIN PASSWORD '$pass';
      ELSE
        ALTER ROLE "$user" WITH PASSWORD '$pass';
      END IF;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Error creating/updating user %: %', '$user', SQLERRM;
    END
    \$\$;

    CREATE DATABASE "$db" WITH OWNER = "$user";

    GRANT ALL PRIVILEGES ON DATABASE "$db" TO "$user";
    GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "$user";
    GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO "$user";
    GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO "$user";

    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO "$user";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO "$user";
    ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO "$user";
EOSQL

  echo "Successfully created database '$db' and user '$user'"
done

echo "PostgreSQL initialization completed successfully!"
