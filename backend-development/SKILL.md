---
name: backend-development
description: "Backend services and APIs: REST, GraphQL, gRPC, OpenAPI, microservices, Kafka, RabbitMQ, JWT, OAuth, rate limits, circuit breakers, Redis caching, BullMQ jobs, tracing, Lambda, serverless, multi-tenant SaaS, Django, Laravel, Rails. Sub-skills: api-design, nodejs-patterns, saas-multi-tenant, serverless, contract-first, error-handling, api-connector-builder, mailtrap-email-integration, content-hash-cache-pattern, django-celery, django-security, django-testing, laravel-security, laravel-testing, laravel-plugin-discovery, rails, nestjs, fastapi, django, php-laravel, firebase-backend."
---
# Backend Development
Design and operate scalable, resilient backend services: contracts, boundaries, integration, security, observability, deployment.

## Core rules
- Capture latency, throughput, consistency, and availability needs before design.
- Start with coarse services. Split only at a clear bounded-context boundary. Record the trade-off in an ADR.
- Keep services stateless. Give each service its own database schema.
- Define the API contract first (OpenAPI, GraphQL SDL, proto). Return RFC 9457 Problem Details or one error envelope `{ error: { code, message, details } }` with the correct HTTP status.
- Use cursor pagination for large sets. Version with `/v1` or `Accept` header; publish a deprecation timeline.
- Keep controllers thin. Put logic in services and data access in repositories.
- Validate all input with a schema (Zod 4, Valibot, JSON Schema 2020-12, Pydantic v2) at the edge.
- Enforce TLS; use mTLS between services. Use short-lived JWTs and rotate signing keys.
- Set a timeout on every outbound call. Retry only transient errors, with exponential backoff and a cap.
- Make write handlers and message consumers idempotent (request IDs, dedup keys). Send failed messages to a DLQ.
- Log structured JSON with `traceId`/`spanId`. Export RED metrics and OpenTelemetry traces.
- Expose `/health/live` and `/health/ready`. Run migrations before new pods start.
- Ship with canary or blue-green and a feature flag for risky changes.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| CRUD over HTTP | REST | GraphQL for simple CRUD |
| Clients need flexible reads | GraphQL | Many bespoke REST endpoints |
| High-performance internal RPC | gRPC | JSON REST between hot services |
| Decouple producer and consumer | Queue (RabbitMQ, SQS) or stream (Kafka, NATS) | Sync chain of calls |
| Distributed transaction | Saga (choreography or orchestration) | 2PC across services |
| Read and write loads differ | CQRS; event sourcing if audit needed | One model for both under strain |
| Legacy monolith migration | Strangler routes behind gateway | Big-bang rewrite |
| UI needs aggregated data | BFF per client | Fat generic API |
| Downstream flaky or slow | Circuit breaker + timeout + graceful fallback | Unbounded retries |
| Hot read path | Cache-aside in Redis with TTL or versioned keys | Cache with no invalidation plan |
| Long-running work | Job queue; return job ID + status endpoint | Hold the HTTP request open |
| Hot query path | Raw SQL | ORM for performance-critical queries |
| Two teams change one API in parallel | Contract-first with generated types | Hand-written client types |

## Load on demand
| Need | Read |
|---|---|
| Integration patterns, event-driven, security list, resilience table + circuit breaker, observability, caching code, jobs, test levels, Dockerfile, deploy steps, feature checklist | [references/service-architecture.md](references/service-architecture.md) |
| REST/GraphQL/tRPC style, versioning, pagination, auth, rate limits, status codes | [references/api-design.md](references/api-design.md) |
| Shared contract (OpenAPI, AsyncAPI, protobuf, JSON Schema), generated types, drift | [references/contract-first.md](references/contract-first.md) |
| Error hierarchies, Result types, error envelopes, retries with jitter (TS, Python, Go) | [references/error-handling.md](references/error-handling.md) |
| Node.js framework choice, layers, async, validation, pitfalls | [references/nodejs-patterns.md](references/nodejs-patterns.md) |
| NestJS 11 modules, DI, guards, pipes, interceptors, TypeORM, Passport JWT | [references/nestjs.md](references/nestjs.md) |
| FastAPI, Pydantic v2, SQLAlchemy 2.0, async tests | [references/fastapi.md](references/fastapi.md) |
| Django 5.2 LTS and 6.1, DRF, Channels, async ORM, django.tasks, deploy | [references/django.md](references/django.md) |
| Django Celery tasks, beat, chords, DLQ | [references/django-celery.md](references/django-celery.md) |
| Django security settings, auth, CSRF, CSP | [references/django-security.md](references/django-security.md) |
| Django tests, factory_boy, verification loop | [references/django-testing.md](references/django-testing.md) |
| PHP 8.3+ and Laravel 12/13 patterns | [references/php-laravel.md](references/php-laravel.md) |
| Laravel security, Sanctum, policies | [references/laravel-security.md](references/laravel-security.md) |
| Laravel tests, Pest, fakes, verification loop | [references/laravel-testing.md](references/laravel-testing.md) |
| Pick a Laravel package (LaraPlugins MCP) | [references/laravel-plugin-discovery.md](references/laravel-plugin-discovery.md) |
| Rails 7.2+ and 8.1 services, Solid Queue, Hotwire | [references/rails.md](references/rails.md) |
| Multi-tenant SaaS, Postgres RLS, tenant middleware | [references/saas-multi-tenant.md](references/saas-multi-tenant.md) |
| AWS Lambda, API Gateway, DynamoDB, SQS, Azure Functions, Cloudflare Workers | [references/serverless.md](references/serverless.md) |
| Firebase: Firestore, rules, Cloud Functions, Storage | [references/firebase-backend.md](references/firebase-backend.md) |
| Add one more API connector in the repo pattern | [references/api-connector-builder.md](references/api-connector-builder.md) |
| Transactional email via Mailtrap, SPF/DKIM/DMARC | [references/mailtrap-email-integration.md](references/mailtrap-email-integration.md) |
| Cache file processing by SHA-256 content hash | [references/content-hash-cache-pattern.md](references/content-hash-cache-pattern.md) |

## Related skills
- [`database-design`](../database-design/SKILL.md) — schema, technology choice, [`database-migration`](../database-design/references/database-migration.md).
- [`redis`](../database-design/references/redis.md) — caching, locks, rate limits, Streams.
- [`secure-coding`](../secure-coding/SKILL.md) — auth, injection, secrets review.
- [`java`](../java/SKILL.md) — Spring Boot, Quarkus backends.
- [`kotlin`](../kotlin/SKILL.md) — Ktor and Exposed backends.
- [`dotnet`](../dotnet/SKILL.md) — ASP.NET Core and EF Core.
- [`devops-iac`](../devops-iac/SKILL.md) — containers, Kubernetes, CI/CD; [`observability`](../devops-iac/references/observability.md).
