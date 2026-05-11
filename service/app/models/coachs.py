from datetime import datetime
from sqlalchemy import Column, DateTime, Integer, String
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class Coach(Base):
    __tablename__ = "coach"
    id = Column(Integer, primary_key=True, index=True)
    external_id = Column(String, unique=True, index=True, nullable=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String, unique=True, index=True)
    image_url = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)
    workout_appointments = relationship("WorkoutAppointment", back_populates="coach")
    user = relationship("User", uselist=False, back_populates="coach")
    programs = relationship("Program", back_populates="coach")
    work_phone = Column(String, nullable=True)
    mobile_phone = Column(String, nullable=True)
    note = Column(String(1000), nullable=True)
    address1 = Column(String, nullable=True)
    address2 = Column(String, nullable=True)
    city = Column(String, nullable=True)
    state = Column(String, nullable=True)
    postal_code = Column(String, nullable=True)
    country = Column(String, nullable=True)
    gender = Column(String, nullable=True)
    biography = Column(String, nullable=True)
