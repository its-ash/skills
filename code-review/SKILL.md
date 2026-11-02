---
name: code-review
description: "Reviews code changes for correctness, security, performance, maintainability, test coverage, and production readiness in pull requests, branch audits, and codebase inspections. Use when opening a PR or merge request, running git diff, lint, or static analysis, hunting bugs, vulnerabilities, or code smells, assessing refactors, dependency updates, or breaking changes, checking test coverage or CI failures, resolving review comments, verifying deployment readiness, or deciding LGTM, approval, or blocker status. Sub-skills: code-review-feedback, click-path-audit, change-impact, verification-loop."
---

# Code Review
Find real risk in a change and report it by severity, with evidence.

## Core rules
- Read the change description, linked issues, and requirements first.
- Get the full diff (`git diff <base>...HEAD`). If truncated, read each changed file. List all changed files before you review.
- Map the attack surface per file: user input, DB queries, auth checks, session/state, external calls, crypto.
- Run the security checklist on every changed file.
- Verify each suspect issue in the surrounding code and tests. Do not report unverified guesses as fact.
- Run available checks (`npm test`, `npm run lint`, `npm audit`, or the stack equivalent).
- Order findings: security, then bugs, then quality. Skip style and format issues.
- Give each finding: `File:Line`, Severity, Problem, Evidence, Fix, References.
- If you find nothing significant, say so. Do not invent issues.
- Report only. Do not change code unless asked.
- List files reviewed, checks done, and unverified areas before you conclude.
- Be specific and actionable. Ask a question when unsure ("Have you considered...?").
- Approve when only minor issues remain. Do not block on preference. The goal is less risk, not perfect code.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Change touches schema, API contract, framework, hot path, or security code | Flag for senior review; load change-impact | Approve on diff alone |
| Large diff | Ask to split; review Critical/High first | Line-by-line nits across all files |
| Many findings | Report Critical and High first; track the rest as issues with owners | One flat list |
| Suspect issue | Check callers, guards, and tests | Report without evidence |
| Production readiness question | Run the audit table in review-checklist | Diff-only review |
| UI action "does nothing" after refactor | Load click-path-audit | Guess from component code |
| You receive review comments | Load code-review-feedback | Agree without verification |

| Severity | Meaning | Merge |
|---|---|---|
| Critical | Exploit, data loss, outage | Block |
| High | Wrong behavior on a main path | Block |
| Medium | Edge-case bug, missing test, perf risk | Fix or ticket |
| Low | Maintainability, minor clarity | Comment only |

## Load on demand
| Need | Read |
|---|---|
| Per-area checklist (functionality, security, perf, quality, tests, docs, design), production-readiness audit, pitfalls | [references/review-checklist.md](references/review-checklist.md) |
| Comment shapes, audit report template, final checklist | [references/review-output.md](references/review-output.md) |
| Request a review or handle received feedback | [references/code-review-feedback.md](references/code-review-feedback.md) |
| Button does nothing or wrong UI state after shared-store refactor | [references/click-path-audit.md](references/click-path-audit.md) |
| Cross-module, migration, auth, or public-interface change: blast radius | [references/change-impact.md](references/change-impact.md) |
| Before a PR: build, types, lint, tests, security grep, PASS/FAIL report | [references/verification-loop.md](references/verification-loop.md) |

## Related skills
- [`secure-coding`](../secure-coding/SKILL.md) — secrets, auth, input validation, injection checks
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — judge and write missing tests
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — root-cause a confirmed bug
- [`clean-code`](../clean-code/SKILL.md) — naming, function design, deslop diff
