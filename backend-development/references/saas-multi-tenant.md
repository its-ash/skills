# SaaS Multi‑Tenant Architecture
Design a SaaS where many customers share the same PostgreSQL database while keeping data isolated. Use row‑level security (RLS), tenant‑scoped queries, and middleware to enforce tenant context automatically.

## When to Use
- Building a SaaS product with multiple customers sharing a database.
- Need to prevent data leakage between tenants.
- Want automatic tenant scoping without manual `WHERE tenant_id = …` in every query.
- Deciding between shared‑schema, schema‑per‑tenant, or database‑per‑tenant.
- Implementing admin endpoints that must read across all tenants.
- Adding `tenant_id` columns to an existing single‑tenant code base.
- Using Express, Fastify, Next.js API routes, Prisma, Drizzle, or similar.

## Core Workflow
1. **Choose tenancy model** – For < 1000 tenants, use a shared schema with a `tenant_id` column on every tenant‑scoped table. Use schema‑per‑tenant only if you need strong operational isolation; use database‑per‑tenant only for regulatory residency.
2. **Add `tenant_id` column** – `NOT NULL`, type `UUID` (or `TEXT`). Include it as the first column in every composite index.
3. **Enable PostgreSQL RLS** – Create a policy that filters rows by `current_setting('app.current_tenant_id')`. This is the last line of defense.
4. **Set tenant context per request** – Extract `tenant_id` from the JWT or session, then run `SET LOCAL app.current_tenant_id = '…'` inside a transaction.
5. **Scope ORM queries** – Add global middleware (Prisma, Drizzle, etc.) that injects `tenant_id` into `where`, `data`, and mutation arguments.
6. **Enforce migrations** – Every migration that creates a table must add `tenant_id` unless the table is explicitly marked global. Add a CI lint rule to reject migrations missing the column.
7. **Create cross‑tenant admin routes** – Bypass RLS with a dedicated role (`admin_bypass`) and protect the route with a separate admin authentication flow.
8. **Provision new tenants** – Insert a row in `tenants`, seed default data, and assign the founding user inside a single transaction.
9. **Handle background jobs** – Include `tenant_id` in the job payload and set the session variable before processing.

## PostgreSQL RLS Policy (Shared‑Schema Isolation)
```sql
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects FORCE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON projects
  USING (tenant_id = current_setting('app.current_tenant_id')::uuid);

CREATE POLICY tenant_insert ON projects
  FOR INSERT
  WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);
```
*The policy blocks any read or write that does not match the current tenant.*

## Express Middleware to Set Tenant Context
```typescript
import { Pool } from "pg";
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

export async function tenantMiddleware(req, res, next) {
  const tenantId = req.auth?.tenantId; // from JWT
  if (!tenantId) return res.status(403).json({ error: "No tenant context" });

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await client.query(
      "SELECT set_config('app.current_tenant_id', $1, true)",
      [tenantId]
    );
    req.db = client;
    req.tenantId = tenantId;
    res.on("finish", async () => {
      try { await client.query("COMMIT"); } catch { await client.query("ROLLBACK"); }
      client.release();
    });
    next();
  } catch (e) {
    await client.query("ROLLBACK").catch(() => {});
    client.release();
    next(e);
  }
}
```
*The middleware starts a transaction, sets the session variable, and guarantees cleanup.*

## Prisma Middleware for Automatic Tenant Scoping
```typescript
import { PrismaClient } from "@prisma/client";
const GLOBAL_TABLES = new Set(["Plan", "FeatureFlag", "SystemConfig"]);

export function createTenantPrisma(tenantId: string): PrismaClient {
  const prisma = new PrismaClient();
  prisma.$use(async (params, next) => {
    if (GLOBAL_TABLES.has(params.model ?? "")) return next(params);
    params.args = params.args ?? {};
    params.args.where = params.args.where ?? {};

    // Reads
    if (["findMany", "findFirst", "count", "aggregate"].includes(params.action)) {
      params.args.where = { ...params.args.where, tenantId };
    }
    // Creates
    if (["create", "createMany"].includes(params.action)) {
      if (params.action === "createMany") {
        params.args.data = params.args.data.map((d: any) => ({ ...d, tenantId }));
      } else {
        params.args.data = { ...params.args.data, tenantId };
      }
    }
    // Updates / Deletes
    if (["update", "updateMany", "delete", "deleteMany"].includes(params.action)) {
      params.args.where = { ...params.args.where, tenantId };
    }
    return next(params);
  });
  return prisma;
}
```
*All Prisma operations automatically include the tenant filter, except for tables listed as global.*

