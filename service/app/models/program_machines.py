from sqlalchemy import Column, ForeignKey, Integer, String, Boolean
from sqlalchemy.orm import relationship, backref

from app.db.base_class import Base
from app.models.machines import Machine
from app.models.programs import Program
from app.models.coachs import Coach


class ProgramMachine(Base):
    __tablename__ = "program_machine"
    id = Column(Integer, primary_key=True)
    index = Column(Integer, nullable=True)
    machine_id = Column(ForeignKey(Machine.id), nullable=False)
    program_id = Column(ForeignKey(Program.id), nullable=False)
    machine = relationship("Machine", backref=backref("program_machines", uselist=True))
    seats = Column(Integer, nullable=True)
    pin = Column(Integer, nullable=True)
    back = Column(Integer, nullable=True)
    handle = Column(String(50), nullable=True)
    knees = Column(String(50), nullable=True)
    legs = Column(String(50), nullable=True)
    for_two_legs = Column(Boolean, default=False)
    chest = Column(String(50), nullable=True)
    angal = Column(String(50), nullable=True)
    note = Column(String(1000), nullable=True)
    thighs = Column(String(50), nullable=True)
    grip = Column(String(50), nullable=True)
    workouts = relationship(
        "WorkoutSession", back_populates="program_machine", lazy=True
    )
