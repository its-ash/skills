@REF:golang-patterns
§PURPOSE{Idiomatic Go:error wrapping,concurrency,interfaces,layout,functional options,memory,linting.}
§TRIG{write|review|refactor Go code|design Go packages/modules}

§PRINCIPLES{
  1:Simplicity>cleverness→direct return+`fmt.Errorf("...: %w", err)`(¬IIFE closures);
  2:Zero-value useful→types usable w/o init(`sync.Mutex`+`count int`,`bytes.Buffer`;¬uninit nil map field that panics);
  3:Accept interfaces,return structs→params=interface(`io.Reader`),returns=concrete(`*Result`,¬interface)
}

§ERR{
  wrap:`fmt.Errorf("load config %s: %w", path, err)`;
  custom:struct implementing `Error() string` (e.g.`ValidationError{Field,Message}`);
  sentinel:`var ErrNotFound = errors.New(...)`;
  inspect:`errors.Is(err, sql.ErrNoRows)` (identity), `var v *ValidationError; errors.As(err, &v)` (type);
  ¬ignore:`_` allowed ONLY for rare documented best-effort cleanup (e.g.`_ = writer.Close()`)
}

§CONCUR{
  WorkerPool:`var wg sync.WaitGroup`;`wg.Add(1)`→`go func(){ defer wg.Done(); for j := range jobs { results <- process(j) } }()`→`wg.Wait(); close(results)`;
  Timeout:`ctx, cancel := context.WithTimeout(ctx, 5*time.Second); defer cancel()`→`http.NewRequestWithContext(ctx, ...)`→`defer resp.Body.Close()`;
  GracefulShutdown:`quit := make(chan os.Signal, 1); signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM); <-quit`→`ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second); defer cancel()`→`server.Shutdown(ctx)`;
  Errgroup(`golang.org/x/sync/errgroup`):`g, ctx := errgroup.WithContext(ctx)`;capture loop vars `i, url := i, url`→`g.Go(func() error {...})`→`g.Wait()`;
  NoLeak:use buffered chan `make(chan []byte, 1)`+`select { case ch <- data: case <-ctx.Done(): }` (unbuffered send blocks forever on cancel)
}

§IFACE{
  small/focused:1-method (`Reader`,`Writer`,`Closer`),compose via embedding (`ReadWriteCloser`);
  consumer-owned:define interface in consumer pkg(e.g.`service.UserStore`),¬provider pkg;
  optional behavior:type assert (`if f, ok := w.(Flusher); ok { return f.Flush() }`)
}

§PKG{
  layout:`cmd/myapp/main.go` | `internal/{handler,service,repository,config}` | `pkg/client` | `api/v1` | `testdata` | `go.mod` | `go.sum` | `Makefile`;
  naming:short,lowercase,¬`_`,¬redundant suffix (`http`,`json`,`user`;¬`httpHandler`,`json_parser`,`userService`);
  no global mutable state/init():inject deps via constructor (`NewServer(db *sql.DB) *Server`)
}

§STRUCT{
  FunctionalOptions:`type Option func(*Server)`;`WithTimeout(d) Option`;`NewServer(addr string, opts ...Option) *Server` w/ defaults(`30*time.Second`,`log.Default()`),loop `opt(s)`;
  Embedding:embed `*Logger` in `Server` to promote `Log(string)`
}

§PERF{
  preallocate:`make([]Result, 0, len(items))`;
  `sync.Pool`:`Get().(*bytes.Buffer)`+`defer func(){ buf.Reset(); pool.Put(buf) }()`;NEVER return/retain `buf.Bytes()` past `Put`⇒copy via `bytes.Clone(buf.Bytes())` (Go 1.20+;else `append([]byte(nil), buf.Bytes()...)`) or accept caller `io.Writer`;
  strings:¬`+=` in loops⇒use `strings.Builder` or `strings.Join(parts, ",")`
}

§CMD{
  build/run:`go build ./...` | `go run ./cmd/myapp`;
  test:`go test ./...` | `go test -race ./...` | `go test -cover ./...`;
  lint/vet:`go vet ./...` | `staticcheck ./...` | `golangci-lint run`;
  mod/fmt:`go mod tidy` | `go mod verify` | `gofmt -w .` | `goimports -w .`
}

§CFG:.golangci.yml{
```yaml
linters:
  enable: [errcheck, gosimple, govet, ineffassign, staticcheck, unused, gofmt, goimports, misspell, unconvert, unparam]
linters-settings:
  errcheck: {check-type-assertions: true}
  govet: {enable: [shadow]}
issues:
  exclude-use-default: false
```
}

§IDIOMS{
  Accept interfaces,return structs;
  Errors are values(¬exceptions);
  Don't communicate by sharing memory(use channels);
  Make zero value useful;
  A little copying > a little dependency;
  Clear > clever;
  `gofmt`/`goimports` always;
  Return early(handle errors first,unindented happy path)
}

§ANTI{
  ¬naked returns in long funcs;
  ¬`panic` for control flow;
  ¬`context.Context` inside struct(MUST be 1st func param);
  ¬mix value+pointer receivers on same type(pick one consistently)
}
