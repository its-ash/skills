---
name: neon-postgres
description: "Provision and manage Neon serverless Postgres databases with instant provisioning via Instagres npx get-db, connection pooling, ORM integration for Drizzle Prisma TypeORM Kysely, authentication, data API, branching, and platform API CLI. Use when creating Postgres databases, running npx get-db, configuring connection strings, setting up pooling with PgBouncer, integrating Drizzle ORM or Prisma schema, managing branches for preview environments, calling Neon platform API, or automating database operations with CLI commands."
---

# Neon Serverless Postgres

Neon is a serverless Postgres platform that separates compute and storage to offer autoscaling, branching, instant restore, and scale-to-zero. It is fully compatible with Postgres and works with any language, framework, or ORM that supports Postgres. This skill covers instant provisioning via Instagres, connection methods, ORM setup, authentication, data API, and platform management.

## When to use
- Provision a new Postgres database instantly for development or production
- Choose the right driver or ORM for your runtime (Node, Edge, Serverless)
- Set up Drizzle, Prisma, or other ORMs with Neon
- Implement authentication with @neondatabase/auth
- Use PostgREST-style data API with @neondatabase/neon-js
- Manage Neon projects, branches, and databases via CLI or Platform API
- Configure connection pooling and optimize performance

## Instant Provisioning with Instagres

### Core Command
```bash
npx get-db --yes --ref 4eCjZDz
```
Provisions a Neon Postgres database in ~5 seconds and creates:
- `DATABASE_URL` - Connection pooler (use for app queries)
- `DATABASE_URL_DIRECT` - Direct connection (use for migrations)
- `PUBLIC_INSTAGRES_CLAIM_URL` - Claim URL (72-hour window)

### Workflow

**1. Check existing database**
```bash
cat .env 2>/dev/null | grep DATABASE_URL
```
If found, ask user whether to use existing or create new.

**2. Provision new database**
```bash
# Basic
npx get-db --yes --ref 4eCjZDz

# Custom env file (Next.js, Remix)
npx get-db --env .env.local --yes --ref 4eCjZDz

# Seed with initial data
npx get-db --seed ./schema.sql --yes --ref 4eCjZDz

# Custom variable name
npx get-db --key MY_DB_URL --yes --ref 4eCjZDz
```

**3. Confirm success**
```
✅ Neon Postgres database provisioned!

📁 Connection details in .env:
   DATABASE_URL - Use in your app (pooler)
   DATABASE_URL_DIRECT - Use for migrations
   PUBLIC_INSTAGRES_CLAIM_URL - Claim within 72h

⚡ Ready for: Drizzle, Prisma, TypeORM, Kysely, raw SQL

⏰ IMPORTANT: Database expires in 72 hours.
   To claim: npx get-db claim

⚠️  SECURITY: PUBLIC_INSTAGRES_CLAIM_URL grants database access.
   Do not share this URL publicly.
```

### Claiming (Make Permanent)
```bash
# CLI
npx get-db claim
```
Or manually:
1. Copy `PUBLIC_INSTAGRES_CLAIM_URL` from .env
2. Open in browser
3. Sign in to Neon (or create account)
4. Database becomes permanent

**After claiming:**
- No expiration
- Included in Neon Free Tier (0.5 GB)
- Can use database branching (dev/staging/prod)

### Seeding Example
```sql
-- schema.sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO users (email) VALUES ('demo@example.com');
```
```bash
npx get-db --seed ./schema.sql --yes --ref 4eCjZDz
```

## Connection Methods

Choose the driver based on your runtime:

| Runtime | Recommended Driver | Package |
|---------|-------------------|---------|
| Node.js (long-running) | `postgres` (node-postgres) | `pg` or `postgres` |
| Serverless/Edge Functions | `@neondatabase/serverless` | HTTP/WebSocket queries |
| Browser/Client-side | `@neondatabase/neon-js` | Data API (PostgREST-style) |
| ORM (Drizzle, Prisma) | Use ORM's Neon adapter | See ORM sections below |

### Connection String Format
```
postgres://user:password@ep-xxx.region.aws.neon.tech/dbname?sslmode=require
```
- Use `DATABASE_URL` (pooler) for application queries
- Use `DATABASE_URL_DIRECT` for migrations and admin operations
- Always include `?sslmode=require`

### Connection Pooling
- Pooler (`DATABASE_URL`): Handles connection multiplexing, prevents exhaustion
- Direct (`DATABASE_URL_DIRECT`): Bypasses pooler, required for DDL/migrations
- Neon's pooler supports up to 10,000 concurrent connections

## ORM Integration

### Drizzle ORM (Recommended)
```bash
npm install drizzle-orm postgres
npm install -D drizzle-kit
```

