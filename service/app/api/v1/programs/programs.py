import logging
from fastapi import APIRouter, Body, Depends, HTTPException, Path, status
from sqlalchemy.orm import Session

from app.api.v1.dependencies import get_current_user
from app.crud.programs import (
    create_program,
    create_program_by_machine_list,
    delete_program,
    get_archive_programs,
    get_program,
    get_programs,
    set_program_archive_status,
    set_workout_date,
    update_program,
    update_program_machines_list,
)
from app.db.session import get_db
from app.schemas.programs import (
    ProgramCreateSchema,
    ProgramSchema,
    ProgramUpdateMachinesSchema,
    UpdateArchiveStatusSchema,
    UpdateWorkoutDateSchema,
)


router = APIRouter()
logger = logging.getLogger(__name__)


@router.post(
    "/programs/", response_model=ProgramSchema, status_code=status.HTTP_201_CREATED
)
def create_program_endpoint(
    program: ProgramSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program = create_program(db=db, program=program)
    if program is None:
        logger.error(f"Error creating program, user: {current_user}")
        raise HTTPException(
            status_code=400, detail="Error creating program, user: {current_user}"
        )
    logger.info(f"Program created successfully, user: {current_user}")
    return program


@router.post(
    "/programs/create-with-machines/",
    response_model=ProgramSchema,
    status_code=status.HTTP_201_CREATED,
)
def create_program_with_machines(
    program: ProgramCreateSchema = Body(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program = create_program_by_machine_list(db=db, data=program)
    if program is None:
        logger.error(f"Error creating program with machines, user: {current_user}")
        raise HTTPException(
            status_code=400,
            detail="Error creating program with machines, user: {current_user}",
        )
    logger.info(f"Program created successfully with machines, user: {current_user}")
    return program


@router.put("/programs/machines/", response_model=ProgramSchema)
def update_program_machines(
    data: ProgramUpdateMachinesSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    try:
        program = update_program_machines_list(db, data)
        if program is None:
            raise HTTPException(
                status_code=404,
                detail=f"Program with id {data.id} not found, user: {current_user}",
            )
        return program
    except Exception as e:
        logger.error(f"Error updating program machines, user: {current_user}")
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/programs/trainee/{trainee_id}/", response_model=list[ProgramSchema])
def read_programs(
    trainee_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    programs = get_programs(db, trainee_id=trainee_id, skip=skip, limit=limit)
    if not programs:
        logger.error(
            f"No programs found for trainee_id: {trainee_id}, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="No programs found")
    logger.info(f"Programs found for trainee_id: {trainee_id}, user: {current_user}")
    return programs


@router.get(
    "/programs/archive/trainee/{trainee_id}/", response_model=list[ProgramSchema]
)
def read_archive_programs(
    trainee_id: int,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    archive_programs = get_archive_programs(
        trainee_id=trainee_id,
        db=db,
        skip=skip,
        limit=limit,
    )
    if not archive_programs:
        logger.error(
            f"No archive programs found for trainee_id: {trainee_id}, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="No archive programs found")
    logger.info(
        f"Archive programs found for trainee_id: {trainee_id}, user: {current_user}"
    )
    return archive_programs


@router.put("/programs/{program_id}/archive/", response_model=ProgramSchema)
def set_program_archive(
    program_id: int = Path(...),
    archive: UpdateArchiveStatusSchema = Body(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_program = set_program_archive_status(
        db=db, program_id=program_id, is_archive=archive.is_archive
    )
    if updated_program is None:
        logger.error(f"Program not found for program_id: {program_id}")
        raise HTTPException(
            status_code=404, detail="Program not found, user: {current_user}"
        )
    logger.info(
        f"Program archived successfully for program_id: {program_id}, user: {current_user}"
    )
    return updated_program


@router.get("/programs/{program_id}/", response_model=ProgramSchema)
def read_program(
    program_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    db_program = get_program(db, program_id=program_id)
    if db_program is None:
        logger.error(f"Program not found for program_id: {program_id}")
        raise HTTPException(
            status_code=404, detail="Program not found, user: {current_user}"
        )
    logger.info(f"Program found for program_id: {program_id}, user: {current_user}")
    return db_program


@router.put("/programs/{program_id}/", response_model=ProgramSchema)
def update_program_endpoint(
    program_id: int,
    program: ProgramSchema,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    updated_program = update_program(
        db=db, program_id=program_id, program_update=program
    )
    if updated_program is None:
        logger.error(
            f"Program not found for program_id: {program_id}, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Program not found")
    logger.info(
        f"Program updated successfully for program_id: {program_id}, user: {current_user}"
    )
    return updated_program


@router.delete("/programs/{program_id}/")
def delete_program_endpoint(
    program_id: int,
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    if not delete_program(db=db, program_id=program_id):
        logger.error(
            f"Program not found for program_id: {program_id}, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Program not found")
    logger.info(
        f"Program deleted successfully for program_id: {program_id}, user: {current_user}"
    )
    return {"detail": "Program deleted successfully"}


@router.post("/programs/{program_id}/workout_date/")
def set_workout_date_endpoint(
    program_id: int,
    workout_info: UpdateWorkoutDateSchema = Body(...),
    db: Session = Depends(get_db),
    current_user: str = Depends(get_current_user),
):
    program = set_workout_date(
        db=db, program_id=program_id, workout_date=workout_info.workout_date
    )
    if program is None:
        logger.error(
            f"Program not found for program_id: {program_id}, user: {current_user}"
        )
        raise HTTPException(status_code=404, detail="Program not found")
    logger.info(
        f"Setting workout date for program_id: {program_id}, user: {current_user}"
    )
    return program
