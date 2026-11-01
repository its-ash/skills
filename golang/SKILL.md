---
name: golang
description: "Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microservice architecture, testing, DevOps, and security best practices. Use when writing or debugging Go code in .go files, using go.mod, go test, gofmt, go vet, golangci-lint, goroutines, channels, context, HTTP servers, gRPC, SQL, Docker, Kubernetes, or fixing race conditions, deadlocks, nil panics, and build errors. Sub-skills: golang-patterns, golang-testing."
---

# golang

Expert guidance for building production‑ready Go 1.21+ applications. Use this skill when you need modern language features, safe concurrency, performance profiling, microservice design, testing strategies, or deployment advice.

## When to use
- You are writing a Go service, CLI, or microservice.
- You need to design or improve concurrency, latency, or memory usage.
- You require a clean architecture, dependency injection, or event‑driven design.
- You must set up testing, CI/CD, containerization, or observability.
- You need security‑focused coding patterns.

## Modern language features
- Use **generics** for reusable, type‑safe collections.
- Enable **type inference** (`:=`) for local variables.
- Use **go.work** workspaces for multi‑module projects.
- Embed static assets with `//go:embed`.
- Wrap errors with `%w` and retrieve with `errors.Is` / `errors.As`.
- Prefer the **slog** package for structured logging (Go 1.21+).

## Concurrency patterns
- **Goroutine lifecycle**: start with `go func(){...}` and defer `wg.Done()`.
- **Worker pool**:
```go
func worker(id int, jobs <-chan Job, results chan<- Result, ctx context.Context) {
    for {
        select {
        case <-ctx.Done():
            return
        case job, ok := <-jobs:
            if !ok { return }
            results <- process(job)
        }
    }
}
```
- **Fan‑out / fan‑in**: launch multiple workers, collect results on a single channel.
- **Pipeline**: chain stages with buffered channels; use back‑pressure to avoid unbounded memory.
- Use **context** for cancellation, deadlines, and request‑scoped values.
- Prefer **sync.WaitGroup** for simple coordination; use **sync.Mutex** or **atomic** only when necessary.
- Run `go test -race` regularly to detect data races.

## Performance & optimization
- Profile CPU with `go tool pprof -http=:8080 cpu.prof` after `runtime/pprof.StartCPUProfile`.
- Profile memory with `go tool pprof -http=:8080 mem.prof` after `runtime/pprof.WriteHeapProfile`.
- Write **benchmarks** (`func BenchmarkX(b *testing.B)`) and run `go test -bench=. -benchmem`.
- Reduce allocations: reuse buffers from `sync.Pool`, avoid unnecessary slices.
- Tune GC: set `GOGC` environment variable, monitor `runtime.ReadMemStats`.
- Use **connection pooling** for databases and HTTP clients (`http.Transport` with `MaxIdleConnsPerHost`).
- Cache frequently accessed data in memory or Redis; invalidate on updates.

## Architecture patterns
- Apply **clean/hexagonal architecture**: keep business logic in `internal/domain`, expose ports via interfaces.
- Use **dependency injection** with the `wire` tool or manual constructors.
- For microservices, separate concerns: API layer, service layer, repository layer.
- Implement **CQRS**: write models for commands, read models for queries.
- Use **event sourcing** when audit trails or replay are required.
- Keep interfaces small; prefer composition over inheritance.

## Web services & APIs
- Choose a router: `net/http` for minimal, `gin` or `fiber` for richer middleware.
- Define REST routes with clear verbs and resource nouns.
- For gRPC, generate code with `protoc --go_out=plugins=grpc` and implement interceptors for logging, metrics, and auth.
- Use **middleware** for request ID, logging, panic recovery, and rate limiting.
- Implement **health checks** (`/healthz`) returning `200` when all dependencies are reachable.
- Secure endpoints with JWT validation or OAuth2 middleware.

## Database & persistence
- Prefer `database/sql` with a driver (e.g., `pgx` for PostgreSQL) for portability.
- Use **prepared statements** or `sqlx` for named parameters.
- For ORM, consider `gorm` but avoid heavy abstraction in performance‑critical paths.
- Enable connection pooling via `sql.DB.SetMaxOpenConns` and `SetConnMaxLifetime`.
- Run migrations with tools like `golang-migrate` or `atlas`.
- Mock databases in tests using `sqlmock` or in‑memory SQLite.

