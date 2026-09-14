import logging
from fastapi import APIRouter, status, HTTPException, Depends, File, UploadFile
from sqlalchemy.orm import Session
from typing import List
from app.api.v1.dependencies import get_current_user, get_current_coach
from app.db.session import get_db
from app.schemas.trainees import Trainee as TraineeSchema
from app.schemas.trainees import TraineeCreate, TraineeUpdate, TraineeOutSchema
from app.services.trainee_service import TraineeService
from app.services import avatar_storage
from app.models.users import User
from app.crud.trainees import get_trainees


router = APIRouter()
logger = logging.getLogger(__name__)


def get_trainee_service(db: Session = Depends(get_db)) -> TraineeService:
    return TraineeService(db=db)


@router.get("/trainees/", response_model=TraineeOutSchema)
async def read_trainees(
    skip: int = 0,
    limit: int = 100,
    q: str = None,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_user),
):
    """Get list of trainees with optional search query"""
    trainee_response = get_trainees(db=trainee_service.db, skip=skip, limit=limit, q=q)
    if not trainee_response:
        logger.error(f"No trainees found, user: {current_user}")
        raise HTTPException(status_code=404, detail="No trainees found")
    logger.info(f"Trainees retrieved successfully, user: {current_user}")
    return trainee_response


@router.get("/trainees/{trainee_id}", response_model=TraineeSchema)
async def read_trainee(
    trainee_id: int,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_user),
):
    """Get trainee by ID"""
    trainee = trainee_service.get_trainee(trainee_id=trainee_id)
    if trainee is None:
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")
    logger.info(
        f"Trainee with id {trainee_id} retrieved successfully, user: {current_user}"
    )
    return trainee


@router.post(
    "/trainees/", response_model=TraineeSchema, status_code=status.HTTP_201_CREATED
)
async def create_trainee(
    trainee: TraineeCreate,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_coach),
):
    """Create new trainee"""
    # Check if email already exists
    db_trainee = trainee_service.get_trainee_by_email(email=trainee.email)
    if db_trainee:
        logger.error(f"Email {trainee.email} already registered, user: {current_user}")
        raise HTTPException(status_code=400, detail="Email already registered")

    created_trainee = trainee_service.create_trainee(trainee=trainee)
    logger.info(f"Trainee created successfully, user: {current_user}")
    return created_trainee


@router.put("/trainees/{trainee_id}", response_model=TraineeSchema)
async def update_trainee(
    trainee_id: int,
    trainee: TraineeUpdate,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_coach),
):
    """Update trainee"""
    updated_trainee = trainee_service.update_trainee(
        trainee_id=trainee_id, trainee=trainee
    )
    if updated_trainee is None:
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")
    logger.info(f"Trainee updated successfully, user: {current_user}")
    return updated_trainee


@router.post("/trainees/{trainee_id}/avatar/", response_model=TraineeSchema)
async def upload_trainee_avatar(
    trainee_id: int,
    file: UploadFile = File(...),
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_coach),
):
    """Store an avatar image for a trainee. Coaches manage their clients' photos."""
    trainee = trainee_service.get_trainee(trainee_id=trainee_id)
    if trainee is None:
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")

    previous_url = trainee.photo_url
    try:
        data = await avatar_storage.read_upload(file)
        photo_url = avatar_storage.save_avatar(
            trainee_id, data, prefix=avatar_storage.TRAINEE_PREFIX
        )
    except avatar_storage.AvatarValidationError as exc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc)
        ) from exc

    updated = trainee_service.update_trainee(
        trainee_id=trainee_id, trainee=TraineeUpdate(photo_url=photo_url)
    )
    # Only once the new URL is committed, so a failed write never leaves the
    # trainee with a dangling photo_url.
    avatar_storage.delete_avatar(previous_url)
    logger.info(f"Avatar updated for trainee {trainee_id}, user: {current_user}")
    return updated


@router.delete("/trainees/{trainee_id}/avatar/", response_model=TraineeSchema)
async def delete_trainee_avatar(
    trainee_id: int,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_coach),
):
    """Remove a trainee's avatar."""
    trainee = trainee_service.get_trainee(trainee_id=trainee_id)
    if trainee is None:
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")

    previous_url = trainee.photo_url
    updated = trainee_service.update_trainee(
        trainee_id=trainee_id, trainee=TraineeUpdate(photo_url=None)
    )
    avatar_storage.delete_avatar(previous_url)
    logger.info(f"Avatar removed for trainee {trainee_id}, user: {current_user}")
    return updated


@router.delete("/trainees/{trainee_id}")
async def delete_trainee(
    trainee_id: int,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_coach),
):
    """Delete trainee"""
    if not trainee_service.delete_trainee(trainee_id=trainee_id):
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")
    logger.info(f"Trainee deleted successfully, user: {current_user}")
    return {"detail": "Trainee deleted successfully"}
