import logging
from fastapi import APIRouter, Body, Depends, HTTPException, Path, status
from sqlalchemy.orm import Session
from app.api.v1.dependencies import get_current_user
from app.crud.program_machines import (
    create_program_machine,
    delete_program_machine,
    get_program_machine,
    get_program_machine_by_program_and_machine,
    get_program_machines,
    update_program_machine,
)
from app.db.session import get_db

from app.schemas.program_machines import ProgramMachineSchema


router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/program-machines/", response_model=list[ProgramMachineSchema])
def read_program_machines(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program_machines = get_program_machines(db, skip=skip, limit=limit)
    if not program_machines:
        logger.error(f"No ProgramMachines found, user: {current_user}")
        raise HTTPException(status_code=404, detail="No ProgramMachines found")
    return program_machines


@router.get(
    "/program-machines/{program_machine_id}", response_model=ProgramMachineSchema
)
def read_program_machine(
    program_machine_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program_machine = get_program_machine(db, program_machine_id=program_machine_id)
    if program_machine is None:
        logger.error(
            f"ProgramMachine with id {program_machine_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="ProgramMachine not found")
    return program_machine


@router.get(
    "/program-machines/program/{program_id}/machine/{machine_id}/",
    response_model=ProgramMachineSchema,
)
def read_program_machine_by_program_machine(
    program_id: int = Path(...),
    machine_id: int = Path(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program_machine = get_program_machine_by_program_and_machine(
        db, program_id=program_id, machine_id=machine_id
    )
    if program_machine is None:
        logger.error(
            f"ProgramMachine with program_id {program_id} and machine_id {machine_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="ProgramMachine not found")
    return program_machine


@router.post(
    "/program-machines/",
    response_model=ProgramMachineSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_a_program_machine(
    program_machine: ProgramMachineSchema = Body(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program_machine = create_program_machine(db=db, program_machine=program_machine)
    if program_machine is None:
        logger.error(f"Error creating ProgramMachine, user: {current_user}")
        raise HTTPException(
            status_code=400,
            detail="Error creating ProgramMachine, user: {current_user}",
        )
    logger.info(f"ProgramMachine created successfully, user: {current_user}")
    return program_machine


@router.put(
    "/program-machines/{program_machine_id}", response_model=ProgramMachineSchema
)
def update_a_program_machine(
    program_machine_id: int,
    program_machine: ProgramMachineSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_program_machine = update_program_machine(
        db=db, program_machine_id=program_machine_id, program_machine=program_machine
    )
    if updated_program_machine is None:
        logger.error(
            f"ProgramMachine with id {program_machine_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="ProgramMachine not found")
    logger.info(f"ProgramMachine updated successfully, user: {current_user}")
    return updated_program_machine


@router.delete("/program-machines/{program_machine_id}")
def delete_a_program_machine(
    program_machine_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    if not delete_program_machine(db=db, program_machine_id=program_machine_id):
        logger.error(
            f"ProgramMachine with id {program_machine_id} not found, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="ProgramMachine not found")
    logger.info(f"ProgramMachine deleted successfully, user: {current_user}")
    return {"detail": "ProgramMachine deleted successfully"}
