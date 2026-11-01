---
name: backend-development
description: "Guides designing building and operating scalable backend services and APIs covering REST GraphQL gRPC contract design microservice decomposition event-driven messaging security resilience observability testing and cloud-native deployment with sub-topics for API design Node.js patterns multi-tenant SaaS and serverless architectures. Use when defining OpenAPI specs GraphQL schemas gRPC proto files microservice boundaries Kafka RabbitMQ event buses JWT OAuth authentication rate limiting circuit breakers retries distributed tracing Prometheus Grafana logging health checks PostgreSQL migrations Prisma Drizzle ORM connection pooling Redis caching background workers BullMQ serverless AWS Lambda API Gateway DynamoDB Azure Functions Docker Kubernetes CI/CD pipelines. Sub-skills: api-design, nodejs-patterns, saas-multi-tenant, serverless, contract-first, error-handling, api-connector-builder, mailtrap-email-integration, content-hash-cache-pattern, django-celery, django-security, django-testing, laravel-security, laravel-testing, laravel-plugin-discovery, rails, nestjs, fastapi, django, php-laravel, firebase-backend."
---

# Backend Development

Design and operate backend systems that are **scalable**, **resilient**, and **maintainable**. The skill covers API contracts, service boundaries, integration patterns, security, observability, testing, and deployment for modern stacks (Node.js, Python, Go, Java, .NET, etc.).

---

## When to use
- You need to design a new service, API, or microservice ecosystem.
- You must define service boundaries, data contracts, or integration patterns.
- You are planning resilience, scaling, observability, or security for a backend.
- You are refactoring existing code to follow layered architecture, DI, or repository patterns.

---

## Architecture & Service Design
1. **Capture requirements** – business domain, latency, throughput, consistency, availability.
2. **Define bounded contexts** – use Domain‑Driven Design to split the domain into services.
3. **Choose service granularity** – start with coarse‑grained services; split only when a clear domain boundary exists.
4. **Document decisions** – create an Architectural Decision Record (ADR) with trade‑offs.
5. **Statelessness** – keep services stateless to enable horizontal scaling.
6. **Deployment unit** – each service is packaged as a Docker image and deployed to Kubernetes (or equivalent).

---

## API Design & Contracts
| Aspect | Recommendation |
|--------|----------------|
| **Style** | REST for CRUD, GraphQL for flexible queries, gRPC for high‑performance internal RPC. |
| **Versioning** | URL versioning (`/v1/users`) or header versioning (`Accept: application/vnd.myapi.v2+json`). Deprecate with clear timeline. |
| **Pagination** | Use cursor‑based pagination for large datasets. |
| **Filtering & Sorting** | Encode as query parameters (`?status=active&sort=created`). |
| **Error model** | Return structured JSON `{ error: { code, message, details } }` with appropriate HTTP status. |
| **Documentation** | OpenAPI/Swagger for REST, GraphQL SDL for GraphQL. Generate SDKs with `openapi-generator` or `graphql-codegen`. |
| **Contract testing** | Use Pact or Spring Cloud Contract to verify provider‑consumer contracts. |

**Example OpenAPI snippet**
```yaml
paths:
  /orders:
    get:
      summary: List orders
      parameters:
        - in: query
          name: cursor
          schema: { type: string }
      responses:
        '200':
          description: Paginated list
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/OrderPage'
``` 
---

## Microservices & Integration Patterns
- **Synchronous calls** – REST or gRPC for low‑latency request/response.
- **Asynchronous calls** – Message queues (RabbitMQ, AWS SQS) or event streams (Kafka, NATS) for decoupling.
- **Service discovery** – Kubernetes DNS, Consul, or Eureka.
- **API Gateway** – Kong, Envoy, AWS API Gateway for routing, auth, rate limiting, and request transformation.
- **Service mesh** – Istio or Linkerd for traffic management, mutual TLS, and observability.
- **Backend‑for‑Frontend (BFF)** – Create thin services that aggregate data for specific UI clients.
- **Strangler pattern** – Incrementally replace legacy monolith endpoints with new microservice routes.
- **Saga pattern** – Manage distributed transactions with choreography (event‑driven) or orchestration (central coordinator).
- **CQRS** – Separate command (write) and query (read) models; pair with event sourcing when auditability is required.

