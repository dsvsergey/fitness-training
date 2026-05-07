"""add birth_date to trainee

Revision ID: e7a2b9c4f1d3
Revises: d2a4f7e8c9b1
Create Date: 2026-05-07 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


revision: str = "e7a2b9c4f1d3"
down_revision: Union[str, None] = "d2a4f7e8c9b1"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TABLE trainee ADD COLUMN IF NOT EXISTS birth_date DATE")


def downgrade() -> None:
    op.execute("ALTER TABLE trainee DROP COLUMN IF EXISTS birth_date")
