"""add comment to program

Revision ID: c5e7f9a1b3d6
Revises: c1e3f5a7b9d2
Create Date: 2026-09-19 22:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


revision: str = "c5e7f9a1b3d6"
down_revision: Union[str, None] = "c1e3f5a7b9d2"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TABLE program ADD COLUMN IF NOT EXISTS comment TEXT")


def downgrade() -> None:
    op.execute("ALTER TABLE program DROP COLUMN IF EXISTS comment")