---

## Event‑Driven Architecture
- **Message queues** – RabbitMQ, SQS for point‑to‑point work queues.
- **Event streaming** – Kafka, Kinesis for high‑throughput log of events.
- **Pub/Sub patterns** – Topic‑based routing, fan‑out, content‑based filtering.
- **Event sourcing** – Store state changes as immutable events; rebuild state by replaying.
- **Dead‑letter queues** – Capture failed messages; implement retry with exponential backoff.
- **Exactly‑once delivery** – Ensure idempotent handlers; use deduplication keys.

---

## Security & Authorization
1. **Transport security** – Enforce TLS everywhere; use mTLS for service‑to‑service calls.
2. **Authentication** – OAuth 2.0 (authorization code, client credentials) or OpenID Connect for user identity.
3. **Token handling** – Use JWTs with short expiry; rotate signing keys.
4. **Authorization** – RBAC for role‑based checks; ABAC for attribute‑based policies.
5. **API keys** – Issue per‑consumer keys; rotate regularly; enforce rate limits.
6. **Input validation** – Schema validation (Zod, Joi, JSON Schema); whitelist allowed values.
7. **Rate limiting** – Token‑bucket or leaky‑bucket algorithm; implement at gateway or service level.
8. **Secrets management** – Store secrets in Vault, AWS Secrets Manager, or environment variables injected at runtime.

---

## Resilience & Fault Tolerance
| Pattern | When to apply |
|---------|---------------|
| **Circuit breaker** | External service latency spikes or failures. |
| **Retry with exponential backoff** | Transient network errors; limit retries to avoid overload. |
| **Bulkhead** | Isolate resources (thread pools, DB connections) per service. |
| **Timeouts** | Set request and connection timeouts; propagate deadlines. |
| **Graceful degradation** | Return cached or default data when downstream is unavailable. |
| **Idempotency** | Ensure repeatable POST/PUT operations using request IDs. |
| **Chaos engineering** | Periodically inject failures (e.g., `chaos-mesh`) to validate resilience. |

**Circuit breaker example (Node.js with `resilience4j`‑like logic)**
```ts
class CircuitBreaker {
  private failures = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') throw new Error('Circuit open');
    try {
      const result = await fn();
      this.failures = 0;
      this.state = 'CLOSED';
      return result;
    } catch (e) {
      this.failures++;
      if (this.failures >= 5) this.state = 'OPEN';
      throw e;
    }
  }
}
``` 
---

## Observability & Monitoring
- **Logging** – Structured JSON logs; include `traceId`, `spanId`, `userId`. Use centralized log aggregation (ELK, Loki, CloudWatch).
- **Metrics** – Export Prometheus metrics; follow RED (Rate, Errors, Duration) plus custom business metrics.
- **Tracing** – OpenTelemetry instrumentation; send spans to Jaeger or Zipkin.
- **Health checks** – Liveness (`/health/live`) and readiness (`/health/ready`) endpoints.
- **Alerting** – Define SLOs; trigger alerts on latency > 95th percentile or error rate > 1%.
- **Dashboards** – Grafana panels for request latency, error rates, queue depth.

---

## Data Access & Caching
1. **Repository pattern** – Abstract data access behind interfaces; inject into services.
2. **ORMs** – Prisma (Node), SQLAlchemy (Python), Hibernate (Java). Use only for simple CRUD; write raw queries for performance‑critical paths.
3. **Database per service** – Own schema to avoid cross‑service coupling.
4. **Caching layers** –
   - **Application cache** – In‑process LRU for cheap lookups.
   - **Distributed cache** – Redis or Memcached; use cache‑aside or read‑through patterns.
   - **HTTP caching** – ETag and `Cache‑Control` headers for GET endpoints.
5. **Cache invalidation** – TTL, event‑driven purge, or versioned keys.

