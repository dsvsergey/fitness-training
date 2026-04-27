# Fitness Training Service

Backend API for managing the full gym training lifecycle — coach and trainee accounts, training programs with per-machine settings, workout scheduling, and session execution tracking.

## Overview

Gyms typically operate on a stack of disconnected tools: spreadsheets for programs, calendars for bookings, paper notes for machine settings (seat height, pin, grip). This service consolidates that workflow into a single API used by a Flutter mobile client and an internal admin panel.

It handles three concerns end-to-end:

- **Identity** — coach and trainee accounts with email/password, Google OAuth, email verification, and password reset. JWT subjects encode the role (`coach:{id}` / `trainee:{id}`) so every authenticated request is role-scoped at the dependency layer.
- **Programs** — a coach assigns a `Program` to a trainee, attaches `Machine`s, and configures per-machine parameters (seats, pin, back, handle, knees, legs, chest, angle, thighs, grip, free-text notes) via `ProgramMachine`. Old programs are archived rather than deleted.
- **Sessions** — `WorkoutAppointment`s are scheduled with a status machine (`Requested → Booked → Arrived → Completed`, plus `NoShow`, `Cancelled`, `LateCancelled`). `WorkoutSession`s record the actual execution: weight used, time spent, status, and a history feed per `(trainee, machine_setting)` pair.

## Key Features

- Two-role identity model (Coach, Trainee) with a single JWT format and role-aware dependency injection
- Email + password registration with token-based email verification (48h TTL) and password reset (24h TTL)
- Google OAuth 2.0 with HMAC-signed `state` (CSRF), account linking by `email`, and JWT issuance on callback
- Training programs with per-machine configuration and archive flag (soft-delete via `is_archive` / `is_delete`)
- Appointment scheduling with explicit status enum and date-range filtering
- Workout history per trainee and machine setting, queryable as a time-series feed
- Database-backed application logging via a custom `logging.Handler` writing to a `Log` table
- Starlette-Admin UI for back-office data management at `/admin`
- Async email delivery via FastAPI `BackgroundTasks` and Celery worker (Redis broker) for longer jobs
- Alembic migrations with a documented bootstrap path for fresh databases

## Architecture

```
                +------------------+
                |  Flutter client  |
                +---------+--------+
                          |
                          v  HTTPS / JWT
                +---------+--------+        +------------------+
                |  FastAPI (API)   | <----> |   Starlette Admin |
                |  app/api/v1/*    |        |     /admin        |
                +---------+--------+        +------------------+
                          |
                          v
                +---------+--------+
                |    Services      |  business logic, orchestration
                |  app/services/*  |
                +---------+--------+
                          |
                +---------+--------+
                |      CRUD        |  SQLAlchemy queries
                |  app/crud/*      |
                +---------+--------+
                          |
                          v
                +---------+--------+        +------------------+
                |  PostgreSQL 16   |        |     Redis        |
                +------------------+        +---------+--------+
                                                      |
                                                      v
                                            +---------+--------+
                                            |  Celery worker   |
                                            |  (background)    |
                                            +------------------+

External: Google OAuth (httpx), SMTP (fastapi-mail)
```

**Layering rules**

- Routers in `app/api/v1/*` are thin: parse request, call a service, return a response schema. No SQL, no business rules.
- Services in `app/services/*` own business logic (authentication, OAuth account linking, password reset state machine, program archival).
- CRUD modules in `app/crud/*` are the only layer that touches the SQLAlchemy session. One file per model.
- `app/core/*` holds cross-cutting concerns: JWT, password hashing, OAuth client, email rendering, settings.

## Tech Stack

| Concern              | Choice                                     |
|----------------------|--------------------------------------------|
| API framework        | FastAPI + Pydantic v2                      |
| ORM / DB             | SQLAlchemy 2.0 + PostgreSQL 16             |
| Migrations           | Alembic                                    |
| Async / scheduled    | Celery + Redis                             |
| Auth                 | python-jose (JWT, HS256), bcrypt           |
| OAuth                | httpx + itsdangerous (signed `state`)      |
| Email                | fastapi-mail + Jinja2 templates            |
| Admin panel          | Starlette-Admin                            |
| Container runtime    | Docker Compose                             |

## API Examples

All endpoints are prefixed with `/api/v1/`. Authenticated requests require `Authorization: Bearer <jwt>`.

### Coach registration

```http
POST /api/v1/coaches/register/
Content-Type: application/json

{
  "email": "coach@example.com",
  "first_name": "Jane",
  "last_name": "Smith",
  "password": "S3cure-Pass!",
  "mobile_phone": "+1-555-0100",
  "biography": "Certified S&C coach, 10 years"
}
```

