---
name: clean-code
description: "Enforces pragmatic clean code standards for AI-assisted development covering naming, function design, structure, and anti-patterns via a mandatory deslop workflow that audits git diffs against main to strip AI-generated slop: excessive comments, defensive checks, type casts, inline imports, style inconsistencies. Use when writing, reviewing, refactoring, or linting code in any language, running git diff, git commit, or pull request reviews, fixing naming violations, simplifying functions, removing dead code, eliminating magic numbers, reducing cyclomatic complexity, or applying SOLID principles during code review, pre-commit hooks, CI pipelines, or pair programming."
---

# Clean Code - Pragmatic Standards & Deslop Workflow

Concise, direct coding standards for AI-assisted development. Enforces single responsibility, minimal abstraction, self-documenting names, and a mandatory deslop pass that strips AI-generated noise from every change.

## When to Use

- Writing new functions, classes, or modules
- Refactoring existing code
- Reviewing PRs or AI-generated patches
- Before committing any change

## Core Principles

| Principle | Rule |
|-----------|------|
| SRP | Each function/class does ONE thing |
| DRY | Extract duplicates, reuse |
| KISS | Simplest solution that works |
| YAGNI | Don't build unused features |
| Boy Scout | Leave code cleaner than found |

## Naming Rules

| Element | Convention |
|---------|------------|
| Variables | Reveal intent: `userCount` not `n` |
| Functions | Verb + noun: `getUserById()` not `user()` |
| Booleans | Question form: `isActive`, `hasPermission`, `canEdit` |
| Constants | SCREAMING_SNAKE: `MAX_RETRY_COUNT` |

**Rule:** If you need a comment to explain a name, rename it.

## Function Rules

| Rule | Description |
|------|-------------|
| Small | Max 20 lines, ideally 5-10 |
| One Thing | Does one thing, does it well |
| One Level | One level of abstraction per function |
| Few Args | Max 3 arguments, prefer 0-2 |
| No Side Effects | Don't mutate inputs unexpectedly |

## Code Structure

| Pattern | Apply |
|---------|-------|
| Guard Clauses | Early returns for edge cases |
| Flat > Nested | Avoid deep nesting (max 2 levels) |
| Composition | Small functions composed together |
| Colocation | Keep related code close |

## AI Coding Style

| Situation | Action |
|-----------|--------|
| User asks for feature | Write it directly |
| User reports bug | Fix it, don't explain |
| No clear requirement | Ask, don't assume |

## Anti-Patterns (Don't)

| ❌ Pattern | ✅ Fix |
|------------|-------|
| Comment every line | Delete obvious comments |
| Helper for one-liner | Inline the code |
| Factory for 2 objects | Direct instantiation |
| `utils.ts` with 1 function | Put code where used |
| "First we import..." | Just write code |
| Deep nesting | Guard clauses |
| Magic numbers | Named constants |
| God functions | Split by responsibility |

## Before Editing Any File (Think First)

Before changing a file, ask:

| Question | Why |
|----------|-----|
| What imports this file? | They might break |
| What does this file import? | Interface changes |
| What tests cover this? | Tests might fail |
| Is this a shared component? | Multiple places affected |

**Rule:** Edit the file + all dependent files in the SAME task. Never leave broken imports or missing updates.

## Deslop Workflow (Mandatory After Every Change)

Run this after completing any code modification to strip AI-generated slop.

### 1. Get the Diff

```bash
git diff main...HEAD
```

### 2. Review Each Changed File for Slop Patterns

Remove the following while preserving legitimate functional changes:

- **Excessive comments** — Comments a human wouldn't add, or comments inconsistent with the rest of the file (e.g., "This function returns the user" above a `getUser()` function)
- **Defensive over-checking** — Extra `try/catch`, null checks, or validation blocks that are abnormal for that code area, especially when called by already-validated codepaths
- **`any` casts** — TypeScript `as any` or Python `cast(Any, ...)` used to silence type errors instead of fixing the type
- **Inline imports** — Python imports inside functions; move to top of file with other imports
- **Style inconsistencies** — Formatting, naming, or patterns that differ from the surrounding file

### 3. Report Summary

After cleaning, output a 1-3 sentence summary:

```
Removed 3 inline comments, 1 unnecessary try/catch, and moved 2 inline imports to module top in user_service.py
```

## Self-Check Before Completing (Mandatory)

Before saying "task complete", verify:

| Check | Question |
|-------|----------|
| ✅ Goal met? | Did I do exactly what user asked? |
| ✅ Files edited? | Did I modify all necessary files? |
| ✅ Code works? | Did I test/verify the change? |
| ✅ No errors? | Lint and type checks pass? |
| ✅ Nothing forgotten? | Any edge cases missed? |
| ✅ Deslop done? | Ran git diff review and cleaned slop? |

**Rule:** If ANY check fails, fix it before completing.

## Verification Commands

Run the project's standard lint/type/test commands after changes. Examples:

```bash
# TypeScript/JS
npm run lint && npm run typecheck && npm test

# Python
ruff check . && mypy . && pytest

# Go
go vet ./... && go test ./...
```

Use the project's configured tooling. Do not invent new scripts.

## Summary

| Do | Don't |
|----|-------|
| Write code directly | Write tutorials |
| Let code self-document | Add obvious comments |
| Fix bugs immediately | Explain the fix first |
| Inline small things | Create unnecessary files |
| Name things clearly | Use abbreviations |
| Keep functions small | Write 100+ line functions |
| Run deslop on every change | Leave AI slop in the codebase |

**Remember: The user wants working, clean code — not a programming lesson.**

## Related skills

Load these when the task spans more than this skill.

- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
