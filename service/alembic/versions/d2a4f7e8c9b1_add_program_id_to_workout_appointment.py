"""add program_id to workoutappointment

Revision ID: d2a4f7e8c9b1
Revises: c1d2e3f4a5b6
Create Date: 2026-04-28 12:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op


revision: str = "d2a4f7e8c9b1"
down_revision: Union[str, None] = "c1d2e3f4a5b6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "workoutappointment",
        sa.Column("program_id", sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        "fk_workoutappointment_program_id",
        "workoutappointment",
        "program",
        ["program_id"],
        ["id"],
    )
    op.create_index(
        "ix_workoutappointment_program_id",
        "workoutappointment",
        ["program_id"],
    )


def downgrade() -> None:
    op.drop_index("ix_workoutappointment_program_id", table_name="workoutappointment")
    op.drop_constraint(
        "fk_workoutappointment_program_id", "workoutappointment", type_="foreignkey"
    )
    op.drop_column("workoutappointment", "program_id")
