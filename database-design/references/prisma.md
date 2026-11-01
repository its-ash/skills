# Prisma

Use this skill to solve Prisma ORM problems. It covers schema design, migrations, query performance, relation definitions, connection handling, and transaction patterns for PostgreSQL, MySQL, and SQLite.

## When to use
- Schema errors or missing indexes
- Migration conflicts or failed deployments
- N+1 queries, over‑fetching, or slow queries
- Connection pool exhaustion or leaks
- Transaction failures or deadlocks

## Environment detection
```bash
# Prisma version
npx prisma --version 2>/dev/null || echo "Prisma not installed"

# Database provider (postgresql, mysql, sqlite)
grep "provider" prisma/schema.prisma 2>/dev/null | head -1

# List existing migrations
ls -la prisma/migrations/ 2>/dev/null | head -5

# Check client generation
ls -la node_modules/.prisma/client/ 2>/dev/null | head -3
```

## Schema design
### Common problems
- Wrong relation definitions cause runtime errors
- Missing indexes on frequently queried fields
- Enum values out of sync with the database
- Field type mismatches

### Diagnosis
```bash
# Validate schema syntax
npx prisma validate

# Detect drift between schema and database
npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma

# Auto‑format schema
npx prisma format
```

### Fix hierarchy
1. **Minimal** – Add or correct `@relation` directives.
2. **Better** – Add `@@index` for hot fields, adjust field types.
3. **Complete** – Normalize models, add composite keys, rename tables with `@@map`.

### Example model
```prisma
model User {
  id        String   @id @default(cuid())
  email     String   @unique
  posts     Post[]   @relation("UserPosts")
  profile   Profile? @relation("UserProfile")
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  @@index([email])
  @@map("users")
}

model Post {
  id       String @id @default(cuid())
  title    String
  author   User   @relation("UserPosts", fields: [authorId], references: [id], onDelete: Cascade)
  authorId String

  @@index([authorId])
  @@map("posts")
}
```

## Migrations
### Common problems
- Conflicting migrations in a team
- Failed migrations leaving the database inconsistent
- Shadow‑database errors during development
- Production deployment failures

### Diagnosis
```bash
# Show migration status
npx prisma migrate status

# List pending migration files
ls -la prisma/migrations/
```

### Fix hierarchy
1. **Minimal** – Reset development DB: `npx prisma migrate reset`.
2. **Better** – Edit the generated SQL, then mark it applied with `npx prisma migrate resolve`.
3. **Complete** – Squash old migrations, create a baseline for new environments.

### Safe workflow
```bash
# Development (creates migration and runs it on a shadow DB)
npx prisma migrate dev --name descriptive_name

# Production (apply only already‑generated migrations)
npx prisma migrate deploy

# If a production migration fails
npx prisma migrate resolve --applied "migration_name"
# or
npx prisma migrate resolve --rolled-back "migration_name"
```

## Query optimization
### Common problems
- N+1 queries when loading related data
- Over‑fetching with large `include` blocks
- Missing `select` causing unnecessary columns
- Slow queries without proper indexes

### Enable query logging
```typescript
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  log: [{ emit: 'event', level: 'query' }],
});

prisma.$on('query', (e) => {
  console.log('Query:', e.query);
  console.log('Duration:', e.duration, 'ms');
});
```

### Fix hierarchy
1. **Minimal** – Use `include` to fetch needed relations in one round.
2. **Better** – Replace `include` with `select` to limit fields.
3. **Complete** – Use `$queryRaw` for complex aggregations or caching.

### Optimized patterns
```typescript
// N+1 problem
const users = await prisma.user.findMany();
for (const u of users) {
  await prisma.post.findMany({ where: { authorId: u.id } });
}

// Fixed with include
const users = await prisma.user.findMany({ include: { posts: true } });

// Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    posts: { select: { id: true, title: true } },
  },
});

// Raw SQL for aggregation
const result = await prisma.$queryRaw`
  SELECT u.id, u.email, COUNT(p.id) AS post_count
  FROM users u
  LEFT JOIN posts p ON p.author_id = u.id
  GROUP BY u.id`;
```

## Connection management
### Common problems
- Exhausted connection pool
- "Too many connections" errors
- Leaked connections in serverless functions
- Slow initial connections

