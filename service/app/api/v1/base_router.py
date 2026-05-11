from fastapi.routing import APIRouter

from app.api.v1.coachs import coachs
from app.api.v1.machines import machines
from app.api.v1.program_machines import program_machines
from app.api.v1.programs import programs
from app.api.v1.trainees import trainees
from app.api.v1.workout_appointment import workout_appointment
from app.api.v1.workout_sessions import workout_sessions
from app.api.v1.auth import auth
from app.api.v1.service import service


api_router = APIRouter()
URL_PREFIX = "/api/v1"

# Include auth router FIRST to give priority to new endpoints
api_router.include_router(auth.router, prefix=URL_PREFIX, tags=["Auth"])

# Include legacy coachs router with different prefix to avoid conflicts
api_router.include_router(
    coachs.router, prefix=URL_PREFIX + "/legacy", tags=["Legacy Coaches"]
)

api_router.include_router(machines.router, prefix=URL_PREFIX, tags=["Machines"])
api_router.include_router(
    program_machines.router, prefix=URL_PREFIX, tags=["Program Machines"]
)
api_router.include_router(programs.router, prefix=URL_PREFIX, tags=["Programs"])
api_router.include_router(trainees.router, prefix=URL_PREFIX, tags=["Trainees"])
api_router.include_router(
    workout_appointment.router, prefix=URL_PREFIX, tags=["Workout Appointment"]
)
api_router.include_router(
    workout_sessions.router, prefix=URL_PREFIX, tags=["Workout Sessions"]
)
api_router.include_router(
    service.router, prefix=URL_PREFIX + "/service", tags=["Service"]
)
