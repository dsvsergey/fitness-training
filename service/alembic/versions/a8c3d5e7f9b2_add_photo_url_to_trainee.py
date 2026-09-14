"""add photo_url to trainee

Revision ID: a8c3d5e7f9b2
Revises: e7a2b9c4f1d3
Create Date: 2026-09-14 10:00:00.000000

"""
from typing import Sequence, Union

from alembic import op


revision: str = "a8c3d5e7f9b2"
down_revision: Union[str, None] = "e7a2b9c4f1d3"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TABLE trainee ADD COLUMN IF NOT EXISTS photo_url VARCHAR")


def downgrade() -> None:
    op.execute("ALTER TABLE trainee DROP COLUMN IF EXISTS photo_url")
