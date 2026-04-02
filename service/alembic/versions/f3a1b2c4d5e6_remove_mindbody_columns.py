"""remove mindbody columns

Revision ID: f3a1b2c4d5e6
Revises: a4eb53f3aded
Create Date: 2026-04-02 00:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = 'f3a1b2c4d5e6'
down_revision: Union[str, None] = 'a4eb53f3aded'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Drop mindbody_id index and column from coach table
    op.drop_index('ix_coach_mindbody_id', table_name='coach', if_exists=True)
    op.drop_column('coach', 'mindbody_id')

    # Drop mindbody_id index and column from trainee table
    op.drop_index('ix_trainee_mindbody_id', table_name='trainee', if_exists=True)
    op.drop_column('trainee', 'mindbody_id')

    # Drop mindbody_token column from users table
    op.drop_column('users', 'mindbody_token')


def downgrade() -> None:
    # Restore mindbody_token column to users table
    op.add_column('users', sa.Column('mindbody_token', sa.String(), nullable=True))

    # Restore mindbody_id column and index to trainee table
    op.add_column('trainee', sa.Column('mindbody_id', sa.String(), nullable=True))
    op.create_index('ix_trainee_mindbody_id', 'trainee', ['mindbody_id'], unique=True)

    # Restore mindbody_id column and index to coach table
    op.add_column('coach', sa.Column('mindbody_id', sa.BigInteger(), nullable=True))
    op.create_index('ix_coach_mindbody_id', 'coach', ['mindbody_id'], unique=True)
