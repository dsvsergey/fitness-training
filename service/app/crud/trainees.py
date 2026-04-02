from sqlalchemy import or_, and_
from sqlalchemy.orm import Session

from app.models.trainees import Trainee
from app.schemas.trainees import TraineeOutSchema, TraineeSchema


def create_trainee(
    db: Session, trainee: TraineeSchema, with_commit: bool = True
) -> Trainee:
    trainee_data = trainee.model_dump()
    db_trainee = Trainee(**trainee_data)
    db.add(db_trainee)
    if with_commit:
        db.commit()
        db.refresh(db_trainee)
    return db_trainee


def get_trainee(db: Session, trainee_id: int) -> Trainee:
    return db.query(Trainee).filter(Trainee.id == trainee_id).first()


def get_trainees(
    db: Session, skip: int = 0, limit: int = 100, q: str = None
) -> TraineeOutSchema:
    query = db.query(Trainee)

    if q:
        search_terms = q.split()
        conditions = []
        for term in search_terms:
            term_filter = or_(
                Trainee.first_name.ilike(f"%{term}%"),
                Trainee.last_name.ilike(f"%{term}%"),
                Trainee.email.ilike(f"%{term}%"),
            )
            conditions.append(term_filter)
        query = query.filter(and_(*conditions))

    total_count = query.count()
    trainees = query.order_by(Trainee.id).offset(skip).limit(limit).all()
    trainee_schemas = [
        TraineeSchema.model_validate(trainee, from_attributes=True)
        for trainee in trainees
    ]
    return TraineeOutSchema(total_count=total_count, trainees=trainee_schemas)


def update_trainee(
    db: Session, trainee_id: int, trainee_data: TraineeSchema, with_commit: bool = True
) -> Trainee:
    db_trainee = db.query(Trainee).filter(Trainee.id == trainee_id).first()
    if db_trainee is None:
        return None
    update_data = trainee_data.model_dump(exclude_unset=True)
    for key, value in update_data.items():
        if key == "programs" or key == "id" or key == "workout_appointments":
            continue
        setattr(db_trainee, key, value)
    if with_commit:
        db.commit()
        db.refresh(db_trainee)
    return db_trainee


def delete_trainee(db: Session, trainee_id: int):
    db_trainee = db.query(Trainee).filter(Trainee.id == trainee_id).first()
    if db_trainee:
        db.delete(db_trainee)
        db.commit()
        return True
    return False


