# PostgreSQL Schema Design

Design robust, maintainable PostgreSQL tables. Follow the rules, choose appropriate types, add needed indexes, and plan for scale, security, and future changes.

## When to Use
- You are creating a new PostgreSQL database or adding tables.
- You need to pick data types, constraints, or indexes for a specific access pattern.
- You plan partitioning, row‑level security, or use extensions such as `pgvector` or `timescaledb`.
- You are reviewing an existing schema for performance, maintainability, or security.

## Core Design Rules
- **Primary Key**: Define a PK for reference tables. Use `BIGINT GENERATED ALWAYS AS IDENTITY` unless you need global uniqueness, then use `UUID` (`uuid_generate_v4()` or `gen_random_uuid()`).
- **Normalization**: Model to 3NF first. Denormalize only after measuring a clear read‑performance gain.
- **NOT NULL & DEFAULT**: Add `NOT NULL` wherever the column must have a value. Use `DEFAULT` for common values.
- **Indexes**: Create indexes only for query paths you actually use. Include PK/unique, foreign‑key columns, frequent filters, sort keys, and join keys.
- **Naming**: Use unquoted, lower‑case `snake_case` for tables and columns. Avoid mixed‑case or quoted identifiers.
- **Versioning**: Keep schema changes in migration files. Test on staging before production.

## Data Types
| Category | Recommended Type | Notes |
|---|---|---|
| **Identifiers** | `BIGINT GENERATED ALWAYS AS IDENTITY` or `UUID` | Use `UUID` only when you need opaque, globally unique IDs.
| **Integers** | `BIGINT` (default) or `INTEGER` if range is small | Avoid `SMALLINT` unless you are certain of the range.
| **Floating‑point** | `DOUBLE PRECISION` | Use `NUMERIC` for exact decimal arithmetic.
| **Strings** | `TEXT` | Use `CHECK (length(col) <= n)` instead of `VARCHAR(n)`. Avoid `CHAR`.
| **Case‑insensitive text** | `CITEXT` extension or expression index `LOWER(col)` | Use `CITEXT` only when you need case‑insensitive constraints.
| **Money** | `NUMERIC(p,s)` | Never use the `money` type.
| **Timestamps** | `TIMESTAMPTZ` | Use `now()` for transaction start time, `clock_timestamp()` for wall‑clock time.
| **Booleans** | `BOOLEAN NOT NULL` | Add `NOT NULL` unless you need a tri‑state.
| **Enums** | `CREATE TYPE ... AS ENUM` for stable small sets | For evolving sets, use `TEXT` + `CHECK` or a lookup table.
| **Arrays** | `TYPE[]` (e.g., `TEXT[]`) | Index with GIN for containment queries. Use for ordered lists, not for relations.
| **Range types** | `tstzrange`, `daterange`, `numrange` | Index with GiST. Use `[)` bounds by default.
| **Network** | `INET`, `CIDR`, `MACADDR` | Provides network operators.
| **Geometric** | `POINT`, `LINE`, `POLYGON`, `CIRCLE` | Index with GiST; for advanced GIS use PostGIS.
| **Full‑text** | `TSVECTOR` + `TSQUERY` | Index with GIN. Always specify language, e.g. `to_tsvector('english', col)`.
| **JSON** | `JSONB` | Preferred for semi‑structured data. Index with GIN. Use plain `JSON` only when order matters.
| **Vector** | `vector` (pgvector) | For embedding similarity search.
| **Domain** | `CREATE DOMAIN` for reusable validation (e.g., email). |
| **Composite** | `CREATE TYPE` for structured column values. |

### Types to Avoid
- `timestamp` without time zone – use `timestamptz`.
- `char(n)` or `varchar(n)` – use `text` with `CHECK` for length.
- `money` – use `numeric`.
- `serial` – use identity columns.
- `timetz` – use `timestamptz`.

## Constraints
- **PRIMARY KEY** – implicit `UNIQUE NOT NULL`. Creates a B‑tree index.
- **FOREIGN KEY** – always add an explicit index on the referencing column. Use `ON DELETE/UPDATE` actions as needed. For circular dependencies, add `DEFERRABLE INITIALLY DEFERRED`.
- **UNIQUE** – creates a B‑tree index. PostgreSQL allows multiple `NULL`s; use `NULLS NOT DISTINCT` (PG15+) to treat `NULL` as a distinct value.
- **CHECK** – validates column values. `NULL` passes the check, so combine with `NOT NULL` when required.
- **EXCLUDE** – prevents overlapping values (e.g., double‑booking). Requires GiST index.

