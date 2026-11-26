---
description: "Detect and remove dead code safely with per-step test verification."
---
@CMD:refactor-clean
§FLOW{
1:detect:JS/TS=`npx knip`|npm=`npx depcheck`|Py_imp=`ruff check --select F401 .`|Py=`vulture src/`|Go=`deadcode ./...`|Rust=`cargo machete`|¬tool⇒grep_exports→0_imports;
2:tiers:{
SAFE:unused_utils,test_helpers,internal_fns⇒delete;
CAUTION:components,API_routes,middleware⇒§CAUTION_checks;
DANGER:configs,entry_pts,type_defs⇒investigate
};
3:delete_loop(∀SAFE,1/step):full_tests(green)→Edit(del)→re-test→(FAIL⇒`git restore <file>`∧skip|PASS⇒next);
4:CAUTION_checks:grep(`import()`,`require()`,`__import__`)∧grep_str(routes,cfg_components)∧pub_API_exports∧ext_consumers;
5:consolidate:dup_fns(>80%)→merge|redundant_types→merge|no-op_wrappers→inline|dead_re-exports→drop;
6:emit_§OUT
}
§R{¬del_without_tests;1_del/step(atomic);uncertain⇒skip;¬refactor_while_cleaning}
§OUT{
```text
Dead Code Cleanup
──────────────────────────────
Deleted:   <n> unused functions
           <n> unused files
           <n> unused dependencies
Skipped:   <n> items (tests failed)
Saved:     ~<n> lines removed
──────────────────────────────
All tests passing PASS:
```
}
