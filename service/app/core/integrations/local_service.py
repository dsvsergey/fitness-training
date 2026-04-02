from typing import Optional, List
from datetime import datetime
from sqlalchemy.orm import Session
from app.core.interfaces.external_service import (
    ExternalServiceInterface,
    ExternalClient,
    ExternalStaff,
    ExternalAppointment,
)
from app.models.coachs import Coach
from app.models.trainees import Trainee
from app.models.workout_appointment import WorkoutAppointment
from app.core.security import get_password_hash


class LocalService(ExternalServiceInterface):
    def __init__(self, db: Session):
        self.db = db

    async def get_client(self, client_id: str) -> Optional[ExternalClient]:
        trainee = self.db.query(Trainee).filter(Trainee.id == int(client_id)).first()
        if not trainee:
            return None

        return ExternalClient(
            external_id=str(trainee.id),
            first_name=trainee.first_name,
            last_name=trainee.last_name,
            email=trainee.email,
            phone=trainee.mobile_phone,
        )

    async def get_clients(self, limit: int = 100) -> List[ExternalClient]:
        trainees = self.db.query(Trainee).limit(limit).all()
        return [
            ExternalClient(
                external_id=str(trainee.id),
                first_name=trainee.first_name,
                last_name=trainee.last_name,
                email=trainee.email,
                phone=trainee.mobile_phone,
            )
            for trainee in trainees
        ]

    async def get_staff_member(self, staff_id: str) -> Optional[ExternalStaff]:
        coach = self.db.query(Coach).filter(Coach.id == int(staff_id)).first()
        if not coach:
            return None

        return ExternalStaff(
            external_id=str(coach.id),
            first_name=coach.first_name,
            last_name=coach.last_name,
            email=coach.email,
        )

    async def get_staff_members(self) -> List[ExternalStaff]:
        coaches = self.db.query(Coach).all()
        return [
            ExternalStaff(
                external_id=str(coach.id),
                first_name=coach.first_name,
                last_name=coach.last_name,
                email=coach.email,
            )
            for coach in coaches
        ]

    async def get_appointment(
        self, appointment_id: str
    ) -> Optional[ExternalAppointment]:
        appointment = (
            self.db.query(WorkoutAppointment)
            .filter(WorkoutAppointment.id == int(appointment_id))
            .first()
        )

        if not appointment:
            return None

        return ExternalAppointment(
            external_id=str(appointment.id),
            start_datetime=appointment.start_datetime,
            end_datetime=appointment.end_datetime,
            staff_id=str(appointment.coach_id),
            client_id=str(appointment.trainee_id),
            status=appointment.status,
            notes=appointment.notes,
        )

    async def get_appointments(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        staff_id: Optional[str] = None,
    ) -> List[ExternalAppointment]:
        query = self.db.query(WorkoutAppointment)

        if start_date:
            query = query.filter(WorkoutAppointment.start_datetime >= start_date)
        if end_date:
            query = query.filter(WorkoutAppointment.end_datetime <= end_date)
        if staff_id:
            query = query.filter(WorkoutAppointment.coach_id == int(staff_id))

        appointments = query.all()

        return [
            ExternalAppointment(
                external_id=str(appointment.id),
                start_datetime=appointment.start_datetime,
                end_datetime=appointment.end_datetime,
                staff_id=str(appointment.coach_id),
                client_id=str(appointment.trainee_id),
                status=appointment.status,
                notes=appointment.notes,
            )
            for appointment in appointments
        ]
