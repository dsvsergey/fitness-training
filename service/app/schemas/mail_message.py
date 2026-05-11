from pydantic import BaseModel
from typing import Optional


class MailMessageSchema(BaseModel):
    mail_to: str
    message: str
    subject: str