## Testing & quality assurance
- Write **unit tests** with the standard `testing` package; use `testify/assert` for expressive assertions.
- Use **table‑driven tests** to cover multiple inputs in one function.
- Generate mocks with `mockery` or `gomock` for interfaces.
- Run **integration tests** in Docker containers using `testcontainers-go`.
- Add **property‑based tests** with `gopter` for edge‑case coverage.
- Measure code coverage: `go test -coverprofile=cover.out && go tool cover -html=cover.out`.
- Enforce linting with `golangci-lint`; treat warnings as errors in CI.

## DevOps & production deployment
- Build Docker images with **multi‑stage builds** to keep final images small.
```Dockerfile
FROM golang:1.21 AS builder
WORKDIR /src
COPY . .
RUN go build -o /app ./cmd/service

FROM alpine:latest
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```
- Deploy to Kubernetes using **Deployments**, **Services**, and **ConfigMaps**.
- Add **readiness** and **liveness** probes that call the health endpoint.
- Export metrics with **Prometheus** client library; expose `/metrics`.
- Use **OpenTelemetry** for distributed tracing.
- Store configuration in environment variables or a config file parsed by `github.com/spf13/viper`.
- Set up CI pipelines (GitHub Actions, GitLab CI) to run `go test`, `golangci-lint`, and build Docker images.

## Tooling
- Manage dependencies with **Go modules** (`go.mod`, `go.sum`).
- Use **go.work** for multi‑module workspaces.
- Run static analysis: `golangci-lint run`, `staticcheck ./...`.
- Generate code with `go generate` and tools like `stringer` or `protobuf`.
- Use **air** for hot reload during development.
- Automate repetitive tasks with a **Makefile** or `just` recipes.

## Security & best practices
- Validate all external input; reject malformed data early.
- Use parameterized queries or ORM sanitization to prevent SQL injection.
- Store secrets outside the binary (environment variables, Vault, or secret manager).
- Enable TLS for all network listeners; prefer `http.Server{TLSConfig: ...}`.
- Run `gosec` or `trivy` in CI to detect known vulnerabilities.
- Apply rate limiting (`golang.org/x/time/rate`) to protect against DDoS.
- Avoid `panic` for expected errors; return typed errors wrapped with context.
- Keep the Go runtime up to date; regularly run `go get -u`.

## Checklist
- [ ] Confirm Go version ≥ 1.21 and required tooling installed.
- [ ] Define module path and initialize `go.mod`.
- [ ] Choose appropriate concurrency pattern (worker pool, pipeline, etc.).
- [ ] Add context propagation to all I/O‑bound functions.
- [ ] Write unit tests for each exported function.
- [ ] Add benchmark tests for performance‑critical code.
- [ ] Run `go test -race` and fix any data races.
- [ ] Profile CPU and memory; address top hotspots.
- [ ] Implement health, metrics, and tracing endpoints.
- [ ] Containerize with a multi‑stage Dockerfile.
- [ ] Create Kubernetes manifests with readiness/liveness probes.
- [ ] Configure CI pipeline: lint, test, coverage, build image.
- [ ] Scan code for security issues with `gosec` or `trivy`.
- [ ] Review error handling: wrap errors, use `errors.Is`/`As`.
- [ ] Document public APIs and architectural decisions.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/golang-patterns.md](references/golang-patterns.md) | Write or review idiomatic Go: zero values, accept interfaces and return structs, error wrapping with `errors.Is`/`As`, worker pools, errgroup, goroutine leaks, graceful shutdown, functional options, `sync.Pool`, package naming, `.golangci.yml`, and anti-patterns. |
| [references/golang-testing.md](references/golang-testing.md) | Write Go tests with TDD: table-driven tests, subtests, `t.Helper`/`t.Cleanup`, golden files, interface mocks, benchmarks, fuzzing, `httptest` handlers, coverage targets, and CI. |

## Related skills

Load these when the task spans more than this skill.

- [`backend-development`](../backend-development/SKILL.md) — Guidance for designing, building, and operating scalable backend services and APIs. Covers REST GraphQL gRPC A…
- [`performance`](../web-quality-audit/references/performance.md) — Analyzes web performance using Chrome DevTools MCP. Measures Core Web Vitals (LCP, INP, CLS) and supplementary…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`docker`](../devops-iac/references/docker.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
