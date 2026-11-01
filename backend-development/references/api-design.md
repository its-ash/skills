# API Design

Create clear, consistent, and secure API contracts. Follow this guide to design REST, GraphQL, or tRPC interfaces that are easy to use, version, and maintain.

## When to use
- Designing a new public or internal API.
- Refactoring an existing API for better usability.
- Establishing team‑wide API design standards.
- Reviewing an API specification before coding.
- Migrating between API paradigms (e.g., REST → GraphQL).
- Preparing developer‑friendly documentation.
- Optimising APIs for mobile, third‑party, or micro‑service consumption.

---

## Workflow
1. **Identify consumers** – list client applications, teams, and external partners.
2. **Gather use cases** – capture required operations, data shapes, and performance constraints.
3. **Define constraints** – latency, payload size, security, backward compatibility.
4. **Choose API style** – apply the Decision Guide (section below) to select REST, GraphQL, or tRPC.
5. **Model resources or types** –
   - REST: define nouns, hierarchy, and relationships.
   - GraphQL: design a type‑safe schema, decide nullability, and set depth limits.
   - tRPC: map TypeScript interfaces to procedures.
6. **Design response envelope** – include `data`, `error`, and optional `meta` fields.
7. **Plan versioning** – select URI, header, or query‑parameter strategy.
8. **Define pagination** – use cursor‑based or offset‑based approach consistently.
9. **Select authentication & authorization** – choose JWT, OAuth2, API keys, or passkeys; decide where auth checks run (resolver vs middleware).
10. **Add rate limiting** – choose token‑bucket or sliding‑window algorithm.
11. **Document** – generate OpenAPI/Swagger for REST, GraphQL SDL for GraphQL, and markdown for tRPC.
12. **Validate** – run schema validation tools (e.g., `swagger-cli validate openapi.yaml`, `graphql-schema-linter`) and review against the checklist.
13. **Security review** – apply OWASP API Top 10 tests and perform auth/role checks.

---

## Decision Guide
| Criterion | REST | GraphQL | tRPC |
|---|---|---|---|
| **Typical use case** | CRUD on well‑defined resources, public APIs, easy caching | Clients need flexible queries, reduce over‑fetching, aggregate data | TypeScript‑only monorepos, internal services, need end‑to‑end type safety |
| **Client control** | Fixed endpoints, limited query shape | Client selects fields, nesting depth | Calls are functions; type safety enforced at compile time |
| **Caching** | HTTP cache headers work out of the box | Requires persisted queries or custom caching layers | In‑process caching possible, but external caching less common |
| **Complexity** | Simple to implement, widely understood | Requires schema design, resolver management, depth limiting | Minimal runtime overhead, but ties you to TypeScript |
| **Tooling** | OpenAPI, Swagger UI, Postman | Apollo Server/Client, GraphQL Code Generator | tRPC library, TypeScript compiler |
| **When to avoid** | Need for highly dynamic queries or many joins | Simple CRUD with no client‑side flexibility needed | Mixed language stack or public API exposure |

---

## Design Rules
### REST
- Use **nouns** for resource paths, never verbs (e.g., `/users`, not `/getUsers`).
- Hierarchy reflects ownership (`/users/{id}/orders`).
- Map HTTP methods to actions: `GET` → read, `POST` → create, `PUT/PATCH` → update, `DELETE` → remove.
- Return appropriate status codes (`200`, `201`, `204`, `400`, `401`, `404`, `409`, `500`).
- Keep URLs lowercase and hyphen‑separated.

```http
GET /users/123/orders?limit=20&cursor=abc HTTP/1.1
Accept: application/json
```

### GraphQL
- Define a **single entry point** (`/graphql`).
- Use **non‑null (`!`)** only for fields that must always be present.
- Limit query depth (e.g., max depth = 7) and complexity (cost analysis).
- Perform **authorization in resolvers**, not only in schema directives.
- Use **DataLoader** or equivalent to batch and cache DB calls.

```graphql
type User {
  id: ID!
  name: String!
  email: String!
  orders(first: Int, after: String): OrderConnection!
}
```

### tRPC
- Export procedures directly from TypeScript modules.
- Keep procedure names verb‑free; the HTTP method is implied by the call.
- Share types between client and server to guarantee contract safety.

```ts
// server.ts
export const user = createRouter()
  .query('getById', {
    input: z.string(),
    resolve({ input }) { return db.user.findUnique({ where: { id: input } }) }
  })
```

