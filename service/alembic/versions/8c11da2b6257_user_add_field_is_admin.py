"""user add field is_admin

Revision ID: 8c11da2b6257
Revises: 7e5c6230d475
Create Date: 2024-05-23 13:50:53.442595

"""

from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision: str = "8c11da2b6257"
down_revision: Union[str, None] = "7e5c6230d475"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column("users", sa.Column("is_admin", sa.Boolean(), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "is_admin")