### Diagnosis (PostgreSQL example)
```bash
psql -c "SELECT count(*) FROM pg_stat_activity WHERE datname = 'your_db';"
```

### Fix hierarchy
1. **Minimal** – Set `connection_limit` in `DATABASE_URL`.
2. **Better** – Manage PrismaClient lifecycle (reuse instance, disconnect on shutdown).
3. **Complete** – Deploy an external pooler such as PgBouncer for high traffic.

### Example configuration (serverless)
```typescript
import { PrismaClient } from '@prisma/client';

const globalForPrisma = global as unknown as { prisma: PrismaClient };
export const prisma =
  globalForPrisma.prisma ||
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

process.on('beforeExit', async () => {
  await prisma.$disconnect();
});
```

```env
# Example DATABASE_URL with pool settings
DATABASE_URL="postgresql://user:pass@host:5432/db?connection_limit=5&pool_timeout=10"
```

## Transaction patterns
### Common problems
- Partial writes when a step fails
- Deadlocks under high concurrency
- Long‑running transactions blocking reads
- Confusion between interactive and batch transactions

### Diagnosis
```typescript
try {
  await prisma.$transaction([...]);
} catch (e) {
  if (e.code === 'P2034') console.log('Transaction conflict');
}
```

### Patterns
- **Batch transaction** – Pass an array of Prisma calls.
- **Interactive transaction** – Provide an async callback with a transaction client.
- **Optimistic concurrency** – Use a version field and conditional update.

```typescript
// Batch transaction
const [user, profile] = await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.profile.create({ data: profileData }),
]);

// Interactive transaction with options
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });
  if (user.email.endsWith('@blocked.com')) throw new Error('Blocked domain');
  const profile = await tx.profile.create({ data: { ...profileData, userId: user.id } });
  return { user, profile };
}, {
  maxWait: 5000,
  timeout: 10000,
  isolationLevel: 'Serializable',
});

// Optimistic concurrency update
await prisma.post.update({
  where: { id: postId, version: currentVersion },
  data: { content: newContent, version: { increment: 1 } },
});
```

## Production patterns and traps
Check the version first (`npx prisma --version`). The API changed across major releases:
- `relationJoins` can load relations with one JOIN. On large 1:N relations or deep `include`, the result can get very large. Measure both methods.
- `omit` and Client Extensions (`prisma.$extends`) are in newer releases.
- Newer installs can need a driver adapter (for example `@prisma/adapter-pg`) in the `PrismaClient` constructor, and the datasource URL can be in `prisma.config.ts`.

### ID strategy
| Strategy | Use when | Avoid when |
|---|---|---|
| `@default(cuid())` | Default choice: URL-safe, no collisions | External systems need sequential IDs |
| `@default(uuid())` | Other systems must read the IDs | High-write tables (random UUIDs fragment B-tree indexes) |
| `@default(autoincrement())` | Join tables, audit logs | Public IDs (they show the record count) |

`@unique` already creates an index; do not add `@@index` for the same field. If soft delete is likely, add `deletedAt DateTime?` and `@@index([deletedAt, createdAt])` at the start.

### `include` or `select`, and response DTOs
- `include` returns all scalar fields and the named relations. `select` returns only the named fields. Use `select` on hot paths and wide tables.
- Do not return Prisma entities from an API. Map them to a DTO so that fields such as `passwordHash` do not leak.

### Transaction form
| Situation | Use |
|---|---|
| Independent operations | Array form `$transaction([...])` |
| A step needs the result of an earlier step | Interactive form `$transaction(async (tx) => ...)`, and use only `tx` inside it |
| External calls (email, HTTP) | Outside the transaction |

### Singleton with a driver adapter
```ts
// lib/prisma.ts
import { PrismaClient } from '@prisma/client';   // Or the generated client path
import { PrismaPg } from '@prisma/adapter-pg';

const globalForPrisma = globalThis as unknown as { prisma?: PrismaClient };

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL! }),   // Remove on installs that do not need an adapter
    log: process.env.NODE_ENV === 'development' ? ['query', 'error'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;
```
Each `PrismaClient` opens its own pool. The `globalThis` cache stops new instances on hot reload.

In serverless, put the pool settings in the URL: `?connection_limit=1&pool_timeout=20`, or `?pgbouncer=true&connection_limit=1` with an external pooler. Do not add parameters with string concatenation, because the URL can already have parameters such as `?schema=public`.

