from pydantic import BaseModel
from typing import Optional

from app.schemas.machines import MachineSchema
from app.schemas.workout_sessions import WorkoutSessionSchema


class ProgramMachineSchema(BaseModel):
    id: Optional[int] = None
    machine_id: int
    program_id: int
    index: Optional[int] = None
    machine: MachineSchema
    seats: Optional[int] = None
    pin: Optional[int] = None
    back: Optional[int] = None
    handle: Optional[str] = None
    knees: Optional[str] = None
    legs: Optional[str] = None
    for_two_legs: Optional[bool] = False
    chest: Optional[str] = None
    angal: Optional[str] = None
    note: Optional[str] = None
    thighs: Optional[str] = None
    grip: Optional[str] = None
    workouts: list[WorkoutSessionSchema]

    class Config:
        from_attributes = True