## Indexing Strategies
- **B‑tree** – default for equality and range queries.
- **Composite** – order columns by selectivity; leftmost prefix must be used in the query.
- **Covering** – `INCLUDE (col1, col2)` to allow index‑only scans.
- **Partial** – index a subset, e.g. `WHERE status = 'active'`.
- **Expression** – index computed values, e.g. `LOWER(email)`. Query must use the same expression.
- **GIN** – for `JSONB`, arrays, and full‑text search.
- **GiST** – for range, geometric, and exclusion constraints.
- **BRIN** – for very large, naturally ordered tables (time‑series). Works well after `CLUSTER`.

## Partitioning
- Use declarative partitioning for tables > 100 M rows or when queries always filter on a partition key.
- **RANGE** – typical for time‑series: `PARTITION BY RANGE (created_at)`. Create partitions with `FOR VALUES FROM ... TO ...`.
- **LIST** – for discrete values such as region codes.
- **HASH** – for even distribution when no natural key exists.
- Include the partition key in PK/UNIQUE constraints because global uniqueness is not enforced.
- Do **not** use table inheritance; use declarative partitioning only.
- Foreign keys from partitioned tables are not supported; use triggers if needed.

## Row‑Level Security (RLS)
```sql
ALTER TABLE tbl ENABLE ROW LEVEL SECURITY;
CREATE POLICY user_access ON orders
  FOR SELECT TO app_user
  USING (user_id = current_setting('app.current_user_id')::bigint);
```
- Define policies for each operation (SELECT, INSERT, UPDATE, DELETE).
- Use `current_setting` or a custom function to expose the session user ID.

## Extensions & Advanced Features
| Extension | Use Case |
|---|---|
| `pgcrypto` | Password hashing (`crypt()`). |
| `uuid-ossp` | Legacy UUID generators (prefer `pgcrypto`). |
| `pg_trgm` | Fuzzy text search (`%` operator). Index with GIN. |
| `citext` | Case‑insensitive text column. |
| `btree_gin` / `btree_gist` | Mixed‑type GIN/GiST indexes. |
| `hstore` | Simple key‑value pairs (mostly superseded by `jsonb`). |
| `timescaledb` | Automated time‑series partitioning, compression, continuous aggregates. |
| `postgis` | Full GIS support. |
| `pgvector` | Vector similarity search for embeddings. |
| `pgaudit` | Audit logging of all activity. |

## JSONB Guidance
- Store optional or semi‑structured attributes in `JSONB`.
- Create a GIN index: `CREATE INDEX ON tbl USING GIN (jsonb_col);`
- For heavy containment (`@>`) queries, use `jsonb_path_ops` opclass for a smaller index.
- To query a scalar field efficiently, add a generated column and index it:
```sql
ALTER TABLE tbl ADD COLUMN price INT GENERATED ALWAYS AS ((jsonb_col->>'price')::INT) STORED;
CREATE INDEX ON tbl (price);
```
- Use `CHECK (jsonb_typeof(col) = 'object')` to enforce object shape.

## Performance‑Focused Tips
### Insert‑Heavy Workloads
- Minimize indexes; each index adds write overhead.
- Use `COPY` or multi‑row `INSERT`.
- Consider `UNLOGGED` tables for temporary staging data.
- Defer index creation: drop indexes, load data, recreate.
- Partition by time or hash to spread inserts.

### Update‑Heavy Tables
- Separate hot columns into a separate table to reduce bloat.
- Set `fillfactor = 90` on indexes to leave room for HOT updates.
- Avoid updating indexed columns when possible.
- Partition by update pattern if a subset is updated frequently.

### Upsert Design
- Ensure a `UNIQUE` index exists on the conflict target columns.
- Use `ON CONFLICT (col1, col2) DO UPDATE SET ...`.
- Reference the incoming row with `EXCLUDED.column`.
- Prefer `DO NOTHING` when you do not need to modify existing rows.

