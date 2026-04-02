from typing import Optional
from pydantic import BaseModel, EmailStr
from datetime import datetime


class CoachBase(BaseModel):
    id: Optional[int] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[str] = None
    work_phone: Optional[str] = None
    mobile_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    biography: Optional[str] = None
    image_url: Optional[str] = None
    note: Optional[str] = None


class CoachCreate(BaseModel):
    """Schema for creating a new coach with local authentication"""

    email: EmailStr
    first_name: str
    last_name: str
    mobile_phone: Optional[str] = None
    work_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    biography: Optional[str] = None
    image_url: Optional[str] = None
    note: Optional[str] = None


class CoachCreateWithPassword(CoachCreate):
    """Schema for creating a coach with password"""

    password: str


class CoachUpdate(BaseModel):
    """Schema for updating coach information"""

    first_name: Optional[str] = None
    last_name: Optional[str] = None
    mobile_phone: Optional[str] = None
    work_phone: Optional[str] = None
    address1: Optional[str] = None
    address2: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    country: Optional[str] = None
    gender: Optional[str] = None
    biography: Optional[str] = None
    image_url: Optional[str] = None
    note: Optional[str] = None


class CoachPasswordUpdate(BaseModel):
    """Schema for updating coach password"""

    current_password: str
    new_password: str


class CoachLogin(BaseModel):
    """Schema for coach login"""

    email: EmailStr
    password: str


class CoachResponse(CoachBase):
    """Schema for coach response"""

    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# Legacy schemas for backward compatibility
class CoachSchema(CoachBase):
    name: Optional[str] = None

    class Config:
        from_attributes = True


# Add an alias for backward compatibility
Coach = CoachSchema
