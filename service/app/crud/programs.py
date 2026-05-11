from fastapi import HTTPException
from sqlalchemy import and_, func
from sqlalchemy.orm import Session
from app.models.programs import Program
from app.schemas.programs import (
    ProgramCreateSchema,
    ProgramMachinesReorderSchema,
    ProgramSchema,
    ProgramUpdateMachinesSchema,
)
from app.models.machines import Machine
from app.models.program_machines import ProgramMachine


def create_program(db: Session, program: ProgramSchema) -> Program:
    db_program = Program(
        number=program.number,
        name=program.name,
        coach_id=program.coach_id,
        trainee_id=program.trainee_id,
    )
    db.add(db_program)
    db.commit()
    db.refresh(db_program)
    return db_program


def create_program_by_machine_list(db: Session, data: ProgramCreateSchema):
    # Checking the number of programs for a client
    existing_programs_count = (
        db.query(func.count(Program.id))
        .filter(Program.trainee_id == data.trainee_id, Program.is_archive == False)
        .scalar()
    )
    if existing_programs_count >= 4:
        raise HTTPException(
            status_code=400, detail="The client already has four active programs"
        )

    # Search for a free or archived name among "Program A", "Program B", "Program C" and "Program D"
    available_names = ["Program A", "Program B", "Program C", "Program D"]
    existing_names = (
        db.query(Program.name)
        .filter(Program.trainee_id == data.trainee_id)
        .filter(Program.is_archive == False)
        .all()
    )
    existing_names = [name for (name,) in existing_names]
    for name in available_names:
        if name not in existing_names:
            new_program_name = name
            break
    else:
        raise HTTPException(
            status_code=400,
            detail="No free or archived name for the new program",
        )

    new_program = Program(
        name=new_program_name,
        coach_id=data.coach_id,
        trainee_id=data.trainee_id,
        number=1,  # If a new program, then assign number 1
    )
    db.add(new_program)
    db.commit()
    db.refresh(new_program)

    for machine_id in data.machine_ids:
        machine = db.query(Machine).get(machine_id)
        if not machine:
            raise HTTPException(
                status_code=404, detail=f"Machine with id {machine_id} not found"
            )

        program_machine = ProgramMachine(
            machine_id=machine.id, program_id=new_program.id
        )
        db.add(program_machine)
        db.commit()

    return new_program


def update_program_machines_list(db: Session, data: ProgramUpdateMachinesSchema):
    program = db.query(Program).get(data.id)
    if not program:
        raise HTTPException(
            status_code=404, detail=f"Program with id {data.id} not found"
        )

    existing_program_machines = (
        db.query(ProgramMachine).filter_by(program_id=data.id).all()
    )

    for program_machine in existing_program_machines:
        if program_machine.machine_id not in data.machine_ids:
            db.delete(program_machine)

    for machine_id in data.machine_ids:
        if not any(
            machine.machine_id == machine_id for machine in existing_program_machines
        ):
            machine = db.query(Machine).get(machine_id)
            if not machine:
                raise HTTPException(
                    status_code=404, detail=f"Machine with id {machine_id} not found"
                )

            new_program_machine = ProgramMachine(
                machine_id=machine.id, program_id=program.id
            )
            db.add(new_program_machine)

    db.commit()

    return program


def reorder_program_machines(
    db: Session, program_id: int, data: ProgramMachinesReorderSchema
) -> Program:
    program = db.query(Program).get(program_id)
    if not program:
        return None

    program_machines = (
        db.query(ProgramMachine).filter_by(program_id=program_id).all()
    )
    pm_by_id = {pm.id: pm for pm in program_machines}

    for pm_id in data.ordered_ids:
        if pm_id not in pm_by_id:
            raise HTTPException(
                status_code=400,
                detail=f"ProgramMachine with id {pm_id} does not belong to program {program_id}",
            )

    if len(data.ordered_ids) != len(pm_by_id):
        raise HTTPException(
            status_code=400,
            detail=f"Expected {len(pm_by_id)} ids, got {len(data.ordered_ids)}",
        )

    for position, pm_id in enumerate(data.ordered_ids):
        pm_by_id[pm_id].index = position

    db.commit()
    db.refresh(program)
    return program


def get_program(db: Session, program_id: int) -> Program:
    return db.query(Program).filter(Program.id == program_id).first()


def get_programs(
    db: Session, trainee_id: int, skip: int = 0, limit: int = 100
) -> list[Program]:
    return (
        db.query(Program)
        .filter(
            and_(
                Program.is_archive == False,
                # Program.is_delete == False,
                Program.trainee_id == trainee_id,
            )
        )
        .order_by(Program.id)
        .offset(skip)
        .limit(limit)
        .all()
    )


def get_archive_programs(
    db: Session, trainee_id: int, skip: int = 0, limit: int = 100
) -> list[Program]:
    return (
        db.query(Program)
        .filter(
            and_(
                Program.is_archive == True,
                # Program.is_delete == False,
                Program.trainee_id == trainee_id,
            )
        )
        .offset(skip)
        .limit(limit)
        .all()
    )


def set_program_archive_status(
    db: Session, program_id: int, is_archive: bool
) -> Program:
    db_program = db.query(Program).filter(Program.id == program_id).first()
    if not db_program:
        return None
    db_program.is_archive = is_archive
    db.commit()
    db.refresh(db_program)
    return db_program


def update_program(
    db: Session, program_id: int, program_update: ProgramSchema
) -> Program:
    db_program = db.query(Program).filter(Program.id == program_id).first()
    if not db_program:
        return None
    program_data = program_update.model_dump(exclude_unset=True)
    for key, value in program_data.items():
        if key in ["trainee", "coach", "program_machines"]:
            continue
        setattr(db_program, key, value)
    db.commit()
    db.refresh(db_program)
    return db_program


def delete_program(db: Session, program_id: int):
    db_program = db.query(Program).filter(Program.id == program_id).first()
    if db_program:
        db_program.is_delete = True
        db.commit()
        return True
    return False


def set_workout_date(db: Session, program_id: int, workout_date: str):
    db_program = db.query(Program).filter(Program.id == program_id).first()
    if not db_program:
        return None
    db_program.workout_date = workout_date
    db.commit()
    db.refresh(db_program)
    return db_program
