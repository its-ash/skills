# Drizzle ORM
Create a type‑safe, zero‑runtime‑overhead database layer with Drizzle ORM and TypeScript.

## When to Use
- Setting up Drizzle in a new or existing project.
- Designing schemas using Drizzle’s TypeScript‑first API.
- Writing relational queries, joins, aggregations, or nested includes.
- Managing migrations with Drizzle Kit.
- Integrating Drizzle with Next.js (App Router), tRPC, or serverless databases (Neon, PlanetScale, Turso, Supabase).
- Optimising performance for edge or serverless runtimes.

## Schema Design
### Table Definition
```typescript
// db/schema.ts
import { pgTable, text, uuid, timestamp, boolean, pgEnum } from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

export const roleEnum = pgEnum("role", ["admin", "user", "moderator"]);

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),
  email: text("email").notNull().unique(),
  name: text("name").notNull(),
  role: roleEnum("role").default("user").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

export const posts = pgTable(
  "posts",
  {
    id: uuid("id").defaultRandom().primaryKey(),
    title: text("title").notNull(),
    content: text("content"),
    published: boolean("published").default(false).notNull(),
    authorId: uuid("author_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (t) => [
    // Example indexes
    // index("posts_author_idx").on(t.authorId),
    // index("posts_created_idx").on(t.createdAt),
  ]
);
```
### Relations
```typescript
// db/relations.ts
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.authorId],
    references: [users.id],
  }),
}));
```
### Type Inference
```typescript
import type { InferSelectModel, InferInsertModel } from "drizzle-orm";

export type User = InferSelectModel<typeof users>;
export type NewUser = InferInsertModel<typeof users>;
export type Post = InferSelectModel<typeof posts>;
export type NewPost = InferInsertModel<typeof posts>;
```

## Query Patterns
### Basic Select
```typescript
const allUsers = await db.select().from(users);
```
### Filtered Select
```typescript
import { eq } from "drizzle-orm";
const admins = await db.select().from(users).where(eq(users.role, "admin"));
```
### Join Query
```typescript
import { eq, desc } from "drizzle-orm";
const postsWithAuthors = await db
  .select({ title: posts.title, authorName: users.name })
  .from(posts)
  .innerJoin(users, eq(posts.authorId, users.id))
  .where(eq(posts.published, true))
  .orderBy(desc(posts.createdAt))
  .limit(10);
```
### Aggregation
```typescript
import { count } from "drizzle-orm";
const postCounts = await db
  .select({ authorId: posts.authorId, postCount: count(posts.id) })
  .from(posts)
  .groupBy(posts.authorId);
```
### Relational (Nested) Queries
```typescript
// One query, nested data
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: {
      where: eq(posts.published, true),
      orderBy: [desc(posts.createdAt)],
      limit: 5,
    },
  },
});
```
### Insert / Update / Delete
```typescript
// Insert and return inserted row (PostgreSQL, SQLite)
const [newUser] = await db
  .insert(users)
  .values({ email: "dev@example.com", name: "Dev" })
  .returning();

// Batch insert
await db.insert(posts).values([
  { title: "Post 1", authorId: newUser.id },
  { title: "Post 2", authorId: newUser.id },
]);

// Update
await db.update(users).set({ name: "Updated" }).where(eq(users.id, newUser.id));

// Delete
await db.delete(posts).where(eq(posts.authorId, newUser.id));
```
### Transactions
```typescript
const result = await db.transaction(async (tx) => {
  const [user] = await tx.insert(users).values({ email, name }).returning();
  await tx.insert(posts).values({ title: "Welcome", authorId: user.id });
  return user;
});
```

## Migration Workflow (Drizzle Kit)
### Configuration (`drizzle.config.ts`)
```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  schema: "./db/schema.ts",
  out: "./drizzle",
  dialect: "postgresql",
  dbCredentials: { url: process.env.DATABASE_URL! },
});
```
### Commands
```bash
# Generate migration files from schema changes
npx drizzle-kit generate

# Apply pending migrations (production)
npx drizzle-kit migrate

# Push schema directly (development only)
npx drizzle-kit push

# Open GUI browser
npx drizzle-kit studio
```

