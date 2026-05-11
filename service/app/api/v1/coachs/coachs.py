import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.api.v1.dependencies import get_current_user
from app.db.session import get_db
from app.schemas.coachs import Coach as CoachSchema
from app.services.coach_service import CoachService


router = APIRouter()
logger = logging.getLogger(__name__)


def get_coach_service(db: Session = Depends(get_db)) -> CoachService:
    return CoachService(db=db)


@router.get("/coaches/", response_model=List[CoachSchema])
async def read_coaches(
    skip: int = 0,
    limit: int = 100,
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Get list of coaches"""
    coaches = coach_service.get_coaches(skip=skip, limit=limit)
    if not coaches:
        logger.error(f"No coaches found, user: {current_user}")
        raise HTTPException(status_code=404, detail="No coaches found")
    logger.info(f"Coaches retrieved successfully, user: {current_user}")
    return coaches


@router.get("/coaches/{coach_id}", response_model=CoachSchema)
async def read_coach(
    coach_id: int,
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Get coach by ID"""
    coach = coach_service.get_coach(coach_id=coach_id)
    if coach is None:
        logger.error(f"Coach with id {coach_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Coach not found")
    logger.info(
        f"Coach with id {coach_id} retrieved successfully, user: {current_user}"
    )
    return coach


@router.post(
    "/coaches/", response_model=CoachSchema, status_code=status.HTTP_201_CREATED
)
async def create_coach(
    coach: CoachSchema,
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Create new coach (legacy endpoint - requires manual password setting)"""
    # Note: This legacy endpoint cannot set passwords
    # Use /api/v1/coaches/register/ for full coach creation with password
    logger.warning(f"Legacy coach creation endpoint used, user: {current_user}")
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Legacy coach creation is deprecated. Use /api/v1/coaches/register/ with password instead.",
    )


@router.put("/coaches/{coach_id}", response_model=CoachSchema)
async def update_coach(
    coach_id: int,
    coach_update_data: CoachSchema,
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Update coach"""
    # Convert legacy schema to new update schema
    from app.schemas.coachs import CoachUpdate

    # Map the fields from CoachSchema to CoachUpdate
    update_dict = {}
    for field in CoachUpdate.__fields__.keys():
        if hasattr(coach_update_data, field):
            value = getattr(coach_update_data, field)
            if value is not None:
                update_dict[field] = value

    coach_update = CoachUpdate(**update_dict)
    updated_coach = coach_service.update_coach(
        coach_id=coach_id, coach_data=coach_update
    )

    if updated_coach is None:
        logger.error(f"Coach with id {coach_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Coach not found")

    logger.info(f"Coach updated successfully, user: {current_user}")
    return updated_coach


@router.delete("/coaches/{coach_id}")
async def delete_coach(
    coach_id: int,
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Delete coach"""
    if not coach_service.delete_coach(coach_id=coach_id):
        logger.error(f"Coach with id {coach_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Coach not found")
    logger.info(f"Coach deleted successfully, user: {current_user}")
    return {"detail": "Coach deleted successfully"}


@router.post("/coaches/sync")
async def sync_coaches(
    coach_service: CoachService = Depends(get_coach_service),
    current_user: str = Depends(get_current_user),
):
    """Sync coaches with external service (deprecated)"""
    logger.warning(
        f"Coach sync endpoint called but no longer supported, user: {current_user}"
    )
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Coach sync with external services is no longer supported. Coaches are now managed locally.",
    )