**Cache‑aside snippet (Node.js with ioredis)**
```ts
async function getUser(id: string) {
  const key = `user:${id}`;
  const cached = await redis.get(key);
  if (cached) return JSON.parse(cached);
  const user = await prisma.user.findUnique({ where: { id } });
  if (user) await redis.setex(key, 300, JSON.stringify(user));
  return user;
}
``` 
---

## Asynchronous Processing & Background Jobs
- **Job queues** – Bull (Node), Celery (Python), Sidekiq (Ruby). Persist jobs in Redis or RabbitMQ.
- **Scheduled tasks** – Cron expressions via `node-cron` or Kubernetes `CronJob`.
- **Long‑running operations** – Return a job ID; provide status endpoint; optionally use webhooks for completion.
- **Batch processing** – Use streaming frameworks (Kafka Streams, Flink) for ETL pipelines.

---

## Testing Strategy
| Level | Goal |
|-------|------|
| **Unit** | Validate pure functions, business logic. Use Jest, pytest, JUnit. |
| **Integration** | Verify API endpoints, DB interactions, external services (use test containers). |
| **Contract** | Ensure provider matches consumer expectations (Pact). |
| **End‑to‑end** | Simulate real user flows; use Playwright or Cypress for API‑driven tests. |
| **Load** | Measure performance under realistic traffic; use k6 or Gatling. |
| **Chaos** | Inject failures to test resilience; use `chaos-mesh` or `Gremlin`. |

- Keep test code alongside source (`src/__tests__`).
- Aim for >80% coverage on critical paths.
- Automate tests in CI pipelines.

---

## Deployment & Operations
1. **Containerization** – Write a multi‑stage Dockerfile; keep image size < 150 MB.
2. **Kubernetes** – Deploy via Helm chart or Kustomize; configure liveness/readiness probes.
3. **CI/CD** – GitHub Actions / GitLab CI to build, test, scan (Snyk), and deploy.
4. **Feature flags** – Use LaunchDarkly or open‑source `unleash` for gradual rollouts.
5. **Blue‑green / Canary** – Deploy new version alongside old; shift traffic with service mesh or ingress controller.
6. **Database migrations** – Use Flyway, Liquibase, or Prisma Migrate; run migrations before new pods start.
7. **Configuration** – Store non‑secret config in ConfigMaps; secrets in sealed secrets or external vault.

**Sample Dockerfile (Node.js)**
```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

# Runtime stage
FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json .
RUN npm ci --production
CMD ["node", "dist/main.js"]
```
---

## Checklist for a New Backend Feature
- [ ] Capture functional and non‑functional requirements.
- [ ] Define service boundary and data ownership.
- [ ] Design API contract (OpenAPI or GraphQL SDL).
- [ ] Choose sync vs async communication.
- [ ] Implement input validation (Zod, Joi, JSON Schema).
- [ ] Add authentication/authorization checks.
- [ ] Write service layer; keep controllers thin.
- [ ] Use repository pattern for data access.
- [ ] Add structured logging and correlation IDs.
- [ ] Export Prometheus metrics and OpenTelemetry traces.
- [ ] Write unit, integration, and contract tests.
- [ ] Run static analysis and security scan.
- [ ] Containerize and push image to registry.
- [ ] Deploy to staging; run health checks.
- [ ] Perform load test; verify SLOs.
- [ ] Promote to production with canary or blue‑green.
- [ ] Document API, architecture diagram, and ADR.

---

