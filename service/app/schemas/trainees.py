from typing import Optional, List
from pydantic import BaseModel, EmailStr
from datetime import datetime

from app.schemas.programs import ProgramSchema


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
    programs: Optional[list[ProgramSchema]] = None


class TraineeCreate(TraineeBase):
    password: str


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
    password: Optional[str] = None


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
    programs: Optional[list[ProgramSchema]] = None

    class Config:
        from_attributes = True


class TraineeOutSchema(BaseModel):
    total_count: int
    trainees: List[TraineeSchema]

    class Config:
        from_attributes = True
