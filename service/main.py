import logging
from fastapi import FastAPI, Request
from fastapi.middleware import Middleware
from fastapi.responses import RedirectResponse
from starlette_admin.contrib.sqla import Admin, ModelView
from starlette.middleware.sessions import SessionMiddleware
from starlette.staticfiles import StaticFiles
from starlette.middleware.trustedhost import TrustedHostMiddleware
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.db.session import engine
from app.db.base_class import Base
from app.models.coachs import Coach
from app.models.machines import Machine
from app.models.program_machines import ProgramMachine
from app.models.programs import Program
from app.models.trainees import Trainee
from app.models.users import User
from app.models.workout_appointment import WorkoutAppointment
from app.models.workout_sessions import WorkoutSession
from app.core.provider import MyAuthProvider
from app.models.tasks import Task
from app.models.log import Log
from app.core.database_log_handler import DatabaseLogHandler

# Configure logging
db_handler = DatabaseLogHandler()
db_handler.setLevel(logging.INFO)
db_handler.setFormatter(logging.Formatter("%(asctime)s [%(levelname)s] %(message)s"))

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[db_handler, logging.StreamHandler()],
)

logger = logging.getLogger(__name__)


# Create tables
def create_tables():
    Base.metadata.create_all(bind=engine)


# Include Starlette Admin
def include_starlette(app: FastAPI, engine):
    admin = Admin(
        engine,
        title="Fitness API",
        base_url="/admin",
        auth_provider=MyAuthProvider(),
        middlewares=[Middleware(SessionMiddleware, secret_key=settings.SECRET)],
    )
    admin.add_view(ModelView(Coach))
    admin.add_view(ModelView(Machine))
    admin.add_view(ModelView(ProgramMachine))
    admin.add_view(ModelView(Program))
    admin.add_view(ModelView(Trainee))
    admin.add_view(ModelView(User))
    admin.add_view(ModelView(WorkoutAppointment))
    admin.add_view(ModelView(WorkoutSession))
    admin.add_view(ModelView(Task))
    admin.add_view(ModelView(Log))
    admin.mount_to(app)


# Start FastAPI application
def start_application():
    app = FastAPI(title=settings.PROJECT_TITLE, version=settings.PROJECT_VERSION)

    # Add CORS middleware
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],  # In production, be more specific
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    from app.api.v1.base_router import api_router

    app.include_router(api_router)
    include_starlette(app, engine)

    # Log startup information
    logger.info(f"Starting {settings.PROJECT_TITLE} v{settings.PROJECT_VERSION}")
    logger.info(f"Database URL configured: {bool(settings.DATABASE_URL)}")
    logger.info(
        f"MindBody configured: {bool(settings.MINDBODY_API_KEY and settings.MINDBODY_BASE_URL)}"
    )

    return app


app = start_application()


@app.middleware("http")
async def https_redirect_middleware(request: Request, call_next):
    admin_path = "/admin"
    if request.url.path.startswith(admin_path) and request.url.scheme == "http":
        url = request.url.replace(scheme="https")
        return RedirectResponse(url)
    response = await call_next(request)
    return response


# Add TrustedHostMiddleware
app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=[
        "78.138.17.28",
        "localhost",
        "127.0.0.1",
        "*",
    ],  # Added wildcard and server IP
)


@app.get("/")
async def root():
    logger.info("Fitness API. v.1.0.4")
    return {"message": "Fitness API. v.1.0.4"}


if __name__ == "__main__":
    """for local debugging"""
    import uvicorn

    uvicorn.run(app, host="127.0.0.1", port=8000)
