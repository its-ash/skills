---
description: "Fix Go build, go vet, and linter issues incrementally via go-build-resolver"
---
@CMD:go-build
§AGENT:go-build-resolver # minimal,surgical fixes
§WHEN{`go build ./...` fail|`go vet ./...` warn|`golangci-lint run` warn|broken mod deps|post-pull break}
§CMD{
  build:`go build ./...`
  vet:`go vet ./...`
  lint:`golangci-lint run` # v2,incl staticcheck
  mod:`go mod verify` ∧ `go mod tidy -v`
  verify:`go vet ./...` ∧ `go test ./...`
}
§FLOW{
  1:run(build,vet,lint)
  2:parse_errs→group(file)→sort(severity)
  3:order(build_errs→vet_warns→lint_warns)
  4:fix(1_err_at_a_time,minimal_Δ,¬refactor)→re-run(build) after ∀Δ
  5:final_verify(`go vet ./...` ∧ `go test ./...`)→report
}
§FIX{
  `undefined: X`⇒add import ⊕ fix typo
  `cannot use X as Y`⇒type conv ⊕ fix assign
  `missing return`⇒add return stmt
  `X does not implement Y`⇒add missing method
  `import cycle`⇒restructure pkgs
  `declared but not used`⇒rm ⊕ use var
  `cannot find package`⇒`go get` ⊕ `go mod tidy`
}
§GATE{
  STOP∧report⇔(same_err≥3_attempts)∨(fix_adds>errs)∨(req_arch_Δ)∨(missing_ext_deps)
}
§OUT{
  per_fix:{file:line,err,cause,minimal_diff,remaining_errs}
  summary:{build_fixed,vet_fixed,files_mod,remaining,status(`PASS: SUCCESS`|FAIL)}
}
§REL{
  cmds:/go-test,/go-review
  agent:go-build-resolver
  skill:golang/SKILL.md
}
