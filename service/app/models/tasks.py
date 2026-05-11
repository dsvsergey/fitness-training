from sqlalchemy import create_engine, Column, Integer, String, DateTime, Enum, JSON
from sqlalchemy.orm import declarative_base
from sqlalchemy.sql import func
from enum import Enum as PyEnum

from app.db.base_class import Base


class TaskStatus(PyEnum):
    NEW = "new"
    COMPLETED = "completed"
    ERROR = "error"


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True)
    body = Column(JSON, nullable=False)
    status = Column(Enum(TaskStatus), nullable=False, default=TaskStatus.NEW)
    error_description = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )
