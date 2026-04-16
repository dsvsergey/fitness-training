"""add oauth and email verification fields

Revision ID: c1d2e3f4a5b6
Revises: f3a1b2c4d5e6
Create Date: 2026-04-16 00:00:00.000000

"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = "c1d2e3f4a5b6"
down_revision: Union[str, None] = "f3a1b2c4d5e6"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # trainee table — make hashed_password nullable, add OAuth + verification fields
    op.alter_column("trainee", "hashed_password", existing_type=sa.String(), nullable=True)
    op.add_column("trainee", sa.Column("oauth_provider", sa.String(), nullable=True))
    op.add_column("trainee", sa.Column("oauth_id", sa.String(), nullable=True))
    op.add_column("trainee", sa.Column("email_verified", sa.Boolean(), nullable=False, server_default="false"))
    op.add_column("trainee", sa.Column("email_verified_at", sa.DateTime(), nullable=True))
    op.create_index("ix_trainee_oauth_id", "trainee", ["oauth_id"], unique=False)

    # users table — add OAuth + verification fields (for coaches)
    op.add_column("users", sa.Column("oauth_provider", sa.String(), nullable=True))
    op.add_column("users", sa.Column("oauth_id", sa.String(), nullable=True))
    op.add_column("users", sa.Column("email_verified", sa.Boolean(), nullable=False, server_default="false"))
    op.add_column("users", sa.Column("email_verified_at", sa.DateTime(), nullable=True))
    op.create_index("ix_users_oauth_id", "users", ["oauth_id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_users_oauth_id", table_name="users")
    op.drop_column("users", "email_verified_at")
    op.drop_column("users", "email_verified")
    op.drop_column("users", "oauth_id")
    op.drop_column("users", "oauth_provider")

    op.drop_index("ix_trainee_oauth_id", table_name="trainee")
    op.drop_column("trainee", "email_verified_at")
    op.drop_column("trainee", "email_verified")
    op.drop_column("trainee", "oauth_id")
    op.drop_column("trainee", "oauth_provider")
    op.alter_column("trainee", "hashed_password", existing_type=sa.String(), nullable=False)
