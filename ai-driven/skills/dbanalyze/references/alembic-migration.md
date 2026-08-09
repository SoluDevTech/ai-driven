# Alembic Migration

## Step 8 — Generate Alembic migration

```python
"""fix schema analysis issues

Revision ID: <rev>
Revises: <prev>
Create Date: <date>
"""
from alembic import op
import sqlalchemy as sa

def upgrade():
    # Drop redundant indexes
    op.drop_index('<redundant_index>', table_name='<table>')

    # Create missing FK indexes
    op.create_index('<table>_<column>_idx', '<table>', ['<column>'])

    # Set FK columns to NOT NULL
    op.alter_column('<table>', '<column>', nullable=False)

def downgrade():
    op.create_index('<redundant_index>', '<table>', ['<column>'])
    op.drop_index('<table>_<column>_idx', table_name='<table>')
    op.alter_column('<table>', '<column>', nullable=True)
```