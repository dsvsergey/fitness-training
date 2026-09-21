from sqlalchemy import Boolean, Column, Integer, String
from app.db.base_class import Base


class Machine(Base):
    __tablename__ = "machine"
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    index = Column(Integer, nullable=True)
    # Machines referenced by programs cannot be deleted, only hidden from the picker.
    is_hidden = Column(Boolean, nullable=False, default=False, server_default="false")
