# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Running the Application

```bash
# Start all services (recommended)
docker compose up --build -d

# View logs
docker compose logs -f api

# Stop services
docker compose down
```

```bash
# Without Docker
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Database Migrations

Fresh database (no existing data) — use `create_all` + stamp, because the legacy migration chain has conflicts:

```bash
# 1. Create all tables from current models
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
print('done')
"

# 2. Mark all migrations as applied (latest revision)
docker compose exec api alembic stamp c1d2e3f4a5b6

# 3. Future migrations can run normally
alembic upgrade head
```

Existing database with data — run normally:

```bash
alembic upgrade head
```

Create a new migration after model changes:

```bash
alembic revision --autogenerate -m "description"
```

### Test Data Scripts

These are utility scripts, not a pytest suite:

```bash
python tests/setup_test_environment.py setup      # Full test environment
python tests/create_test_coach.py create          # Create a test coach
python tests/create_test_trainees.py create 25    # Create N test trainees
python tests/create_fake_schedule.py generate     # Generate fake appointments
python tests/test_validation.py                   # Run JWT validation tests
```

---

## Architecture

### Stack

- **FastAPI** + **SQLAlchemy 2.0** + **PostgreSQL 16** — core API and persistence
- **Redis** + **Celery** — async task queue and scheduled jobs (beat)
- **Starlette-Admin** — admin panel UI at `/admin`
- **Pydantic v2** — request/response validation
- **python-jose** — JWT auth
- **httpx** — async HTTP client (Google OAuth token exchange)
- **itsdangerous** — signed state parameter for Google OAuth CSRF protection
- **Authlib** — installed, available for future OAuth use
- **Jinja2** — HTML email template rendering

### Layer Structure

```
app/
├── api/v1/          # Route handlers (thin — delegate to services)
│   └── auth/auth.py # All auth + registration endpoints
├── services/        # Business logic (coach_service, trainee_service)
├── crud/            # Database operations (one file per model)
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic schemas (request/response)
├── core/
│   ├── auth.py      # JWT creation/decoding
│   ├── config.py    # Settings (env vars)
│   ├── security.py  # bcrypt password hashing
│   ├── email.py     # Email sending (fastapi-mail + Jinja2)
│   ├── oauth.py     # Google OAuth helpers (NEW)
│   └── provider.py  # Starlette-Admin auth provider
├── templates/       # HTML email templates (NEW)
│   ├── email_verification.html
│   └── password_reset.html
└── db/              # Engine, session factory, base class
```

---

## Authentication & Registration

### JWT Token Format

Subject field encodes role + id: `"coach:10"` or `"trainee:456"`.  
`get_current_user` dependency in `app/api/v1/dependencies.py` parses this prefix.

Token types used in `type` claim:

| `type` | Lifetime | Purpose |
|--------|----------|---------|
| `access_token` | 8 days (default) | API access |
| `email_verification` | 48 hours | Verify email after registration |
| `pwd_reset_token` | 24 hours | Password reset link |

### Auth Endpoints (all at `/api/v1/`)

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/trainees/register/` | Trainee self-registration, sends verification email |
| `GET`  | `/trainees/me/` | Authenticated trainee profile |
| `POST` | `/coaches/register/` | Coach registration |
| `POST` | `/coaches/login/` | Coach login |
| `GET`  | `/coaches/me/` | Authenticated coach profile |
| `PUT`  | `/coaches/me/` | Update coach profile |
| `PUT`  | `/coaches/me/password/` | Change coach password |
| `POST` | `/login/` | Universal login (tries coach then trainee) |
| `GET`  | `/verify-email?token=` | Verify email address |
| `POST` | `/password-reset/request` | Send password reset email |
| `POST` | `/password-reset/confirm` | Set new password via reset token |
| `GET`  | `/google/authorize?role=` | Get Google OAuth URL (`role=trainee\|coach`) |
| `GET`  | `/google/callback` | Google OAuth callback (handles code exchange) |

### Model OAuth & Verification Fields

