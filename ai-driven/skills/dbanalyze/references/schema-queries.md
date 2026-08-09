# Schema Queries & Normalization Analysis

## Step 2 — Extract full schema (smart query)

```bash
psql -U <user> -d <database> -c "
SELECT
  t.table_name,
  c.column_name,
  c.ordinal_position,
  c.data_type,
  c.is_nullable,
  c.column_default,
  tc.constraint_type,
  kcu.constraint_name,
  ccu.table_name  AS foreign_table,
  ccu.column_name AS foreign_column,
  ix.indexname,
  ix.indexdef
FROM information_schema.tables t
JOIN information_schema.columns c
  ON t.table_name = c.table_name AND t.table_schema = c.table_schema
LEFT JOIN information_schema.key_column_usage kcu
  ON c.table_name = kcu.table_name
  AND c.column_name = kcu.column_name
  AND c.table_schema = kcu.table_schema
LEFT JOIN information_schema.table_constraints tc
  ON kcu.constraint_name = tc.constraint_name
  AND kcu.table_schema = tc.table_schema
LEFT JOIN information_schema.referential_constraints rc
  ON tc.constraint_name = rc.constraint_name
LEFT JOIN information_schema.key_column_usage ccu
  ON rc.unique_constraint_name = ccu.constraint_name
LEFT JOIN pg_indexes ix
  ON t.table_name = ix.tablename
  AND c.column_name = ANY(string_to_array(
    regexp_replace(ix.indexdef, '.* USING .* \\((.*)\\)', '\\1'),
    ', '
  ))
WHERE t.table_schema = 'public'
  AND t.table_type = 'BASE TABLE'
ORDER BY t.table_name, c.ordinal_position;
"
```

---

## Step 5 — Normalization analysis (from smart query output)

Using the smart query output, analyze the schema for:

### 1NF violations
- Columns with incrementing names (`contact1`, `contact2`) → denormalization
- Array or JSON columns hiding multi-valued attributes
- Columns that appear to store comma-separated values

### 2NF violations (composite PKs only)
- Non-key columns that depend on only part of a composite PK
- Example: `order_items(order_id, product_id, product_name)` — `product_name` depends only on `product_id`

### 3NF violations
- Transitive dependencies between non-key columns
- Example: `users(id, zip_code, city)` — `city` depends on `zip_code`, not on `id`
- Look for columns that could live in a separate lookup table

### Design smells (beyond normal forms)
- Table with `user_id` AND a junction table for users → ambiguous ownership, rename to `owner_id`
- Inconsistent naming conventions (`lastsaved_at` vs `last_saved_at`)
- Junction tables with surrogate key instead of composite PK
- JSONB columns hiding relational data that should be normalized
- Nullable FK columns on junction tables