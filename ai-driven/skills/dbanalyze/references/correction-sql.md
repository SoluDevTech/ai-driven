# Correction SQL

## Step 7 — Generate correction SQL

### Drop redundant indexes
```sql
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = '<table>' AND schemaname = 'public';

DROP INDEX public.<redundant_index>;
```

### Create index on missing FK
```sql
CREATE INDEX <table>_<column>_idx ON public.<table> (<column>);
```

### Set nullable column to NOT NULL
```sql
SELECT COUNT(*) FROM public.<table> WHERE <column> IS NULL;
-- If 0:
ALTER TABLE public.<table> ALTER COLUMN <column> SET NOT NULL;
```

### Extract 3NF violation to lookup table
```sql
CREATE TABLE <lookup_table> (
  id SERIAL PRIMARY KEY,
  <dependent_column> TEXT NOT NULL UNIQUE
);

ALTER TABLE <source_table>
  ADD COLUMN <lookup_id> INT REFERENCES <lookup_table>(id);

-- Migrate data
INSERT INTO <lookup_table> (<dependent_column>)
  SELECT DISTINCT <dependent_column> FROM <source_table>;

UPDATE <source_table> s
  SET <lookup_id> = l.id
  FROM <lookup_table> l
  WHERE s.<dependent_column> = l.<dependent_column>;

ALTER TABLE <source_table> DROP COLUMN <dependent_column>;
```