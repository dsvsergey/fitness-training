from typing import List, Optional
from sqlalchemy.orm import Session
from app.core.security import get_password_hash, verify_password
from app.models.trainees import Trainee
from app.schemas.trainees import TraineeCreate, TraineeUpdate


class TraineeService:
    def __init__(self, db: Session):
        self.db = db

    def get_trainee(self, trainee_id: int) -> Optional[Trainee]:
        """Get trainee by ID"""
        return self.db.query(Trainee).filter(Trainee.id == trainee_id).first()

    def get_trainee_by_email(self, email: str) -> Optional[Trainee]:
        """Get trainee by email"""
        return self.db.query(Trainee).filter(Trainee.email == email).first()

    def get_trainees(self, skip: int = 0, limit: int = 100) -> List[Trainee]:
        """Get list of trainees"""
        return self.db.query(Trainee).offset(skip).limit(limit).all()

    def create_trainee(self, trainee: TraineeCreate) -> Trainee:
        """Create new trainee"""
        db_trainee = Trainee(
            email=trainee.email,
            hashed_password=get_password_hash(trainee.password),
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
        )
        self.db.add(db_trainee)
        self.db.commit()
        self.db.refresh(db_trainee)
        return db_trainee

    def update_trainee(
        self, trainee_id: int, trainee: TraineeUpdate
    ) -> Optional[Trainee]:
        """Update trainee"""
        db_trainee = self.get_trainee(trainee_id)
        if not db_trainee:
            return None

        update_data = trainee.dict(exclude_unset=True)
        if "password" in update_data:
            update_data["hashed_password"] = get_password_hash(
                update_data.pop("password")
            )

        for field, value in update_data.items():
            setattr(db_trainee, field, value)

        self.db.commit()
        self.db.refresh(db_trainee)
        return db_trainee

    def delete_trainee(self, trainee_id: int) -> bool:
        """Delete trainee"""
        db_trainee = self.get_trainee(trainee_id)
        if not db_trainee:
            return False

        self.db.delete(db_trainee)
        self.db.commit()
        return True

    def authenticate(self, email: str, password: str) -> Optional[Trainee]:
        """Authenticate trainee"""
        trainee = self.get_trainee_by_email(email)
        if not trainee:
            return None
        if not verify_password(password, trainee.hashed_password):
            return None
        return trainee
