# Fitness Training Service

Backend service for managing the gym training process: coach and trainee registration, training programs, machines, workout schedules and sessions, background jobs, and an admin panel.

## Stack

- **FastAPI** + **Pydantic v2** — REST API and validation
- **SQLAlchemy 2.0** + **PostgreSQL 16** — ORM and storage
- **Alembic** — database migrations
- **Redis** + **Celery** (worker + beat) — async and periodic tasks
- **Starlette-Admin** — admin UI at `/admin`
- **python-jose** — JWT authentication
- **fastapi-mail** + **Jinja2** — email delivery (verification, password reset)
- **httpx** + **itsdangerous** — Google OAuth (token exchange, signed `state` for CSRF)
- **Docker Compose** — local service orchestration

## Project Layout

```
app/
├── api/v1/          # Route handlers (thin — delegate to services)
│   └── auth/        # Registration, login, OAuth, password reset
├── services/        # Business logic (coach_service, trainee_service, ...)
├── crud/            # Database operations (one file per model)
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic request/response schemas
├── core/
│   ├── auth.py          # JWT creation/decoding
│   ├── config.py        # Settings (env vars)
│   ├── security.py      # bcrypt password hashing
│   ├── email.py         # Email sending
│   ├── oauth.py         # Google OAuth helpers
│   └── provider.py      # Auth provider for Starlette-Admin
├── templates/       # HTML email templates
└── db/              # Engine, session factory, base class
alembic/             # Migrations
tests/               # Utility scripts for seeding test data
docs/                # Documentation (e.g. Flutter integration guide)
main.py              # FastAPI entry point
celery_worker.py     # Celery configuration
docker-compose.yml
Dockerfile
```

## Quick Start

### With Docker (recommended)

```bash
cp .env_src .env          # fill in required values (see below)
docker compose up --build -d
docker compose logs -f api
```

The API will be available at `http://localhost:8000`, the admin panel at `http://localhost:8000/admin`.

### Without Docker

