# Go Production Stack

Tool and library choices for services: APIs, persistence, profiling, deployment, tooling, security. Idioms: [golang-patterns.md](golang-patterns.md). Tests: [golang-testing.md](golang-testing.md).

## Language features (1.21+)
- Generics for reusable type-safe collections.
- `go.work` for multi-module workspaces.
- `//go:embed` for static assets.
- `log/slog` for structured logs.

## Architecture
- Clean/hexagonal: business logic in `internal/domain`; expose ports as small interfaces.
- Layers for services: API → service → repository.
- DI: manual constructors; use `wire` only for large graphs.
- CQRS (write models for commands, read models for queries) and event sourcing only when you need audit trail or replay.

## HTTP and gRPC
| Need | Use |
|---|---|
| Minimal router | `net/http` (1.22+ `ServeMux` has method and path patterns) |
| Rich middleware | `gin` or `fiber` |
| gRPC codegen | `protoc --go_out=. --go-grpc_out=.` (`protoc-gen-go-grpc`); interceptors for logging, metrics, auth |
| Middleware set | request ID, logging, panic recovery, rate limit (`golang.org/x/time/rate`) |
| Health | `/healthz` → `200` only when dependencies are reachable |
| Auth | JWT or OAuth2 middleware |
| HTTP client pool | `http.Transport{MaxIdleConnsPerHost: N}`; reuse one client |

## Persistence
- `database/sql` + driver (`pgx` for PostgreSQL). `sqlx` for named params.
- `gorm` only off hot paths.
- Pool: `db.SetMaxOpenConns`, `db.SetConnMaxLifetime`.
- Migrations: `golang-migrate` or `atlas`.
- Test doubles: `sqlmock` or in-memory SQLite; real DB via `testcontainers-go`.
- Cache hot reads in memory or Redis; invalidate on write.

## Profiling and tuning
```bash
go test -bench=. -benchmem
go tool pprof -http=:8080 cpu.prof   # from runtime/pprof.StartCPUProfile
go tool pprof -http=:8080 mem.prof   # from runtime/pprof.WriteHeapProfile
```
- Cut allocations: `sync.Pool` for buffers, preallocate slices.
- GC: tune `GOGC`; read `runtime.ReadMemStats`.

## Testing tools
`testify/assert`, `mockery` or `gomock`, `testcontainers-go`, `gopter` (property tests), `go test -coverprofile=cover.out && go tool cover -html=cover.out`.

## Deploy
```Dockerfile
FROM golang:1.21 AS builder
WORKDIR /src
COPY . .
RUN go build -o /app ./cmd/service

FROM alpine:latest
COPY --from=builder /app /app
ENTRYPOINT ["/app"]
```
- Kubernetes: Deployment, Service, ConfigMap; readiness and liveness probes call `/healthz`.
- Metrics: Prometheus client, expose `/metrics`. Traces: OpenTelemetry.
- Config: env vars, or `spf13/viper` for files.
- CI: `golangci-lint`, `go test -race`, coverage, image build.

## Tooling
- `golangci-lint run`, `staticcheck ./...`; fail CI on warnings.
- `go generate` with `stringer`, protobuf.
- `air` for hot reload. Makefile or `just` for tasks.

## Security
- Validate external input early; reject malformed data.
- Parameterized queries only.
- Secrets in env, Vault, or a secret manager; never in the binary.
- TLS on all listeners (`http.Server{TLSConfig: ...}`).
- Scan with `gosec`, `govulncheck`, or `trivy` in CI.
- Do not `panic` on expected errors; return wrapped errors.
- Keep Go and deps current (`go get -u ./...`).
