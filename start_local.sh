#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="ticketing-postgres"
DB_VOLUME="ticketing-postgres-data"
DB_PORT="5432"
DB_IMAGE="postgres:17"
APP_PORT="${APP_PORT:-8080}"

DB_NAME="ticketing"
DB_USER="ticketing_user"
DB_PASSWORD="ticketing_pass"

if command -v lsof >/dev/null 2>&1 && lsof -iTCP:"${APP_PORT}" -sTCP:LISTEN -n -P >/dev/null 2>&1; then
  echo "Port ${APP_PORT} is already in use. The app may already be running on http://localhost:${APP_PORT}." >&2
  echo "Stop the existing process or run with APP_PORT=<port> ./start_local.sh" >&2
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but not installed or not on PATH." >&2
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "${DB_CONTAINER}"; then
  if ! docker ps --format '{{.Names}}' | grep -qx "${DB_CONTAINER}"; then
    echo "Starting existing PostgreSQL container: ${DB_CONTAINER}"
    docker start "${DB_CONTAINER}" >/dev/null
  else
    echo "PostgreSQL container already running: ${DB_CONTAINER}"
  fi
else
  echo "Creating PostgreSQL container: ${DB_CONTAINER}"
  docker volume create "${DB_VOLUME}" >/dev/null
  docker run -d \
    --name "${DB_CONTAINER}" \
    -e POSTGRES_DB="${DB_NAME}" \
    -e POSTGRES_USER="${DB_USER}" \
    -e POSTGRES_PASSWORD="${DB_PASSWORD}" \
    -p "${DB_PORT}:5432" \
    -v "${DB_VOLUME}:/var/lib/postgresql/data" \
    "${DB_IMAGE}" >/dev/null
fi

echo "Waiting for PostgreSQL to be ready..."
for _ in {1..30}; do
  if docker exec "${DB_CONTAINER}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
    echo "PostgreSQL is up."
    break
  fi
  sleep 2
done

if ! docker exec "${DB_CONTAINER}" pg_isready -U "${DB_USER}" -d "${DB_NAME}" >/dev/null 2>&1; then
  echo "PostgreSQL did not become ready in time." >&2
  exit 1
fi

echo "Starting Spring Boot app..."
exec env \
  PORT="${APP_PORT}" \
  SPRING_DATASOURCE_URL="jdbc:postgresql://localhost:${DB_PORT}/${DB_NAME}" \
  SPRING_DATASOURCE_USERNAME="${DB_USER}" \
  SPRING_DATASOURCE_PASSWORD="${DB_PASSWORD}" \
  mvn spring-boot:run
