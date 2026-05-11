from pydantic import BaseModel

from app.schemas.coachs import CoachSchema


class UserBase(BaseModel):
    username: str


class UserIn(UserBase):
    password: str


class UserOut(UserBase):
    id: int
    token: str | None
    coach: CoachSchema | None


class UserDB(UserBase):
    id: int | None
    hashed_password: str | None
    token: str | None
    coach_id: int | None
    is_admin: bool | None


class UserDBCreate(UserBase):
    hashed_password: str | None
    coach_id: int | None
