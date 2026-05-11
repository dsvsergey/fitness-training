from sqlalchemy.orm import Session

from app.models.users import User as UserModel
from app.schemas.users import UserDB, UserDBCreate


def get_user(db: Session, user_id: int):
    return db.query(UserModel).filter(UserModel.id == user_id).first()


def get_user_by_username(db: Session, username: str):
    return db.query(UserModel).filter(UserModel.name == username).first()


def create_user(db: Session, user_in: UserDBCreate) -> UserModel:
    user = UserModel(
        hashed_password=user_in.hashed_password,
        name=user_in.username,
        coach_id=user_in.coach_id,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def update_user(db: Session, user: UserModel, user_in: UserDB):
    user_data = user_in.model_dump(exclude_unset=True)
    for key, value in user_data.items():
        setattr(user, key, value)
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def delete_user(db: Session, user_id: int):
    user = get_user(db, user_id)
    db.delete(user)
    db.commit()
    return user


def get_user_by_coach_id(db: Session, coach_id: int) -> UserModel:
    return db.query(UserModel).filter(UserModel.coach_id == coach_id).first()
