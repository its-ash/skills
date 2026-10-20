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
