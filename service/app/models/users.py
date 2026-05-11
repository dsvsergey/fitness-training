from datetime import datetime
from sqlalchemy import TIMESTAMP, Column, DateTime, ForeignKey, Integer, String, Boolean
from sqlalchemy.orm import relationship

from app.db.base_class import Base
from app.models.coachs import Coach


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    hashed_password = Column(String, nullable=True)
    token = Column(String, nullable=True)
    name = Column(String, nullable=True)
    coach_id = Column(ForeignKey(Coach.id), nullable=True)
    coach = relationship("Coach", back_populates="user")
    last_login = Column(TIMESTAMP)
    is_admin = Column(Boolean, default=False)

    # OAuth fields
    oauth_provider = Column(String, nullable=True)   # "google" or None for local
    oauth_id = Column(String, nullable=True, index=True)

    # Email verification
    email_verified = Column(Boolean, default=False)
    email_verified_at = Column(DateTime, nullable=True)
