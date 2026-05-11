from datetime import datetime
from sqlalchemy import Column, Date, ForeignKey, Integer, Enum
from sqlalchemy.orm import relationship, backref
import enum

from app.db.base_class import Base
from app.models.coachs import Coach
from app.models.trainees import Trainee
from app.models.program_machines import ProgramMachine


class SessionStatus(enum.Enum):
    Planned = "Planned"
    InProgress = "InProgress"
    Completed = "Completed"


class WorkoutSession(Base):
    __tablename__ = "workout_sessions"
    id = Column(Integer, primary_key=True)
    program_machine_id = Column(ForeignKey(ProgramMachine.id), nullable=False)
    trainee_id = Column(ForeignKey(Trainee.id), nullable=False)
    coach_id = Column(ForeignKey(Coach.id), nullable=False)
    date_session = Column(Date, nullable=True)
    session_time = Column(Integer, nullable=True)
    weight = Column(Integer, nullable=True)
    session_status = Column(Enum(SessionStatus), default=SessionStatus.Planned)
    created_at = Column(Date, default=datetime.utcnow().date)
    program_machine = relationship(
        "ProgramMachine", backref=backref("workout_sessions", overlaps="workouts")
    )
