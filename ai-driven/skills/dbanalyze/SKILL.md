---
name: dbanalyze
description: Analyze a database schema by running SchemaCrawler lint and extracting the full schema via information_schema. Use this skill whenever the user wants to audit a database schema, check normalization, detect missing indexes, redundant indexes, nullable FK columns, inconsistent data types, design smells, or get improvement recommendations.
---

# DB Analyze — Lint & Schema Analysis

## What this skill does
Combines SchemaCrawler lint (structural issues) with a full schema extraction via `information_schema` (normalization, design analysis). Produces a prioritized action plan covering both technical and design issues.

---

## Prerequisites

SchemaCrawler wrapper at `/usr/local/bin/schemacrawler`:
```
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
/usr/local/opt/schemacrawler-17.1.4-bin/bin/schemacrawler.sh
```

psql must be available for the smart query.

---

## Workflow

### Step 1 — Run SchemaCrawler lint

→ Load `references/schemacrawler-config.md` for the lint command, supported servers, and per-project connection conventions.

### Step 2 — Extract full schema (smart query)

→ Load `references/schema-queries.md` for the `information_schema` smart query that extracts tables, columns, constraints, FKs, and indexes in one pass.

### Step 3 — SchemaCrawler linter reference

→ Load `references/schemacrawler-config.md` for the full linter table (description + severity for every built-in linter).

### Step 4 — Noise filter

**Always ignore**
| Lint | Reason |
|------|--------|
| `LinterTableWithNoRemarks` (low) | Not urgent in dev |
| `LinterTableEmpty` (low) | Expected on fresh dev databases |
| `LinterTableWithNoSurrogatePrimaryKey` (low) | Composite PKs valid on junction tables |
| `LinterTableWithPrimaryKeyNotFirst` (low) | Convention only, no functional impact |

**Always escalate**
| Lint | Priority |
|------|----------|
| `LinterRedundantIndexes` | P1 |
| `LinterTableWithNoPrimaryKey` | P1 |
| `LinterForeignKeyWithNoIndexes` | P1 |
| `LinterForeignKeyMismatch` | P1 |
| `LinterNullColumnsInIndex` | P1 |
| `LinterTableCycles` | P1 |
| `LinterColumnTypes` | P2 |
| `LinterTableAllNullableColumns` | P2 |
| `LinterForeignKeySelfReference` | P2 |

### Step 5 — Normalization analysis

→ Load `references/schema-queries.md` for the 1NF / 2NF / 3NF checks and design-smell list to apply against the smart query output.

### Step 6 — Prioritization grid

**P1 — Fix before next deployment**
- Redundant indexes → `DROP INDEX`
- FK without index → `CREATE INDEX`
- Unique index with nullable columns → `NOT NULL`
- Table without PK
- FK data type mismatch → align types

**P2 — Fix this week**
- Heterogeneous `id` types across tables → document or homogenize
- Fully nullable tables → constrain mandatory columns
- 3NF violations → extract to lookup tables
- Self-referencing FK → verify `ON DELETE` strategy

**P3 — Continuous improvement**
- Missing column remarks → `COMMENT ON COLUMN`
- Naming inconsistencies
- Composite PKs on junction tables instead of surrogate keys

### Step 7 — Generate correction SQL

→ Load `references/correction-sql.md` for ready-to-use SQL templates (drop redundant indexes, create missing FK indexes, set NOT NULL, extract 3NF violations to lookup tables).

### Step 8 — Generate Alembic migration

→ Load `references/alembic-migration.md` for the Alembic migration skeleton (upgrade + downgrade) wrapping the correction SQL.

### Step 9 — Custom linter config (YAML)

→ Load `references/schemacrawler-config.md` for the YAML linter-config format (disable linters, override severity, custom SQL lints) and the `--linter-configs` invocation.

### Step 10 — Expected response format

1. **Summary**: SchemaCrawler high/medium/low counts + normalization issues found
2. **P1**: structural lints with ready-to-use SQL
3. **P2**: design smells and normalization violations with impact explanation
4. **P3**: naming and convention issues
5. **What we ignore** and why
6. **Alembic migration** if the user wants to version the corrections

---

## References

| File | Description |
|------|-------------|
| `references/schemacrawler-config.md` | SchemaCrawler lint command, linter reference table, and custom YAML config |
| `references/schema-queries.md` | `information_schema` smart query + 1NF/2NF/3NF normalization analysis |
| `references/correction-sql.md` | SQL templates for redundant indexes, missing FK indexes, NOT NULL, 3NF extraction |
| `references/alembic-migration.md` | Alembic migration skeleton (upgrade/downgrade) for schema fixes |