### Stable cursor pagination
```ts
async function getPosts(cursor?: string, limit = 20) {
  const items = await prisma.post.findMany({
    where: { published: true },
    orderBy: [{ createdAt: 'desc' }, { id: 'desc' }],   // The unique second key keeps pages stable
    take: limit + 1,
    ...(cursor && { cursor: { id: cursor }, skip: 1 }),
  });
  const hasNextPage = items.length > limit;
  if (hasNextPage) items.pop();
  return { items, nextCursor: hasNextPage ? items[items.length - 1].id : null };
}
```

### Error codes at the service boundary
```ts
import { Prisma } from '@prisma/client';

try {
  await prisma.user.create({ data: { email } });
} catch (e) {
  if (e instanceof Prisma.PrismaClientKnownRequestError) {
    if (e.code === 'P2002') throw new ConflictError('Email already exists');    // Unique violation
    if (e.code === 'P2025') throw new NotFoundError('Record not found');        // Not found
    if (e.code === 'P2003') throw new BadRequestError('Referenced record does not exist');   // Foreign key
  }
  throw e;
}
```
Do not show raw Prisma messages to API clients.

### Traps
- **`updateMany` and `deleteMany` return `{ count }`, not rows.** To get the rows, select the IDs first, update `where: { id: { in: ids } }`, then fetch those IDs.
- **`deleteMany()` with no `where` deletes all rows.** Always give a `where`.
- **`@updatedAt` does not change on `updateMany`.** Set `updatedAt: new Date()` in `data`.
- **The interactive transaction times out after 5 seconds by default** ("Transaction already closed"). Move external calls out. Increase `timeout` only for real bulk work.
- **`migrate dev` can reset the database** when it finds drift. Use it only on a local solo database. Use `migrate deploy` everywhere else. To check drift without changes:
  ```bash
  npx prisma migrate diff --from-migrations ./prisma/migrations \
    --to-schema-datamodel ./prisma/schema.prisma --shadow-database-url "$SHADOW_DATABASE_URL"
  ```
- **Do not edit an applied migration file.** Prisma stores a checksum, and each environment that ran it fails with `P3006`. Write a new migration.
- **Soft delete and `findUniqueOrThrow`:** it returns soft-deleted rows, and `{ id, deletedAt: null }` is not a unique input. Use `findFirstOrThrow({ where: { id, deletedAt: null } })`. Filter `deletedAt: null` explicitly; do not hide it in middleware.
- **A breaking change (new `NOT NULL`, rename) needs more than one migration:** add the column, backfill it in a script or job, then add the constraint in a new migration. See `database-migration.md`.

## Checklist
### Schema quality
- Every model has an `@id` field.
- Relations use explicit `@relation` with `fields` and `references`.
- Cascade rules (`onDelete`, `onUpdate`) are defined where needed.
- Frequently queried columns have `@@index` or composite indexes.
- Enums are defined for fixed value sets.
- Table names follow conventions via `@@map`.

### Query patterns
- No N+1 queries; use `include` or `select` appropriately.
- `select` limits fields to those required.
- Pagination (`skip`, `take`) is applied to list queries.
- Raw SQL is used only for complex aggregations.
- Errors from Prisma calls are caught and logged.

### Performance
- Connection pool size matches deployment environment.
- Indexes exist for all `WHERE` clause columns.
- Composite indexes cover multi‑column filters.
- Query logging is enabled in development.
- Slow queries are identified and optimized.

### Migration safety
- Run migrations in a development sandbox first.
- Use `migrate dev` only locally; `migrate deploy` for production.
- Review generated SQL before applying.
- Have a rollback plan (e.g., `migrate resolve --rolled-back`).
- Avoid schema‑breaking changes without data migration scripts.

### Transaction safety
- Wrap related writes in a single `$transaction`.
- Set appropriate isolation level for critical sections.
- Use version fields for optimistic concurrency when needed.
- Keep transactions short to reduce lock contention.

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](database-migration.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`database-optimization`](database-optimization.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`drizzle-orm`](drizzle-orm.md) — Provides concise guidance for using Drizzle ORM with TypeScript: schema design, relational queries, migrations…
- [`nextjs`](../../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`node`](../../node/SKILL.md) — Node.js project conventions and setup rules. Load when creating, configuring, or working on any Node.js projec…
