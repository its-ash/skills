# Schema Design Reference

## Database categories

| Category | Engines |
|---|---|
| Relational | PostgreSQL, MySQL, MariaDB, SQL Server, SQLite (simple or local apps) |
| Document | MongoDB, Firestore, CouchDB |
| Key-value | Redis, DynamoDB, Memcached |
| Wide-column | Cassandra, ScyllaDB, HBase |
| Time-series | TimescaleDB, InfluxDB, ClickHouse |
| Graph | Neo4j, Amazon Neptune |
| Search | Elasticsearch, OpenSearch, Meilisearch |
| NewSQL / distributed | CockroachDB, TiDB, Google Spanner |

## Design workflow

1. Analysis: entities, relationships, access patterns (read-heavy vs write-heavy).
2. Conceptual: map business concepts to entities; draw the ERD in Mermaid.
3. Logical: SQL → normalize to 3NF, denormalize only for proven read paths. NoSQL → embed for fast related reads; reference for flexibility or large sets.
4. Physical: exact data types, constraints, indexes.

## Index types

| Type | Use |
|---|---|
| B-tree | Equality and range |
| Composite | Multi-column filters; most selective column first |
| GIN / GiST | JSONB, full-text, spatial |
| Partial | Subset of rows; saves space |

## Scaling

- Vertical: more CPU, RAM, IOPS.
- Horizontal: read replicas; sharding (choose shard key with care); partitioning (range, hash, list).
- Cache: cache-aside or write-through with Redis or Memcached ([redis.md](redis.md)).

## Anti-patterns

| Anti-pattern | Problem | Fix |
|---|---|---|
| `VARCHAR(255)` everywhere | Wastes storage, hides intent | Size per field |
| FLOAT for money | Rounding errors | `DECIMAL(10,2)` |
| No FK constraints | Orphaned rows | Explicit FKs with `ON DELETE` |
| Dates as strings | No sort or compare | `DATE` / `TIMESTAMP` |
| Irreversible migrations | No recovery | Write `DOWN` scripts |
| Full SQL server for trivial app | Overkill | SQLite or NoSQL |
| `SELECT *` | Extra I/O, brittle | List columns |
| Queries in a loop (N+1) | Many round trips | JOIN or eager load |

## Review checklist

- [ ] Every table has a primary key.
- [ ] Every relationship has an FK and an `ON DELETE` strategy.
- [ ] Indexes on all FKs and high-cardinality filter columns.
- [ ] Correct types: `DECIMAL` for money, `TIMESTAMP` for dates.
- [ ] `NOT NULL` on all required fields.
- [ ] `created_at` and `updated_at` on every table.
- [ ] Migrations reversible and backward compatible.
- [ ] Access patterns justify normalization or denormalization.
