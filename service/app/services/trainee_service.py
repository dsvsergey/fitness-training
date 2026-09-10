import logging
from datetime import datetime
from typing import List, Optional

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.auth import (
    create_email_verification_token,
    create_pwd_reset_token,
    jwt_decode,
)
from app.core.email import send_password_reset_email, send_verification_email
from app.core.security import get_password_hash, verify_password
from app.models.trainees import Trainee
from app.schemas.trainees import TraineeCreate, TraineeRegister, TraineeUpdate

logger = logging.getLogger(__name__)


class TraineeService:
    def __init__(self, db: Session):
        self.db = db

    # ------------------------------------------------------------------
    # Basic CRUD
    # ------------------------------------------------------------------

    def get_trainee(self, trainee_id: int) -> Optional[Trainee]:
        return self.db.query(Trainee).filter(Trainee.id == trainee_id).first()

    def get_trainee_by_email(self, email: str) -> Optional[Trainee]:
        return self.db.query(Trainee).filter(Trainee.email == email).first()

    def get_trainees(self, skip: int = 0, limit: int = 100) -> List[Trainee]:
        return self.db.query(Trainee).offset(skip).limit(limit).all()

    def create_trainee(self, trainee: TraineeCreate) -> Trainee:
        """Create trainee directly (admin use, email marked verified)."""
        db_trainee = Trainee(
            email=trainee.email,
            hashed_password=(
                get_password_hash(trainee.password) if trainee.password else None
            ),
            first_name=trainee.first_name,
            last_name=trainee.last_name,
            mobile_phone=trainee.mobile_phone,
            address1=trainee.address1,
            address2=trainee.address2,
            city=trainee.city,
            state=trainee.state,
            postal_code=trainee.postal_code,
            country=trainee.country,
            gender=trainee.gender,
            notes=trainee.notes,
            weight=trainee.weight,
            height=trainee.height,
            email_verified=True,
        )
        self.db.add(db_trainee)
        self.db.commit()
        self.db.refresh(db_trainee)
        return db_trainee

    def update_trainee(self, trainee_id: int, trainee: TraineeUpdate) -> Optional[Trainee]:
        db_trainee = self.get_trainee(trainee_id)
        if not db_trainee:
            return None

        update_data = trainee.dict(exclude_unset=True)
        if "password" in update_data:
            update_data["hashed_password"] = get_password_hash(update_data.pop("password"))

        for field, value in update_data.items():
            setattr(db_trainee, field, value)

        self.db.commit()
        self.db.refresh(db_trainee)
        return db_trainee

    def delete_trainee(self, trainee_id: int) -> bool:
        db_trainee = self.get_trainee(trainee_id)
        if not db_trainee:
            return False
        self.db.delete(db_trainee)
        self.db.commit()
        return True

    def authenticate(self, email: str, password: str) -> Optional[Trainee]:
        trainee = self.get_trainee_by_email(email)
        if not trainee:
            return None
        if not trainee.hashed_password:
            return None  # OAuth-only account — no password set
        if not verify_password(password, trainee.hashed_password):
            return None
        return trainee

    # ------------------------------------------------------------------
    # Registration with email verification
    # ------------------------------------------------------------------

    async def register_trainee(self, data: TraineeRegister) -> Trainee:
        """Create a new trainee and send a verification email."""
        if self.get_trainee_by_email(data.email):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email already exists.",
            )

        trainee = Trainee(
            email=data.email,
            hashed_password=get_password_hash(data.password),
            first_name=data.first_name,
            last_name=data.last_name,
            email_verified=False,
        )
        self.db.add(trainee)
        self.db.commit()
        self.db.refresh(trainee)

        token = create_email_verification_token(sub=f"trainee:{trainee.id}")
        try:
            await send_verification_email(
                mail_to=trainee.email,
                name=trainee.first_name,
                token=token,
            )
        except Exception:
            logger.exception("Failed to send verification email to %s", trainee.email)

        return trainee

    def verify_email(self, token: str) -> Trainee:
        """Verify trainee email with the token from the verification link."""
        try:
            payload = jwt_decode(token)
        except Exception:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid or expired verification token.",
            )

        if payload.get("type") != "email_verification":
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid token type.",
            )

        sub: str = payload.get("sub", "")
        if not sub.startswith("trainee:"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token is not for a trainee account.",
            )

        trainee_id = int(sub.split(":")[1])
        trainee = self.get_trainee(trainee_id)
        if not trainee:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainee not found.")

        if trainee.email_verified:
            return trainee  # already verified — idempotent

        trainee.email_verified = True
        trainee.email_verified_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(trainee)
        return trainee

    # ------------------------------------------------------------------
    # Password reset
    # ------------------------------------------------------------------

    async def request_password_reset(self, email: str) -> None:
        """Send password reset email. Silent on unknown email (prevents enumeration)."""
        trainee = self.get_trainee_by_email(email)
        if not trainee:
            return

        token = create_pwd_reset_token(sub=f"trainee:{trainee.id}")
        try:
            await send_password_reset_email(
                mail_to=trainee.email,
                name=trainee.first_name,
                token=token,
            )
        except Exception:
            logger.exception("Failed to send reset email to %s", trainee.email)

    def reset_password(self, token: str, new_password: str) -> Trainee:
        """Reset trainee password using the token from the reset email."""
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
        if not sub.startswith("trainee:"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Token is not for a trainee account.",
            )

        trainee_id = int(sub.split(":")[1])
        trainee = self.get_trainee(trainee_id)
        if not trainee:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainee not found.")

        trainee.hashed_password = get_password_hash(new_password)
        self.db.commit()
        self.db.refresh(trainee)
        return trainee

    # ------------------------------------------------------------------
    # Google OAuth
    # ------------------------------------------------------------------

    def get_or_create_from_google(self, google_user: dict) -> Trainee:
        """Find an existing trainee by Google ID or email, or create a new one."""
        google_id: str = google_user["sub"]
        email: str = google_user["email"]

        # 1. Match by existing google oauth_id
        trainee = (
            self.db.query(Trainee)
            .filter(Trainee.oauth_provider == "google", Trainee.oauth_id == google_id)
            .first()
        )
        if trainee:
            return trainee

        # 2. Match by email (user previously registered with email/password)
        trainee = self.get_trainee_by_email(email)
        if trainee:
            # Link Google account to existing record
            trainee.oauth_provider = "google"
            trainee.oauth_id = google_id
            if not trainee.email_verified:
                trainee.email_verified = True
                trainee.email_verified_at = datetime.utcnow()
            self.db.commit()
            self.db.refresh(trainee)
            return trainee

        # 3. Create new trainee
        trainee = Trainee(
            email=email,
            first_name=google_user.get("given_name", ""),
            last_name=google_user.get("family_name", ""),
            oauth_provider="google",
            oauth_id=google_id,
            email_verified=True,
            email_verified_at=datetime.utcnow(),
        )
        self.db.add(trainee)
        self.db.commit()
        self.db.refresh(trainee)
        return trainee
