from datetime import datetime, timedelta
import logging
from sqlalchemy import and_, func, or_
from sqlalchemy.orm import Session, joinedload

from app.models.workout_appointment import (
    AppointmentStatus,
    WorkoutAppointment,
    convert_to_appointment_status_enum,
)
from app.schemas.workout_appointment import (
    AppointmentFilterSchema,
    WorkoutAppointmentSchema,
    WorkoutAppointmentStatsSchema,
    WorkoutAppointmentResultSchema,
)
from app.models.coachs import Coach


# Statuses that occupy a time slot. Cancelled / NoShow / NoneStatus do not block scheduling.
ACTIVE_STATUSES = (
    AppointmentStatus.Requested,
    AppointmentStatus.Booked,
    AppointmentStatus.Confirmed,
    AppointmentStatus.Arrived,
    AppointmentStatus.Completed,
)


def parse_datetime(date_str: str) -> datetime:
    try:
        return datetime.strptime(date_str, "%Y-%m-%d %H:%M:%S.%f")
    except ValueError:
        return datetime.strptime(date_str + " 00:00:00.000000", "%Y-%m-%d %H:%M:%S.%f")


def find_overlapping_appointment(
    db: Session,
    coach_id: int,
    trainee_id: int,
    start_at: datetime,
    end_at: datetime,
    exclude_id: int | None = None,
) -> WorkoutAppointment | None:
    """Return the first appointment that overlaps the given time range for this coach
    or trainee, excluding the appointment being updated. Two ranges overlap when
    `existing.start < new.end AND existing.end > new.start`."""
    query = db.query(WorkoutAppointment).filter(
        WorkoutAppointment.status.in_(ACTIVE_STATUSES),
        WorkoutAppointment.start_at < end_at,
        WorkoutAppointment.end_at > start_at,
        or_(
            WorkoutAppointment.coach_id == coach_id,
            WorkoutAppointment.trainee_id == trainee_id,
        ),
    )
    if exclude_id is not None:
        query = query.filter(WorkoutAppointment.id != exclude_id)
    return query.first()


def create_workout_appointment(
    db: Session, appointment: WorkoutAppointmentSchema
) -> WorkoutAppointment:
    db_appointment = WorkoutAppointment(
        trainee_id=appointment.trainee_id,
        coach_id=appointment.coach_id,
        duration=appointment.duration,
        status=appointment.status,
        start_at=appointment.start_at,
        end_at=appointment.end_at,
        notes=appointment.notes,
    )
    db.add(db_appointment)
    db.commit()
    db.refresh(db_appointment)
    return db_appointment


def get_workout_appointment(db: Session, appointment_id: int) -> WorkoutAppointment:
    return (
        db.query(WorkoutAppointment)
        .filter(WorkoutAppointment.id == appointment_id)
        .first()
    )


def get_all_workout_appointments(
    db: Session,
    skip: int = 0,
    limit: int = 100,
) -> list[WorkoutAppointment]:
    return db.query(WorkoutAppointment).offset(skip).limit(limit).all()


def get_filter_workout_appointments(
    db: Session,
    current_user: str,
    skip: int = 0,
    limit: int = 100,
    filter: AppointmentFilterSchema = None,
) -> list[WorkoutAppointment]:
    query = db.query(WorkoutAppointment).outerjoin(WorkoutAppointment.coach)

    if filter and filter.start_date:
        start_date = parse_datetime(filter.start_date).replace(
            hour=0, minute=0, second=0, microsecond=0
        )
        end_start_date = start_date + timedelta(days=1)

        query = query.filter(
            and_(
                WorkoutAppointment.start_at >= start_date,
                WorkoutAppointment.start_at < end_start_date,
                WorkoutAppointment.status != AppointmentStatus.NoneStatus,
            )
        )

    if filter and filter.coach_ids:
        query = query.filter(Coach.id.in_(filter.coach_ids))

    results = (
        query.options(joinedload(WorkoutAppointment.coach))
        .order_by(WorkoutAppointment.id)
        .offset(skip)
        # .limit(limit)
        .all()
    )
    return results


def get_workout_appointments_dates(
    db: Session,
    current_user: str,
    filter: AppointmentFilterSchema = None,
) -> list[datetime]:
    if filter and filter.start_date:
        start_date = parse_datetime(filter.start_date)
        start_of_month = start_date.replace(
            day=1, hour=0, minute=0, second=0, microsecond=0
        )
        end_of_month = start_of_month + timedelta(days=45)
        query = (
            db.query(WorkoutAppointment.start_at)
            .join(WorkoutAppointment.coach)
            .filter(
                and_(
                    WorkoutAppointment.start_at >= start_of_month,
                    WorkoutAppointment.start_at <= end_of_month,
                )
            )
        )

        if filter.coach_ids:
            query = query.filter(Coach.id.in_(filter.coach_ids))

        dates = query.all()
        unique_dates = list({d.start_at.date() for d in dates})
        unique_dates.sort()
        return unique_dates

    return []


def update_workout_appointment(
    db: Session,
    appointment_id: int,
    appointment: WorkoutAppointmentSchema,
) -> WorkoutAppointment:
    db_appointment = (
        db.query(WorkoutAppointment)
        .filter(WorkoutAppointment.id == appointment_id)
        .first()
    )
    if db_appointment:
        for var, value in vars(appointment).items():
            if var in ["trainee", "coach"]:
                continue
            setattr(db_appointment, var, value) if value else None
        db.commit()
        db.refresh(db_appointment)
    return db_appointment


def set_workout_completed(db: Session, appointment_id: int) -> WorkoutAppointment:
    db_appointment = (
        db.query(WorkoutAppointment)
        .filter(WorkoutAppointment.id == appointment_id)
        .first()
    )
    if db_appointment:
        db_appointment.status = AppointmentStatus.Completed
        db.commit()
        db.refresh(db_appointment)
    return db_appointment


def delete_workout_appointment(db: Session, appointment_id: int):
    db_appointment = (
        db.query(WorkoutAppointment)
        .filter(WorkoutAppointment.id == appointment_id)
        .first()
    )
    if db_appointment:
        db.delete(db_appointment)
        db.commit()
        return True
    return False


def get_workout_appointment_stats_by_month_and_coach(
    db: Session,
    coach_id: int,
    start_date: datetime,
    end_date: datetime,
) -> list[WorkoutAppointmentStatsSchema]:
    results = (
        db.query(
            func.date(WorkoutAppointment.start_at).label("date"),
            func.count(WorkoutAppointment.id).label("count"),
            WorkoutAppointment.coach_id,
        )
        .filter(
            and_(
                WorkoutAppointment.start_at >= start_date,
                WorkoutAppointment.start_at <= end_date,
                WorkoutAppointment.coach_id == coach_id,
            )
        )
        .group_by(func.date(WorkoutAppointment.start_at), WorkoutAppointment.coach_id)
        .all()
    )

    return [
        WorkoutAppointmentStatsSchema(
            date=result.date, count=result.count, coach_id=result.coach_id
        )
        for result in results
    ]


def get_workout_appointment_results(
    db: Session,
    appointments: list[WorkoutAppointment],
) -> list[WorkoutAppointmentResultSchema]:
    return [WorkoutAppointmentResultSchema.model_validate(obj) for obj in appointments]