---

## Response Patterns
- **Envelope**: `{ "data": ..., "error": null, "meta": { ... } }`
- **Error object**: `{ "code": "ERR_NOT_FOUND", "message": "User not found", "details": { "id": "123" } }`
- **Pagination** (cursor‑based):
  ```json
  {
    "data": [...],
    "meta": { "nextCursor": "xyz", "hasMore": true }
  }
  ```
- **Pagination** (offset‑based): include `page`, `pageSize`, `totalCount` in `meta`.

---

## Versioning Strategies
- **URI versioning** – `/v1/users` (simple, visible).
- **Header versioning** – `Accept: application/vnd.myapi.v2+json` (clean URLs).
- **Query‑parameter versioning** – `/users?api-version=3` (fallback for legacy clients).
- Increment major version for breaking changes; keep old versions available for at least one deprecation cycle.

---

## Authentication & Authorization
- **JWT** – short‑lived access tokens, signed with RS256.
- **OAuth 2.0** – use Authorization Code flow for third‑party apps.
- **API Keys** – simple for server‑to‑server calls; rotate regularly.
- **Passkeys/WebAuthn** – optional for high‑security human users.
- Perform **resource‑level checks** in resolvers or middleware, not only at the gateway.

---

## Rate Limiting
- **Token bucket** – allow bursts, refill at a steady rate.
- **Sliding window** – enforce strict request count per interval.
- Return `429 Too Many Requests` with `Retry-After` header.
- Apply per‑client or per‑IP limits based on usage patterns.

---

## Documentation
- **REST** – write OpenAPI 3.0 spec; generate Swagger UI or Redoc.
- **GraphQL** – expose SDL; use GraphQL Playground or GraphiQL for interactive docs.
- **tRPC** – generate TypeScript declaration files; publish as npm package for client consumption.
- Keep docs versioned alongside the API contract.

---

## Security Checklist (OWASP API Top 10)
- Validate all inputs; use schema validation libraries.
- Enforce **least privilege** for each endpoint.
- Protect against **excessive data exposure** – return only required fields.
- Implement **rate limiting** and **throttling**.
- Use **HTTPS** everywhere.
- Disable GraphQL introspection in production unless needed.
- Log authentication failures and monitor for abuse patterns.
- Test for **injection**, **broken object level authorization**, and **mass assignment**.

---

## REST Reference

### URL and naming

```
# Plural, lowercase, kebab-case nouns
GET    /api/v1/team-members
GET    /api/v1/users/:id/orders        # Sub-resource for ownership
POST   /api/v1/orders/:id/cancel       # Action that is not CRUD: use a verb only here
POST   /api/v1/auth/refresh

# BAD
/api/v1/getUsers         # verb in URL
/api/v1/user             # singular
/api/v1/team_members     # snake_case in URL
```

### Method semantics

| Method | Idempotent | Safe | Use for |
|--------|-----------|------|---------|
| GET | Yes | Yes | Read resources |
| POST | No | No | Create resources, start actions |
| PUT | Yes | No | Full replacement |
| PATCH | No (can be made idempotent) | No | Partial update |
| DELETE | Yes | No | Remove a resource |

### Status codes

```
200 OK                    GET, PUT, PATCH with a body
201 Created               POST (add a Location header)
204 No Content            DELETE, or PUT without a body
400 Bad Request           Malformed JSON or bad syntax
401 Unauthorized          Missing or invalid authentication
403 Forbidden             Authenticated, but not permitted
404 Not Found             Resource does not exist
409 Conflict              Duplicate entry or state conflict
422 Unprocessable Entity  Valid JSON, but the data fails validation
429 Too Many Requests     Rate limit exceeded (add Retry-After)
500 Internal Server Error Unexpected failure (never show details)
502 Bad Gateway           An upstream service failed
503 Service Unavailable   Temporary overload (add Retry-After)
```

Do not return `200` with `"success": false`. Do not return `500` for validation errors. Return `201` with a `Location` header for a new resource.

### Error with field details

```json
{
  "error": {
    "code": "validation_error",
    "message": "Request validation failed",
    "details": [
      { "field": "email", "message": "Must be a valid email address", "code": "invalid_format" }
    ]
  }
}
```

Use the envelope `{ data, meta, links }` for public APIs. Internal APIs can return the resource directly and use the HTTP status to show errors.

### Pagination choice

