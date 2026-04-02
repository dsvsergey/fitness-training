from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.crud.coachs import get_coach_by_email
from app.crud.users import get_user_by_username, update_user
from app.schemas.users import UserDB


def link_coach_to_user():
    db = SessionLocal()
    try:
        # Get the existing user
        user = get_user_by_username(db, "Dmitriy.mironyuk@gmail.com")
        if not user:
            print("User not found")
            return

        # Get existing coach
        coach = get_coach_by_email(db, "Dmitriy.mironyuk@gmail.com")
        if not coach:
            print("Coach not found")
            return

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

        print(f"Coach {coach.id} linked to user {user.id}")
    finally:
        db.close()


if __name__ == "__main__":
    link_coach_to_user()
