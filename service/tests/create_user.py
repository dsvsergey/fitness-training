from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.crud.users import create_user
from app.schemas.users import UserDBCreate
from app.core.security import get_password_hash


def create_test_user():
    db = SessionLocal()
    try:
        user_in = UserDBCreate(
            username="Dmitriy.mironyuk@gmail.com",
            hashed_password=get_password_hash("Sonik@9751"),
            coach_id=None,  # We can update this later if needed
        )
        user = create_user(db, user_in)
        print(f"User created successfully with id: {user.id}")
    finally:
        db.close()


if __name__ == "__main__":
    create_test_user()
