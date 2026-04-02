from sqlalchemy import BigInteger, Column, DateTime, ForeignKey, Integer, Enum, String
from sqlalchemy.orm import relationship
import enum

from app.db.base_class import Base
from app.models.coachs import Coach
from app.models.trainees import Trainee
from app.schemas.workout_appointment import AppointmentStatusEnum


class AppointmentStatus(enum.Enum):
    NoneStatus = "None"
    Requested = "Requested"
    Booked = "Booked"
    Completed = "Completed"
    Confirmed = "Confirmed"
    Arrived = "Arrived"
    NoShow = "NoShow"
    Cancelled = "Cancelled"
    LateCancelled = "LateCancelled"


def convert_to_appointment_status_enum(
    appointment_status_enum_value: AppointmentStatusEnum,
) -> AppointmentStatus:
    return {
        AppointmentStatusEnum.NoneStatus.value: AppointmentStatus.NoneStatus,
        AppointmentStatusEnum.Requested.value: AppointmentStatus.Requested,
        AppointmentStatusEnum.Booked.value: AppointmentStatus.Booked,
        AppointmentStatusEnum.Completed.value: AppointmentStatus.Completed,
        AppointmentStatusEnum.Confirmed.value: AppointmentStatus.Confirmed,
        AppointmentStatusEnum.Arrived.value: AppointmentStatus.Arrived,
        AppointmentStatusEnum.NoShow.value: AppointmentStatus.NoShow,
        AppointmentStatusEnum.Cancelled.value: AppointmentStatus.Cancelled,
        AppointmentStatusEnum.LateCancelled.value: AppointmentStatus.LateCancelled,
    }.get(appointment_status_enum_value.value)


class WorkoutAppointment(Base):
    id = Column(Integer, primary_key=True)
    trainee_id = Column(ForeignKey(Trainee.id), nullable=False)
    trainee = relationship("Trainee", back_populates="workout_appointments")
    coach_id = Column(ForeignKey(Coach.id), nullable=False)
    coach = relationship("Coach", back_populates="workout_appointments")
    duration = Column(Integer, nullable=False)
    status = Column(Enum(AppointmentStatus), default=AppointmentStatus.NoneStatus)
    start_at = Column(DateTime, nullable=False)
    end_at = Column(DateTime, nullable=False)
    notes = Column(String, nullable=True)
