# Hermes Monorepo

Hermes is a Flutter app backed by a FastAPI + worker backend stack.

## Repo Layout

- `hermes_flutter/` — Flutter app for iOS, Android, and web on `http://localhost:8080`
- `services/api/` — FastAPI + SQLAlchemy + Alembic
- `services/worker/` — RQ worker tasks for async lead jobs
- `infra/` — helper scripts
- `docker-compose.yml` — postgres + redis + api + worker

## Prerequisites

- Flutter 3.38+
- Docker + Docker Compose

## 1) Configure Environment

### Flutter (`hermes_flutter` dart defines)

Local development defaults to the FastAPI development actor with `DEV_AUTH_TOKEN=dev-token`.

- `API_URL=http://localhost:8000`
- `WEB_ORIGIN=http://localhost:8080`
- `DEV_AUTH_ENABLED=true`
- `DEV_AUTH_TOKEN=dev-token`
- `CLERK_PUBLISHABLE_KEY=`
- `CLERK_SIGN_IN_URL=`
- `CLERK_SIGN_UP_URL=`

### API (`services/api/.env`)

Copy from `services/api/.env.example` and set external integration keys.

## 2) Start Infrastructure + Backend

From repo root:

```bash
make up
make api-migrate
```

This starts:

- Postgres: `localhost:5432`
- Redis: `localhost:6379`
- API: `localhost:8000`
- Worker queue consumer

Health check:

```bash
curl http://localhost:8000/health
```

## 3) Run Flutter Web

```bash
make flutter-dev
```

## Core Product Behavior

- Pricing plans: Lite ($15), Starter ($25), Pro ($100), Enterprise (sales)
- Monthly limits are based on **verified contacts**, not credits
- A contact counts once per period when email or phone becomes verified
- Quota enforcement blocks additional reveals when cap is reached
- Apollo credits and vendor usage are tracked internally (`vendor_calls`, `vendor_usage`)

## API Overview

Public:

- `POST /public/enterprise-lead`

Auth/context:

- `GET /me`

Lead jobs/results:

- `POST /leads/jobs`
- `GET /leads/jobs`
- `GET /leads/jobs/{id}`
- `POST /leads/jobs/{id}/cancel`
- `GET /leads/jobs/{id}/results`
- `GET /leads/jobs/{id}/export.csv`
- `GET /leads/results`

Recipes:

- `GET /recipes`
- `POST /recipes`
- `PATCH /recipes?recipe_id=...`
- `PATCH /recipes/{id}`
- `POST /recipes/{id}/rerun`

Billing:

- `GET /billing/summary`
- `POST /billing/create-checkout-session`
- `POST /billing/portal-session`
- `POST /billing/webhook`

Profile:

- `GET /profile`
- `PUT /profile`
- `POST /profile/accept-terms`

## Useful Commands

```bash
make up
make down
make api-migrate
make worker
make flutter-dev
make flutter-test
make flutter-build-web
```

## Notes

- In `APP_ENV=development`, API auth allows a fallback dev actor if no bearer token is provided.
- Apollo mapping is isolated in `services/api/app/integrations/apollo_mapping.py` with TODO markers for vendor field verification.
- AI research uses deterministic placeholder output unless a real model integration is added.
