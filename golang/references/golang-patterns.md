@REF:golang-patterns
§R{
  simplicity>cleverness⇒direct_return+fmt.Errorf("...: %w",err)∧return_early(errors_first,flat_happy_path);
  zero_value_useful⇒usable_without_init(sync.Mutex+count,bytes.Buffer;¬uninit_nil_map_panic);
  interfaces⇒accept_interfaces(consumer-defined,1-2_methods)∧return_concrete_structs;
  errors⇒values(¬exceptions)∧wrap(%w)∧match(errors.Is∨errors.AsType[T](1.26+)∨errors.As)∧¬ignore;
  concurrency⇒every_goroutine_has_owner+exit_path(ctx∨chan∨WaitGroup.Go∨errgroup);
  deps⇒inject_via_constructors∧¬global_mutable_state∧¬init()_side_effects;
  tooling⇒go.mod_tool_directive(1.24+)∧gofmt/golangci-lint_fmt∧go_fix(1.26+_modernize)∧golangci-lint_v2;
  safety⇒os.Root(1.24+)_for_untrusted_subpaths∧consistent_receiver_type(value_XOR_pointer);
}
§D{
  extract_error_type⇒errors.AsType[*MyErr](err)(1.26+,compile-time_safe)¬errors.As_pointer_boilerplate;
  inline_pointer_alloc⇒new(expr)(1.26+,e.g.new(yearsSince(born)))¬ptr_helper_fn_or_temp_var;
  spawn_and_wait⇒wg.Go(fn)(1.25+,auto_Add+Done)¬manual_wg.Add(1)+defer_wg.Done();
  fail_fast_fanout⇒errgroup.WithContext(ctx)+g.SetLimit(n)¬manual_WaitGroup+err_chan;
  signal_shutdown⇒signal.NotifyContext(ctx,SIGINT,SIGTERM)¬manual_os.Signal_channel;
  loop_closures(1.22+)⇒capture_loop_var_directly¬obsolete_v:=v_shadow_rebind;
  JSON_encoding⇒encoding/json/v2(1.27+:strict_UTF-8,no_dup_keys,Options)∨omitzero(1.24+)¬omitempty_on_structs;
  lazy_iteration(1.23+)⇒iter.Seq[V]|iter.Seq2[K,V]+slices/maps_pkgs¬eager_slice_materialization;
  generic_methods(1.27+)⇒type_params_on_concrete_methods(¬interface_methods)¬pkg_wrapper_funcs;
  UUIDs(1.27+)⇒stdlib_uuid([16]byte,UUIDv7)¬third-party_uuid_dep;
  dev_CLI_tools(1.24+)⇒go_get_-tool+go_tool_<name>¬tools.go_blank_imports;
  confined_FS(1.24+)⇒os.OpenRoot(dir)→root.Open(rel)¬filepath.Join_untrusted_input;
}
§PAT{
  Errors:wrap=`fmt.Errorf("load %s: %w",path,err)`;sentinel=`var ErrNotFound = errors.New("not found")`;custom=struct_w/_`Error() string`;inspect=`errors.Is(err,sql.ErrNoRows)`∧`if v,ok := errors.AsType[*ValidationError](err); ok {}`(1.26+);multi=`errors.Join(e1,e2)`;`_`⇒ONLY_documented_best-effort_cleanup(`_ = w.Close()`);
  WorkerPool:`var wg sync.WaitGroup`;`for range workers { wg.Go(func() { for j := range jobs { select { case results <- process(j): case <-ctx.Done(): return } } }) }`;`wg.Wait(); close(results)`;
  Errgroup(`golang.org/x/sync/errgroup`):`g, ctx := errgroup.WithContext(ctx)`;`g.SetLimit(maxConc)`;`for _, u := range urls { g.Go(func() error { return fetch(ctx, u) }) }`;`return g.Wait()`;
  Timeout:`ctx, cancel := context.WithTimeout(ctx, 5*time.Second); defer cancel()`→`http.NewRequestWithContext(ctx,...)`→`defer resp.Body.Close()`;
  GracefulShutdown:`ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM); defer stop()`→`<-ctx.Done()`→`shut, cancel := context.WithTimeout(context.Background(), 30*time.Second); defer cancel()`→`server.Shutdown(shut)`;
  NoLeak:buffered_chan `make(chan []byte, 1)`+`select { case ch <- data: case <-ctx.Done(): }`(unbuffered_send_leaks_on_cancel);verify_in_prod_via_`/debug/pprof/goroutineleak`(1.27+);
  Interfaces:1-method(`io.Reader`,`io.Writer`,`io.Closer`),compose_by_embedding;define@consumer(`service.UserStore`),¬provider;optional_iface⇒type_assert(`if f, ok := w.(http.Flusher); ok { f.Flush() }`);
  PkgLayout:`cmd/<app>/main.go` | `internal/{domain,handler,service,repository,config}` | `pkg/<client>` | `api/v1` | `testdata` | `go.mod` | `go.sum` | `Makefile`;short_lowercase_names,¬`_`,¬redundant_suffix(`http`,`user`;¬`httpHandler`,`userService`);
  Struct&Options:`type Option func(*Server)`;`WithTimeout(d) Option`;`NewServer(addr string, opts ...Option) *Server` w/_defaults(`30*time.Second`,`slog.Default()`);optional_ptr_fields⇒`new(expr)`(1.26+);struct_field_selectors(1.27+)_in_composite_literals;embed_`*Logger`_to_promote_methods;
  Memory&Perf:prealloc=`make([]Result,0,len(items))`;`sync.Pool`⇒`Get().(*bytes.Buffer)`+`defer func(){ buf.Reset(); pool.Put(buf) }()`,NEVER_retain_`buf.Bytes()`_past_`Put`(copy_via_`bytes.Clone(buf.Bytes())`_or_write_to_caller_`io.Writer`);strings⇒`strings.Builder`∨`strings.Join`¬`+=`_in_loops;Go1.26+_GreenTea_GC∧Go1.27+_small_alloc(<80B)_fast_path;
}
§CMD{
  build/run:`go build ./...` | `go run ./cmd/myapp`;
  test:`go test -race ./...` | `go test -cover ./...`;
  lint/fix/sec:`go vet ./...` | `go fix ./...` (1.26+_modernizer) | `golangci-lint run` | `golangci-lint fmt` | `golangci-lint migrate` (v1→v2) | `govulncheck ./...`;
  mod/tools/doc:`go mod tidy` | `go mod verify` | `go get -tool <pkg>` | `go tool <name>` (1.24+) | `go doc -http` (1.25+);
}
§CFG:.golangci.yml(v2){
```yaml
version: "2"
run:
  relative-path-mode: cfg
linters:
  default: standard
  enable: [bodyclose, errcheck, govet, misspell, revive, staticcheck, unconvert, unparam]
  settings:
    errcheck: {check-type-assertions: true}
    govet: {enable: [shadow]}
  exclusions:
    presets: [common-false-positives]
    paths: ["_test\\.go$", "testdata/"]
formatters:
  enable: [gofumpt, goimports]
  settings:
    gofmt: {simplify: true}
```
}
§ANTI{
  ¬naked_returns_in_long_funcs;
  ¬panic_for_expected_control_flow;
  ¬context.Context_inside_struct(MUST_be_arg0);
  ¬mix_value+pointer_receivers_on_same_type;
  ¬global_mutable_state∨init()_IO;
  ¬obsolete_v1_.golangci.yml(linters-settings,gosimple,formatters_in_linters,issues.exclude-use-default);
  ¬tools.go_blank_imports(use_go.mod_tool_directive);
  ¬unbounded_goroutine_spawning_in_loops;
}
§CHK{
  ∀err_handled_or_wrapped(%w)∧¬ignored;
  ∀goroutine_bounded+cancelable(ctx/WaitGroup.Go/errgroup);
  ∀blocking_fn_takes_ctx_arg0∧¬ctx_field_in_struct;
  `gofmt`/`golangci-lint fmt`+`go vet`+`go fix`+`golangci-lint run`+`go test -race ./...`_pass_zero_warnings;
}
