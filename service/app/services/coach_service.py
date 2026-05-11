import logging
from datetime import datetime
from typing import List, Optional

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import create_pwd_reset_token, jwt_decode
from app.core.email import send_password_reset_email
from app.core.security import get_password_hash, verify_password
from app.crud.users import create_user
from app.models.coachs import Coach
from app.models.users import User
from app.schemas.coachs import CoachCreate, CoachUpdate
from app.schemas.users import UserDBCreate

logger = logging.getLogger(__name__)


class CoachService:
    def __init__(self, db: Session):
        self.db = db

    def get_coach(self, coach_id: int) -> Optional[Coach]:
        """Get coach by ID"""
        return self.db.query(Coach).filter(Coach.id == coach_id).first()

    def get_coach_by_email(self, email: str) -> Optional[Coach]:
        """Get coach by email"""
        return self.db.query(Coach).filter(Coach.email == email).first()

    def get_coaches(self, skip: int = 0, limit: int = 100) -> List[Coach]:
        """Get list of coaches"""
        return self.db.query(Coach).offset(skip).limit(limit).all()

    def create_coach(self, coach_data: CoachCreate, password: str) -> Coach:
        """Create new coach with local authentication"""
        # Check if coach with this email already exists
        existing_coach = self.get_coach_by_email(coach_data.email)
        if existing_coach:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Coach with this email already exists",
            )

        # Create coach
        db_coach = Coach(
            email=coach_data.email,
            first_name=coach_data.first_name,
            last_name=coach_data.last_name,
            mobile_phone=coach_data.mobile_phone,
            work_phone=coach_data.work_phone,
            address1=coach_data.address1,
            address2=coach_data.address2,
            city=coach_data.city,
            state=coach_data.state,
            postal_code=coach_data.postal_code,
            country=coach_data.country,
            gender=coach_data.gender,
            biography=coach_data.biography,
            image_url=coach_data.image_url,
            note=coach_data.note,
        )
        self.db.add(db_coach)
        self.db.commit()
        self.db.refresh(db_coach)

        # Create user for authentication
        user_data = UserDBCreate(
            coach_id=db_coach.id,
            username=coach_data.email,
            hashed_password=get_password_hash(password),
        )
        user = create_user(self.db, user_data)

        return db_coach

    def authenticate_coach(self, email: str, password: str) -> Optional[Coach]:
        """Authenticate coach using local credentials"""
        coach = self.get_coach_by_email(email)
        if not coach:
            return None

        # Check if coach has a user account
        if not coach.user:
            return None

        # Verify password
        if not verify_password(password, coach.user.hashed_password):
            return None

        return coach

    def update_coach(self, coach_id: int, coach_data: CoachUpdate) -> Optional[Coach]:
        """Update coach"""
        db_coach = self.get_coach(coach_id)
        if not db_coach:
            return None

        update_data = coach_data.dict(exclude_unset=True)

        for field, value in update_data.items():
            setattr(db_coach, field, value)

        self.db.commit()
        self.db.refresh(db_coach)
        return db_coach

    def update_coach_password(self, coach_id: int, new_password: str) -> bool:
        """Update coach password"""
        db_coach = self.get_coach(coach_id)
        if not db_coach or not db_coach.user:
            return False

        db_coach.user.hashed_password = get_password_hash(new_password)
        self.db.commit()
        return True

    def delete_coach(self, coach_id: int) -> bool:
        """Delete coach and associated user"""
        db_coach = self.get_coach(coach_id)
        if not db_coach:
            return False

        # Delete associated user first
        if db_coach.user:
            self.db.delete(db_coach.user)

        # Delete coach
        self.db.delete(db_coach)
        self.db.commit()
        return True

    def activate_coach(self, coach_id: int) -> bool:
        """Activate coach account"""
        db_coach = self.get_coach(coach_id)
        if not db_coach or not db_coach.user:
            return False

        # Add activation logic here if needed
        # For now, just ensure user exists
        return True

    def deactivate_coach(self, coach_id: int) -> bool:
        """Deactivate coach account"""
        db_coach = self.get_coach(coach_id)
        if not db_coach or not db_coach.user:
            return False

        # Add deactivation logic here if needed
        # Could set a flag or remove user
        return True

    # ------------------------------------------------------------------
    # Password reset
    # ------------------------------------------------------------------

    async def request_password_reset(self, email: str) -> None:
        """Send password reset email. Silent on unknown email (prevents enumeration)."""
        coach = self.get_coach_by_email(email)
        if not coach:
            return

        token = create_pwd_reset_token(sub=f"coach:{coach.id}")
        try:
            await send_password_reset_email(
                mail_to=coach.email,
                name=coach.first_name,
                token=token,
            )
        except Exception:
            logger.exception("Failed to send reset email to %s", coach.email)

    def reset_password(self, token: str, new_password: str) -> Coach:
        """Reset coach password using the token from the reset email."""
        try:
            payload = jwt_decode(token)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired reset token.",
            )

        if payload.get("type") != "pwd_reset_token":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid token type.",
            )

        sub: str = payload.get("sub", "")
        if not sub.startswith("coach:"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token is not for a coach account.",
            )

        coach_id = int(sub.split(":")[1])
        coach = self.get_coach(coach_id)
        if not coach or not coach.user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Coach not found.")

        coach.user.hashed_password = get_password_hash(new_password)
        self.db.commit()
        return coach

    # ------------------------------------------------------------------
    # Google OAuth
    # ------------------------------------------------------------------

    def get_or_create_from_google(self, google_user: dict) -> Coach:
        """Find an existing coach by Google ID or email, or create a new one."""
        google_id: str = google_user["sub"]
        email: str = google_user["email"]

        # 1. Match by existing google oauth_id on the User record
        user = (
            self.db.query(User)
            .filter(User.oauth_provider == "google", User.oauth_id == google_id)
            .first()
        )
        if user and user.coach:
            return user.coach

        # 2. Match by email
        coach = self.get_coach_by_email(email)
        if coach:
            if coach.user:
                coach.user.oauth_provider = "google"
                coach.user.oauth_id = google_id
                if not coach.user.email_verified:
                    coach.user.email_verified = True
                    coach.user.email_verified_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(coach)
            return coach

        # 3. Create new coach + user
        db_coach = Coach(
            email=email,
            first_name=google_user.get("given_name", ""),
            last_name=google_user.get("family_name", ""),
            image_url=google_user.get("picture"),
        )
        self.db.add(db_coach)
        self.db.commit()
        self.db.refresh(db_coach)

        user_data = UserDBCreate(
            coach_id=db_coach.id,
            username=email,
            hashed_password=None,
        )
        user = create_user(self.db, user_data)
        user.oauth_provider = "google"
        user.oauth_id = google_id
        user.email_verified = True
        user.email_verified_at = datetime.utcnow()
        self.db.commit()

        return db_coach