| Use case | Type |
|----------|------|
| Admin dashboards, small datasets (< 10K rows) | Offset |
| Infinite scroll, feeds, large datasets | Cursor |
| Public APIs | Cursor as default, offset as an option |
| Search results | Offset (users expect page numbers) |

```sql
-- Cursor: fetch one extra row to calculate has_next
SELECT * FROM users WHERE id > :cursor_id ORDER BY id ASC LIMIT 21;
```

Large `OFFSET` values are slow and give unstable pages when rows are inserted at the same time.

### Filtering, sorting, sparse fields

```
GET /api/v1/orders?status=active&customer_id=abc-123
GET /api/v1/products?price[gte]=10&price[lte]=100
GET /api/v1/products?category=electronics,clothing
GET /api/v1/products?sort=-featured,price,-created_at     # "-" means descending
GET /api/v1/products?q=wireless+headphones
GET /api/v1/users?fields=id,name,email
```

### Rate-limit headers and tiers

```
HTTP/1.1 200 OK
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000

HTTP/1.1 429 Too Many Requests
Retry-After: 60
```

| Tier | Limit | Key |
|------|-------|-----|
| Anonymous | 30/min | IP |
| Authenticated | 100/min | User |
| Premium | 1000/min | API key |
| Internal | 10000/min | Service |

### Version lifecycle

1. Start with `/api/v1/`. Keep a maximum of 2 active versions (current and previous).
2. To deprecate, announce it (6 months for public APIs), send a `Sunset` header, and return `410 Gone` after the sunset date.
3. Changes that do not break clients need no new version: new response fields, new optional query parameters, new endpoints.
4. Changes that break clients need a new version: removed or renamed fields, changed field types, changed URL structure, changed authentication.

### Example: validated create endpoint (TypeScript)

```typescript
import { z } from "zod";
import { NextRequest, NextResponse } from "next/server";

const createUserSchema = z.object({ email: z.string().email(), name: z.string().min(1).max(100) });

export async function POST(req: NextRequest) {
  const parsed = createUserSchema.safeParse(await req.json().catch(() => null));
  if (!parsed.success) {
    return NextResponse.json({
      error: {
        code: "validation_error",
        message: "Request validation failed",
        details: parsed.error.issues.map(i => ({ field: i.path.join("."), message: i.message, code: i.code })),
      },
    }, { status: 422 });
  }
  const user = await createUser(parsed.data);
  return NextResponse.json({ data: user }, { status: 201, headers: { Location: `/api/v1/users/${user.id}` } });
}
```

### Endpoint checklist

- [ ] URL is plural, kebab-case, and has no verbs (except action endpoints)
- [ ] Correct method and status codes
- [ ] Input validated with a schema (Zod, Pydantic, Bean Validation)
- [ ] Errors use the standard format with codes
- [ ] List endpoints are paginated
- [ ] Authentication required, or the endpoint is marked as public
- [ ] Ownership checked (a user gets only their own resources)
- [ ] Rate limit configured
- [ ] No internal details (stack traces, SQL errors) in responses
- [ ] Field case (camelCase or snake_case) is the same as other endpoints
- [ ] OpenAPI spec updated

For contract changes between teams, see `backend-development/references/contract-first.md`.

---

## Common Pitfalls & Anti‑Patterns
- Defaulting to REST for every use case.
- Using verbs in endpoint paths (`/createUser`).
- Returning inconsistent response formats across endpoints.
- Exposing internal error stack traces to clients.
- Omitting rate limiting or depth limiting for GraphQL.
- Placing all authorization logic in schema directives only.
- Making every GraphQL field nullable – hides real errors.
- Ignoring versioning; changing contracts without a deprecation plan.

---

## Checklist
- [ ] Identify all API consumers and their requirements.
- [ ] Choose the appropriate API style (REST, GraphQL, tRPC).
- [ ] Model resources/types with clear naming conventions.
- [ ] Define a consistent response envelope and error format.
- [ ] Select a versioning strategy and document the version policy.
- [ ] Decide on pagination method and include it in the spec.
- [ ] Pick authentication method(s) and plan field‑level authorization.
- [ ] Add rate‑limiting rules and define `429` handling.
- [ ] Write OpenAPI spec or GraphQL SDL; generate docs.
- [ ] Run schema validation (`swagger-cli validate openapi.yaml` or `graphql-schema-linter`).
- [ ] Perform OWASP API Top 10 security tests.
- [ ] Review checklist with stakeholders before implementation.
