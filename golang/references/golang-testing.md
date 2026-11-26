@REF:golang-testing
§PURPOSE{Go TDD:table-driven tests,subtests,helpers,golden files,interface mocks,benchmarks,fuzzing,HTTP tests,coverage.}
§TRIG{new funcs/methods|add coverage|benchmarks|fuzz input validation|TDD in Go}

§TDD{RED(stub `panic("not implemented")`→failing test)→GREEN(minimal code to pass)→REFACTOR(keep green)→REPEAT}

§PAT{
  TableDriven:`tests := []struct{ name string; ...; want ...; wantErr bool }{...}`→`for _, tt := range tests { t.Run(tt.name, func(t *testing.T) { ... }) }`;check `wantErr`→`t.Fatalf` on unexpected err→`reflect.DeepEqual(got, tt.want)`;
  Subtests:shared setup(e.g.`db := setupTestDB(t)`)→`t.Run("Create",...)`,`t.Run("Get",...)`;
  Parallel:`for _, tt := range tests { tt := tt; t.Run(tt.name, func(t *testing.T) { t.Parallel(); ... }) }`;
  Helpers:`t.Helper()`, `t.Cleanup(func(){ db.Close() })`, generic `assertEqual[T comparable](t *testing.T, got, want T)`, `t.TempDir()`, `filepath.Join(tmpDir, ...)`, `os.WriteFile(..., 0644)`;
  Golden(`testdata/`):`var update = flag.Bool("update", false, "update golden files")`;`if *update { os.WriteFile(golden, got, 0644) }`;`want, err := os.ReadFile(golden)`;`!bytes.Equal(got, want)`;update via `go test -update`;
  InterfaceMock:define dep interface(`UserRepository`),test struct `MockUserRepository` w/ func fields(`GetUserFunc`,`SaveUserFunc`),inject into `NewUserService(mock)`
}

§BENCH{
  `func BenchmarkProcess(b *testing.B)`:setup→`b.ResetTimer()`→`for i := 0; i < b.N; i++ { ... }`;
  sizes:`for _, size := range []int{100,1000,10000,100000} { b.Run(fmt.Sprintf("size=%d", size), ...) }`;copy slice before in-place sort(`copy(tmp, data); sort.Ints(tmp)`);
  run:`go test -bench=BenchmarkProcess -benchmem`→reports `ns/op`, `B/op`, `allocs/op`;compare `+=` vs `strings.Builder` vs `strings.Join`
}

§FUZZ(Go 1.18+){
  `func FuzzX(f *testing.F)`→`f.Add(...)` seeds→`f.Fuzz(func(t *testing.T, ...) { ... })`;
  check invariants:round-trip(`json.Unmarshal` ok⇒`json.Marshal` must succeed),algebraic(`Compare(a,a)==0`,antisymmetry `Compare(a,b)` vs `Compare(b,a)`);
  run:`go test -fuzz=FuzzParseJSON -fuzztime=30s`
}

§COV{
  cmds:`go test -cover ./...` | `go test -coverprofile=coverage.out ./...` | `go tool cover -html=coverage.out` | `go tool cover -func=coverage.out` | `go test -race -coverprofile=coverage.out ./...`;
  targets:{critical biz logic:100%, public APIs:90%+, general:80%+, generated code:Exclude};
  exclude generated:`//go:generate mockgen -source=interface.go -destination=mock_interface.go` + `go test -cover -tags=!generate ./...`
}

§HTTP{
  `req := httptest.NewRequest(method, path, body)`;`req.Header.Set("Content-Type", "application/json")`;
  `w := httptest.NewRecorder()`;`handler.ServeHTTP(w, req)` (or `HealthHandler(w, req)`);
  `resp := w.Result(); defer resp.Body.Close()`;assert `resp.StatusCode`/`w.Code` & `io.ReadAll(resp.Body)`/`w.Body.String()`
}

§CMD{
  `go test ./...` | `go test -v ./...` | `go test -run TestAdd ./...` | `go test -run "TestUser/Create" ./...` |
  `go test -race ./...` | `go test -cover -coverprofile=coverage.out ./...` | `go test -short ./...` |
  `go test -timeout 30s ./...` | `go test -bench=. -benchmem ./...` | `go test -fuzz=FuzzParse -fuzztime=30s ./...` | `go test -count=10 ./...` (flaky check)
}

§R{
  DO:[TDD first,table-driven tests,test behavior(¬impl),`t.Helper()`,`t.Parallel()` for independent tests,`t.Cleanup()`,descriptive test names];
  ANTI:[¬test private funcs directly(test via public API),¬`time.Sleep()`(use channels/conditions),¬ignore flaky tests,¬mock everything(prefer integration tests),¬skip error paths]
}

§CI:GitHubActions{
```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-go@v5
      with: {go-version: '1.22'}
    - run: go test -race -coverprofile=coverage.out ./...
    - run: |
        go tool cover -func=coverage.out | grep total | awk '{print $3}' | \
        awk -F'%' '{if ($1 < 80) exit 1}'
```
}
