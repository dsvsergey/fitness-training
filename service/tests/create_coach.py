import os
import sys

# Add the project root directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.crud.coachs import create_coach
from app.schemas.coachs import CoachCreate
from app.crud.users import get_user_by_username, update_user
from app.schemas.users import UserDB


def create_test_coach():
    db = SessionLocal()
    try:
        # Get the existing user
        user = get_user_by_username(db, "Dmitriy.mironyuk@gmail.com")
        if not user:
            print("User not found")
            return

        # Create coach
        coach_schema = CoachCreate(
            email="Dmitriy.mironyuk@gmail.com",
            first_name="Dmitriy",
            last_name="Mironyuk",
            mobile_phone=None,
            work_phone=None,
            address1=None,
            city=None,
            state=None,
            postal_code=None,
            country=None,
            biography=None,
            image_url=None,
            gender=None,
            note=None,
            address2=None,
        )
        coach = create_coach(db, coach_schema)

        # Link coach to user
        user_update = UserDB(
            id=user.id,
            username=user.name,
            coach_id=coach.id,
            hashed_password=user.hashed_password,
            token=user.token,
            mindbody_token=user.mindbody_token,
            is_admin=user.is_admin,
        )
        update_user(db, user, user_update)

        print(f"Coach created successfully with id: {coach.id}")
    finally:
        db.close()


if __name__ == "__main__":
    create_test_coach()
