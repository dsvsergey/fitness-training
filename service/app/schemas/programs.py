from pydantic import BaseModel
from datetime import datetime
from typing import Optional

from app.schemas.coachs import CoachSchema
from app.schemas.program_machines import ProgramMachineSchema


class ProgramSchema(BaseModel):
    id: Optional[int] = None
    name: str
    number: int = -1
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    coach_id: int
    coach: CoachSchema
    trainee_id: int
    program_machines: list[ProgramMachineSchema] = []
    is_archive: bool = False
    is_delete: bool = False
    workout_date: Optional[datetime] = None

    class Config:
        from_attributes = True


class ProgramCreateSchema(BaseModel):
    coach_id: int
    trainee_id: int
    machine_ids: list[int]


class ProgramUpdateMachinesSchema(BaseModel):
    id: int
    machine_ids: list[int]


class UpdateArchiveStatusSchema(BaseModel):
    is_archive: bool


class UpdateDeleteStatusSchema(BaseModel):
    is_delete: bool


class UpdateWorkoutDateSchema(BaseModel):
    workout_date: datetime