## Migration Lint Rule (Conceptual)
- Scan each migration file.
- If a `CREATE TABLE` statement does **not** contain `tenant_id` and the table name is not in the global‑table list, fail the CI job.
- Provide a clear error message: `Migration creates tenant‑scoped table without tenant_id`.

## Cross‑Tenant Admin Routes
1. Use a dedicated database role that has `bypassrls` privilege.
2. In the request handler, run `SET LOCAL role = 'admin_bypass'` before any query.
3. Protect the endpoint with admin‑only authentication (different JWT issuer, API key, or OAuth client).
4. Never expose this route to regular tenant users.

## Tenant Provisioning
```sql
BEGIN;
INSERT INTO tenants (id, name, slug, plan_id) VALUES ($1, $2, $3, $4);
INSERT INTO users (id, tenant_id, email, role) VALUES ($5, $1, $6, 'owner');
-- Add default settings, feature flags, etc.
COMMIT;
```
*Wrap all steps in a single transaction to avoid orphan records.*

## Background Jobs
- Include `tenantId` in the job payload.
- At job start, open a DB connection, begin a transaction, and set `app.current_tenant_id`.
- Process the job, then `COMMIT` and release the connection.
- If a job processes many tenants, loop over tenant IDs and repeat the above steps for each.

## Edge Cases
| Situation | Recommended Approach |
|-----------|----------------------|
| **Tenant deletion** | Soft‑delete the tenant (`deleted_at` column). Revoke sessions. Run a background batch job that deletes data in chunks.
| **Data export (GDPR)** | Keep a manifest of all tenant‑scoped tables. Query each table with `WHERE tenant_id = $1` and bundle results (CSV, JSON, or archive).
| **Shared resources (marketplace)** | Use `owner_tenant_id` column. RLS policy allows reads without tenant filter but enforces `owner_tenant_id` on writes.
| **Schema‑per‑tenant scaling** | Avoid one connection pool per schema. Use PgBouncer in transaction‑pooling mode or switch to shared‑schema before reaching hundreds of tenants.

## Best Practices
- **Single source of truth**: a `tenants` table with `id`, `name`, `slug`, `plan_id`, `created_at`, `deleted_at`.
- **Indexing**: always make `tenant_id` the leading column in composite indexes, e.g., `CREATE INDEX ON invoices (tenant_id, created_at);`.
- **Tenant routing**: map subdomains (`acme.myapp.com`) or path prefixes (`/org/acme`) to `tenant_id` early (edge proxy or middleware). Cache the mapping for ~60 seconds.
- **Global vs tenant tables**: maintain an explicit list (code constant or DB table). Use it in middleware, lint rules, and export jobs.
- **Testing**: seed at least three tenants in development. Verify that data from one tenant never appears in another.
- **Per‑tenant rate limiting**: store counters with keys like `ratelimit:{tenant_id}:{endpoint}` in Redis; apply sliding‑window limits per tenant.

## Never Do
- Execute a tenant‑scoped query without a `tenant_id` filter, even if middleware exists.
- Rely solely on application‑layer filtering; always enforce with RLS.
- Use auto‑increment integer primary keys for tenant data; prefer UUIDs to prevent enumeration.
- Allow regular tenant JWTs to reach admin aggregation endpoints.
- Run migrations with RLS enabled on the migration connection; use a superuser or `bypassrls` role.
- Share a pooled connection across requests without resetting the tenant session variable.

## Checklist
- [ ] Chosen tenancy model matches scale and isolation needs.
- [ ] Every tenant‑scoped table has a `tenant_id` column (`NOT NULL`, UUID).
- [ ] RLS policies are created and `FORCE ROW LEVEL SECURITY` is enabled.
- [ ] Middleware sets `app.current_tenant_id` at the start of each request/worker job.
- [ ] ORM middleware injects tenant filters for reads and writes.
- [ ] CI lint rule verifies migrations include `tenant_id` unless table is global.
- [ ] Admin routes use a dedicated role with `bypassrls` and separate auth.
- [ ] Tenant provisioning runs in a single transaction.
- [ ] Background jobs include tenant context.
- [ ] Indexes start with `tenant_id`.
- [ ] Tenant routing (subdomain/path) is cached.
- [ ] Global‑table list is up‑to‑date.
- [ ] Tests run with ≥ 3 tenants.
- [ ] Per‑tenant rate limits are configured.
