from sqlalchemy.orm import Session

from app.models.coachs import Coach
from app.schemas.coachs import CoachSchema


def get_coach(db: Session, coach_id: int):
    return db.query(Coach).filter(Coach.id == coach_id).first()


def get_coaches(db: Session, skip: int = 0, limit: int = 100):
    return db.query(Coach).order_by(Coach.id).offset(skip).limit(limit).all()


def create_coach(db: Session, coach: CoachSchema, with_commit: bool = True):
    db_coach = Coach(**coach.model_dump())
    db.add(db_coach)
    if with_commit:
        db.commit()
        db.refresh(db_coach)
    return db_coach


def update_coach(
    db: Session, coach_id: int, coach: CoachSchema, with_commit: bool = True
):
    db_coach = db.query(Coach).filter(Coach.id == coach_id).first()
    if not db_coach:
        return None
    update_data = coach.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_coach, key, value)
    if with_commit:
        db.commit()
        db.refresh(db_coach)
    return db_coach


def delete_coach(db: Session, coach_id: int):
    db_coach = db.query(Coach).filter(Coach.id == coach_id).first()
    if db_coach:
        db.delete(db_coach)
        db.commit()
        return True
    return False


def get_coach_by_email(db: Session, email: str):
    return db.query(Coach).filter(Coach.email == email).first()
