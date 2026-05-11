from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field, field_validator, model_validator

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


# Map the API-style status (used by mobile clients, all uppercase) to the DB enum value.
_API_TO_DB_STATUS = {
    "BOOKED": "Booked",
    "COMPLETED": "Completed",
    "CONFIRMED": "Confirmed",
    "ARRIVED": "Arrived",
    "NO_SHOW": "NoShow",
    "CANCELLED": "Cancelled",
    "REQUESTED": "Requested",
    "NONE": "None",
}

# Reverse map: DB enum value → API string returned to clients.
_DB_TO_API_STATUS = {
    "Booked": "BOOKED",
    "Completed": "COMPLETED",
    "Confirmed": "CONFIRMED",
    "Arrived": "ARRIVED",
    "NoShow": "NO_SHOW",
    "Cancelled": "CANCELLED",
    "LateCancelled": "CANCELLED",
    "Requested": "BOOKED",
    "None": "NONE",
    "NoneStatus": "NONE",
}


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
    program_id: Optional[int] = None
    duration: Optional[int] = None
    status: Optional[str] = None
    start_at: Optional[datetime] = None
    end_at: Optional[datetime] = None
    notes: Optional[str] = None

    class Config:
        from_attributes = True

    @model_validator(mode="before")
    @classmethod
    def _flatten_nested(cls, data):
        # Mobile clients post payloads with nested {trainee: {id}, coach: {id},
        # program: {id}} objects. Pull the id out of each so the route handler
        # can rely on the flat *_id fields.
        if not isinstance(data, dict):
            return data
        for src, dst in (
            ("trainee", "trainee_id"),
            ("coach", "coach_id"),
            ("program", "program_id"),
        ):
            if not data.get(dst):
                nested = data.get(src)
                if isinstance(nested, dict) and nested.get("id") is not None:
                    data[dst] = nested["id"]
        return data

    @field_validator("status", mode="before")
    @classmethod
    def _normalize_status(cls, v):
        # Whatever the source — a SQLAlchemy enum value (Booked), an API enum
        # value (BOOKED), or a request string in either case — funnel through
        # to the API-facing form so clients always see uppercase values.
        if v is None:
            return v
        s = v.value if hasattr(v, "value") else str(v)
        if s in _DB_TO_API_STATUS:
            return _DB_TO_API_STATUS[s]
        return s.upper()


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
    program_id: Optional[int] = None
    duration: Optional[int] = None
    start_datetime: datetime = Field(..., alias="start_at")
    end_datetime: datetime = Field(..., alias="end_at")
    status: AppointmentStatusEnum
    notes: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None
    trainee: Optional[Trainee] = None
    coach: Optional[Coach] = None

    model_config = {"from_attributes": True, "populate_by_name": True}

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
