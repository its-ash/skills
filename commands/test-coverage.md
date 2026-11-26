---
description: "Coverage analysis, gap detection, test gen to >=80%."
---
@CMD:test-coverage
§DETECT{
`vitest.config.*`(default)⇒`npx vitest run --coverage`
`jest.config.*`∨`package.json` jest(legacy)⇒`npx jest --coverage --coverageReporters=json-summary`
`pyproject.toml` pytest⇒`uv run pytest --cov=src --cov-report=json`
`Cargo.toml`⇒`cargo llvm-cov --json`
`pom.xml`+JaCoCo⇒`mvn test jacoco:report`
`go.mod`⇒`go test -coverprofile=coverage.out ./...`
}
§FLOW{
1:run(cmd∈§DETECT)→parse(JSON_summary∨stdout)
2:list(files<80%,worst_first)→∀f:find(untested_fns,missing_branches(if/else,switch,err),dead_code_denom)
3:∀gap→gen(1:happy_path(valid_in)→2:err_handle(invalid_in,missing_data,net_fail)→3:edges([],null/undefined,0,-1,MAX_INT)→4:branches(if/else,switch,ternary))
4:verify:run(full_suite,all_pass)→rerun(cov,Δ↑)→(<80%⇒goto:3)
}
§R{
place:adjacent(`foo.ts`→`foo.test.ts`∨proj_conv)
style:match_proj(imports,asserts,mocks)
isolate:mock_ext(DB,API,FS)∧¬shared_mutable_state
name:descriptive(`test_create_user_with_duplicate_email_returns_409`)
focus:{complex_branch,err/catch,shared_utils,API(req→res),edges(null,undefined,"",[],0,<0)}
}
§OUT{
```text
Coverage Report
---
File | Before | After
<path> | <N%> | <N%>
---
Overall: <N%> | <N%> PASS:
```
}
