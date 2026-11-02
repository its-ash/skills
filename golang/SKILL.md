---
name: golang
description: "Provides expert guidance for Go 1.21+ development, covering concurrency patterns, performance tuning, microservice architecture, testing, DevOps, and security best practices. Use when writing or debugging Go code in .go files, using go.mod, go test, gofmt, go vet, golangci-lint, goroutines, channels, context, HTTP servers, gRPC, SQL, Docker, Kubernetes, or fixing race conditions, deadlocks, nil panics, and build errors. Sub-skills: golang-patterns, golang-testing."
---

# golang

Build production Go 1.21+ services, CLIs, and libraries with safe concurrency.

## Core rules
- Manage deps with Go modules (`go.mod`, `go.sum`); use `go.work` for multi-module repos.
- Run `gofmt`, `go vet`, and `golangci-lint`; fail CI on lint warnings.
- Wrap errors with `fmt.Errorf("...: %w", err)`; match with `errors.Is` / `errors.As`. Never ignore an error.
- Pass `context.Context` as the first argument to every I/O or blocking function. Honor `ctx.Done()`.
- Give every goroutine an owner and an exit path (`ctx`, closed channel, `WaitGroup`, `errgroup`).
- Run `go test -race ./...` in CI and fix all races.
- Bound pipelines with buffered channels or worker pools; never spawn unbounded goroutines.
- Prefer channels and `WaitGroup`; use `sync.Mutex` or `atomic` only for shared state that needs it.
- Keep interfaces small; define them where they are used. Accept interfaces, return structs.
- Log with `log/slog`.
- Pool DB and HTTP connections; set pool limits explicitly.
- Write table-driven tests for exported functions and benchmarks for hot paths.
- Return errors for expected failures; reserve `panic` for programmer bugs.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| N independent jobs | worker pool over a jobs channel + `ctx` | one goroutine per item, no limit |
| Fail fast across goroutines | `errgroup.WithContext` | manual `WaitGroup` + error channel |
| Multi-stage stream | pipeline with buffered channels (back-pressure) | unbounded slices between stages |
| Simple wait | `sync.WaitGroup` | busy loops, `time.Sleep` |
| Router | `net/http` (small); `gin`/`fiber` (rich middleware) | heavy framework for 3 routes |
| SQL | `database/sql` + `pgx`; `sqlx` for named params | `gorm` on hot paths |
| DI | constructors; `wire` for large graphs | global package state |
| Slow code | benchmark + `pprof` first, then fix top hotspot | guess-driven tuning |
| Many short-lived buffers | `sync.Pool`, preallocate slices | allocate per call |
| Container image | multi-stage build to small base | shipping the toolchain |

## Load on demand
| Need | Read |
|---|---|
| Idioms: zero values, error types, worker pool, errgroup, goroutine leaks, graceful shutdown, functional options, `sync.Pool`, package layout, `.golangci.yml`, anti-patterns | [references/golang-patterns.md](references/golang-patterns.md) |
| Tests: TDD, table-driven, subtests, `t.Helper`/`t.Cleanup`, golden files, mocks, benchmarks, fuzzing, `httptest`, coverage, CI | [references/golang-testing.md](references/golang-testing.md) |
| Stack choices: HTTP/gRPC, middleware, health, persistence, migrations, pprof, Dockerfile, K8s probes, metrics, tracing, tooling, security scans | [references/production-stack.md](references/production-stack.md) |

## Related skills
- [`backend-development`](../backend-development/SKILL.md) — API design, resilience, service boundaries.
- [`performance`](../web-quality-audit/references/performance.md) — Web performance and Core Web Vitals.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — General test structure and TDD.
- [`docker`](../devops-iac/references/docker.md) — Dockerfile optimization and container security.
- [`secure-coding`](../secure-coding/SKILL.md) — Secrets, auth, input validation, injection.