```json
HTTP/1.1 201 Created
{
  "id": 12,
  "email": "coach@example.com",
  "first_name": "Jane",
  "last_name": "Smith",
  "mobile_phone": "+1-555-0100",
  "biography": "Certified S&C coach, 10 years",
  "created_at": "2026-04-27T10:14:32",
  "updated_at": "2026-04-27T10:14:32"
}
```

### Login (universal, tries coach then trainee)

```http
POST /api/v1/login/
Content-Type: application/json

{ "email": "coach@example.com", "password": "S3cure-Pass!" }
```

```json
HTTP/1.1 200 OK
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer",
  "coach": { "id": 12, "email": "coach@example.com", "first_name": "Jane", "last_name": "Smith" }
}
```

The JWT payload looks like:

```json
{ "sub": "coach:12", "type": "access_token", "exp": 1745844872 }
```

### Create a workout appointment (coach only)

```http
POST /api/v1/workout-appointments/
Authorization: Bearer <coach jwt>
Content-Type: application/json

{
  "trainee_id": 5,
  "coach_id": 12,
  "duration": 60,
  "status": "BOOKED",
  "start_at": "2026-04-28T10:00:00",
  "end_at":   "2026-04-28T11:00:00",
  "notes": "Chest & shoulders"
}
```

```json
HTTP/1.1 201 Created
{
  "id": 4321,
  "trainee_id": 5,
  "coach_id": 12,
  "duration": 60,
  "status": "BOOKED",
  "start_at": "2026-04-28T10:00:00",
  "end_at":   "2026-04-28T11:00:00",
  "notes": "Chest & shoulders"
}
```

### List appointments in a date range

```http
GET /api/v1/workout-appointments/?start_date=2026-04-27&end_date=2026-05-04&coach_ids=12
Authorization: Bearer <coach jwt>
```

```json
{
  "appointments": [ { "id": 4321, "trainee_id": 5, "status": "BOOKED", "...": "..." } ],
  "work_days":   [ "2026-04-28", "2026-04-30", "2026-05-02" ]
}
```

### Create a program with machines

```http
POST /api/v1/programs/create-with-machines/
Authorization: Bearer <coach jwt>
Content-Type: application/json

{
  "number": 1,
  "name": "Full Body Strength",
  "coach_id": 12,
  "trainee_id": 5,
  "machines": [
    { "machine_id": 10, "index": 1, "seats": 3, "pin": 80, "handle": "neutral", "note": "Keep back flat" },
    { "machine_id": 14, "index": 2, "seats": 2, "pin": 60, "grip": "wide" }
  ]
}
```

### Google OAuth (mobile WebView flow)

```http
GET /api/v1/google/authorize?role=trainee
```

```json
{ "url": "https://accounts.google.com/o/oauth2/v2/auth?..." }
```

The client opens that URL; Google redirects to `/api/v1/google/callback?code=...&state=...`, the backend issues a JWT, and either returns it as JSON or 302s to `${FRONTEND_URL}/auth/callback?token=...&sub=...` when `FRONTEND_URL` is configured for a non-localhost host.

A complete endpoint reference, including all auth, programs, machines, sessions, and admin routes, is generated automatically at `/docs` (Swagger UI) and `/redoc`.

## How It Works

### Email + password registration

1. Client calls `POST /api/v1/coaches/register/` with email, password, profile fields.
2. `coach_service.create_coach` hashes the password (bcrypt), creates the `Coach` and `User` rows in one transaction, and emits an `email_verification` JWT (TTL 48h).
3. The JWT is rendered into a Jinja2 template and dispatched via `fastapi-mail` on a `BackgroundTasks` queue — the request returns 201 without waiting for SMTP.
4. The verification link points to `GET /api/v1/verify-email?token=...`. The handler decodes the token, sets `email_verified=True` and `email_verified_at=now()`, and returns success.

### Google OAuth

1. `GET /google/authorize?role=trainee|coach` returns an authorize URL with a `state` parameter signed by `itsdangerous` (the requested role is encoded into `state`, not user-controllable).
2. Google redirects the user to `/google/callback?code=&state=`. The handler verifies `state`, exchanges the `code` for tokens via `httpx`, and fetches the user profile (`sub`, `email`, `name`).
3. Account resolution: lookup by `(oauth_provider="google", oauth_id=sub)` → fall back to lookup by `email` (linking Google to a pre-existing local account) → otherwise create a new account with `email_verified=True` and `hashed_password=NULL`.
4. Issue an `access_token` JWT and either return JSON or redirect to the frontend.

