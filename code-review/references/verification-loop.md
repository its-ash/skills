@REF:verification-loop
§D{when∈{post_feat|sig_Δ,pre_PR,quality_gate,post_refactor};cont:6_phases(q15m|major_Δ@{fn,comp,pre_next});hooks=edit_lint_fmt;loop=pre_done;maint→[codehealth-mcp](../../clean-code/references/codehealth-mcp.md)}
§CMD{
  pipefail:"set -o pipefail # keep exit code; sed(¬head) avoids SIGPIPE on linters";
  p1_build:"(npm run build||pnpm build) 2>&1|tail -20 # fail⇒STOP∧fix";
  p2_types:"npx --no-install tsc --noEmit 2>&1|sed -n '1,30p' # TS | pyright . 2>&1|sed -n '1,30p' # Py; fix_crit";
  p3_lint:"npm run lint 2>&1|sed -n '1,30p' # JS/TS | ruff check . 2>&1|sed -n '1,30p' # Py";
  p4_test:"npm run test -- --coverage 2>&1|tail -50 # min_cov≥80%; report(total,pass,fail,cov%)";
  p5_sec:"grep -rnE 'sk-|api_key' --include='*.ts' --include='*.js' . 2>/dev/null|head -10; grep -rn 'console.log' --include='*.ts' --include='*.tsx' src/ 2>/dev/null|head -10";
  p6_diff:"git diff --stat; git diff HEAD~1 --name-only # chk(unintended_Δ,err_handle,edge)"
}
§R{
  target:deploy|target_verif⇒sep_from_local∧rec{env,ver?,evidence,next_check|access_dep};
  local|review|merge|release≠target;exec⇒VERIFIED|FAILED+evidence;¬prod_wo_auth;local_only⇒NOT APPLICABLE;
  ex:"local:PASS;staging:NOT PERFORMED(no access);next:maintainer runs staging smoke test"
}
§OUT{
```
VERIFICATION REPORT
Build:[PASS/FAIL]|Types:[PASS/FAIL](X errors)|Lint:[PASS/FAIL](X warnings)
Tests:[PASS/FAIL](X/Y passed,Z% coverage)|Security:[PASS/FAIL](X issues)|Diff:[X files changed]
Overall:[READY/NOT READY] for PR
Target:[VERIFIED/FAILED/NOT PERFORMED/NOT APPLICABLE](env/ver,evidence)
Next permitted step:[check|access_dep;none if complete/N/A]
Issues to Fix:1..N
```
}
