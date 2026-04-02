import logging
import os
from fastapi import APIRouter, BackgroundTasks, Body, Depends, HTTPException
from fastapi.responses import FileResponse

from app.api.v1.dependencies import get_current_user
from app.schemas.mail_message import MailMessageSchema
from app.core.email import send_mail


router = APIRouter()
logger = logging.getLogger(__name__)


@router.post("/send-test-mail/")
async def send_test_mail(
    background_tasks: BackgroundTasks,
    mail: MailMessageSchema = Body(...),
    current_user: str = Depends(get_current_user),
):
    background_tasks.add_task(send_mail, **mail.model_dump())
    logger.info(f"Test mail sent, user: {current_user}")
    return {"message": "Test mail sent"}


@router.get("/image/{file_path:path}")
async def get_image(file_path: str):
    if not os.path.exists(file_path):
        logger.error(f"File not found: {file_path}")
        raise HTTPException(status_code=404, detail="File not found")

    logger.info(f"Sending image: {file_path}")
    return FileResponse(file_path)
