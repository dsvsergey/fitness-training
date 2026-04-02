from sqlalchemy import and_
from sqlalchemy.orm import Session
from app.models.workout_sessions import WorkoutSession
from app.schemas.workout_sessions import WorkoutSessionSchema


def create_workout_session(
    db: Session, workout_session: WorkoutSessionSchema
) -> WorkoutSession:
    workout_dict = workout_session.model_dump()
    if "create_at" in workout_dict:
        del workout_dict["create_at"]
    db_workout_session = WorkoutSession(**workout_dict)
    db.add(db_workout_session)
    db.commit()
    db.refresh(db_workout_session)
    return db_workout_session


def get_workout_session(db: Session, workout_session_id: int) -> WorkoutSession:
    return (
        db.query(WorkoutSession).filter(WorkoutSession.id == workout_session_id).first()
    )


def get_workout_sessions(
    db: Session, skip: int = 0, limit: int = 100
) -> list[WorkoutSession]:
    return db.query(WorkoutSession).offset(skip).limit(limit).all()


def get_trainee_machine_history(
    db: Session, trainee_id: int, machine_setting_id: int
) -> list[WorkoutSession]:
    return (
        db.query(WorkoutSession)
        .filter(
            and_(
                WorkoutSession.trainee_id == trainee_id,
                WorkoutSession.machine_setting_id == machine_setting_id,
            )
        )
        .order_by(WorkoutSession.id)
        .all()
    )


def update_workout_session(
    db: Session, workout_session_id: int, workout_session: WorkoutSessionSchema
) -> WorkoutSession:
    db_workout_session = (
        db.query(WorkoutSession).filter(WorkoutSession.id == workout_session_id).first()
    )
    if db_workout_session is None:
        return None
    update_data = workout_session.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_workout_session, key, value)
    db.commit()
    db.refresh(db_workout_session)
    return db_workout_session


def delete_workout_session(db: Session, workout_session_id: int):
    db_workout_session = (
        db.query(WorkoutSession).filter(WorkoutSession.id == workout_session_id).first()
    )
    if db_workout_session:
        db.delete(db_workout_session)
        db.commit()
        return True
    return False
