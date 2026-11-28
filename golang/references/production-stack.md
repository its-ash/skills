@REF:production-stack
§REL{./golang-patterns.md:idioms;./golang-testing.md:tests}
§R{
  toolchain⇒Go1.26–1.27(supported_latest_2)∧pin_go.mod∧dev_CLIs⇒go.mod_tool_directive(1.24+);
  arch⇒hexagonal(internal/domain+small_port_ifaces)∧layers(transport→service→repository);CQRS+ES⇔audit_trail|replay;
  DI⇒manual_constructors(main.go)_default∧large_graphs⇒samber/do|uber-go/dig(¬archived_google/wire);
  clients⇒single_shared_HTTP_client+DB_pool∧explicit(pool_limits∧timeouts);
  containers⇒multi-stage(CGO_ENABLED=0,-trimpath,-ldflags="-s -w")→distroless:nonroot∨scratch;
  runtime⇒Go1.25+_native_cgroup_GOMAXPROCS∧explicit_GOMEMLIMIT(80–90%_pod_limit)∧GreenTea_GC(1.26+);
  security⇒validate_early∧param_queries_only∧os.Root(1.24+)∧http.CrossOriginProtection(1.25+)∧secrets∈env|SecretMgr(∉bin)∧govulncheck;
}
§D{
  HTTP_router⇒net/http.ServeMux(1.22+_method+path)∨chi;(rich_mw⇒gin|fiber_v3)¬heavy_fw_for_small_APIs;
  RPC⇒ConnectRPC(connectrpc.com/connect:net/http+gRPC+browser)∨gRPC+buf¬manual_protoc_scripts;
  PostgreSQL⇒pgx/v5(pgxpool)+sqlc(compile-time_SQL)∨sqlx(dynamic_SQL)¬(gorm_on_hot_paths∨lib/pq);
  migrations⇒atlas∨goose∨golang-migrate¬manual_prod_DDL;
  DI⇒manual_ctors(default)∨samber/do|uber-go/dig(large)¬google/wire[archived_Aug_2025];
  JSON⇒encoding/json/v2(1.27+:strict_UTF-8,no_dup_keys,fast)∨omitzero(1.24+)¬slow_custom_reflect;
  UUID⇒stdlib_uuid(1.27+:UUIDv7,[16]byte)¬external_uuid_dep;
  CSRF⇒http.CrossOriginProtection(1.25+:Sec-Fetch-Site/Origin)¬custom_token_mw_for_browsers;
  K8s_CPU⇒Go1.25+_container-aware_GOMAXPROCS¬uber-go/automaxprocs;
  K8s_mem⇒set_GOMEMLIMIT(80–90%_cgroup_limit)¬unbounded_heap_OOMKill;
  container_base⇒gcr.io/distroless/static-debian12:nonroot∨scratch+ca-certs¬(golang_img∨root_alpine);
  config⇒typed_env_struct(caarlos0/env|envconfig)∨koanf|viper¬scattered_os.Getenv;
}
§PAT{
  LangMilestones:1.22(loopvar,ServeMux_method+path,range_int)|1.23(iter,range-over-func)|1.24(go.mod_tool,b.Loop,t.Context,os.Root,omitzero)|1.25(cgroup_GOMAXPROCS,synctest,WaitGroup.Go,CrossOriginProtection,go.mod_ignore)|1.26(errors.AsType,new(expr),GreenTea_GC,go_fix_modernize,t.ArtifactDir)|1.27(generic_methods,json/v2,stdlib_uuid,goroutineleak_pprof,crypto/mldsa);
  HTTP&MW:`http.ServeMux`("GET /items/{id}",`r.PathValue("id")`);mw:{reqID,slog_access_log,panic_recovery,`http.CrossOriginProtection`,`golang.org/x/time/rate`,JWT|OAuth2};probes:{`/livez`:alive,`/readyz`:200⇔deps_reachable(short_ctx)};`http.Server{ReadHeaderTimeout:5*time.Second,ReadTimeout:15*time.Second,WriteTimeout:30*time.Second,IdleTimeout:60*time.Second}`;client:reuse_1+`http.Transport{MaxIdleConnsPerHost:N,IdleConnTimeout:90*time.Second}`;
  RPC:ConnectRPC(`connectrpc.com/connect`+`buf generate`)_mounts_on_`net/http.ServeMux`(HTTP/1.1+HTTP/2+gRPC+gRPC-Web)∨`google.golang.org/grpc`+interceptors(slog,OTel,auth,recovery);
  DB&Cache:`pgxpool.New(ctx,dsn)`(`MaxConns`,`MinConns`,`MaxConnLifetime`,`MaxConnIdleTime`)+`sqlc`;`database/sql`⇒`SetMaxOpenConns`,`SetMaxIdleConns`,`SetConnMaxLifetime`;cache:in-mem|Redis(TTL+invalidate_on_write);doubles:`testcontainers-go`≻`sqlite_mem`≻`sqlmock`;
  Observability:logs⇒`log/slog`(JSON_in_prod,`slog.NewMultiHandler`_1.26+);traces+metrics⇒OpenTelemetry_Go_SDK(`go.opentelemetry.io/otel`+OTLP)∧Prometheus_`/metrics`;profiles⇒`net/http/pprof`_(private_port_ONLY,incl.`/debug/pprof/goroutineleak`_1.27+);
  Security:`os.OpenRoot(dir)`(1.24+)_against_path_traversal;`http.CrossOriginProtection`(1.25+);`tls.Config{MinVersion:tls.VersionTLS13}`(or_TLS12);`crypto/mldsa`(1.27+)_PQ_sigs;scans⇒`govulncheck`+`gosec`+`trivy`;
}
§CFG:Dockerfile{
```dockerfile
FROM golang:1.27 AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /app ./cmd/service

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /app /app
ENV GOMEMLIMIT=400MiB
USER nonroot:nonroot
ENTRYPOINT ["/app"]
```
}
§CMD{
  prof:`go tool pprof -http=:8080 cpu.prof|mem.prof` | `curl http://127.0.0.1:6060/debug/pprof/goroutineleak > leak.prof`(1.27+);
  bench/cov:`go test -bench=. -benchmem -count=6 ./...` | `go test -race -coverprofile=cover.out ./... && go tool cover -html=cover.out`;
  lint/fix/sec:`golangci-lint run` | `golangci-lint fmt` | `go fix ./...` | `govulncheck ./...` | `gosec ./...` | `trivy image <img:tag>`;
  gen/dev:`go tool sqlc generate` | `buf generate` | `go generate ./...` | `air` | `Makefile`;
  deps:`go get -u=patch ./... && go mod tidy` (review_minor/major_explicitly);
}
§ANTI{
  ¬google/wire_on_new_projects(archived_Aug_2025);
  ¬lib/pq(deprecated⇒pgx/v5)∧¬gorm_on_hot_paths;
  ¬expose_/debug/pprof_on_public_port;
  ¬omit_http.Server_timeouts(slowloris_DoS);
  ¬omit_GOMEMLIMIT_in_K8s_containers;
  ¬uber-go/automaxprocs_on_Go1.25+(redundant);
  ¬ship_Go_toolchain_or_run_as_root_in_prod_image;
  ¬blind_go_get_-u_./..._without_running_tests;
}
§CHK{
  `/livez`+`/readyz`+graceful_shutdown(`signal.NotifyContext`→`server.Shutdown`)_wired;
  `http.Server`_timeouts∧DB_pool_limits∧`GOMEMLIMIT`_set;
  nonroot_distroless/scratch_image∧pprof_bound_to_private_port_only;
  `govulncheck ./...`∧`golangci-lint run`∧`go test -race ./...`_pass_in_CI;
}
