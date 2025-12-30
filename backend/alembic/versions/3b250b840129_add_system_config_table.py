"""add_system_config_table

Revision ID: 3b250b840129
Revises: 767920a31cfc
Create Date: 2025-12-30 22:00:20.891668

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '3b250b840129'
down_revision = '767920a31cfc'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Créer la table system_config
    op.create_table(
        'system_config',
        sa.Column('key', sa.String(length=100), nullable=False),
        sa.Column('value', sa.String(length=500), nullable=False),
        sa.Column('description', sa.String(length=500), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('now()'), nullable=False),
        sa.PrimaryKeyConstraint('key')
    )
    op.create_index(op.f('ix_system_config_key'), 'system_config', ['key'], unique=True)


def downgrade() -> None:
    # Supprimer la table system_config
    op.drop_index(op.f('ix_system_config_key'), table_name='system_config')
    op.drop_table('system_config')
