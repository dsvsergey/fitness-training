from abc import ABC, abstractmethod
from typing import Optional, List
from datetime import datetime
from pydantic import BaseModel


class ExternalClient(BaseModel):
    external_id: str
    first_name: str
    last_name: str
    email: Optional[str] = None
    phone: Optional[str] = None


class ExternalStaff(BaseModel):
    external_id: str
    first_name: str
    last_name: str
    email: Optional[str] = None


class ExternalAppointment(BaseModel):
    external_id: str
    start_datetime: datetime
    end_datetime: datetime
    staff_id: str
    client_id: str
    status: str
    notes: Optional[str] = None


class ExternalServiceInterface(ABC):
    """Abstract interface for external fitness service integration"""

    @abstractmethod
    async def get_client(self, client_id: str) -> Optional[ExternalClient]:
        """Get client by ID"""
        pass

    @abstractmethod
    async def get_clients(self, limit: int = 100) -> List[ExternalClient]:
        """Get list of clients"""
        pass

    @abstractmethod
    async def get_staff_member(self, staff_id: str) -> Optional[ExternalStaff]:
        """Get staff member by ID"""
        pass

    @abstractmethod
    async def get_staff_members(self) -> List[ExternalStaff]:
        """Get list of staff members"""
        pass

    @abstractmethod
    async def get_appointment(
        self, appointment_id: str
    ) -> Optional[ExternalAppointment]:
        """Get appointment by ID"""
        pass

    @abstractmethod
    async def get_appointments(
        self,
        start_date: Optional[datetime] = None,
        end_date: Optional[datetime] = None,
        staff_id: Optional[str] = None,
    ) -> List[ExternalAppointment]:
        """Get list of appointments with optional filters"""
        pass