## Safe Schema Evolution
- Run DDL inside a transaction to test rollback: `BEGIN; ALTER TABLE ...; ROLLBACK;`.
- Use `CREATE INDEX CONCURRENTLY` to avoid blocking writes (cannot run inside a transaction).
- Adding a `NOT NULL` column with a volatile default rewrites the whole table; use a stable default or add the column nullable then backfill and set `NOT NULL`.
- Drop constraints before dropping columns to avoid dependency errors.
- `CREATE OR REPLACE FUNCTION` adds an overload; drop the old version if not needed.

## Generated Columns
- Stored generated columns: `col GENERATED ALWAYS AS (expr) STORED`.
- PG18+ adds `VIRTUAL` columns that compute on read (no storage).
- Use generated columns for indexing derived values, e.g., JSONB fields.

## Query Patterns
| Query pattern | Index | Example |
|---|---|---|
| `WHERE col = v` or `col > v` | B-tree | `CREATE INDEX ON t (col)` |
| `WHERE a = x AND b > y` | Composite (equality first, then range) | `CREATE INDEX ON orders (status, created_at)` |
| `SELECT email, name ... WHERE email = ?` | Covering | `CREATE INDEX ON users (email) INCLUDE (name, created_at)` |
| Only active rows | Partial | `CREATE INDEX ON users (email) WHERE deleted_at IS NULL` |
| `jsonb @> '{}'`, `tsv @@ query` | GIN | `CREATE INDEX ON t USING gin (col)` |
| Time-series ranges | BRIN | `CREATE INDEX ON t USING brin (created_at)` |

```sql
-- Keyset pagination: constant cost; OFFSET reads and discards all earlier rows
SELECT * FROM products WHERE id > $1 ORDER BY id LIMIT 20;

-- Queue claim: workers do not block each other
UPDATE jobs SET status = 'processing'
WHERE id = (
  SELECT id FROM jobs WHERE status = 'pending'
  ORDER BY created_at LIMIT 1
  FOR UPDATE SKIP LOCKED
) RETURNING *;

-- RLS: wrap the function in SELECT so it runs once for each query, not once for each row
CREATE POLICY orders_owner ON orders USING ((SELECT auth.uid()) = user_id);
```

## Diagnostics
```sql
-- Foreign keys without an index
SELECT c.conrelid::regclass AS table_name, a.attname AS column_name
FROM pg_constraint c
JOIN pg_attribute a ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
WHERE c.contype = 'f'
  AND NOT EXISTS (
    SELECT 1 FROM pg_index i
    WHERE i.indrelid = c.conrelid AND a.attnum = ANY(i.indkey)
  );

-- Slow queries (needs the pg_stat_statements extension)
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
WHERE mean_exec_time > 100
ORDER BY mean_exec_time DESC;

-- Tables with many dead rows (bloat)
SELECT relname, n_dead_tup, last_autovacuum
FROM pg_stat_user_tables
WHERE n_dead_tup > 1000
ORDER BY n_dead_tup DESC;
```

## Server Settings
```sql
ALTER SYSTEM SET idle_in_transaction_session_timeout = '30s';
ALTER SYSTEM SET statement_timeout = '30s';        -- Or set it for each app role
ALTER SYSTEM SET work_mem = '8MB';                 -- Applies to each sort or hash operation
CREATE EXTENSION IF NOT EXISTS pg_stat_statements; -- Also add it to shared_preload_libraries
REVOKE ALL ON SCHEMA public FROM public;
SELECT pg_reload_conf();
```
- Keep `max_connections` low (about 100) and put a pooler (PgBouncer, or the platform pooler) in front of the app.
- Size these values from the RAM and the workload. They are a start point, not fixed rules.

## Checklist
- [ ] Capture entities, access patterns, and scale targets (row count, QPS, retention).
- [ ] Choose appropriate data types and add `NOT NULL`/`DEFAULT` where needed.
- [ ] Define a primary key for reference tables.
- [ ] Add foreign‑key constraints and explicit indexes on FK columns.
- [ ] Create indexes only for real query paths (PK, FK, filters, sorts, joins).
- [ ] Use partial or expression indexes for selective queries.
- [ ] Plan partitioning if table exceeds 100 M rows or requires time‑based pruning.
- [ ] Enable RLS and write policies for each operation.
- [ ] Review JSONB usage: store optional data, add GIN index, consider generated columns for scalar fields.
- [ ] Verify that `EXPLAIN` shows index usage for critical queries.
- [ ] Run migrations on a staging environment before production.
- [ ] Ensure backups and a rollback plan exist before applying destructive DDL.
- [ ] Document any extensions used and their version requirements.
