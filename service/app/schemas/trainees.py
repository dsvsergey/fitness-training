from typing import Optional, List
from pydantic import BaseModel, EmailStr, field_validator
from datetime import date, datetime

from app.schemas.programs import ProgramSchema


def _parse_birth_date(value):
    if value is None or isinstance(value, date):
        return value
    if isinstance(value, datetime):
        return value.date()
    if isinstance(value, str):
        return datetime.fromisoformat(value.replace("Z", "+00:00")).date()
    return value


class TraineeRegister(BaseModel):
    """Minimal schema for self-registration (email + password)."""
    email: EmailStr
    first_name: str
    last_name: str
    password: str


class TraineeBase(BaseModel):
    email: EmailStr
    first_name: str
    last_name: str
    mobile_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    notes: Optional[str] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    birth_date: Optional[date] = None
    programs: Optional[list[ProgramSchema]] = None

    @field_validator("birth_date", mode="before")
    @classmethod
    def _coerce_birth_date(cls, v):
        return _parse_birth_date(v)


class TraineeCreate(TraineeBase):
    # Optional: a coach-created trainee has no login yet. A password is set
    # later via the password-reset flow when dashboard access is granted.
    password: Optional[str] = None


class TraineeUpdate(BaseModel):
    email: Optional[EmailStr] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    mobile_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    notes: Optional[str] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    birth_date: Optional[date] = None
    password: Optional[str] = None

    @field_validator("birth_date", mode="before")
    @classmethod
    def _coerce_birth_date(cls, v):
        return _parse_birth_date(v)


class TraineeInDBBase(TraineeBase):
    id: int
    email_verified: bool = False
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class Trainee(TraineeInDBBase):
    pass


class TraineeResponse(TraineeInDBBase):
    pass


class TraineeInDB(TraineeInDBBase):
    hashed_password: str


# Additional schemas for compatibility
class TraineeSchema(BaseModel):
    id: Optional[int] = None
    email: Optional[EmailStr] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    mobile_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    notes: Optional[str] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    birth_date: Optional[date] = None
    programs: Optional[list[ProgramSchema]] = None

    @field_validator("birth_date", mode="before")
    @classmethod
    def _coerce_birth_date(cls, v):
        return _parse_birth_date(v)

    class Config:
        from_attributes = True


class TraineeOutSchema(BaseModel):
    total_count: int
    trainees: List[TraineeSchema]

    class Config:
        from_attributes = True
