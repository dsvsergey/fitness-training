from sqlalchemy import Column, Integer, String
from app.db.base_class import Base


class Machine(Base):
    __tablename__ = "machine"
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    index = Column(Integer, nullable=True)
