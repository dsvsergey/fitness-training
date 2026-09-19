"""add weight_2 to workout_sessions

Revision ID: b4d6e8f0a2c4
Revises: a8c3d5e7f9b2
Create Date: 2026-09-19 21:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


revision: str = "b4d6e8f0a2c4"
down_revision: Union[str, None] = "a8c3d5e7f9b2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute(
        "ALTER TABLE workout_sessions ADD COLUMN IF NOT EXISTS weight_2 INTEGER"
    )


def downgrade() -> None:
    op.execute("ALTER TABLE workout_sessions DROP COLUMN IF EXISTS weight_2")
