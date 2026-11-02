# Service Architecture and Operations

Integration, events, security, resilience, observability, caching, jobs, testing, deployment, and a feature checklist. Parent: [`backend-development`](../SKILL.md). API style, versioning, pagination, errors: [api-design.md](api-design.md). Error types and retries: [error-handling.md](error-handling.md).

## Service design steps
1. Capture requirements: domain, latency, throughput, consistency, availability.
2. Split bounded contexts with DDD.
3. Start coarse-grained; split only at a clear domain boundary.
4. Record trade-offs in an ADR.
5. Keep services stateless for horizontal scale.
6. Package each service as a Docker image; deploy to Kubernetes or equivalent.

## API contract extras (not in api-design.md)
- Docs: OpenAPI/Swagger for REST, SDL for GraphQL. Generate SDKs with `openapi-generator` or `graphql-codegen`.
- Contract tests: Pact or Spring Cloud Contract for provider/consumer checks.

```yaml
paths:
  /orders:
    get:
      summary: List orders
      parameters:
        - { in: query, name: cursor, schema: { type: string } }
      responses:
        '200':
          description: Paginated list
          content:
            application/json:
              schema: { $ref: '#/components/schemas/OrderPage' }
```

## Integration patterns
| Pattern | Use |
|---|---|
| REST / gRPC sync | Low-latency request/response |
| Queues (RabbitMQ, SQS) / streams (Kafka, NATS) | Decoupling |
| Service discovery | Kubernetes DNS, Consul, Eureka |
| API gateway (Kong, Envoy, AWS API Gateway) | Routing, auth, rate limit, request transform |
| Service mesh (Istio, Linkerd) | Traffic management, mTLS, observability |
| BFF | Thin aggregator per UI client |
| Strangler | Replace monolith routes one by one |
| Saga | Distributed transactions: choreography (events) or orchestration (coordinator) |
| CQRS | Split write and read models; add event sourcing when audit is required |

## Event-driven
- Point-to-point work: RabbitMQ, SQS. High-throughput event log: Kafka, Kinesis.
- Pub/sub: topic routing, fan-out, content-based filtering.
- Event sourcing: store immutable state changes; rebuild by replay.
- Dead-letter queues for failed messages; retry with exponential backoff.
- "Exactly once": make handlers idempotent; use deduplication keys.

## Security
1. TLS everywhere; mTLS service to service.
2. OAuth 2.0 (authorization code, client credentials) or OIDC for identity.
3. Short-lived JWTs; rotate signing keys.
4. RBAC for roles; ABAC for attribute policies.
5. Per-consumer API keys; rotate; rate-limit.
6. Schema validation (Zod, Joi, JSON Schema); allowlist values.
7. Rate limit with token bucket or leaky bucket at gateway or service.
8. Secrets in Vault, AWS Secrets Manager, or runtime-injected env vars.

## Resilience
| Pattern | Apply when |
|---|---|
| Circuit breaker | Downstream latency spikes or failures |
| Retry + exponential backoff | Transient network errors; cap attempts |
| Bulkhead | Isolate thread pools, DB connections per dependency |
| Timeouts | Always; set request and connection timeouts; propagate deadlines |
| Graceful degradation | Return cached or default data when downstream is down |
| Idempotency | Repeatable POST/PUT via request IDs |
| Chaos engineering | Inject failures (`chaos-mesh`, Gremlin) on a schedule |

```ts
class CircuitBreaker {
  private failures = 0;
  private state: 'CLOSED' | 'OPEN' | 'HALF_OPEN' = 'CLOSED';
  async call<T>(fn: () => Promise<T>): Promise<T> {
    if (this.state === 'OPEN') throw new Error('Circuit open');
    try {
      const res = await fn();
      this.failures = 0;
      this.state = 'CLOSED';
      return res;
    } catch (e) {
      if (++this.failures >= 5) this.state = 'OPEN';
      throw e;
    }
  }
}
```

## Observability
- Structured JSON logs with `traceId`, `spanId`, `userId`; aggregate in ELK, Loki, CloudWatch.
- Prometheus metrics: RED (Rate, Errors, Duration) plus business metrics.
- OpenTelemetry traces to Jaeger or Zipkin.
- Health: liveness `/health/live`, readiness `/health/ready`.
- Alert on SLOs, e.g. p95 latency breach or error rate > 1%.
- Grafana panels: latency, error rate, queue depth.

## Data access and caching
- Repository interfaces injected into services.
- ORMs (Prisma, SQLAlchemy, Hibernate) for simple CRUD; raw queries for hot paths.
- Database per service; no cross-service schema coupling.
- Cache tiers: in-process LRU; Redis/Memcached (cache-aside or read-through); HTTP ETag + `Cache-Control` on GET.
- Invalidate by TTL, event-driven purge, or versioned keys.

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

## Background jobs
- Queues: BullMQ (Node), Celery (Python), Sidekiq (Ruby); persist in Redis or RabbitMQ.
- Schedules: `node-cron` or Kubernetes `CronJob`.
- Long operations: return job ID + status endpoint; optional completion webhook.
- Batch/ETL: Kafka Streams, Flink.

## Testing levels
| Level | Goal / tools |
|---|---|
| Unit | Pure logic; Jest, pytest, JUnit |
| Integration | Endpoints, DB, external services; Testcontainers |
| Contract | Provider meets consumer expectations; Pact |
| E2E | Real flows; Playwright, Cypress |
| Load | Realistic traffic; k6, Gatling |
| Chaos | Failure injection; chaos-mesh, Gremlin |

Keep tests beside source (`src/__tests__`). Target > 80% coverage on critical paths. Run all in CI.

## Deployment
1. Multi-stage Dockerfile; image < 150 MB.
2. Helm or Kustomize; liveness and readiness probes.
3. CI/CD (GitHub Actions, GitLab CI): build, test, scan (Snyk), deploy.
4. Feature flags: LaunchDarkly or `unleash`.
5. Blue-green or canary via mesh or ingress.
6. Migrations (Flyway, Liquibase, Prisma Migrate) run before new pods start.
7. Non-secret config in ConfigMaps; secrets in sealed secrets or external vault.

```dockerfile
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json .
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json .
RUN npm ci --omit=dev
CMD ["node", "dist/main.js"]
```

## New feature checklist
- [ ] Functional and non-functional requirements
- [ ] Service boundary and data ownership
- [ ] API contract (OpenAPI or SDL)
- [ ] Sync vs async choice
- [ ] Input validation
- [ ] AuthN/AuthZ checks
- [ ] Thin controllers, service layer, repositories
- [ ] Structured logs with correlation IDs
- [ ] Prometheus metrics and OTel traces
- [ ] Unit, integration, contract tests
- [ ] Static analysis and security scan
- [ ] Container image pushed
- [ ] Staging deploy with health checks
- [ ] Load test against SLOs
- [ ] Canary or blue-green to production
- [ ] API docs, architecture diagram, ADR
