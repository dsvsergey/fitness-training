from pydantic import BaseModel
from datetime import date
from typing import Optional
from enum import Enum


class SessionStatusEnum(str, Enum):
    Planned = "Planned"
    InProgress = "InProgress"
    Completed = "Completed"


class WorkoutSessionSchema(BaseModel):
    id: Optional[int] = None
    program_machine_id: int
    trainee_id: int
    coach_id: int
    date_session: Optional[date] = None
    session_time: Optional[int] = None
    weight: Optional[int] = None
    session_status: SessionStatusEnum = SessionStatusEnum.Planned
    create_at: Optional[date] = None

    class Config:
        from_attributes = True
