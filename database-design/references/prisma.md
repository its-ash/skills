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
