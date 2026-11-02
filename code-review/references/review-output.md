# Review Output Formats

## Finding fields
`File:Line` · Severity · Problem · Evidence · Fix · References.

## Comment shapes
````markdown
**Issue:** [problem]
**Current code:**
```js
// problematic code
```
**Suggested fix:**
```js
// improved code
```
**Why:** [reason]
````

```markdown
**Question:** [question]
**Context:** [why you ask]
**Suggestion:** [optional]
```

```markdown
**Nice!** [what you liked] — this is good because [reason]
```

## Audit report
```markdown
# Code Review Report
**Scope:** [PR, branch, or codebase]
**Date:** [date]

## Summary
[overall status and recommendation]

## Findings
### Critical
### High
### Medium
### Low

## Verified clean
- [areas checked with no issues]

## Unverified areas
- [areas not fully checked and why]
```

## Final checklist
- [ ] Full diff and all changed files reviewed.
- [ ] Context and requirements understood.
- [ ] Functionality, security, performance, quality, tests, docs, Git, design checked.
- [ ] Findings prioritized, each with evidence.
- [ ] Unverified areas disclosed.
