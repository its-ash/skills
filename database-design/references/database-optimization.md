# Database Optimization

Expert guidance for modern database performance tuning, query optimization, and scalable architecture design across OLTP and OLAP environments.

## When to use

- Optimizing slow queries or analyzing execution plans (EXPLAIN ANALYZE).
- Designing indexing strategies for high-traffic applications.
- Resolving N+1 query patterns in ORMs or GraphQL APIs.
- Scaling databases via partitioning, sharding, or read replicas.
- Tuning database configurations for production environments.
- Designing schemas for cloud-native or hybrid HTAP systems.
- Implementing multi-tier caching architectures.

## Query Optimization Workflow

1. **Performance Assessment**: Identify bottlenecks using slow query logs, `pg_stat_statements` (Postgres), Performance Schema (MySQL), or Cloud Insights (AWS/Azure/GCP).
2. **Execution Plan Analysis**: Run `EXPLAIN ANALYZE` to identify scan types (Seq Scan vs Index Scan), join strategies (Hash vs Nested Loop), and cost-based bottlenecks.
3. **Query Rewriting**: 
    - Replace inefficient subqueries with JOINs or CTEs.
    - Optimize window functions and recursive queries.
    - Implement efficient pagination (keyset pagination over OFFSET).
4. **Indexing Strategy**: 
    - Apply B-tree for range/equality, GIN/GiST for full-text/JSONB, and BRIN for very large sequential tables.
    - Create composite indexes based on column selectivity and query order.
    - Use partial indexes to reduce index size and improve write performance.
5. **Validation**: Benchmark the optimized query against the original using realistic data volumes and concurrent load.

## Optimization Rules & Patterns

### Indexing & Storage
- **Selectivity First**: Place the most selective columns first in composite indexes.
- **Covering Indexes**: Include frequently accessed columns in the index to avoid heap fetches.
- **Avoid Over-indexing**: Balance read performance with write overhead; remove unused or redundant indexes.
- **Data Types**: Use the smallest sufficient data type to reduce I/O and memory usage.

### Application Integration
- **N+1 Resolution**: Use eager loading (JOIN FETCH, `select_related`, `prefetch_related`) or DataLoader patterns for GraphQL.
- **Connection Management**: Optimize pool sizing and timeouts to prevent connection exhaustion.
- **Transaction Scope**: Keep transactions short to minimize lock contention and prevent deadlocks.

### Scaling & Caching
- **Read Scaling**: Implement read replicas and manage eventual consistency.
- **Write Scaling**: Use batch processing, asynchronous writes, or sharding for write-heavy workloads.
- **Partitioning**: Use range, hash, or list partitioning for massive tables to improve maintainability and query pruning.
- **Caching Tiers**: 
    - L1: Application-level/In-memory.
    - L2: Distributed cache (Redis/Memcached) using Cache-Aside or Write-Through patterns.
    - L3: Database buffer pool tuning.

## Database-Specific Tuning

### PostgreSQL
- **Memory Tuning**: Adjust `shared_buffers`, `work_mem`, and `effective_cache_size` based on available RAM.
- **Vacuum Management**: Configure `autovacuum` to prevent table bloat and maintain statistics.
- **Maintenance**: Regularly run `ANALYZE` to update the query planner's statistics.

### Cloud-Native (Aurora, Snowflake, BigQuery)
- **Storage Tiering**: Use columnar storage for analytical (OLAP) workloads.
- **Auto-scaling**: Configure elastic pools or serverless tiers for variable workloads.
- **Cost Control**: Identify expensive queries via resource usage metrics to reduce cloud spend.

## Common Pitfalls

- **Indexing Every Column**: Increases write latency and storage costs without guaranteed read gains.
- **Ignoring Statistics**: Relying on theoretical optimization without checking actual execution plans.
- **Over-Normalization**: Excessive JOINs in read-heavy systems; consider strategic denormalization.
- **Production Testing**: Running heavy analytical queries on production without limits or read replicas.

## Checklist

- [ ] Slow queries identified via profiling tools.
- [ ] Execution plans analyzed for scan and join efficiency.
- [ ] Indexing strategy aligned with actual query patterns.
- [ ] N+1 queries eliminated in the application layer.
- [ ] Database configuration tuned for the specific hardware/instance size.
- [ ] Maintenance tasks (Vacuum/Analyze) automated.
- [ ] Monitoring and alerting configured for performance regressions.
- [ ] Scalability plan (Partitioning/Sharding) documented for future growth.

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](database-migration.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`performance`](../../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`django`](../../backend-development/references/django.md) — Provides concise, production‑ready guidance for Django 5.x projects, covering async views, DRF, Celery, Channe…
- [`prisma`](prisma.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
