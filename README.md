# Ticketing

Local development setup for the Ticketing Spring Boot app.

## Prerequisites

- Java 21
- Maven 3.8+
- Docker

## Quick start (local MySQL via Docker)

1) Start MySQL

```bash
docker volume create ticketing-mysql-data

docker run -d \
  --name ticketing-mysql \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=ticketing \
  -e MYSQL_USER=ticketing_user \
  -e MYSQL_PASSWORD=ticketing_pass \
  -p 3306:3306 \
  -v ticketing-mysql-data:/var/lib/mysql \
  mysql:9.5
```

2) Configure the app (already set in `src/main/resources/application.properties`)

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/ticketing?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=ticketing_user
spring.datasource.password=ticketing_pass
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
```

If you prefer different credentials, update both the `docker run` values and
`src/main/resources/application.properties` accordingly.

3) Run the app

```bash
mvn spring-boot:run
```

The app starts on http://localhost:8080.

## Default credentials (dev only)

- Requester: `requester` / `requester123`
- Engineer: `engineer` / `engineer123`
- Admin: `admin` / `admin123`

These users are stored in the local database and seeded via migration `V5__create_users.sql`.

## Authentication (JWT)

Login to get a token:

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'
```

Use the returned token for authenticated calls:

```bash
curl -H "Authorization: Bearer <token>" http://localhost:8080/api/tickets
```

Ticket list supports pagination and sorting:

```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets?page=0&size=20&sort=createdAt,desc"
```

## API docs (OpenAPI/Swagger)

Start the app and visit:

- OpenAPI JSON: http://localhost:8080/v3/api-docs
- Swagger UI: http://localhost:8080/swagger-ui/index.html

## User management (admin only)

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"username":"newuser","password":"changeMe123","role":"ENGINEER","enabled":true}'

curl -H "Authorization: Bearer <token>" http://localhost:8080/api/users

curl -X PATCH http://localhost:8080/api/users/1/enabled \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"enabled":false}'

curl -X PATCH http://localhost:8080/api/users/1/password \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"password":"newPass123"}'
```

## Useful Docker commands

- Stop the DB: `docker stop ticketing-mysql`
- Start the DB again: `docker start ticketing-mysql`
- Remove the DB: `docker rm -f ticketing-mysql`
- Remove data volume: `docker volume rm ticketing-mysql-data`

## Notes

- Flyway will create the schema history table on first run.
- You can add migrations under `src/main/resources/db/migration`.