```bash
pip install -r requirements.txt
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

You'll need a running PostgreSQL and Redis on the addresses configured in `.env`.

## Database Migrations

**Fresh database (no existing data)** — use `create_all` + `stamp` because the legacy migration chain has conflicts:

```bash
docker compose exec api python -c "
from app.models.coachs import Coach
from app.models.machines import Machine
from app.models.program_machines import ProgramMachine
from app.models.programs import Program
from app.models.trainees import Trainee
from app.models.users import User
from app.models.workout_appointment import WorkoutAppointment
from app.models.workout_sessions import WorkoutSession
from app.models.tasks import Task
from app.models.log import Log
from app.db.base_class import Base
from app.db.session import engine
Base.metadata.create_all(bind=engine)
"
docker compose exec api alembic stamp c1d2e3f4a5b6
```

After that, migrations work as usual:

```bash
alembic upgrade head
alembic revision --autogenerate -m "description"
```

## Test Data Scripts

These are utility scripts, **not** a pytest suite:

```bash
python tests/setup_test_environment.py setup      # full test environment
python tests/create_test_coach.py create          # create a test coach
python tests/create_test_trainees.py create 25    # create N trainees
python tests/create_fake_schedule.py generate     # fake appointments
python tests/test_validation.py                   # JWT validation checks
```

## Authentication

The JWT subject encodes role and id: `"coach:10"` or `"trainee:456"`. The `get_current_user` dependency in `app/api/v1/dependencies.py` parses this prefix.

Token types (`type` claim):

| `type`               | Lifetime           | Purpose                                  |
|----------------------|--------------------|-------------------------------------------|
| `access_token`       | 8 days (default)   | API access                                |
| `email_verification` | 48 hours           | Verify email after registration           |
| `pwd_reset_token`    | 24 hours           | Password reset link                       |

### Endpoints (prefixed with `/api/v1/`)

| Method | Path                          | Description                                       |
|--------|-------------------------------|---------------------------------------------------|
| POST   | `/trainees/register/`         | Trainee self-registration, sends verification email |
| GET    | `/trainees/me/`               | Authenticated trainee profile                     |
| POST   | `/coaches/register/`          | Coach registration                                |
| POST   | `/coaches/login/`             | Coach login                                       |
| GET    | `/coaches/me/`                | Authenticated coach profile                       |
| PUT    | `/coaches/me/`                | Update coach profile                              |
| PUT    | `/coaches/me/password/`       | Change coach password                             |
| POST   | `/login/`                     | Universal login (tries coach, then trainee)       |
| GET    | `/verify-email?token=`        | Verify email address                              |
| POST   | `/password-reset/request`     | Send password reset email                         |
| POST   | `/password-reset/confirm`     | Set new password via reset token                  |
| GET    | `/google/authorize?role=`     | Get Google OAuth URL (`role=trainee\|coach`)      |
| GET    | `/google/callback`            | Google OAuth callback                             |

### Google OAuth Flow

1. Client calls `GET /api/v1/google/authorize?role=trainee` and receives `{ "url": "..." }`.
2. Client opens the URL in a browser/WebView.
3. Google redirects to `/api/v1/google/callback?code=...&state=...`.
4. Backend verifies `state` (HMAC via `itsdangerous`), exchanges the code for tokens via `httpx`, and fetches the user profile from Google.
5. Looks up the account by `oauth_id` → by `email` (linking Google to an existing local account) → or creates a new one.
6. Returns a JWT. If `FRONTEND_URL` is set (and not localhost), redirects to `{FRONTEND_URL}/auth/callback?token=...&sub=...`.

Implementation: `app/core/oauth.py`, `app/services/trainee_service.py::get_or_create_from_google`, `app/services/coach_service.py::get_or_create_from_google`.

### OAuth Model Fields

Columns added in migration `c1d2e3f4a5b6` for both `Trainee` and `User` (coach auth table):

```
oauth_provider      String   nullable   — "google" or NULL for local accounts
oauth_id            String   nullable   — Google user ID (sub claim)
email_verified      Boolean  default=False
email_verified_at   DateTime nullable
```

`Trainee.hashed_password` is nullable — Google-only accounts have no password.

## Configuration (.env)

Copy `.env_src` to `.env` and fill in the values:

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/fitness

# JWT
SECRET_KEY=<random>
JWT_SECRET=<random>                     # defaults to SECRET_KEY
ACCESS_TOKEN_EXPIRE_MINUTES=11520       # 8 days
ACCESS_TOKEN_EXPIRE_MINUTES_LONG=43200  # 30 days (remember me)

# Email (Gmail example)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=<app password>
MAIL_FROM=your@gmail.com
SUPPRESS_SENDING_EMAILS=False           # True in dev to skip sending

# Google OAuth (https://console.cloud.google.com/)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/google/callback

# Frontend (used in email links and OAuth redirect)
FRONTEND_URL=http://localhost:3000

# Admin panel (Starlette-Admin)
SECRET=<random>   # session secret AND admin password
                  # Login: admin, password = SECRET value

# Redis / Celery
REDIS_URL=redis://redis:6379/0
```

> The `ADMIN` / `PWR` variables in `.env_src` are legacy and unused.

## Admin Panel

Starlette-Admin is available at `http://localhost:8000/admin`.

- **Username:** `admin`
- **Password:** value of the `SECRET` env variable

Registered models: `Coach`, `Trainee`, `User`, `Machine`, `Program`, `WorkoutAppointment`, `WorkoutSession`, `Task`, `Log`.

The HTTPS redirect middleware is disabled by default. To enable it (e.g. behind nginx with TLS), set `FORCE_HTTPS_ADMIN=true`.

## Deployment

### Deploy Update

```bash
# Sync code from your local machine
rsync -az --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' \
  ./ <user>@<host>:<remote-path>/

# Restart the API on the server
ssh <user>@<host> "docker restart <api-container>"
```

### Google Cloud Console

Add the appropriate callback URLs for each environment to **Authorized redirect URIs** in the OAuth 2.0 Client, for example:

- `http://localhost:8000/api/v1/google/callback` (local development)
- `https://<your-domain>/api/v1/google/callback` (staging/production)

## Flutter Integration

The full mobile-client guide lives in `docs/auth-api-flutter.md`. It covers:

- All auth endpoints with request/response examples
- Google OAuth via WebView
- Deep links for email verification and password reset
- JWT decoding in Dart
- Recommended packages
