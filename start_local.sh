#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="ticketing-mysql"
DB_VOLUME="ticketing-mysql-data"
DB_PORT="3306"
DB_IMAGE="mysql:9.5"

DB_ROOT_PASSWORD="rootpass"
DB_NAME="ticketing"
DB_USER="ticketing_user"
DB_PASSWORD="ticketing_pass"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required but not installed or not on PATH." >&2
  exit 1
fi

if docker ps -a --format '{{.Names}}' | grep -qx "${DB_CONTAINER}"; then
  if ! docker ps --format '{{.Names}}' | grep -qx "${DB_CONTAINER}"; then
    echo "Starting existing MySQL container: ${DB_CONTAINER}"
    docker start "${DB_CONTAINER}" >/dev/null
  else
    echo "MySQL container already running: ${DB_CONTAINER}"
  fi
else
  echo "Creating MySQL container: ${DB_CONTAINER}"
  docker volume create "${DB_VOLUME}" >/dev/null
  docker run -d \
    --name "${DB_CONTAINER}" \
    -e MYSQL_ROOT_PASSWORD="${DB_ROOT_PASSWORD}" \
    -e MYSQL_DATABASE="${DB_NAME}" \
    -e MYSQL_USER="${DB_USER}" \
    -e MYSQL_PASSWORD="${DB_PASSWORD}" \
    -p "${DB_PORT}:3306" \
    -v "${DB_VOLUME}:/var/lib/mysql" \
    "${DB_IMAGE}" >/dev/null
fi

echo "Waiting for MySQL to be ready..."
for _ in {1..30}; do
  if docker exec "${DB_CONTAINER}" mysqladmin ping -uroot -p"${DB_ROOT_PASSWORD}" >/dev/null 2>&1; then
    echo "MySQL is up."
    break
  fi
  sleep 2
done

if ! docker exec "${DB_CONTAINER}" mysqladmin ping -uroot -p"${DB_ROOT_PASSWORD}" >/dev/null 2>&1; then
  echo "MySQL did not become ready in time." >&2
  exit 1
fi

echo "Starting Spring Boot app..."
exec mvn spring-boot:run
