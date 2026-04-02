import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.api.v1.dependencies import get_current_user
from app.crud.machines import (
    create_machine,
    delete_machine,
    get_machine,
    get_machines,
    update_machine,
)
from app.db.session import get_db

from app.schemas.machines import MachineSchema


router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/machines/", response_model=list[MachineSchema])
def read_machines(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    machines = get_machines(db, skip=skip, limit=limit)
    if not machines:
        logger.error(f"No machines found, user: {current_user}")
        raise HTTPException(status_code=404, detail="No machines found")
    logger.info(f"Machines retrieved successfully, user: {current_user}")
    return machines


@router.get("/machines/{machine_id}", response_model=MachineSchema)
def read_machine(
    machine_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    db_machine = get_machine(db, machine_id=machine_id)
    if db_machine is None:
        logger.error(f"Machine with id {machine_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Machine not found")
    logger.info(f"Machine retrieved successfully, user: {current_user}")
    return db_machine


@router.post(
    "/machines/", response_model=MachineSchema, status_code=status.HTTP_201_CREATED
)
def create_a_machine(
    machine: MachineSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    machine = create_machine(db=db, machine=machine)
    if machine is None:
        logger.error(f"Error creating machine, user: {current_user}")
        raise HTTPException(status_code=400, detail="Error creating machine")
    logger.info(f"Machine created successfully, user: {current_user}")
    return machine


@router.put("/machines/{machine_id}", response_model=MachineSchema)
def update_a_machine(
    machine_id: int,
    machine: MachineSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_machine = update_machine(db=db, machine_id=machine_id, machine=machine)
    if updated_machine is None:
        logger.error(f"Machine with id {machine_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Machine not found")
    logger.info(f"Machine updated successfully, user: {current_user}")
    return updated_machine


@router.delete("/machines/{machine_id}")
def delete_a_machine(
    machine_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    if not delete_machine(db=db, machine_id=machine_id):
        logger.error(f"Machine with id {machine_id} not found, user: {current_user}")
        raise HTTPException(status_code=404, detail="Machine not found")
    logger.info(f"Machine deleted successfully, user: {current_user}")
    return {"detail": "Machine deleted successfully"}