### Authenticated request → role check

```
Bearer <jwt>
   │
   ▼
oauth2_scheme  →  get_current_user           (decodes jwt, returns "coach:12" or "trainee:5")
                       │
                       ├──► get_current_coach  (asserts subject startswith "coach:", else 403)
                       │
                       └──► route handler       (delegates to service with role-scoped id)
```

### Workout history feed

`GET /api/v1/workout-sessions/history/{trainee_id}/{machine_setting_id}/` returns the trainee's chronological sessions for a single `ProgramMachine` row — used by the mobile app to show "last time you were on this machine: 80kg, 14 reps, 3 sets."

## Engineering Focus

**Validation.** Every request body is a Pydantic v2 model — invalid payloads never reach a service. Enum-valued fields (`WorkoutAppointment.status`, `WorkoutSession.session_status`) are validated on the way in and normalized on the way out. A `field_validator(mode="before")` on `WorkoutAppointmentResultSchema.normalize_status` maps SQLAlchemy enum values (`"Completed"`) to the API enum casing (`"COMPLETED"`) so the wire format stays stable even if the DB representation drifts.

**Error handling.** Errors surface as `HTTPException` with intent-matched status codes — `400` for validation/duplicates, `401` for invalid/expired tokens, `403` for role-scoped denials (a trainee JWT calling a coach-only endpoint), `404` for missing entities, `501`/`502`/`503` for explicitly unimplemented or unavailable upstream paths (legacy `/legacy/coaches/sync` is `501 Not Implemented` rather than silently broken).

**Authentication design.**
- A single JWT format across both roles (`sub = "coach:12"` / `sub = "trainee:5"`) means one decoder, one dependency tree, one place to revoke.
- Token type is in the `type` claim — `access_token`, `email_verification`, `pwd_reset_token` — so a verification token cannot be reused as an access token.
- Password reset endpoints return the same response whether the email exists or not, to avoid account enumeration.
- OAuth `state` is HMAC-signed via `itsdangerous`, not stored server-side, so the OAuth flow stays stateless and horizontally scalable.

**Reliability.**
- Email delivery runs on `BackgroundTasks`; SMTP latency or failure cannot block a registration response.
- A custom `DatabaseLogHandler` mirrors `INFO+` log records into a `Log` table, giving a queryable audit trail that survives container restarts.
- The `Task` table tracks long-running async jobs with `status` (`new` / `completed` / `error`) and a JSON `body`, so a Celery failure leaves a durable record instead of vanishing into worker logs.
- `SUPPRESS_SENDING_EMAILS=True` short-circuits SMTP in dev/CI without code changes.

**Scalability.**
- Stateless API — JWT-only auth, no server-side session store for API requests (Starlette session is admin-panel only).
- Redis-backed Celery for fan-out of slow work; `result_expires=3600` keeps the result store bounded.
- All long lookups are paginated (`skip` / `limit`) and history queries are indexed on `(trainee_id, program_machine_id, date_session)`.
- Soft-delete (`is_archive`, `is_delete` on `Program`) avoids row removal on tables referenced by foreign keys, keeping historical sessions intact.

**Configuration.** All secrets and per-environment URLs come from `.env` via Pydantic settings (`app/core/config.py`). No hardcoded credentials, hosts, or API keys in code.

## Project Structure

```
app/
├── api/v1/
│   ├── auth/                 # registration, login, OAuth, password reset, email verification
│   ├── coachs/               # legacy coach CRUD
│   ├── trainees/             # trainee CRUD (coach-gated)
│   ├── programs/             # programs + program-with-machines composite create
│   ├── machines/             # machine master data
│   ├── program_machines/     # per-program machine configuration
│   ├── workout_appointment/  # scheduling + range filtering + monthly stats
│   ├── workout_sessions/     # session execution + history feed
│   ├── service/              # admin/utility endpoints
│   └── dependencies.py       # get_current_user / get_current_coach (role gate)
├── services/                 # business logic, one module per aggregate
├── crud/                     # SQLAlchemy queries, one module per model
├── models/                   # SQLAlchemy ORM models
├── schemas/                  # Pydantic request/response models
├── core/
│   ├── auth.py               # JWT encode/decode
│   ├── config.py             # Pydantic settings
│   ├── security.py           # bcrypt
│   ├── email.py              # fastapi-mail + Jinja2 dispatch
│   ├── oauth.py              # Google OAuth client
│   ├── provider.py           # Starlette-Admin auth provider
│   └── database_log_handler.py  # logging.Handler → Log table
├── templates/                # email_verification.html, password_reset.html
└── db/                       # engine, session factory, declarative base

alembic/                      # migrations
tests/                        # data-seeding scripts (not a pytest suite)
docs/auth-api-flutter.md      # mobile client integration guide
main.py                       # FastAPI app + admin mount + middleware
celery_worker.py              # Celery app
docker-compose.yml
Dockerfile
```