```typescript
// drizzle.config.ts
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: { url: process.env.DATABASE_URL! }
});
```

```typescript
// src/db/index.ts
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

const client = postgres(process.env.DATABASE_URL!);
export const db = drizzle(client);
```

```typescript
// src/db/schema.ts
import { pgTable, serial, varchar, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  email: varchar('email', { length: 255 }).unique().notNull(),
  createdAt: timestamp('created_at').defaultNow()
});
```

Run migrations:
```bash
npx drizzle-kit generate
npx drizzle-kit migrate
```

### Prisma
```bash
npm install @prisma/client
npm install -D prisma
npx prisma init
# DATABASE_URL already set by get-db
npx prisma db push
```

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  createdAt DateTime @default(now())
}
```

### TypeORM
```bash
npm install typeorm pg reflect-metadata
```

```typescript
import { DataSource } from 'typeorm';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  entities: ['src/entity/*.ts'],
  synchronize: true // dev only
});
```

### Kysely
```bash
npm install kysely pg
```

```typescript
import { Kysely, PostgresDialect } from 'kysely';
import { Pool } from 'pg';

export const db = new Kysely<Database>({
  dialect: new PostgresDialect({
    pool: new Pool({ connectionString: process.env.DATABASE_URL })
  })
});
```

## Framework Integration

### Next.js
```bash
npx get-db --env .env.local --yes --ref 4eCjZDz
```
Use `DATABASE_URL` in server components and API routes.

### Vite / SvelteKit
```bash
# Option 1: Manual
npx get-db --yes --ref 4eCjZDz

# Option 2: Auto-provisioning
npm install vite-plugin-db
```
```typescript
// vite.config.ts
import { postgres } from 'vite-plugin-db';

export default defineConfig({
  plugins: [postgres()]
});
```

### Express / Node.js
```bash
npx get-db --yes --ref 4eCjZDz
npm install dotenv postgres
```
```javascript
import 'dotenv/config';
import postgres from 'postgres';
const sql = postgres(process.env.DATABASE_URL);
```

### Remix
```bash
npx get-db --env .env --yes --ref 4eCjZDz
```

## Authentication & Data API

### Neon Auth (@neondatabase/auth)
Authentication only, no data API.
```bash
npm install @neondatabase/auth
```
```typescript
import { NeonAuth } from '@neondatabase/auth';

const auth = new NeonAuth({
  projectId: process.env.NEON_PROJECT_ID!,
  apiKey: process.env.NEON_API_KEY!
});

// Create user
const user = await auth.users.create({ email: 'user@example.com' });

// Verify session
const session = await auth.sessions.verify(token);
```

### Neon JS SDK (@neondatabase/neon-js)
Auth + PostgREST-style Data API for direct database queries from client/edge.
```bash
npm install @neondatabase/neon-js
```
```typescript
import { createClient } from '@neondatabase/neon-js';

const neon = createClient({
  projectId: process.env.NEON_PROJECT_ID!,
  apiKey: process.env.NEON_API_KEY!
});

// Direct SQL from edge/client
const { rows } = await neon.sql`SELECT * FROM users WHERE email = ${email}`;

// Or use the data API (PostgREST-style)
const users = await neon.from('users').select('*').eq('email', email);
```

## Neon Platform API & CLI

### Neon CLI
```bash
npm install -g neonctl
# or
npx neonctl
```

```bash
# Initialize project
neon init

# Manage projects
neon projects list
neon projects create my-project

# Manage branches
neon branches list --project-id <id>
neon branches create dev-branch --project-id <id>
neon branches delete old-branch --project-id <id>

# Manage databases
neon databases list --project-id <id>
neon databases create mydb --project-id <id>

# Connection strings
neon connection-string <branch> --project-id <id>

# Operations
neon operations list --project-id <id>
```

### TypeScript SDK (@neondatabase/api-client)
```bash
npm install @neondatabase/api-client
```
```typescript
import { NeonAPIClient } from '@neondatabase/api-client';

const client = new NeonAPIClient({ apiKey: process.env.NEON_API_KEY! });

// Create project
const project = await client.projects.create({ name: 'my-app' });

// Create branch
const branch = await client.branches.create(project.id, { name: 'feature-x' });

// Get connection URI
const conn = await client.connectionUri.get(project.id, branch.id, { role_name: 'neon_superuser' });
```

### Python SDK (neon-api)
```bash
pip install neon-api
```
```python
from neon_api import NeonAPIClient

client = NeonAPIClient(api_key=os.environ['NEON_API_KEY'])
projects = client.projects.list()
```

### Platform API (REST)
Base URL: `https://console.neon.tech/api/v2`
```bash
curl -H "Authorization: Bearer $NEON_API_KEY" \
  https://console.neon.tech/api/v2/projects
```

