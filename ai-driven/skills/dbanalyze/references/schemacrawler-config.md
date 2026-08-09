# SchemaCrawler Configuration & Linter Reference

## Step 1 — Run SchemaCrawler lint

```bash
schemacrawler \
  --server=<server> \
  --host=localhost \
  --port=5432 \
  --database=<database> \
  --schemas=public \
  --user=<user> \
  --password=<password> \
  --info-level=maximum \
  --command=lint
```

**Supported servers:** `postgresql`, `mysql`, `sqlserver`, `oracle`, `sqlite`, `db2`

**Connection conventions per project:**
- ubby → `--server=postgresql --database=ubby --user=ubby --password=ubby`
- pickpro → `--server=postgresql --database=pickpro --user=pickpro --password=pickpro`
- If the password is unknown, ask the user

---

## Step 3 — SchemaCrawler linter reference

| Linter | Description | Severity |
|--------|-------------|----------|
| `LinterColumnTypes` | Same column name, different types across tables | medium |
| `LinterForeignKeyMismatch` | FK type differs from referenced PK type | high |
| `LinterForeignKeySelfReference` | FK self-references PK — record cannot be deleted | medium |
| `LinterForeignKeyWithNoIndexes` | FK columns with no index — seq scans on lookups | high |
| `LinterNullColumnsInIndex` | Nullable columns in unique index — uniqueness not guaranteed | medium |
| `LinterNullIntendedColumns` | Default value is string `'NULL'` instead of actual NULL | medium |
| `LinterRedundantIndexes` | Index already covered by another index | high |
| `LinterTableAllNullableColumns` | All non-PK columns nullable — design smell | medium |
| `LinterTableCycles` | Cyclical FK relationships — delete/insert issues | high |
| `LinterTableEmpty` | Table has no data | low |
| `LinterTableWithBadlyNamedColumns` | Columns named according to forbidden patterns | medium |
| `LinterTableWithIncrementingColumns` | Columns `col1`, `col2` etc — denormalization indicator | medium |
| `LinterTableWithNoIndexes` | Table has no indexes at all | high |
| `LinterTableWithNoPrimaryKey` | Table has no primary key | high |
| `LinterTableWithNoRemarks` | Tables or columns with no comments | low |
| `LinterTableWithNoSurrogatePrimaryKey` | Composite PK — recommends surrogate key | low |
| `LinterTableWithPrimaryKeyNotFirst` | PK columns are not first in table | low |
| `LinterTableWithQuotedNames` | Names with spaces or SQL reserved words | medium |
| `LinterTableWithSingleColumn` | Table with no columns or only one column | medium |
| `LinterTooManyLobs` | Too many CLOB/BLOB columns (default: >1) | medium |
| `LinterCatalogSql` | Custom SQL lint at database level | configurable |
| `LinterTableSql` | Custom SQL lint per table | configurable |

---

## Step 9 — Custom linter config (YAML)

```yaml
linters:
  - id: schemacrawler.tools.linter.LinterTableWithNoRemarks
    run: false
  - id: schemacrawler.tools.linter.LinterTableWithNoPrimaryKey
    severity: critical
  - id: schemacrawler.tools.linter.LinterTooManyLobs
    config:
      max-large-objects: 3
  - id: schemacrawler.tools.linter.LinterCatalogSql
    config:
      message: "Tables without created_at column"
      sql: >
        SELECT table_name FROM information_schema.columns
        WHERE table_schema = 'public'
        GROUP BY table_name
        HAVING SUM(CASE WHEN column_name = 'created_at' THEN 1 ELSE 0 END) = 0
        LIMIT 1
```

```bash
schemacrawler \
  --server=postgresql \
  --host=localhost \
  --port=5432 \
  --database=<database> \
  --schemas=public \
  --user=<user> \
  --password=<password> \
  --info-level=maximum \
  --command=lint \
  --linter-configs=schemacrawler-linter-config.yaml
```