## Setup

### Prerequisites

- Docker + Docker Compose, or local Python 3.11+, PostgreSQL 16, and Redis
- Google OAuth 2.0 client (for OAuth login) — register at [Google Cloud Console](https://console.cloud.google.com/)
- SMTP credentials (for email verification and password reset)

### Run with Docker

```bash
cp .env_src .env       # fill in the required values
docker compose up --build -d
docker compose logs -f api
```

- API: `http://localhost:8000`
- OpenAPI docs: `http://localhost:8000/docs`
- Admin panel: `http://localhost:8000/admin` (user `admin`, password = `SECRET` env var)

### Run without Docker

```bash
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
celery -A celery_worker.celery_app worker --loglevel=info
```

### Environment variables

```bash
DATABASE_URL=postgresql://postgres:postgres@db:5432/fitness

SECRET_KEY=<random>
JWT_SECRET=<random>                      # falls back to SECRET_KEY
ACCESS_TOKEN_EXPIRE_MINUTES=11520        # 8 days
ACCESS_TOKEN_EXPIRE_MINUTES_LONG=43200   # 30 days (remember-me)

MAIL_SERVER=smtp.example.com
MAIL_PORT=587
MAIL_USERNAME=...
MAIL_PASSWORD=...
MAIL_FROM=no-reply@example.com
SUPPRESS_SENDING_EMAILS=False            # True in dev to skip SMTP

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/google/callback

FRONTEND_URL=http://localhost:3000
SECRET=<random>                          # admin session secret + admin password
REDIS_URL=redis://redis:6379/0
```

### Migrations

For an existing database:

```bash
alembic upgrade head
alembic revision --autogenerate -m "describe change"
```

For a fresh database the legacy migration chain has conflicts; bootstrap with `Base.metadata.create_all` and stamp to the latest revision instead:

```bash
docker compose exec api python -c "
from app.db.base_class import Base
from app.db.session import engine
import app.models  # noqa: F401  ensure all models are registered
Base.metadata.create_all(bind=engine)
"
docker compose exec api alembic stamp c1d2e3f4a5b6
```

### Test data

Utility scripts (not a pytest suite):

```bash
python tests/setup_test_environment.py setup      # full test environment
python tests/create_test_coach.py create
python tests/create_test_trainees.py create 25
python tests/create_fake_schedule.py generate
python tests/test_validation.py                   # JWT validation checks
```

## Future Improvements

- **Pytest suite.** The `tests/` directory currently holds seeding scripts, not assertions. Add `pytest` + `pytest-asyncio` + `httpx.AsyncClient` integration tests against a disposable Postgres, with the auth/OAuth/program flows as the first targets.
- **Migration chain consolidation.** Squash the divergent legacy revisions into a single baseline so fresh databases can run `alembic upgrade head` without the `create_all` + `stamp` workaround.
- **CORS hardening.** `allow_origins=["*"]` in `main.py` is permissive for development convenience; production should read an allowlist from `BACKEND_CORS_ORIGINS`.
- **Rate limiting.** Login, password-reset request, and OAuth callback endpoints are unthrottled. Add a Redis-backed limiter (e.g. `slowapi`) keyed on IP + email.
- **Refresh tokens.** Access tokens are 8 days by default with no refresh endpoint. Splitting into short-lived access (~15m) + refresh tokens with rotation would reduce the impact of leaked tokens.
- **Appointment status state machine.** Status transitions (`Booked → Arrived → Completed`) are currently free-form. Enforcing valid transitions in the service layer would prevent inconsistent histories.
- **Celery beat.** No periodic schedule is currently defined. Recurring jobs (reminder emails the day before an appointment, no-show auto-marking) would be a natural next step.
- **Structured logging.** The `DatabaseLogHandler` writes free-text `message` fields. Switching to JSON-structured logs with explicit `request_id`, `user_id`, `endpoint` fields would make the `Log` table queryable for incident review.
- **Observability.** Add Prometheus metrics middleware and OpenTelemetry tracing on the FastAPI → service → CRUD path to make latency regressions visible.

## Mobile Integration

The Flutter client integration guide — endpoint contracts, OAuth via WebView, deep-link handling for verification and reset, JWT decoding in Dart — lives in [`docs/auth-api-flutter.md`](docs/auth-api-flutter.md).
