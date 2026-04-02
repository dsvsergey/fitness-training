from datetime import datetime, timedelta
import logging
from fastapi import APIRouter, Body, status, HTTPException, Depends
from sqlalchemy.orm import Session
from app.api.v1.dependencies import get_current_user
from app.crud.workout_appointment import (
    create_workout_appointment,
    delete_workout_appointment,
    get_all_workout_appointments,
    get_filter_workout_appointments,
    get_workout_appointment,
    get_workout_appointment_stats_by_month_and_coach,
    get_workout_appointments_dates,
    set_workout_completed,
    update_workout_appointment,
)
from app.db.session import get_db

from app.schemas.workout_appointment import (
    AppointmentFilterSchema,
    WorkoutAppointmentResultSchema,
    WorkoutAppointmentListResultSchema,
    WorkoutAppointmentSchema,
    WorkoutAppointmentStatsSchema,
)
from app.models.workout_appointment import WorkoutAppointment

import pprint as pp


router = APIRouter()
logger = logging.getLogger(__name__)


@router.post(
    "/workout-appointments/",
    response_model=WorkoutAppointmentSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_workout_appointment_endpoint(
    appointment: WorkoutAppointmentSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    workout_appointment = create_workout_appointment(db=db, appointment=appointment)
    if workout_appointment is None:
        logger.error(f"Error creating workout appointment, user: {current_user}")
        raise HTTPException(
            status_code=400, detail="Error creating workout appointment"
        )
    logger.info(f"Workout appointment created successfully, user: {current_user}")
    return workout_appointment


@router.get("/workout-appointments/", response_model=WorkoutAppointmentListResultSchema)
def read_all_workout_appointments(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
    filter: AppointmentFilterSchema = Body(...),
):
    try:
        appointments = get_filter_workout_appointments(
            db,
            current_user=current_user,
            skip=skip,
            limit=limit,
            filter=filter,
        )
        logger.info(
            f"Retrieved {len(appointments)} workout appointments for user: {current_user}"
        )

        work_days = get_workout_appointments_dates(
            db,
            current_user=current_user,
            filter=filter,
        )
        logger.info(f"Retrieved work days: {work_days} for user: {current_user}")

        # Convert appointments to result schema
        appointment_results = [
            WorkoutAppointmentResultSchema.model_validate(appointment)
            for appointment in appointments or []
        ]

        result = WorkoutAppointmentListResultSchema(
            appointments=appointment_results, work_days=work_days or []
        )

        pp.pprint(result)

        return WorkoutAppointmentListResultSchema(
            appointments=appointment_results, work_days=work_days or []
        )

    except Exception as e:
        logger.error(
            f"An error occurred while retrieving workout appointments: {str(e)}"
        )
        raise HTTPException(
            status_code=500,
            detail="An error occurred while retrieving workout appointments",
        )


@router.get("/workout-appointments/test/")
def test_local_workout_appointments(
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    """Simple test endpoint to debug local appointments"""
    try:
        # Simple query without any filters
        appointments = db.query(WorkoutAppointment).limit(5).all()
        logger.info(f"Found {len(appointments)} appointments")

        result = []
        for appt in appointments:
            result.append(
                {
                    "id": appt.id,
                    "start_at": str(appt.start_at),
                    "status": str(appt.status),
                    "coach_id": appt.coach_id,
                    "trainee_id": appt.trainee_id,
                }
            )

        return {"appointments": result, "count": len(result)}

    except Exception as e:
        logger.error(f"Test endpoint error: {str(e)}")
        import traceback

        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Test error: {str(e)}")


@router.get(
    "/workout-appointments/{appointment_id}", response_model=WorkoutAppointmentSchema
)
def read_workout_appointment(
    appointment_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    appointment = get_workout_appointment(db, appointment_id=appointment_id)
    if appointment is None:
        logger.error(
            f"Workout appointment with id {appointment_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout appointment not found")
    logger.info(
        f"Workout appointment with id {appointment_id} retrieved successfully, user: {current_user}"
    )
    return appointment


@router.put(
    "/workout-appointments/{appointment_id}", response_model=WorkoutAppointmentSchema
)
def update_workout_appointment_endpoint(
    appointment_id: int,
    appointment: WorkoutAppointmentSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_appointment = update_workout_appointment(
        db=db, appointment_id=appointment_id, appointment=appointment
    )
    if updated_appointment is None:
        logger.error(
            f"Workout appointment with id {appointment_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout appointment not found")
    logger.info(
        f"Workout appointment with id {appointment_id} updated successfully, user: {current_user}"
    )
    return updated_appointment


@router.put(
    "/workout-appointments/{appointment_id}/completed",
    response_model=WorkoutAppointmentSchema,
)
def workout_completed(
    appointment_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_appointment = set_workout_completed(db=db, appointment_id=appointment_id)
    if updated_appointment is None:
        logger.error(
            f"Workout appointment with id {appointment_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout appointment not found")
    logger.info(
        f"Workout appointment with id {appointment_id} updated successfully, user: {current_user}"
    )
    return updated_appointment


@router.delete("/workout-appointments/{appointment_id}")
def delete_workout_appointment_endpoint(
    appointment_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    success = delete_workout_appointment(db=db, appointment_id=appointment_id)
    if not success:
        logger.error(
            f"Workout appointment with id {appointment_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Workout appointment not found")
    logger.info(
        f"Workout appointment with id {appointment_id} deleted successfully, user: {current_user}"
    )
    return {"message": "Workout appointment deleted successfully"}


@router.get(
    "/workout_appointments/stats/", response_model=list[WorkoutAppointmentStatsSchema]
)
def get_workout_appointment_stats(
    coach_id: int, date: datetime, db: Session = Depends(get_db)
):
    start_date = date.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    end_date = start_date + timedelta(days=32)
    end_date = end_date.replace(day=1) - timedelta(days=1)
    end_date = end_date.replace(hour=23, minute=59, second=59, microsecond=999999)

    return get_workout_appointment_stats_by_month_and_coach(
        db=db, coach_id=coach_id, start_date=start_date, end_date=end_date
    )


