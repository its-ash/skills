---
description: "Enforce Go TDD: table-driven tests first, implement, verify >=80% coverage via go test -cover"
---
@CMD:go-test
§WHEN{new_Go_fns|add_coverage|bug_fix(failing_test_first)|critical_logic|learning_Go_TDD}
§FLOW{
  1:scaffold types/ifaces/fn_sigs(`panic("not implemented")`)
  2:RED→write table-driven tests covering valid+edge(empty,nil,max)
  3:run `go test <pkg>`→verify FAIL for right reason
  4:GREEN→implement minimal code to pass
  5:run `go test <pkg>`→verify PASS
  6:REFACTOR→improve keeping tests green
  7:check `go test -cover`≥target;repeat next case
}
§TPL{
  table:`tests := []struct{name string; input T; want U; wantErr bool}{...}; for _, tt := range tests { t.Run(tt.name, func(t *testing.T){ ... }) }`
  parallel:`t.Parallel()` inside `t.Run`
  helper:`func setup(t *testing.T) *DB { t.Helper(); ...; t.Cleanup(func(){...}); return db }`
}
§CMD{
  cov:`go test -cover ./...`
  prof:`go test -coverprofile=coverage.out ./...`
  html:`go tool cover -html=coverage.out`
  func:`go tool cover -func=coverage.out`
  race:`go test -race -cover ./...`
}
§GATE{
  cov_targets:{critical_logic:100%,public_APIs:≥90%,general:≥80%,generated:exclude}
}
§R{
  DO:test_BEFORE_impl|run_after_∀Δ|table-driven|test_behavior_¬impl|edge_cases(empty,nil,max)
  ¬DO:impl_before_test|skip_RED|test_private_fns_directly|`time.Sleep`(use `testing/synctest`)|ignore_flaky_tests
}
§REL{
  cmds:/go-build,/go-review
  agent:tdd-guide
  refs:golang/references/golang-testing.md,unit-testing-patterns/references/test-driven-development.md
}
