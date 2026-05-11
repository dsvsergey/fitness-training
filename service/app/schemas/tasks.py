from pydantic import BaseModel, Field
from typing import Optional, Dict, Any
from datetime import datetime
from enum import Enum as PyEnum


class TaskStatus(PyEnum):
    NEW = "new"
    COMPLETED = "completed"
    ERROR = "error"


class TaskBase(BaseModel):
    body: Dict[str, Any]
    status: TaskStatus = Field(default=TaskStatus.NEW)
    error_description: Optional[str] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(TaskBase):
    pass


class TaskInDBBase(TaskBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class Task(TaskInDBBase):
    pass


class TaskInDB(TaskInDBBase):
    pass
