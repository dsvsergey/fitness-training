from sqlalchemy import Column, Integer, String, DateTime, Text, func
from app.db.base_class import Base


class Log(Base):
    __tablename__ = "logs"

    id = Column(Integer, primary_key=True, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    level = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    logger_name = Column(String, nullable=False)
