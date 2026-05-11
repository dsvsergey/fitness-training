import logging
from fastapi import APIRouter, Body, Depends, HTTPException, Path, status
from sqlalchemy.orm import Session
from app.api.v1.dependencies import get_current_user
from app.crud.workout_sessions import (
    create_workout_session,
    delete_workout_session,
    get_trainee_machine_history,
    get_workout_session,
    get_workout_sessions,
    update_workout_session,
)
from app.db.session import get_db

from app.schemas.workout_sessions import WorkoutSessionSchema


router = APIRouter()
logger = logging.getLogger(__name__)


@router.post(
    "/workout-sessions/",
    response_model=WorkoutSessionSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_workout_session_endpoint(
    session: WorkoutSessionSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    workout_session = create_workout_session(db=db, workout_session=session)
    if workout_session is None:
        logger.error(f"Error creating workout session, user: {current_user}")
        raise HTTPException(
            status_code=400,
            detail="Error creating workout session, user: {current_user}",
        )
    logger.info(f"Workout session created successfully, user: {current_user}")
    return workout_session


@router.get("/workout-sessions/", response_model=list[WorkoutSessionSchema])
def read_workout_sessions(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    sessions = get_workout_sessions(db, skip=skip, limit=limit)
    if not sessions:
        logger.error(f"No workout sessions found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Workout session not found")
    return sessions


@router.get("/workout-sessions/{session_id}", response_model=WorkoutSessionSchema)
def read_workout_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    session = get_workout_session(db, workout_session_id=session_id)
    if session is None:
        logger.error(
            f"Workout session with id {session_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout session not found")
    return session


@router.get(
    "/workout-sessions/history/{trainee_id}/{machine_setting_id}/",
    response_model=list[WorkoutSessionSchema],
)
def read_trainee_machine_history(
    trainee_id: int = Path(...),
    machine_setting_id: int = Path(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    sessions = get_trainee_machine_history(
        db=db, trainee_id=trainee_id, machine_setting_id=machine_setting_id
    )
    if not sessions:
        logger.error(f"No workout sessions found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Workout session not found")
    return sessions


@router.put("/workout-sessions/{session_id}", response_model=WorkoutSessionSchema)
def update_workout_session_endpoint(
    session_id: int,
    session: WorkoutSessionSchema = Body(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_session = update_workout_session(
        db=db, workout_session_id=session_id, workout_session=session
    )
    if updated_session is None:
        logger.error(
            f"Workout session with id {session_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout session not found")
    logger.info(
        f"Workout session with id {session_id} updated successfully, user: {current_user}"
    )
    return updated_session


@router.delete("/workout-sessions/{session_id}")
def delete_workout_session_endpoint(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    if not delete_workout_session(db=db, workout_session_id=session_id):
        logger.error(
            f"Workout session with id {session_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout session not found")
    logger.info(
        f"Workout session with id {session_id} deleted successfully, user: {current_user}"
    )
    return {"detail": "Workout session deleted successfully"}
