# Node.js Backend Patterns and Best Practices

Provide clear, maintainable, and production‑ready backend code. Follow the steps below to decide on frameworks, structure the application, handle async work, validate data, secure endpoints, test reliably, and avoid common pitfalls.

## When to use
- Building REST APIs, GraphQL servers, or WebSocket services with Node.js.
- Creating micro‑services or monolithic backends that need to scale.
- Designing authentication, authorization, or background job processing.
- Integrating SQL or NoSQL databases.
- Setting up middleware, error handling, and logging.

---

## 1. Choose a framework
Select a framework that matches the deployment target, performance needs, and team familiarity.

| Deployment target | Recommended framework | Reason |
|-------------------|----------------------|--------|
| Edge / serverless (Cloudflare, Vercel) | **Hono** | Minimal dependencies, fastest cold start |
| High‑performance API | **Fastify** | 2‑3× faster than Express, good TypeScript support |
| Enterprise or large team | **NestJS** | Structured, dependency injection, decorators |
| Legacy or maximum ecosystem | **Express** | Mature, many middleware packages |
| Full‑stack with React/Next.js | **Next.js API routes** or **tRPC** | Shares code with frontend |

**Decision checklist**
- Is cold‑start latency critical? → Hono.
- Does the team need strong typing and DI? → NestJS.
- Do you need the largest middleware ecosystem? → Express.
- Are you targeting edge runtimes? → Hono.

## 2. Runtime and module system
- **Node.js 22+** supports native TypeScript with `--experimental-strip-types`. Use for simple scripts or small APIs to avoid a build step.
- Choose **ESM (`import`/`export`)** for new projects: modern, better tree‑shaking, async loading.
- Use **CommonJS (`require`)** only for existing codebases that depend on legacy packages.
- Consider alternative runtimes when appropriate:
  - **Bun** for raw performance and built‑in bundling.
  - **Deno** for security‑first environments with first‑class TypeScript.

## 3. Layered architecture
Structure code into three clear layers. This improves testability, flexibility, and readability.

```
Request → Controller/Route Layer
    └─ Validate input, map to service call
Service Layer
    └─ Business logic, framework‑agnostic
Repository Layer
    └─ Data access, ORM or raw queries only
```

**When to simplify**
- Small scripts or prototypes may use a single file.
- Always ask: *Will this code grow?* If yes, adopt the layered approach.

## 4. Middleware and centralized error handling
1. Create custom error classes (e.g., `BadRequestError`, `UnauthorizedError`).
2. Throw these errors from any layer.
3. Add a top‑level error‑handling middleware that:
   - Maps error types to HTTP status codes.
   - Returns a JSON response with `{ code, message }`.
   - Logs full stack trace, request ID, and timestamp.

**Status‑code mapping**
| Situation | HTTP status |
|-----------|-------------|
| Invalid client data | 400 |
| Missing/invalid auth | 401 |
| Authenticated but forbidden | 403 |
| Resource not found | 404 |
| Conflict (duplicate) | 409 |
| Business‑rule validation | 422 |
| Unexpected server error | 500 |

## 5. Async patterns and event‑loop awareness
- Use **`async/await`** for sequential operations.
- Use **`Promise.all`** for independent parallel work.
- Use **`Promise.allSettled`** when some parallel tasks may fail but you need all results.
- Use **`Promise.race`** for timeouts or “first response wins”.

**Avoid blocking the event loop**
- Never call synchronous I/O (`fs.readFileSync`, `crypto.pbkdf2Sync`) in production.
- Offload CPU‑heavy work to worker threads or external services.
- Stream large data instead of loading it entirely into memory.

## 6. Validation strategy
Validate at every boundary:
- Incoming HTTP request bodies, query parameters, and headers.
- Before database writes.
- Responses from external APIs.
- Environment variables at startup.

**Library recommendation (TypeScript projects)**
| Library | Strength |
|---------|----------|
| Zod | Type inference, rich schema |
| Valibot | Small bundle, tree‑shakable |
| ArkType | High performance |
| Yup | Familiar to React developers |

**Validation principles**
- Fail fast: reject bad input early.
- Provide clear error messages.
- Never trust internal or external data without checks.

## 7. Security checklist
- **Input validation** for all request data.
- **Parameterized queries** (prepared statements) for SQL.
- **Password hashing** with `bcrypt` or `argon2`.
- **JWT verification**: check signature, expiration, audience.
- **Rate limiting** to mitigate abuse.
- **Security headers** via `helmet` or similar.
- Enforce **HTTPS** in production.
- Configure **CORS** to allow only required origins.
- Store secrets only in environment variables; never commit them.
- Run `npm audit` regularly and update vulnerable dependencies.

## 8. Testing strategy
| Test type | Goal | Recommended tools |
|-----------|------|-------------------|
| Unit | Isolate business logic | `node:test`, Vitest |
| Integration | Verify API endpoints and middleware | Supertest |
| End‑to‑end | Full user flows, authentication, external services | Playwright |

**Priorities**
- Test critical paths (auth, payments, core business rules).
- Test edge cases (empty inputs, boundary values).
- Test error handling (simulate failures).
- Skip testing of framework internals or trivial getters.

**Built‑in runner (Node.js 22+)**
```bash
node --test src/**/*.test.ts
```
- No extra dependencies required.
- Supports coverage and watch mode.

## 9. Performance and runtime tuning
- Profile with `clinic` or Node’s `--inspect` before optimizing.
- Prefer **Fastify** or **Hono** for latency‑critical services.
- Use **Bun** if you need a bundled binary and can accept a newer runtime.
- For security‑first environments, consider **Deno** (built‑in permissions).

## 10. Anti‑patterns to avoid
- Using **Express** for edge‑runtime projects where cold start matters.
- Placing business logic inside controllers or route handlers.
- Skipping input validation at any layer.
- Hard‑coding secrets or API keys.
- Blocking the event loop with synchronous or CPU‑heavy code.
- Trusting external data without verification.

## 11. Implementation checklist
- [ ] Clarify project goals, deployment target, and team expertise.
- [ ] Choose framework based on the decision table.
- [ ] Decide on ESM vs. CommonJS and runtime (Node/Bun/Deno).
- [ ] Set up layered folder structure (`controllers/`, `services/`, `repositories/`).
- [ ] Implement centralized error‑handling middleware.
- [ ] Select a validation library and add boundary checks.
- [ ] Apply security checklist (headers, rate limiting, JWT, etc.).
- [ ] Write unit tests for services, integration tests for routes, E2E tests for critical flows.
- [ ] Profile, then optimise only after measurement.
- [ ] Review code for listed anti‑patterns before release.
