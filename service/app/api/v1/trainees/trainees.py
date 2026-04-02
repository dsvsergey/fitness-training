import logging
from fastapi import APIRouter, status, HTTPException, Depends
from sqlalchemy.orm import Session
from typing import List
from app.api.v1.dependencies import get_current_user
from app.db.session import get_db
from app.schemas.trainees import Trainee as TraineeSchema
from app.schemas.trainees import TraineeCreate, TraineeUpdate, TraineeOutSchema
from app.services.trainee_service import TraineeService
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
    current_user: str = Depends(get_current_user),
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
    current_user: str = Depends(get_current_user),
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


@router.delete("/trainees/{trainee_id}")
async def delete_trainee(
    trainee_id: int,
    trainee_service: TraineeService = Depends(get_trainee_service),
    current_user: str = Depends(get_current_user),
):
    """Delete trainee"""
    if not trainee_service.delete_trainee(trainee_id=trainee_id):
        logger.error(f"Trainee with id {trainee_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Trainee not found")
    logger.info(f"Trainee deleted successfully, user: {current_user}")
    return {"detail": "Trainee deleted successfully"}
