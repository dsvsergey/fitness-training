from datetime import datetime
from sqlalchemy import Column, Date, DateTime, Integer, String, Float, Boolean
from sqlalchemy.orm import relationship

from app.db.base_class import Base


class Trainee(Base):
    __tablename__ = "trainee"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String, nullable=True)
    first_name = Column(String)
    last_name = Column(String)
    mobile_phone = Column(String, nullable=True)
    address1 = Column(String, nullable=True)
    address2 = Column(String, nullable=True)
    city = Column(String, nullable=True)
    state = Column(String, nullable=True)
    postal_code = Column(String, nullable=True)
    country = Column(String, nullable=True)
    gender = Column(String, nullable=True)
    notes = Column(String, nullable=True)
    weight = Column(Float, nullable=True)
    height = Column(Float, nullable=True)
    birth_date = Column(Date, nullable=True)

    # OAuth fields
    oauth_provider = Column(String, nullable=True)   # "google" or None for local
    oauth_id = Column(String, nullable=True, index=True)

    # Email verification
    email_verified = Column(Boolean, default=False)
    email_verified_at = Column(DateTime, nullable=True)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    workout_appointments = relationship("WorkoutAppointment", back_populates="trainee")
    programs = relationship("Program", back_populates="trainee")