Both `Trainee` and `User` (coach auth) have these columns added in migration `c1d2e3f4a5b6`:

```
oauth_provider      String  nullable   — "google" or NULL for local accounts
oauth_id            String  nullable   — Google user ID (sub claim)
email_verified      Boolean default=False
email_verified_at   DateTime nullable
```

`Trainee.hashed_password` is nullable — Google-only accounts have no password.

### Google OAuth Flow

1. Client calls `GET /api/v1/google/authorize?role=trainee` → receives `{url: "..."}`.
2. Client opens URL in browser/WebView.
3. Google redirects to `/api/v1/google/callback?code=...&state=...`.
4. Backend verifies `state` (itsdangerous HMAC), exchanges code for tokens via `httpx`, fetches user info from Google.
5. Finds existing account by `oauth_id` → or by `email` (links Google to existing local account) → or creates new account.
6. Returns JWT. If `FRONTEND_URL` is set (and not localhost), redirects to `{FRONTEND_URL}/auth/callback?token=...&sub=...`.

Implementation: `app/core/oauth.py`, `app/services/trainee_service.py::get_or_create_from_google`, `app/services/coach_service.py::get_or_create_from_google`.

---

## Environment Configuration

Copy `.env_src` to `.env`. Key variables:

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/fitness

# JWT
SECRET_KEY=<random secret>
JWT_SECRET=<random secret>            # defaults to SECRET_KEY if not set
ACCESS_TOKEN_EXPIRE_MINUTES=11520     # 8 days
ACCESS_TOKEN_EXPIRE_MINUTES_LONG=43200 # 30 days (remember me)

# Email (Gmail example)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your@gmail.com
MAIL_PASSWORD=<app password>
MAIL_FROM=your@gmail.com
SUPPRESS_SENDING_EMAILS=False         # set True in dev to skip sending

# Google OAuth (register at https://console.cloud.google.com/)
GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/google/callback

# Frontend URL — used in email links and Google OAuth redirect
FRONTEND_URL=http://localhost:3000

# Admin panel (Starlette-Admin)
SECRET=<random string>   # used as admin panel SESSION secret AND admin password
                         # Admin login: username=admin, password=<SECRET value>

# Redis / Celery
REDIS_URL=redis://redis:6379/0
```

---

## Admin Panel

Starlette-Admin at `http://localhost:8000/admin`.

**Credentials** — defined in `app/core/provider.py`:
- **Username:** `admin`
- **Password:** value of `SECRET` env variable

> Do NOT confuse with `ADMIN`/`PWR` env vars — those are unused legacy variables.

The HTTPS redirect middleware is disabled by default. To enable it (e.g. behind nginx with TLS), set `FORCE_HTTPS_ADMIN=true` in `.env`.

All models are registered: Coach, Trainee, User, Machine, Program, WorkoutAppointment, WorkoutSession, Task, Log.

---

## Deployment

### Staging Server

- **Host:** `207.126.161.154`
- **API:** `http://207.126.161.154:8000`
- **Admin:** `http://207.126.161.154:8000/admin`
- **Project path:** `/opt/fitness-training-service/`

### Deploy Update

```bash
# Sync code (run from local machine)
rsync -az --exclude='.git' --exclude='__pycache__' --exclude='*.pyc' --exclude='.env' \
  ./ root@207.126.161.154:/opt/fitness-training-service/

# Restart API on server
ssh root@207.126.161.154 "docker restart fitness_svr"
```

### Google Cloud Console (required for OAuth)

Add both URIs to **Authorized redirect URIs** in the OAuth 2.0 Client:
- `http://localhost:8000/api/v1/google/callback` (local dev)
- `http://207.126.161.154:8000/api/v1/google/callback` (staging)

---

## Flutter Integration

See `docs/auth-api-flutter.md` for the full Flutter developer guide covering:
- All auth endpoints with request/response examples
- Google OAuth WebView flow
- Deep link handling for email verification and password reset
- JWT decoding in Dart
- Recommended packages
