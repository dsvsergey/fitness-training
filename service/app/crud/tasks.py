from sqlalchemy.orm import Session
from typing import List, Optional

from app.schemas.tasks import Task, TaskCreate, TaskUpdate


def get_task(db: Session, task_id: int) -> Optional[Task]:
    return db.query(Task).filter(Task.id == task_id).first()


def create_task(db: Session, task_data: TaskCreate) -> Task:
    task = Task(
        body=task_data.body,
        status=task_data.status,
        error_description=task_data.error_description,
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task


def update_task(db: Session, task_id: int, task_data: TaskUpdate) -> Optional[Task]:
    task = get_task(db, task_id)
    if not task:
        return None

    task.body = task_data.body
    task.status = task_data.status
    task.error_description = task_data.error_description

    db.commit()
    db.refresh(task)
    return task


def delete_task(db: Session, task_id: int) -> bool:
    task = get_task(db, task_id)
    if not task:
        return False

    db.delete(task)
    db.commit()
    return True


def get_all_tasks(db: Session) -> List[Task]:
    return db.query(Task).all()
