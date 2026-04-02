from sqlalchemy import TIMESTAMP, Column, ForeignKey, Integer, String, Boolean
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
