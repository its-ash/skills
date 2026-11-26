@REF:production-stack
§REL{idioms:golang-patterns.md;tests:golang-testing.md}
§LANG{1.21+:generics,go.work,//go:embed,log/slog;1.22+:net/http.ServeMux(method+path)}
§ARCH{hexagonal:internal/domain+small_port_ifaces;layers:API→service→repository;DI:manual_ctors⊕wire(large_graphs);CQRS(cmd/query)+event_sourcing⇔audit_trail|replay}
§NET{router:net/http(1.22+ServeMux)⊕(rich_mw⇒gin|fiber);gRPC:protoc --go_out=. --go-grpc_out=. (protoc-gen-go-grpc)+interceptors(log,metrics,auth);mw:{reqID,log,panic_recovery,golang.org/x/time/rate,JWT|OAuth2};/healthz→200⇔deps_reachable;client:reuse_1+http.Transport{MaxIdleConnsPerHost:N}}
§DB{database/sql+pgx(PG);sqlx(named_params);gorm∉hot;db.SetMaxOpenConns,db.SetConnMaxLifetime;migrate:golang-migrate|atlas;doubles:sqlmock|sqlite_mem|testcontainers-go;cache:mem|Redis(invalidate_on_write)}
§PERF{sync.Pool,prealloc_slices,GOGC,runtime.ReadMemStats}
§TST{testify/assert,mockery|gomock,testcontainers-go,gopter}
§CMD{bench:go test -bench=. -benchmem;prof:go tool pprof -http=:8080 cpu.prof|mem.prof(runtime/pprof.StartCPUProfile|WriteHeapProfile);cov:go test -coverprofile=cover.out && go tool cover -html=cover.out;lint:golangci-lint run && staticcheck ./...;gen:go generate(stringer,protobuf);dev:air|Makefile|just;deps:go get -u ./...}
§DEPLOY{k8s:{Deployment,Service,ConfigMap,readiness+liveness→/healthz};Prometheus:/metrics;OTel:traces;cfg:env|spf13/viper;ci:{golangci-lint,go test -race,cov,img};docker:FROM golang:1.21 AS b;WORKDIR /src;COPY . .;RUN go build -o /app ./cmd/service;FROM alpine:latest;COPY --from=b /app /app;ENTRYPOINT ["/app"]}
§SEC{validate_early;param_queries_only;secrets∈env|Vault|secret_mgr(∉bin);TLS:http.Server{TLSConfig:...};scan:gosec|govulncheck|trivy;¬panic(expected_err)⇒wrap_err}
