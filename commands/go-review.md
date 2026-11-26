---
description: "Go code review for idiomatic patterns, concurrency, error handling, security via go-reviewer"
---
@CMD:go-review
§AGENT:go-reviewer
§WHEN{post-Δ Go|pre-commit|Go PR review|onboarding Go repo|learning idiomatic Go}
§FLOW{
  1:find Δ `.go` files via `git diff`
  2:run(`go vet ./...`,`golangci-lint run`,`go build -race ./...`,`govulncheck ./...`)
  3:audit(security,concurrency,error_handling,idioms)
  4:report(categorized_issues,approval_status)
}
§CMD{
  vet:`go vet ./...`
  lint:`golangci-lint run` # v2+staticcheck,if installed
  race:`go build -race ./...`
  sec:`govulncheck ./...`
}
§CHK{
  CRITICAL(must_fix):SQL/cmd_inj|unsynced_race|goroutine_leak|hardcoded_creds|`unsafe`_ptr|ignored_critical_err
  HIGH(should_fix):err_unwrapped(`fmt.Errorf("...: %w", err)`)|`panic`_vs_err|`context.Context`_unpropagated|unbuffered_chan_deadlock|iface_unsatisfied|missing_mutex(`sync.RWMutex`/`sync.Map`)
  MEDIUM(consider):non-idiomatic|missing_export_godoc|inefficient_str_concat|unpreallocated_slice|non-table-driven_test
}
§GATE{
  `PASS: Approve`⇔CRITICAL=0 ∧ HIGH=0
  `WARNING: Warning`⇔CRITICAL=0 ∧ HIGH=0 ∧ MEDIUM>0 # merge w/ caution
  `FAIL: Block`⇔CRITICAL>0 ∨ HIGH>0
}
§OUT{
  files_reviewed,static_results,issues(`[SEVERITY] title`,file:line,issue,fix_code),counts(CRITICAL,HIGH,MEDIUM),recommendation
}
§REL{
  cmds:/go-test(first),/go-build(on_build_err),/go-review(pre-commit),/code-review(non-Go)
  agent:go-reviewer
  refs:golang/references/golang-patterns.md,golang/references/golang-testing.md
}
