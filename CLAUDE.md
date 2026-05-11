# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

This is a monorepo containing two subprojects that together form one product. Each subproject has its own toolchain — there is no shared package manager.

| Path | Role | Stack |
|---|---|---|
| `app/` | Mobile/web client used by coaches and trainees | Flutter, BLoC, AutoRoute, built_value, GetIt + injectable |
| `service/` | Backend API + admin panel | FastAPI, SQLAlchemy 2.0, PostgreSQL 16, Redis + Celery, Starlette-Admin |

**Each subproject has its own `CLAUDE.md`** — read it before working in that subtree. The per-project files cover commands (build/run/test/migrations), layering rules, code generation, and stack-specific conventions. Do not duplicate that material here.

History note: `app/` and `service/` were merged from two previously-separate repositories (`fitnes-app` and `fitnes-service`) in May 2026. Full history of both is preserved under their respective subdirectories.

## How the two projects relate

- The Flutter app talks to the FastAPI service over HTTPS with JWT auth. JWT subjects encode role + id as `"coach:{id}"` or `"trainee:{id}"` — both sides parse this prefix, so changes to the format must land in both subprojects.
- The app additionally calls a third-party **Mindbody** API directly; that traffic does not go through the backend.
- Auth/registration flows (email verification, password reset, Google OAuth) are documented from the Flutter side in `service/docs/auth-api-flutter.md`. When touching auth, check that doc and update both subprojects.
- Shared staging server: `207.126.161.154` (API on `:8000`, admin at `/admin`). Google OAuth redirect URIs must include both localhost and the staging host — see `service/CLAUDE.md` for the deployment recipe.

## Cross-cutting guidance

- When a change touches the API contract (routes, request/response shape, JWT claims, OAuth flow), update **both** subprojects in lockstep — the Dart models in `app/lib/data/` and the Pydantic schemas in `service/app/schemas/` must stay aligned.
- `cd` into the relevant subproject before running its commands; tooling (Flutter, Alembic, Docker Compose) expects to run from the subproject root, not from this monorepo root.