## Database Client Setup
### PostgreSQL (Neon)
```typescript
// db/index.ts
import { drizzle } from "drizzle-orm/neon-http";
import { neon } from "@neondatabase/serverless";
import * as schema from "./schema";

const sql = neon(process.env.DATABASE_URL!);
export const db = drizzle(sql, { schema });
```
### SQLite (Turso / LibSQL)
```typescript
import { drizzle } from "drizzle-orm/libsql";
import { createClient } from "@libsql/client";
import * as schema from "./schema";

const client = createClient({
  url: process.env.TURSO_DATABASE_URL!,
  authToken: process.env.TURSO_AUTH_TOKEN,
});
export const db = drizzle(client, { schema });
```
### MySQL (PlanetScale)
```typescript
import { drizzle } from "drizzle-orm/planetscale-serverless";
import { Client } from "@planetscale/database";
import * as schema from "./schema";

const client = new Client({ url: process.env.DATABASE_URL! });
export const db = drizzle(client, { schema });
```

## Performance Optimisation
### Prepared Statements
```typescript
const getUserById = db.query.users
  .findFirst({ where: eq(users.id, sql.placeholder("id")) })
  .prepare("get_user_by_id");

const user = await getUserById.execute({ id: "abc-123" });
```
### Batch Operations
```typescript
const [allUsers, recentPosts] = await db.batch([
  db.select().from(users),
  db.select().from(posts).orderBy(desc(posts.createdAt)).limit(10),
]);
```
### Indexes (PostgreSQL example)
```typescript
import { index } from "drizzle-orm/pg-core";

export const posts = pgTable(
  "posts",
  { /* columns */ },
  (t) => [
    index("posts_author_idx").on(t.authorId),
    index("posts_created_idx").on(t.createdAt),
  ]
);
```

## Next.js Integration
### Server Component
```tsx
// app/users/page.tsx
import { db } from "@/db";
import { users } from "@/db/schema";

export default async function UsersPage() {
  const list = await db.select().from(users);
  return (
    <ul>
      {list.map((u) => (
        <li key={u.id}>{u.name}</li>
      ))}
    </ul>
  );
}
```
### Server Action (form handling)
```tsx
// app/actions.ts
"use server";
import { db } from "@/db";
import { users } from "@/db/schema";

export async function createUser(formData: FormData) {
  const name = formData.get("name") as string;
  const email = formData.get("email") as string;
  await db.insert(users).values({ name, email });
}
```

## Rules & Best Practices
- Keep all schema objects in a single `db/schema.ts` or organise by domain.
- Use `InferSelectModel` / `InferInsertModel` for type safety; avoid manual interfaces.
- Use the relational query API (`db.query.*`) for nested data to prevent N+1 queries.
- Prepare frequently executed statements with `.prepare()`.
- Run `drizzle-kit generate` + `drizzle-kit migrate` in production. Do not use `push` in production.
- Pass the full `schema` object to `drizzle()`; otherwise `db.query.*` will be undefined.
- Do not create a new database connection per request in serverless environments; reuse the client.
- Do not write raw SQL when Drizzle provides a builder method.
- For MySQL, avoid `.returning()`; use `.execute()` and read `insertId`.

## Common Pitfalls & Troubleshooting
| Problem | Solution |
|---|---|
| `db.query.tableName` is undefined | Ensure `drizzle(client, { schema })` receives the complete schema, including relations. |
| Migration conflicts after schema change | Run `npx drizzle-kit generate` to create a new migration, then `npx drizzle-kit migrate`. |
| Type error on `.returning()` with MySQL | MySQL does not support `RETURNING`. Use `.execute()` and read `insertId` from the result. |
| Connection per request in serverless | Initialise the client once (e.g., in `db/index.ts`) and export the shared `db` instance. |

## Checklist
- [ ] Define tables with `pgTable`, `sqliteTable`, or `mysqlTable` as appropriate.
- [ ] Add `relations()` for any foreign‑key relationships you need.
- [ ] Export inferred types with `InferSelectModel` / `InferInsertModel`.
- [ ] Configure `drizzle.config.ts` with correct `dialect` and `schema` path.
- [ ] Generate and apply migrations before deploying.
- [ ] Use prepared statements for high‑frequency queries.
- [ ] Verify that `db` is instantiated with `{ schema }`.
- [ ] Test queries in a server component or server action before production.

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](database-migration.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`database-optimization`](database-optimization.md) — Expert database optimization for SQL and NoSQL systems. Use for query tuning, indexing strategies, performance…
- [`nextjs`](../../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`prisma`](prisma.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