**End of skill**

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/api-design.md](references/api-design.md) | Provides a complete workflow, decision guide, and best‑practice checklist for designing REST, GraphQL, or tRPC APIs. Use it when you need to define contracts, choose an API style, plan versioning, pagination, auth, rate limiting, and documentation before implementation. |
| [references/nodejs-patterns.md](references/nodejs-patterns.md) | Guidance for designing, building, and maintaining Node.js backend applications. Covers framework choice, layered architecture, async patterns, validation, security, testing, runtime options, and common pitfalls. Use when creating REST/GraphQL APIs, micro‑services, or real‑time servers. |
| [references/saas-multi-tenant.md](references/saas-multi-tenant.md) | Guides the design and implementation of a multi‑tenant SaaS using a shared‑schema PostgreSQL database, row‑level security, tenant‑aware middleware, ORM integration, safe migrations, cross‑tenant admin routes, provisioning, and related best‑practice patterns. |
| [references/serverless.md](references/serverless.md) | Provides concise patterns, anti‑patterns and operational tips for building production‑ready serverless applications on AWS (Lambda, API Gateway, DynamoDB, SQS) and Azure Functions (isolated worker, Durable Functions, Node/Python). Use when you need event‑driven APIs, async processing, or low‑maintenance compute. |
| [references/contract-first.md](references/contract-first.md) | Coordinates consumer and provider work through one machine-checkable contract (OpenAPI, AsyncAPI, Protocol Buffers, JSON Schema) with generated types and contract-verified integration. Use when frontend and backend or two services change an API or event schema in parallel and fields, nullability, enums, or mocks drift. |
| [references/error-handling.md](references/error-handling.md) | Typed error hierarchies, Result types, API error envelopes, React error boundaries, Go error wrapping, retries with backoff and jitter, and user-facing messages in TypeScript, Python, and Go. Use when you design error types, retries, or failure messages, or find swallowed errors. |
| [references/api-connector-builder.md](references/api-connector-builder.md) | Adds a new API connector or provider that matches the existing integration pattern of the repo (layout, config schema, auth, retries, registry wiring, tests). Use when you add one more integration (Jira, Slack, and so on) to a codebase that already has connectors. |
| [references/mailtrap-email-integration.md](references/mailtrap-email-integration.md) | Transactional email with the Mailtrap Email API and Sandbox: Bearer auth, sandbox and production separation, SPF/DKIM/DMARC domain checks, and send-failure handling. Use when you add signup, password-reset, or notification email, or debug email that does not arrive. |
| [references/content-hash-cache-pattern.md](references/content-hash-cache-pattern.md) | Caches expensive file-processing results by SHA-256 content hash, with JSON cache files, corruption-safe reads, and a service-layer wrapper. Use when PDF, OCR, text-extraction, or image pipelines process the same files again, or a CLI needs `--cache/--no-cache`. |
| [references/django-celery.md](references/django-celery.md) | Django and Celery: broker settings, idempotent and retryable tasks, time limits, beat schedules, chains, groups, chords, dead-letter handling, task tests, and monitoring. Use when you add background jobs, periodic tasks, or async processing to a Django app, or debug task failures and queue backlogs. |
| [references/django-security.md](references/django-security.md) | Django production security settings, custom user model, password hashers, permissions and RBAC, SQL injection, XSS, CSRF, file upload checks, DRF throttling and auth, CSP, secrets, and security logging. Use when you review Django auth, input handling, or deployment settings. |
| [references/django-testing.md](references/django-testing.md) | pytest-django TDD with factory_boy, fixtures, model, view, serializer, and DRF API tests, mocks, coverage goals, and a phased verification loop (lint, migrations, tests, pip-audit, bandit, settings, diff) with a report template and CI example. Use when you write Django tests or prepare a Django PR or deploy. |
| [references/laravel-security.md](references/laravel-security.md) | Laravel production config, HTTPS and trusted proxies, Sanctum and Passport, password rules, sessions, gates and policies, mass assignment, SQL injection, CSRF, Blade XSS, CORS, rate limits, upload storage, encrypted jobs, and security logs. Use when you review Laravel auth, Eloquent safety, or deployment config. |
| [references/laravel-testing.md](references/laravel-testing.md) | PHPUnit and Pest TDD with factories, model, HTTP, JSON API, Sanctum, and authorization tests, Http/Mail/Queue/Storage/Event fakes, coverage goals, and a verification loop (Composer, Pint, PHPStan, tests, audit, migrations, caches, queues). Use when you write Laravel tests or prepare a Laravel PR or deploy. |
| [references/laravel-plugin-discovery.md](references/laravel-plugin-discovery.md) | Finds and evaluates Laravel packages by health score, Laravel and PHP version support, and vendor with the LaraPlugins.io MCP server. Use when you ask which package to use for a Laravel feature or check if a package is maintained. Needs the LaraPlugins MCP server. |
| [references/rails.md](references/rails.md) | Rails 7.1+ and 8.x patterns: directory contract, skinny controllers, service objects with Result types, form and query objects, N+1 prevention, counter caches, idempotent jobs, ViewComponent, Hotwire, Solid stack, callbacks, and concerns. Use when you build or review Rails controllers, models, services, jobs, or views. |
| [references/nestjs.md](references/nestjs.md) | Guides NestJS development covering modules, dependency injection, controllers, guards, interceptors, pipes, Jest/Supertest testing, TypeORM/Mongoose, Passport JWT auth, config, error handling, and performance. Use when working with nestjs nest @nestjs module provider controller guard interceptor pipe jest supertest typeorm mongoose passport jwt config env exception filter swagger openapi decorator injectable dto validation class-validator middleware logger docker kubernetes microservice grpc websocket cache redis bull queue health check. |
| [references/fastapi.md](references/fastapi.md) | Build async FastAPI endpoints with Pydantic v2 schemas, SQLAlchemy 2.0 models, dependency-injected auth, cursor pagination, caching, and pytest-asyncio tests. Use when creating REST APIs, CRUD routes, routers, schemas, models, services, authentication dependencies, pagination helpers, async tests, or debugging FastAPI, Starlette, Uvicorn, Pydantic validation, SQLAlchemy sessions, JWT auth, HTTPException, TestClient, and pytest failures. |
| [references/django.md](references/django.md) | Django 5.x guidance for async views, DRF APIs, Celery tasks, Channels WebSockets, ORM optimization, migrations, auth, testing, security, and deployment. Use when building or debugging Django projects, manage.py commands, models, views, serializers, urls, templates, admin, middleware, signals, pytest-django, gunicorn, uWSGI, ASGI, WSGI, PostgreSQL, Redis, Docker, or Django REST Framework endpoints. |
| [references/php-laravel.md](references/php-laravel.md) | Provides idiomatic PHP 8.1+ and Laravel 10/11 patterns for services, jobs, controllers, policies, Eloquent models, and Octane-ready code. Use when creating artisan commands, queue workers, API resources, form requests, middleware, migrations, seeders, factories, Pest or PHPUnit tests, Blade components, Horizon configs, Telescope debugging, Sanctum tokens, Passport OAuth, Scout search, Reverb websockets, Pennant features, or fixing N+1 queries, eager loading, transactions, cache tags, rate limiters, and scheduler tasks. |
| [references/firebase-backend.md](references/firebase-backend.md) | Builds and secures Firebase backends using Firestore data modeling, security rules, Cloud Functions, Cloud Storage, Hosting, and cost controls. Use when implementing Firebase Auth, Firestore queries, NoSQL document schemas, indexes, transactions, Cloud Functions triggers, Storage rules, Hosting deploys, Firebase Admin SDK, emulator tests, or debugging permission-denied, quota, and billing errors. |

## Related skills

Load these when the task spans more than this skill.

- [`database-design`](../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`database-migration`](../database-design/references/database-migration.md) — Provides step‑by‑step guidance for database schema and data migrations using Sequelize, TypeORM, and Prisma, c…
- [`redis`](../database-design/references/redis.md) — Redis caching, distributed locks, rate limiting, Pub/Sub, Streams, and connection management.
- [`java`](../java/SKILL.md) — Java, Spring Boot, Quarkus, JPA, and MyBatis backends.
- [`kotlin`](../kotlin/SKILL.md) — Kotlin backends with Ktor and Exposed.
- [`devops-iac`](../devops-iac/SKILL.md) — DevOps IaC skill provides a step-by-step workflow for designing, implementing, and operating cloud infrastruct…
- [`observability`](../devops-iac/references/observability.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
