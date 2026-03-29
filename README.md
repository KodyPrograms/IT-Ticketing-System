# Ticketing Console

An internal IT ticketing & service request system built with Spring Boot, PostgreSQL, and a lightweight SPA. The focus is on role-aware workflows, auditability, and enterprise-ready reporting. Made as a proof of concept for my work. Feel free to critize it to your hearts desire.

## Live app

This is a local-only demo.

## Deploying on Koyeb

This project can run on Koyeb as a single Spring Boot web service backed by PostgreSQL. The app needs:

- One Koyeb web service for the Spring Boot app
- One reachable PostgreSQL database

The simplest hosted option is Koyeb Database Services, which currently offer managed PostgreSQL.

This repo is configured so Koyeb can inject runtime settings using environment variables.

### 1. Push the repo to GitHub

Koyeb deploys this project cleanly from Git since it is a Maven Spring Boot app.

### 2. Prepare a PostgreSQL database

Create a PostgreSQL database and note:

- Host
- Port
- Database name
- Username
- Password

This app uses Flyway, so the schema migrations in `src/main/resources/db/migration` run automatically at startup.

### 3. Create the Koyeb service

In Koyeb:

1. Click `Create Web Service`
2. Choose `GitHub`
3. Select this repository
4. Let Koyeb detect the app as a Java/Maven service
5. Set the branch you want to deploy

You do not need a custom start command for the standard Java buildpack flow.

### 4. Add environment variables

Set these on the Koyeb service:

```text
SPRING_DATASOURCE_URL=jdbc:postgresql://<host>:<port>/<database>?sslmode=require
SPRING_DATASOURCE_USERNAME=<username>
SPRING_DATASOURCE_PASSWORD=<password>
SECURITY_JWT_SECRET=<long-random-secret>
SECURITY_JWT_ISSUER=ticketing
SECURITY_JWT_EXPIRATION_SECONDS=3600
```

This app also supports Koyeb-style `DATABASE_URL` values like `postgres://user:pass@host:5432/dbname` and will convert them to JDBC at startup if `SPRING_DATASOURCE_URL` is not set.

Notes:

- Koyeb injects `PORT` automatically and the app now binds to it.
- If you are using a local PostgreSQL container, `jdbc:postgresql://localhost:5432/ticketing` is enough.
- Use a strong JWT secret in Koyeb, not the development fallback from `application.properties`.

### 5. Deploy

After the first deploy:

- Koyeb builds the jar with Maven
- Spring Boot starts on the Koyeb-assigned port
- Flyway creates or updates the schema in PostgreSQL

If startup fails, check:

- The JDBC URL format
- Database network access rules
- PostgreSQL user permissions
- Flyway migration errors in the Koyeb logs

### 6. Seed users if needed

Koyeb will run schema migrations automatically, but it will not automatically create demo users unless your database already has them.

If you want hosted demo data, import `scripts/seed_test_data.sql` into the deployed PostgreSQL database after the app is up.

### Koyeb checklist for this repo

- Runtime: Java 21
- Build: Maven
- Web entrypoint: Spring Boot
- Persistent dependency: PostgreSQL database
- Required secrets: datasource credentials and JWT secret

### Optional hardening before sharing the deployment

- Restrict Swagger in production
- Add an admin bootstrap flow instead of relying on seeded users
- Add a production CORS policy if the frontend and API ever split across domains
- Add health/readiness endpoints if you want stricter deployment checks

## Running locally

### Things you need

- Java 21
- Maven 3.8+
- Docker

### The easy way

I made an easy local testing script that you can run below that will start both back and front ends.

```bash
git clone https://github.com/KodyPrograms/IT-Ticketing-System.git
cd IT-Ticketing-System
chmod +x start_local.sh
./start_local.sh
```

Starts PostgreSQL in Docker and runs the Spring Boot app on http://localhost:8080.

`start_local.sh` always uses the local Docker PostgreSQL container. Hosted environments like Koyeb should use service-level environment variables such as `DATABASE_URL` or `SPRING_DATASOURCE_*`.

### The harder way

If you don't like things being easy you can do it this way as well.

```bash
# Terminal 1 - PostgreSQL

docker volume create ticketing-postgres-data

docker run -d \
  --name ticketing-postgres \
  -e POSTGRES_DB=ticketing \
  -e POSTGRES_USER=ticketing_user \
  -e POSTGRES_PASSWORD=ticketing_pass \
  -p 5432:5432 \
  -v ticketing-postgres-data:/var/lib/postgresql/data \
  postgres:17
```

```bash
# Terminal 2 - Spring Boot
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/ticketing \
SPRING_DATASOURCE_USERNAME=ticketing_user \
SPRING_DATASOURCE_PASSWORD=ticketing_pass \
mvn spring-boot:run
```

Open http://localhost:8080

## Demo accounts (local)

The database is automatically populated with demo users and filler ticket data by Flyway on startup.

- Admin: `admin` / `admin123`
- Engineer: `engineer` / `engineer123`
- Requester: `requester` / `requester123`
- Additional demo users such as `liam`, `noah`, `emma`, `carlos`, and `zara` use `admin123`

If you want to reapply the filler dataset manually to an existing database, use [scripts/seed_test_data.sql](/home/mint/Documents/ticketing/scripts/seed_test_data.sql).

## Architecture

```
- Browser (SPA)
- Spring Boot (Controller -> Service -> Repository)
- PostgreSQL (Flyway migrations)
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
