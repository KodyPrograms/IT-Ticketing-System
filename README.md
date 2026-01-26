# Ticketing Console

An internal IT ticketing & service request system built with Spring Boot, MySQL, and a lightweight SPA. The focus is on role-aware workflows, auditability, and enterprise-ready reporting. Made as a proof of concept for my work. Feel free to critize it to your hearts desire.

## Live app

This is a local-only demo.

## Running locally

### Things you need

- Java 21
- Maven 3.8+
- Docker

### The easy way

I made an easy local testing script that you can run below that will start both back and front ends.

```bash
git clone https://github.com/KodyPrograms/ticketing.git
cd ticketing
chmod +x start_local.sh
./start_local.sh
```

Starts MySQL in Docker and runs the Spring Boot app on http://localhost:8080.

### The harder way

If you don't like things being easy you can do it this way as well.

```bash
# Terminal 1 - MySQL

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

```bash
# Terminal 2 - Spring Boot
mvn spring-boot:run
```

Open http://localhost:8080

## Demo accounts (local)

All demo users use the same password: `admin123`

- Admin: `admin` / `admin123`
- Engineer: `engineer` / `admin123`
- Requester: `requester` / `admin123`

If you want realistic demo data (profiles, tickets, comments, audit trails), run:

```bash
scripts/seed_test_data.sql
```

## Architecture

```
- Browser (SPA)
- Spring Boot (Controller -> Service -> Repository)
- MySQL (Flyway migrations)
```

- Controllers enforce role rules and expose the API
- Services implement workflow rules + audit logging
- Repositories provide persistence with Spring Data JPA
- Flyway manages schema migrations in `src/main/resources/db/migration`

## Business rules (core)

- Roles: Requester, Engineer, Admin
- Requesters can only close their own tickets
- Engineers can move tickets out of NEW and close tickets
- Audit entries are created for all important changes (status, priority, assignee, comments)

## API docs (OpenAPI / Swagger)

Once running:

- JSON: http://localhost:8080/v3/api-docs
- UI: http://localhost:8080/swagger-ui/index.html

## Auth (JWT)

```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"admin123"}'
```

Use the token:

```bash
curl -H "Authorization: Bearer <token>" http://localhost:8080/api/tickets
```

## Tickets API (examples)

```bash
# List tickets (pagination + filters + search)
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets?page=0&size=20&sort=createdAt,desc&search=printer"

# Update status
curl -X PATCH http://localhost:8080/api/tickets/1/status \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"status":"IN_PROGRESS"}'

# Add comment
curl -X POST http://localhost:8080/api/tickets/1/comments \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"visibility":"PUBLIC","body":"Working on this now."}'
```

## Reports API (examples)

Reports default to the last 30 days unless you pass dates.

```bash
curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets/reports/engineer-summary"

curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets/reports/requester-summary"

curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets/reports/backlog-aging"

curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets/reports/sla-buckets"

curl -H "Authorization: Bearer <token>" \
  "http://localhost:8080/api/tickets/reports/dashboard"
```

## User management (admin)

```bash
curl -X POST http://localhost:8080/api/users \
  -H "Authorization: Bearer <token>" \
  -H 'Content-Type: application/json' \
  -d '{"username":"newuser","password":"changeMe123","role":"ENGINEER","enabled":true,"displayName":"New User","title":"Support","email":"new@company.local"}'

curl -H "Authorization: Bearer <token>" http://localhost:8080/api/users
```

## Notes

- UI is a single-page app served from `src/main/resources/static/`.
- Flyway runs automatically on startup.
- The database schema is fully versioned and repeatable via migrations.

Enjoy!
