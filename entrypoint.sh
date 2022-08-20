#!/bin/bash
# docker entrypoint script.

# assign a default for the database_user
DB_USER=${DATABASE_USER:-postgres}

# wait until Postgres is ready
while ! pg_isready -q -h $DATABASE_HOST -p 5432 -U $DB_USER
do
  echo "$(date) - waiting for database to start"
  sleep 1
done

# start the elixir ap
echo "Executing Ecto migrations..."
eval "/app/bin/turbo eval \"Turbo.Release.migrate\""

# start the elixir application
echo "Starting Turbo Racer..."

# the `exec` command is special because when used to execute a 
# command like running our service, it will replace the parent process 
# with the new process. 
# Now when Docker sends the SIGTERM signal to the process id,
# our Elixir app will trap the SIGTERM and gracefully shutting down.
exec "/app/bin/server" "start"