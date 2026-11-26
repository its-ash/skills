---
description: "React/JSX review: hooks, perf, RSC, a11y, sec via react-reviewer (+typescript-reviewer on TSX/JSX)."
---
@CMD:react-review
§SCOPE{
when:PR∨commit∩Δ{.tsx,.jsx} ∨ post-Δ(component|hook|page) ∨ pre-merge_React ∨ a11y_audit ∨ hook_rules/deps ∨ Next_RSC_boundary;
pure(.ts,.js)∧¬React_imports ⇒ `/code-review`;
lanes:react-reviewer(hooks,JSX,RSC,a11y,React_sec,perf) | typescript-reviewer(TS/JS:`any`,async,Node_sec) | security-reviewer(repo_sec) | /code-review(generic);
TSX/JSX_PR ⇒ react-reviewer ∧ typescript-reviewer(non-overlapping)
}
§FLOW{
1:`git diff`→Δ{.tsx,.jsx}∧React-importing{.ts,.js};
2:`npx eslint .`(needs `eslint-plugin-react-hooks`,`eslint-plugin-jsx-a11y`; ¬cfg⇒flag HIGH config_gap∧continue);
3:`npx eslint . --rule 'jsx-a11y/alt-text: error' --rule 'jsx-a11y/anchor-is-valid: error' --rule 'jsx-a11y/click-events-have-key-events: error'`;
4:typecheck(skip_if_JS_only):`npm run typecheck --if-present` ∧ `[ -f tsconfig.json ] && tsc --noEmit -p tsconfig.json`;
5:`npm audit`;
6:review(hooks,RSC,a11y,perf,React_sec);
7:emit_§OUT
}
§CAT{
CRITICAL:[
`dangerouslySetInnerHTML` unsanitized,
`href`/`src` unvalidated_URL(`javascript:`,`data:`),
Server_Action ¬input_val,
client_secret(`NEXT_PUBLIC_*`,`VITE_*`,`REACT_APP_*`),
`localStorage`/`sessionStorage` session_tokens,
conditional_hook(Rules_of_Hooks),
direct_state_mutation,
hook∉(component∨custom_hook)
];
HIGH:[
missing `useEffect`/`useMemo`/`useCallback` deps(disabled `exhaustive-deps` ¬justif),
effect for derived_state,
effect ¬cleanup(e.g.`AbortController`),
stale_closures(handlers/intervals),
server-only_import in Client_Comp,
sensitive_props→Client_Comp,
Server_Action ¬auth,
a11y(¬labels,non-semantic_interactive,ARIA_misuse),
`key={index}` dynamic_list,
dup_state, `useEffect` chains
];
MEDIUM:[
manual `useMemo`/`useCallback` w/ React_Compiler,
inline obj/fn prop→memo_child,
`Suspense` route-root-only(¬progressive),
long_list ¬virtualization,
high-freq `useContext`,
custom_val in non-trivial_form,
prop_drill>3,
component>200L,
new class_component
]
}
§GATE{
PASS:Approve ⇔ CRITICAL=0∧HIGH=0;
WARNING:Warning ⇔ CRITICAL=0∧HIGH=0∧MEDIUM>0;
FAIL:Block ⇔ CRITICAL>0∨HIGH>0
}
§OUT{
```text
# React Code Review Report
## Files Reviewed
- <path> (modified|new)
## Lint Results
PASS|FAIL: eslint / typecheck
## Issues Found
[<SEVERITY>] <title>
File: <path>:<line>
Issue: <problem>
Why: <impact>
Fix: <code_fix>
## Summary
- CRITICAL: <n> | HIGH: <n> | MEDIUM: <n>
Recommendation: <PASS|WARNING|FAIL>: <reason>
```
}
§REL{
cmds:/react-build(if_broken)→/react-test→/react-review(pre-merge), /code-review(non-React);
agents:react-reviewer,typescript-reviewer;
skills:`frontend-development/references/react-patterns.md`,`unit-testing-patterns/references/react-testing.md`,`web-quality-audit/references/web-accessibility.md`
}