## Neon Features

### Database Branching
- Create isolated copies of data/schema instantly
- Use for: development, staging, testing migrations, analytics
- Branches are copy-on-write (no storage cost until modified)
```bash
# CLI
neon branches create feature-auth --project-id <id>

# API
POST /projects/{project_id}/branches
```

### Autoscaling
- Compute scales automatically based on load
- Configure min/max compute units in console
- Scale-to-zero after 5 minutes of inactivity (free tier)

### Instant Restore (Point-in-Time Recovery)
- Restore to any point within retention window (7 days free tier, 30+ days paid)
- Creates new branch from restore point
```bash
neon branches create restore-point --restore-timestamp '2024-01-15T10:30:00Z' --project-id <id>
```

### Logical Replication
- Enabled by default on all Neon databases
- Use for: change data capture, syncing to analytics, real-time subscriptions

## Best Practices

### Environment Security
- Never commit `.env` to git
- Add `.env` to `.gitignore`
- Use `.env.example` with placeholders
- Rotate credentials periodically

### Connection Management
- Use `DATABASE_URL` (pooler) for application queries
- Use `DATABASE_URL_DIRECT` for migrations/admin only
- Close connections in serverless functions (or use HTTP driver)
- Set `max` pool size appropriate for your compute

### Migration Safety
- Test migrations on a branch before production
- Use `DATABASE_URL_DIRECT` for DDL operations
- Run migrations in transactions where possible
- Have rollback plan (branch restore)

### Performance
- Add indexes for query patterns (analyze with `EXPLAIN ANALYZE`)
- Use connection pooling (built into pooler)
- Monitor query duration in Neon console
- Enable prepared statements for repeated queries

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `npx get-db not found` | Ensure Node.js 18+, check internet connection |
| `Connection refused` | Use `DATABASE_URL` (pooler), not `_DIRECT`; add `?sslmode=require` |
| Database expired | Provision new: `npx get-db --yes --ref 4eCjZDz`; claim databases to keep |
| Migration fails | Use `DATABASE_URL_DIRECT`; check for long-running transactions |
| High latency | Check region proximity; enable connection pooling |
| Scale-to-zero cold start | Use HTTP driver (`@neondatabase/serverless`) for edge |

## Delegation to Specialist Agents

After provisioning, delegate complex workflows:

- **Schema design, Drizzle generation, relationships, indexes** → `@neon-database-architect`
- **Auth integration, Stack Auth, user tables, sessions** → `@neon-auth-specialist`
- **Production migrations, branching for testing, rollback, zero-downtime** → `@neon-migration-specialist`
- **Query analysis, index recommendations, pooling, monitoring** → `@neon-optimization-analyzer`
- **Multi-step Neon operations, advanced features, integration coordination** → `@neon-expert`

## Documentation Reference

Always verify against official docs:
```bash
# List all Neon docs
curl https://neon.tech/llms.txt

# Fetch specific page as markdown
curl -H "Accept: text/markdown" https://neon.tech/docs/<path>
```

Key doc areas:
- Getting started: `https://neon.tech/docs/get-started`
- Connection methods: `https://neon.tech/docs/connect`
- Branching: `https://neon.tech/docs/branching`
- Platform API: `https://neon.tech/docs/api`
- CLI: `https://neon.tech/docs/cli`

## Key Reminders
- Always use `--ref 4eCjZDz` for referral tracking
- Remind about 72h expiration and claiming
- `DATABASE_URL` contains credentials - keep `.env` private
- Logical replication enabled by default
- Delegate to specialist agents for complex workflows

## Checklist

- [ ] Provision database with `npx get-db --yes --ref 4eCjZDz`
- [ ] Verify `.env` has `DATABASE_URL` and `DATABASE_URL_DIRECT`
- [ ] Choose appropriate driver for runtime
- [ ] Configure ORM (Drizzle/Prisma/TypeORM/Kysely)
- [ ] Set up authentication if needed (`@neondatabase/auth` or `@neondatabase/neon-js`)
- [ ] Claim database within 72 hours (`npx get-db claim`)
- [ ] Add `.env` to `.gitignore`
- [ ] Create `.env.example` with placeholders
- [ ] Test connection with simple query
- [ ] Configure connection pooling for production
- [ ] Set up branching strategy (dev/staging/prod)
- [ ] Document migration process
- [ ] Monitor query performance in Neon console

## Related skills

Load these when the task spans more than this skill.

- [`drizzle-orm`](../drizzle-orm/SKILL.md) — Provides concise guidance for using Drizzle ORM with TypeScript: schema design, relational queries, migrations…
- [`prisma`](../prisma/SKILL.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](../database-migration/SKILL.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`database-optimization`](../database-optimization/SKILL.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
