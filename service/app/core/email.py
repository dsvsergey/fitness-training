import logging
from fastapi_mail import FastMail, MessageSchema

from app.core.config import settings


logger = logging.getLogger(__name__)


async def send_mail(mail_to: str, message: str, subject: str):
    message = MessageSchema(
        subject="Your Task Completed",
        recipients=[mail_to],
        body=message,
        subtype="html",
    )
    fm = FastMail(settings.email_conf)
    await fm.send_message(message)
    logger.info(f"Sending mail to {mail_to} with subject {subject}")
    logger.info(f"Message: {message}")
