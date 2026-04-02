"""fix tasks and logs

Revision ID: 7e5c6230d475
Revises: 48166da40ea3
Create Date: 2024-05-22 16:01:39.134380

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from enum import Enum as PyEnum


# revision identifiers, used by Alembic.
revision: str = "7e5c6230d475"
down_revision: Union[str, None] = "48166da40ea3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


class TaskStatus(PyEnum):
    NEW = "new"
    COMPLETED = "completed"
    ERROR = "error"


def upgrade():
    op.create_table(
        "logs",
        sa.Column("id", sa.Integer, primary_key=True, index=True),
        sa.Column(
            "created_at", sa.DateTime(timezone=True), server_default=sa.func.now()
        ),
        sa.Column("level", sa.String, nullable=False),
        sa.Column("message", sa.Text, nullable=False),
        sa.Column("logger_name", sa.String, nullable=False),
    )

    op.create_table(
        "tasks",
        sa.Column("id", sa.Integer, primary_key=True),
        sa.Column("body", sa.JSON, nullable=False),
        sa.Column(
            "status", sa.Enum(TaskStatus), nullable=False, default=TaskStatus.NEW
        ),
        sa.Column("error_description", sa.String, nullable=True),
        sa.Column(
            "created_at", sa.DateTime(timezone=True), server_default=sa.func.now()
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.func.now(),
            onupdate=sa.func.now(),
        ),
    )


def downgrade():
    op.drop_table("logs")
    op.drop_table("tasks")
