---
name: database-design
description: "Designs data layers by selecting database technologies, modeling schemas, and planning migrations for scalable architectures. Use when choosing SQL or NoSQL databases like PostgreSQL MySQL MongoDB, creating entity relationship diagrams ERD, normalizing tables, defining constraints indexes partitions, writing migration scripts, optimizing query performance, or reviewing production schema designs. Sub-skills: postgresql, mysql-patterns, clickhouse, redis, database-migration, database-optimization, prisma, drizzle-orm."
---
# Database Design

Choose the store, model the schema, index it, and evolve it safely.

## Core rules
- Pick the database from access patterns, consistency needs (CAP), and scale. Do not default to one engine.
- Model business concepts, not UI layouts.
- Enforce integrity in the database: `NOT NULL`, `UNIQUE`, `CHECK`.
- Use `BIGINT` primary keys; use UUIDs for distributed systems.
- Define every FK with an explicit `ON DELETE` strategy, and index every FK.
- Store money as `DECIMAL`/`NUMERIC`, never FLOAT. Store dates as `DATE`/`TIMESTAMP`, never strings.
- Add `created_at` and `updated_at` to every table.
- Index columns used in `WHERE`, `ORDER BY`, and `JOIN`. Order composite columns most selective first.
- List columns explicitly; avoid `SELECT *`. Prevent N+1 with JOINs or eager loading.
- Version every migration (Flyway, Liquibase, Alembic, Prisma Migrate) and write a `DOWN` script.
- Add `NOT NULL` to a live table in steps: add nullable → backfill → apply constraint.
- Use online schema-change tools on large tables to avoid locks.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Transactional, relational data (OLTP) | PostgreSQL / MySQL, normalize to 3NF | Document store for joins-heavy data |
| Simple or local app | SQLite | A database server |
| Analytics, events, time-series (OLAP) | ClickHouse / TimescaleDB | Row-store aggregates at scale |
| Cache, sessions, rate limits, locks | Redis | Cache in the primary DB |
| Flexible nested documents read together | Document DB, embed | Reference when always read together |
| Large or independently updated children | Reference | Unbounded embedded arrays |
| Full-text or faceted search | Elasticsearch / OpenSearch / Meilisearch | `LIKE '%x%'` scans |
| Relationship traversal | Graph DB (Neo4j) | Deep recursive SQL joins |
| Global scale + strong consistency | NewSQL (CockroachDB, Spanner) | Hand-rolled sharding |
| Read-heavy hot path proven slow | Denormalize or add a replica | Denormalize before you measure |
| Large re-architecture | Strangler pattern, expand-contract | Big-bang cutover |

## Load on demand

| Need | Read |
|---|---|
| Engine catalog, design workflow, index types, scaling, anti-patterns, review checklist | [references/schema-design.md](references/schema-design.md) |
| PostgreSQL types, constraints, indexes, partitioning, RLS, extensions | [references/postgresql.md](references/postgresql.md) |
| MySQL/MariaDB defaults, EXPLAIN, upserts, keyset pagination, locks, replicas | [references/mysql-patterns.md](references/mysql-patterns.md) |
| ClickHouse MergeTree family, materialized views, funnel/retention queries | [references/clickhouse.md](references/clickhouse.md) |
| Redis caching, locks, rate limits, Streams, eviction, stampede prevention | [references/redis.md](references/redis.md) |
| Zero-downtime migrations, backfills, expand-contract, rollback (many ORMs) | [references/database-migration.md](references/database-migration.md) |
| Slow queries, EXPLAIN plans, indexing strategy, pooling, scaling | [references/database-optimization.md](references/database-optimization.md) |
| Prisma schema, migrate, relations, transactions, P2002/P2025/P2003 | [references/prisma.md](references/prisma.md) |
| Drizzle ORM schema, queries, drizzle-kit, serverless DBs | [references/drizzle-orm.md](references/drizzle-orm.md) |

## Related skills
- [`backend-development`](../backend-development/SKILL.md) — APIs and services on top of the data layer
- [`software-architecture`](../software-architecture/SKILL.md) — CQRS, event sourcing, multi-tenancy decisions
- [`nestjs`](../backend-development/references/nestjs.md) — NestJS data access and modules
- [`java`](../java/SKILL.md) — JPA, Hibernate, MyBatis
- [`kotlin`](../kotlin/SKILL.md) — Exposed ORM, HikariCP, Flyway
