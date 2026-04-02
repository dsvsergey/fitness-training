from sqlalchemy import and_
from sqlalchemy.orm import Session
from app.models.program_machines import ProgramMachine
from app.schemas.program_machines import ProgramMachineSchema
from app.models.workout_sessions import SessionStatus, WorkoutSession


def get_program_machine(db: Session, program_machine_id: int) -> ProgramMachine:
    return (
        db.query(ProgramMachine).filter(ProgramMachine.id == program_machine_id).first()
    )


def get_program_machine_by_program_and_machine(
    db: Session, program_id: int, machine_id: int
) -> ProgramMachine:
    return (
        db.query(ProgramMachine)
        .filter(
            and_(
                ProgramMachine.program_id == program_id,
                ProgramMachine.machine_id == machine_id,
            )
        )
        .one_or_none()
    )


def get_program_machines(
    db: Session, skip: int = 0, limit: int = 100
) -> list[ProgramMachine]:
    return (
        db.query(ProgramMachine)
        .order_by(ProgramMachine.id)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_program_machine(
    db: Session, program_machine: ProgramMachineSchema
) -> ProgramMachine:
    program_machine_dict = program_machine.model_dump()
    db_program_machine = ProgramMachine(**program_machine_dict)
    db.add(db_program_machine)
    db.commit()
    db.refresh(db_program_machine)
    return db_program_machine


def update_program_machine(
    db: Session, program_machine_id: int, program_machine: ProgramMachineSchema
) -> ProgramMachine:
    db_program_machine = (
        db.query(ProgramMachine).filter(ProgramMachine.id == program_machine_id).first()
    )
    if not db_program_machine:
        return None
    update_data = program_machine.model_dump(exclude_unset=False)
    for key, value in update_data.items():
        if key == "workouts" and value:
            for workout in value:
                if workout.get("id") is None:
                    workout = {k: v for k, v in workout.items() if k != "create_at"}
                    new_workout = WorkoutSession(**workout)
                    db.add(new_workout)
                else:
                    db_workout = (
                        db.query(WorkoutSession)
                        .filter(WorkoutSession.id == workout.get("id"))
                        .first()
                    )
                    if (
                        db_workout
                        and db_workout.session_status == SessionStatus.Planned
                    ):
                        for workout_key, workout_value in workout.items():
                            if workout_key in [
                                "date_session",
                                "session_time",
                                "weight",
                                "session_status",
                            ]:
                                setattr(db_workout, workout_key, workout_value)
        elif key in ["machine", "create_at"] and value:
            continue
        else:
            if isinstance(value, dict):
                value = {k: v for k, v in value.items() if hasattr(ProgramMachine, k)}
                for k, v in value.items():
                    setattr(db_program_machine, k, v)
            else:
                setattr(db_program_machine, key, value)
    db.commit()
    db.refresh(db_program_machine)
    return db_program_machine


def delete_program_machine(db: Session, program_machine_id: int):
    db_program_machine = (
        db.query(ProgramMachine).filter(ProgramMachine.id == program_machine_id).first()
    )
    if db_program_machine:
        db.delete(db_program_machine)
        db.commit()
        return True
    return False
