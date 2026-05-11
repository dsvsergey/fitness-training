import os
import sys

# Add the project root directory to Python path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.crud.machines import create_machine, get_machines
from app.db.session import SessionLocal
from app.schemas.machines import MachineSchema


machines = [
    "A1",
    "A2",
    "A3",
    "A4",
    "B1",
    "B5",
    "B6",
    "B8",
    "C1",
    "C3",
    "C5",
    "C7",
    "D5",
    "D6",
    "D7",
    "E1",
    "E2",
    "E3",
    "E4",
    "E5",
    "F1",
    "F2",
    "F3",
    "G1",
    "G3",
    "H1",
    "H2",
    "J1",
]


def create_machines():
    db = SessionLocal()
    existing_machines = get_machines(db)
    for index, machine in enumerate(machines):
        if machine not in [m.name for m in existing_machines]:
            machine_schema = MachineSchema(name=machine, index=index)
            create_machine(db, machine_schema)
            print(f"Machine {machine} created with id: {machine_schema.id}")
        else:
            print(f"Machine {machine} already exists")
    db.close()


if __name__ == "__main__":
    create_machines()
