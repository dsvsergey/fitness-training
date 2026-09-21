from sqlalchemy.orm import Session
from app.models.machines import Machine
from app.models.program_machines import ProgramMachine
from app.schemas.machines import MachineSchema


def get_machine(db: Session, machine_id: int) -> Machine:
    return db.query(Machine).filter(Machine.id == machine_id).first()


def get_machines(db: Session, skip: int = 0, limit: int = 100) -> list[Machine]:
    return (
        db.query(Machine)
        .filter(Machine.is_hidden.is_(False))
        .order_by(Machine.id)
        .offset(skip)
        .limit(limit)
        .all()
    )


def create_machine(db: Session, machine: MachineSchema) -> Machine:
    db_machine = Machine(name=machine.name, index=machine.index)
    db.add(db_machine)
    db.commit()
    db.refresh(db_machine)
    return db_machine


def update_machine(db: Session, machine_id: int, machine: MachineSchema) -> Machine:
    db_machine = db.query(Machine).filter(Machine.id == machine_id).first()
    if not db_machine:
        return None
    db_machine.name = machine.name
    db_machine.index = machine.index
    db.commit()
    db.refresh(db_machine)
    return db_machine


def delete_machine(db: Session, machine_id: int):
    db_machine = db.query(Machine).filter(Machine.id == machine_id).first()
    if db_machine:
        remove_machine(db, db_machine)
        db.commit()
        return True
    return False


def remove_machine(db: Session, db_machine: Machine) -> None:
    """Delete a machine, or hide it if programs still reference it."""
    is_referenced = db.query(
        db.query(ProgramMachine)
        .filter(ProgramMachine.machine_id == db_machine.id)
        .exists()
    ).scalar()
    if is_referenced:
        db_machine.is_hidden = True
    else:
        db.delete(db_machine)
