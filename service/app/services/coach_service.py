from typing import List, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.core.security import get_password_hash, verify_password
from app.models.coachs import Coach
from app.models.users import User
from app.schemas.coachs import CoachCreate, CoachUpdate
from app.schemas.users import UserDBCreate
from app.crud.users import create_user


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
