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

```bash
# Run migrations
alembic upgrade head

# Create a new migration
alembic revision --autogenerate -m "description"

# Create tables directly (without Alembic)
docker compose exec api python -c "from app.models import *; from app.db.base_class import Base; from app.db.session import engine; Base.metadata.create_all(bind=engine)"
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

## Architecture

### Stack

- **FastAPI** + **SQLAlchemy 2.0** + **PostgreSQL** — core API and persistence
- **Redis** + **Celery** — async task queue and scheduled jobs (beat)
- **Starlette-Admin** — admin panel UI at `/admin`
- **Pydantic v2** — request/response validation
- **python-jose** — JWT auth
- **httpx** — async HTTP client for external integrations

### Layer Structure

```
app/
├── api/v1/          # Route handlers (thin — delegate to services/crud)
├── services/        # Business logic layer (coach_service, trainee_service)
├── crud/            # Database operations (one file per model)
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic schemas (request/response)
├── core/            # Auth, config, security, email, integrations
│   └── integrations/  # MindBody API client & local service abstraction
└── db/              # Engine, session factory, base class
```

### API Structure

All routes are prefixed `/api/v1/`. Routes are aggregated in `app/api/v1/base_router.py`.

Legacy endpoints live under `/api/v1/legacy/` to avoid route conflicts with current endpoints.

### Authentication

JWT tokens contain a user type prefix in the subject: `"coach:10"` or `"trainee:456"`. The `get_current_user` dependency in `app/core/auth.py` parses this prefix to determine the user type. Coaches and Trainees are separate models with separate `User` credential records.

### MindBody Integration

`app/core/integrations/` has an abstract interface (`interfaces/`) with two implementations: `MindBodyService` and `LocalService`. The Celery beat schedule (in `celery_worker.py`) is currently **commented out** — MindBody sync tasks are disabled. To re-enable, uncomment the `beat_schedule` config and provide MindBody credentials in `.env`.

### Environment Configuration

Copy `.env_src` to `.env`. Key variables:

- `DATABASE_URL` or individual `DB_HOST/PORT/NAME/USERNAME/PASSWORD`
- `JWT_SECRET` / `SECRET_KEY` — for token signing
- `REDIS_URL` — Celery broker
- `ADMIN` / `PWR` — admin panel credentials
- `MINDBODY_BASE_URL`, `MINDBODY_API_KEY`, `MINDBODY_SITE_ID` — optional integration
- `SUPPRESS_SENDING_EMAILS` — set to disable email in dev

### Admin Panel

Starlette-Admin at `http://localhost:8000/admin`. Auth is handled by `app/core/provider.py`. All models are registered including Coach, Trainee, Machine, Program, WorkoutAppointment, WorkoutSession, Task, and Log.
