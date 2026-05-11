from typing import Optional
from pydantic import BaseModel, EmailStr
from app.schemas.coachs import CoachResponse
from app.schemas.trainees import TraineeResponse


class Token(BaseModel):
    access_token: str
    token_type: str
    coach: Optional[CoachResponse] = None
    trainee: Optional[TraineeResponse] = None


class TokenPayload(BaseModel):
    sub: Optional[str] = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class MobileLoginRequest(BaseModel):
    Username: EmailStr
    Password: str


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordResetConfirm(BaseModel):
    token: str
    new_password: str


class GoogleAuthorizeResponse(BaseModel):
    url: str
