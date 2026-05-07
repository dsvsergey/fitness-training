from datetime import datetime
from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Boolean
from sqlalchemy.orm import relationship, backref

from app.db.base_class import Base
from app.models.coachs import Coach
from app.models.trainees import Trainee


class Program(Base):
    __tablename__ = "program"
    id = Column(Integer, primary_key=True)
    number = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)
    coach_id = Column(ForeignKey(Coach.id), nullable=False)
    trainee_id = Column(ForeignKey(Trainee.id), nullable=False)
    trainee = relationship("Trainee", back_populates="programs")
    coach = relationship("Coach")
    program_machines = relationship(
        "ProgramMachine",
        backref=backref("program", uselist=False),
        order_by="ProgramMachine.index, ProgramMachine.id",
    )
    is_archive = Column(Boolean, default=False)
    is_delete = Column(Boolean, nullable=False, default=False)
    workout_date = Column(DateTime, nullable=True)
