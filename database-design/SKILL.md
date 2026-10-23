---
name: database-design
description: "Designs data layers by selecting database technologies, modeling schemas, and planning migrations for scalable architectures. Use when choosing SQL or NoSQL databases like PostgreSQL MySQL MongoDB, creating entity relationship diagrams ERD, normalizing tables, defining constraints indexes partitions, writing migration scripts, optimizing query performance, or reviewing production schema designs. Sub-skills: database-migration, database-optimization, prisma, drizzle-orm."
---

# Database Design

Expert guidance for designing scalable, performant, and maintainable data layers. This skill covers the entire lifecycle from technology selection and conceptual modeling to physical implementation and migration planning.

## When to use
- Selecting database technologies or storage patterns based on access patterns.
- Designing schemas, partitions, or replication strategies.
- Planning migrations or re-architecting existing data layers.
- Designing for specific workloads: OLTP (transactional) or OLAP (analytical).
- Implementing multi-tenancy, event sourcing, or CQRS architectures.

## Technology Selection

Choose the database based on the data domain, consistency requirements (CAP theorem), and scale targets. Do not default to a single database (e.g., PostgreSQL) for every project.

### Database Categories
- **Relational (SQL):** PostgreSQL, MySQL, MariaDB, SQL Server, SQLite (for simple/local apps).
- **NoSQL Document:** MongoDB, Firestore, CouchDB.
- **Key-Value:** Redis, DynamoDB, Memcached.
- **Wide-Column:** Cassandra, ScyllaDB, HBase.
- **Time-Series:** TimescaleDB, InfluxDB, ClickHouse.
- **Graph:** Neo4j, Amazon Neptune.
- **Search Engines:** Elasticsearch, OpenSearch, Meilisearch.
- **NewSQL/Distributed:** CockroachDB, TiDB, Google Spanner.

## Data Modeling & Schema Design

### Design Workflow
1. **Analysis:** Identify entities, relationships, and access patterns (read-heavy vs. write-heavy).
2. **Conceptual Design:** Map business requirements to entities; create ERDs (use Mermaid syntax).
3. **Logical Design:** 
   - **SQL:** Normalize to 3NF to reduce redundancy. Use denormalization only for read-performance optimization.
   - **NoSQL:** Decide between embedding (for fast reads of related data) or referencing (for flexibility/large datasets).
4. **Physical Design:** Select precise data types, define constraints, and plan indexing.

### Core Rules
- **Model the Domain:** Design based on business concepts, not UI layouts.
- **Data Integrity:** Enforce constraints at the database level (NOT NULL, UNIQUE, CHECK).
- **Primary Keys:** Use BIGINT for standard IDs or UUIDs for distributed systems.
- **Foreign Keys:** Always define FK constraints and specify an `ON DELETE` strategy.
- **Money/Currency:** Never use FLOAT; always use `DECIMAL` or `NUMERIC`.
- **Timestamps:** Include `created_at` and `updated_at` for every table.

## Indexing & Performance

### Indexing Strategy
- **Mandatory Indexes:** Index every foreign key to prevent slow JOINs.
- **Query-Based Indexing:** Create indexes on columns frequently used in `WHERE`, `ORDER BY`, and `JOIN` clauses.
- **Index Types:**
  - **B-Tree:** Standard for equality and range queries.
  - **Composite:** Order columns by selectivity (most selective first).
  - **GIN/GiST:** For JSONB, full-text search, or spatial data.
  - **Partial:** Index only a subset of rows to save space.

### Optimization Patterns
- **N+1 Prevention:** Use eager loading or JOINs instead of multiple queries in a loop.
- **Query Design:** Avoid `SELECT *`; explicitly list required columns.
- **Caching:** Implement Cache-aside or Write-through patterns using Redis/Memcached.
- **Scaling:** 
  - **Vertical:** Increase resources.
  - **Horizontal:** Read replicas, sharding (select shard keys carefully), and partitioning (range, hash, or list).

## Migration & Evolution

### Migration Strategy
- **Version Control:** Use tools like Flyway, Liquibase, Alembic, or Prisma Migrate.
- **Reversibility:** Every migration must have a corresponding `DOWN` script to rollback changes.
- **Zero-Downtime Patterns:** 
  - Use the Strangler pattern for large re-architectures.
  - For `NOT NULL` constraints on existing tables: Add as nullable $\rightarrow$ backfill data $\rightarrow$ apply constraint.
  - Use online schema change tools for large tables to avoid locking.

