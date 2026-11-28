@REF:golang-testing
§R{
  TDD⇒RED(failing_test)→GREEN(minimal_impl)→REFACTOR(keep_green)→REPEAT;
  table-driven⇒default_for_exported_fns∧assert_behavior(¬private_internals);
  helpers⇒mark_t.Helper()∧cleanup_via_t.Cleanup()∧temp_files_via_t.TempDir()∧ctx_via_t.Context()(1.24+);
  concurrency_tests⇒testing/synctest(synctest.Test,1.25+)∧¬time.Sleep;
  benchmarks⇒for_b.Loop()(1.24+)∧report_allocs(-benchmem)∧compare(benchstat);
  fuzzing⇒FuzzX(f *testing.F)_for_parsers,decoders,validators;
  CI⇒go_test_-race_-count=1_./...∧coverage_targets:{critical_biz:100%,public_API:≥90%,general:≥80%,generated:exclude};
}
§D{
  async_or_timer_test⇒testing/synctest(synctest.Test+fake_clock+auto_leak_detect)¬time.Sleep;
  benchmark_loop⇒for_b.Loop()(1.24+,auto_timer+prevents_DCE)¬for_i:=0;i<b.N;i++;
  test_ctx⇒t.Context()/b.Context()(1.24+,auto_cancel)¬context.Background()+manual_cancel;
  value_equality⇒slices.Equal/maps.Equal∨google/go-cmp(cmp.Diff)¬reflect.DeepEqual_noisy_diffs;
  test_doubles⇒handwritten_small_fake_struct∨testcontainers-go(real_DB/Redis)¬over-mocking;
  generated_mocks⇒go.uber.org/mock/mockgen∨mockery_v3(.mockery.yaml)¬archived_golang/mock;
  test_artifacts_in_CI⇒t.ArtifactDir()+go_test_-artifacts(1.26+)¬ad-hoc_tmp_dirs;
  parallel_subtests(1.22+)⇒t.Parallel()_directly_on_loop_var¬obsolete_tt:=tt;
  CI_Go_version⇒actions/setup-go@v7(go-version-file:go.mod)¬hardcoded_stale_version;
}
§PAT{
  TableDriven:`tests := []struct{ name string; in ...; want ...; wantErr error }{...}`→`for _, tt := range tests { t.Run(tt.name, func(t *testing.T) { t.Parallel(); got, err := Fn(t.Context(), tt.in); if !errors.Is(err, tt.wantErr) { t.Fatalf(...) }; if diff := cmp.Diff(tt.want, got); diff != "" { t.Errorf("mismatch (-want +got):\n%s", diff) } }) }`;
  Synctest(1.25+):`synctest.Test(t, func(t *testing.T) { ... })`→isolated_bubble+fake_monotonic_clock(advances_when_all_goroutines_durably_blocked)+auto_fail_on_leaked_goroutines_at_exit;`synctest.Wait()`_for_quiescence;1.27+_adds_`synctest.Sleep`;
  Helpers&Lifecycle:`t.Helper()`;`t.Cleanup(func(){ _ = db.Close() })`;`ctx := t.Context()`(1.24+);`dir := t.TempDir()`;`t.Chdir(dir)`(1.24+);`out := t.ArtifactDir()`(1.26+,saved_via_`go test -artifacts=dir`);generic_`assertEqual[T comparable](t *testing.T, got, want T)`;
  Golden(`testdata/`):`var update = flag.Bool("update", false, "update golden")`;`if *update { os.WriteFile(golden, got, 0644) }`;`want, err := os.ReadFile(golden)`;`!bytes.Equal(got, want)`;refresh_via_`go test -update`;
  Fakes&Mocks:consumer_iface(`UserRepo`)→fake_struct_w/_func_fields(`GetUserFn`)_injected_into_`NewUserService(fake)`;generated⇒`go tool mockgen`(via_`go.uber.org/mock/mockgen`)∨`mockery`v3(`.mockery.yaml`);integration⇒`testcontainers-go`;
  Benchmarks(1.24+):`func BenchmarkProcess(b *testing.B) { data := setup(); for b.Loop() { sink = process(data) } }`;sizes⇒`for _, n := range []int{100,1e3,1e4,1e5} { b.Run(fmt.Sprintf("n=%d", n), ...) }`;mutating_input⇒`b.StopTimer()`_copy_or_fresh_per_iter;compare_via_`benchstat old.txt new.txt`;
  Fuzz:`func FuzzParse(f *testing.F)`→`f.Add(seed)`→`f.Fuzz(func(t *testing.T, in []byte) { ... })`;assert_round-trip(`Unmarshal`⇒`Marshal`)∧algebraic_invariants(`Compare(a,a)==0`,antisymmetry);
  HTTP:`req := httptest.NewRequestWithContext(t.Context(), method, path, body)`;`w := httptest.NewRecorder()`;`mux.ServeHTTP(w, req)`;`resp := w.Result(); defer resp.Body.Close()`;end-to-end⇒`httptest.NewServer`∨`httptest.NewTestServer`(1.27+_in-memory,synctest-safe);
  Coverage:exclude_generated_pkgs_or_build_tags;verify_total_threshold_via_`go tool cover -func=coverage.out`;
}
§CMD{
  unit:`go test ./...` | `go test -v -run "TestUser/Create" ./...` | `go test -short ./...`;
  race/flake:`go test -race -count=1 ./...` | `go test -timeout 30s ./...` | `go test -count=10 ./...`;
  cov/artifacts:`go test -race -coverprofile=coverage.out ./...` | `go tool cover -func=coverage.out` | `go tool cover -html=coverage.out` | `go test -artifacts=test-out ./...`(1.26+);
  bench/fuzz:`go test -bench=. -benchmem -count=6 ./...` | `go tool benchstat old.txt new.txt` | `go test -fuzz=FuzzParse -fuzztime=30s ./...`;
}
§CFG:GitHubActions{
```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v7
    - uses: actions/setup-go@v7
      with: {go-version-file: go.mod, check-latest: true}
    - uses: golangci/golangci-lint-action@v9
    - run: go test -race -count=1 -coverprofile=coverage.out -artifacts=test-out ./...
    - run: go tool cover -func=coverage.out | awk '/total:/ {sub(/%/,"",$3); if ($3+0 < 80) exit 1}'
```
}
§ANTI{
  ¬time.Sleep_for_synchronization(use_synctest∨channels);
  ¬legacy_for_i:=0;i<b.N;i++_on_Go1.24+(use_b.Loop());
  ¬obsolete_tt:=tt_capture_on_Go1.22+;
  ¬archived_golang/mock(use_go.uber.org/mock∨mockery_v3∨small_fakes);
  ¬test_private_funcs_directly(test_public_contract);
  ¬ignore_flaky_tests_or_skip_error_paths;
  ¬hardcode_old_go-version_in_CI(use_go-version-file:go.mod);
}
§CHK{
  `go test -race -count=1 ./...`_green∧zero_data_races;
  concurrent_tests_use_synctest/channels(¬time.Sleep)∧zero_goroutine_leaks;
  benchmarks_use_`b.Loop()`∧tested_w/_`-benchmem`;
  error_paths+boundary_cases_covered∧total_coverage≥80%;
}
