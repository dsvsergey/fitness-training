import logging
from pathlib import Path

from fastapi_mail import FastMail, MessageSchema
from jinja2 import Environment, FileSystemLoader

from app.core.config import settings

logger = logging.getLogger(__name__)

_templates_dir = Path(__file__).parent.parent / "templates"
_jinja_env = Environment(loader=FileSystemLoader(str(_templates_dir)), autoescape=True)


def _render(template_name: str, context: dict) -> str:
    return _jinja_env.get_template(template_name).render(**context)


async def send_mail(mail_to: str, body: str, subject: str) -> None:
    """Send an HTML email. Respects SUPPRESS_SENDING_EMAILS setting."""
    if settings.SUPPRESS_SENDING_EMAILS:
        logger.info(f"[SUPPRESSED] Email to {mail_to!r} — subject: {subject!r}")
        return

    message = MessageSchema(
        subject=subject,
        recipients=[mail_to],
        body=body,
        subtype="html",
    )
    fm = FastMail(settings.email_conf)
    await fm.send_message(message)
    logger.info(f"Email sent to {mail_to!r} — subject: {subject!r}")


async def send_verification_email(mail_to: str, name: str, token: str) -> None:
    """Send email address verification link."""
    verify_url = f"{settings.FRONTEND_URL}/verify-email?token={token}"
    body = _render("email_verification.html", {"name": name, "verify_url": verify_url})
    await send_mail(mail_to, body, "Verify your email address")


async def send_password_reset_email(mail_to: str, name: str, token: str) -> None:
    """Send password reset link."""
    reset_url = f"{settings.FRONTEND_URL}/reset-password?token={token}"
    body = _render("password_reset.html", {"name": name, "reset_url": reset_url})
    await send_mail(mail_to, body, "Reset your password")
