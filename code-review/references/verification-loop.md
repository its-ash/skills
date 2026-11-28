@REF:verification-loop
§D{
  when∈{post_feat|sig_Δ,pre_PR,quality_gate,post_refactor};
  cont:6_phases(q15m|major_Δ@{fn,comp,pre_next});
  hooks=fast_edit_lint_fmt;
  loop=pre_done_full_gate;
  maint→../../clean-code/references/codehealth-mcp.md;
}
§CMD{
  pipefail:"set -o pipefail # keep exit code; sed(¬head) avoids SIGPIPE on linters";
  p1_build:"JS/TS:(pnpm build||bun run build||npm run build) 2>&1|tail -20 | Go:go build ./... | Rust:cargo build --all-targets # fail⇒STOP∧fix";
  p2_types:"TS:(npx --no-install tsgo --noEmit||npx --no-install tsc --noEmit) 2>&1|sed -n '1,30p' | Py:(uvx ty check||pyrefly check||basedpyright .) 2>&1|sed -n '1,30p' | Go:go vet ./... # fix_crit";
  p3_lint:"JS/TS:(npx --no-install biome check .||npx --no-install oxlint --type-aware||npm run lint) 2>&1|sed -n '1,30p' | Py:ruff check . 2>&1|sed -n '1,30p' | Go:golangci-lint run 2>&1|sed -n '1,30p' # v2 | Rust:cargo clippy --all-targets -- -D warnings";
  p4_test:"JS/TS:(pnpm test -- --coverage||npx vitest run --coverage) 2>&1|tail -50 | Py:uv run pytest --cov 2>&1|tail -50 | Go:go test -race -cover ./... | Rust:cargo nextest run # min_cov≥80%_crit; report(total,pass,fail,cov%)";
  p5_sec:"secrets:(gitleaks git --staged||gitleaks detect --no-git||trufflehog git file://. --since-commit HEAD~1); SCA:(osv-scanner scan -r .||trivy fs .||npm audit||uv run pip-audit||govulncheck ./...||cargo deny check); SAST:(semgrep scan --config auto --sarif-output=out.sarif||opengrep); CI_wf:zizmor .github/workflows/; debug_chk:git diff <base>...HEAD|grep -nE 'console\\.log|debugger|print\\(|TODO|FIXME'|head -20";
  p6_diff:"git diff <base>...HEAD --stat; git diff <base>...HEAD --name-only # chk(unintended_Δ,lockfiles,CI_pins,err_handle,edge,AI_slop)";
}
§R{
  target:deploy|target_verif⇒sep_from_local∧rec{env,ver?,evidence,next_check|access_dep};
  local|review|merge|release≠target;
  exec⇒VERIFIED|FAILED+evidence;
  ¬prod_wo_auth;
  local_only⇒NOT APPLICABLE;
  ex:"local:PASS;staging:NOT PERFORMED(no access);next:maintainer runs staging smoke test";
}
§OUT{
```
VERIFICATION REPORT
Build:[PASS/FAIL]|Types:[PASS/FAIL](X errors)|Lint:[PASS/FAIL](X warnings)
Tests:[PASS/FAIL](X/Y passed,Z% coverage)|Security(SAST/SCA/Secrets):[PASS/FAIL](X issues)|Diff:[X files changed]
Overall:[READY/NOT READY] for PR
Target:[VERIFIED/FAILED/NOT PERFORMED/NOT APPLICABLE](env/ver,evidence)
Next permitted step:[check|access_dep;none if complete/N/A]
Issues to Fix:1..N
```
}
