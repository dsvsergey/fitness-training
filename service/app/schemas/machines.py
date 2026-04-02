from pydantic import BaseModel
from typing import Optional


class MachineSchema(BaseModel):
    id: Optional[int] = None
    name: str
    index: Optional[int] = None

    class Config:
        from_attributes = True
