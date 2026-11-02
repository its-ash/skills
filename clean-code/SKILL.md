---
name: clean-code
description: "Enforces pragmatic clean code standards for AI-assisted development covering naming, function design, structure, and anti-patterns via a mandatory deslop workflow that audits git diffs against main to strip AI-generated slop: excessive comments, defensive checks, type casts, inline imports, style inconsistencies. Use when writing, reviewing, refactoring, or linting code in any language, running git diff, git commit, or pull request reviews, fixing naming violations, simplifying functions, removing dead code, eliminating magic numbers, reducing cyclomatic complexity, or applying SOLID principles during code review, pre-commit hooks, CI pipelines, or pair programming. Sub-skills: coding-standards, inherit-legacy-style, codehealth-mcp."
---
# Clean Code

Keep code small, direct, and free of AI slop. Run the deslop pass after every change.

## Core rules
- Give each function or class one responsibility (SRP). Keep one level of abstraction per function.
- Build the simplest thing that works (KISS). Do not build unused features (YAGNI).
- Extract real duplication (DRY); do not abstract one-off code.
- Leave touched code cleaner than you found it.
- Keep functions ≤20 lines (ideally 5–10) with ≤3 args (prefer 0–2). Do not mutate inputs unexpectedly.
- Use guard clauses and early returns. Keep nesting ≤2 levels.
- Name functions verb + noun (`getUserById`), booleans as questions (`isActive`, `hasPermission`, `canEdit`), constants in `SCREAMING_SNAKE`. If a name needs a comment, rename it.
- Replace magic numbers with named constants.
- Colocate related code; compose small functions.
- Before you edit a file, find what imports it, what it imports, which tests cover it, and whether it is shared. Update all dependents in the same task.
- After every change, run the deslop pass on `git diff main...HEAD`: remove excess comments, abnormal defensive checks, `any` casts, inline imports, and style drift.
- Run the project's lint, type, and test commands before you say done.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Helper wraps a one-liner | inline it | new function |
| Two object types to build | direct instantiation | factory |
| `utils` file with one function | put code where it is used | catch-all utils module |
| God function | split by responsibility | adding flags/params |
| Deep `if` nesting | guard clauses | else-chains |
| Obvious comment | delete it | comment every line |
| Type error | fix the type | `as any`, `cast(Any, ...)` |
| Requirement unclear | ask one question | assume and build |

## Load on demand

| Need | Read |
|---|---|
| Deslop steps, slop table, report format, completion self-check, verify commands | [references/deslop.md](references/deslop.md) |
| TS/JS examples: naming, immutability, error handling, async, types, file layout, comments, smells | [references/coding-standards.md](references/coding-standards.md) |
| Legacy codebase: extract unwritten conventions into `.ai-style-rules.md`, stop style drift | [references/inherit-legacy-style.md](references/inherit-legacy-style.md) |
| CodeScene Code Health MCP: score before/after edits, gate commits and PRs | [references/codehealth-mcp.md](references/codehealth-mcp.md) |

## Related skills
- [`code-review`](../code-review/SKILL.md) — correctness, security, and readiness review of changes.
- [`software-architecture`](../software-architecture/SKILL.md) — patterns and architecture decisions.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Jest and pytest unit test patterns.
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — root cause of bugs and test failures.