## Pitfalls & Anti-Patterns

| Anti-Pattern | Why it's bad | Better Approach |
| :--- | :--- | :--- |
| `VARCHAR(255)` everywhere | Wastes storage; hides intent | Size appropriately per field |
| FLOAT for money | Rounding errors | `DECIMAL(10,2)` |
| Missing FK constraints | Orphaned data/corruption | Define explicit Foreign Keys |
| Storing dates as strings | Cannot sort or compare | `DATE` or `TIMESTAMP` types |
| Non-reversible migrations | Cannot recover from failure | Always write `DOWN` scripts |
| Defaulting to SQL for all | Overkill for simple apps | Consider SQLite or NoSQL |

## Checklist
- [ ] Every table has a primary key.
- [ ] All relationships have foreign key constraints and `ON DELETE` strategies.
- [ ] Indexes exist on all foreign keys and high-cardinality filter columns.
- [ ] Appropriate data types used (e.g., `DECIMAL` for money, `TIMESTAMP` for dates).
- [ ] `NOT NULL` constraints applied to all required fields.
- [ ] `created_at` and `updated_at` timestamps included.
- [ ] Migration scripts are reversible and backward compatible.
- [ ] Access patterns analyzed to justify normalization vs. denormalization.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/postgresql.md](references/postgresql.md) | Guidelines for designing PostgreSQL schemas, selecting data types, defining constraints, creating indexes, partitioning, RLS, extensions, and performance‑related best practices. Use when you need a production‑ready PostgreSQL table design or want to review an existing schema. |

## Related skills

Load these when the task spans more than this skill.

- [`database-migration`](references/database-migration.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`database-optimization`](references/database-optimization.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`nestjs`](../backend-development/references/nestjs.md) — Expert guidance for NestJS applications covering module architecture, dependency injection, middleware, guards…
| [references/database-migration.md](references/database-migration.md) | Guides database schema and data migrations across Sequelize, TypeORM, and Prisma with safe column additions, renames, type changes, data backfills, and zero-downtime patterns like expand-contract and dual-write. Use when running npx sequelize db:migrate, npx typeorm migration:run, or npx prisma migrate deploy, executing ALTER TABLE for NOT NULL columns with defaults, two-step column renames, varchar-to-text changes on large tables, UPDATE backfills, BEGIN TRANSACTION atomic blocks, backup-table checkpoints, PostgreSQL MySQL SQLite dialect handling, and rollback scripts after failed deployments. |
| [references/database-optimization.md](references/database-optimization.md) | Expert database optimization for SQL and NoSQL systems. Use when tuning slow queries, designing indexing strategies, analyzing performance bottlenecks, or scaling architectures in PostgreSQL, MySQL, Snowflake, MongoDB, BigQuery, and Aurora. Covers query plan analysis, execution time reduction, storage efficiency, caching patterns, and cloud-native database configuration. Trigger terms include slow query, index optimization, EXPLAIN plan, query performance, database scaling, connection pooling, partitioning, and latency reduction. |
| [references/prisma.md](references/prisma.md) | Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation modeling, connection management, and transactions. Use when you encounter schema errors, migration conflicts, performance issues, or connection problems in PostgreSQL, MySQL, or SQLite projects, or when working with Prisma schema, Prisma Client, prisma migrate, prisma db push, prisma db pull, relations, indexes, foreign keys, N+1 queries, connection pooling, transactions, rollbacks, deadlocks, slow queries, schema drift, migration locks, shadow databases, introspection, seeding, or Prisma Studio. |
| [references/drizzle-orm.md](references/drizzle-orm.md) | Use Drizzle ORM in TypeScript projects to define schemas, infer types, run relational queries, manage migrations, and connect serverless databases. Use when working with drizzle-orm, drizzle-kit, pgTable, mysqlTable, sqliteTable, relations, db.select, db.insert, db.update, db.delete, drizzle-kit generate, drizzle-kit migrate, drizzle-kit push, schema.ts, .sql migration files, Neon, Vercel Postgres, Turso, or Next.js data access. |
