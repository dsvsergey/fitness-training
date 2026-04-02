from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field, field_validator

from app.schemas.coachs import Coach
from app.schemas.trainees import Trainee


class AppointmentStatusEnum(str, Enum):
    BOOKED = "BOOKED"
    COMPLETED = "COMPLETED"
    CONFIRMED = "CONFIRMED"
    ARRIVED = "ARRIVED"
    NO_SHOW = "NO_SHOW"
    CANCELLED = "CANCELLED"
    NONE = "NONE"


class WorkoutAppointmentBase(BaseModel):
    start_datetime: datetime
    end_datetime: datetime
    status: AppointmentStatusEnum
    notes: Optional[str] = None


class WorkoutAppointmentCreate(WorkoutAppointmentBase):
    coach_id: int
    trainee_id: int


class WorkoutAppointmentUpdate(WorkoutAppointmentBase):
    pass


class WorkoutAppointmentInDBBase(WorkoutAppointmentBase):
    id: int
    coach_id: int
    trainee_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class WorkoutAppointment(WorkoutAppointmentInDBBase):
    coach: Optional[Coach] = None
    trainee: Optional[Trainee] = None


class WorkoutAppointmentInDB(WorkoutAppointmentInDBBase):
    pass


# Additional schemas for compatibility
class WorkoutAppointmentSchema(BaseModel):
    id: Optional[int] = None
    trainee_id: Optional[int] = None
    coach_id: Optional[int] = None
    duration: Optional[int] = None
    status: Optional[str] = None
    start_at: Optional[datetime] = None
    end_at: Optional[datetime] = None
    notes: Optional[str] = None

    class Config:
        from_attributes = True


class WorkoutAppointmentStatsSchema(BaseModel):
    date: datetime
    count: int
    coach_id: int

    class Config:
        from_attributes = True


class WorkoutAppointmentResultSchema(BaseModel):
    id: Optional[int] = None
    trainee_id: Optional[int] = None
    coach_id: Optional[int] = None
    duration: Optional[int] = None
    start_datetime: datetime = Field(..., alias="start_at")
    end_datetime: datetime = Field(..., alias="end_at")
    status: AppointmentStatusEnum
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    trainee: Optional[Trainee] = None
    coach: Optional[Coach] = None

    model_config = {"from_attributes": True}

    @field_validator("status", mode="before")
    @classmethod
    def normalize_status(cls, v):
        if hasattr(v, "value"):  # If it's an enum from SQLAlchemy
            status_value = v.value
        else:
            status_value = str(v)

        # Map status values to AppointmentStatusEnum
        status_mapping = {
            "Completed": "COMPLETED",
            "Booked": "BOOKED",
            "Confirmed": "CONFIRMED",
            "Arrived": "ARRIVED",
            "NoShow": "NO_SHOW",
            "Cancelled": "CANCELLED",
            "None": "NONE",
            "Requested": "BOOKED",  # Map Requested to BOOKED
            "LateCancelled": "CANCELLED",  # Map LateCancelled to CANCELLED
        }

        return status_mapping.get(status_value, status_value.upper())


class WorkoutAppointmentListResultSchema(BaseModel):
    appointments: list[WorkoutAppointmentResultSchema] = []
    work_days: list[datetime] = []

    model_config = {"from_attributes": True}


class AppointmentFilterSchema(BaseModel):
    start_date: Optional[str] = None
    end_date: Optional[str] = None
    coach_ids: Optional[list[int]] = None
