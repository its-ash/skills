---
name: verification-before-completion
description: "This skill runs fresh verification commands — unit tests, integration tests, lint, type checks, builds, security scans — and confirms clean output before declaring work complete, committing, or opening a pull request. Use when you are about to claim done, finished, fixed, passing, ready to commit, ready to merge, ready to push, ready for review; trigger terms include pytest, jest, vitest, cargo test, go test, npm test, mvn test, eslint, prettier, ruff, mypy, pyright, tsc, cargo check, go vet, npm run build, cargo build, go build, make, bandit, semgrep, trivy, snyk, git commit, git push, gh pr create."
---

# Verification Before Completion

**Purpose**: Ensure that every claim of success—tests passing, lint clean, build succeeding, bug fixed, or task completed—is backed by fresh, concrete evidence from the appropriate verification command.

## When to Use
- Before stating any positive result about code or a task.
- Before committing, pushing, or opening a pull request.
- Before moving to the next work item or delegating to another agent.
- After any code change, configuration change, or dependency update.

## Verification Gate
1. **Identify** the command that proves the claim (e.g., `npm test`, `ruff check`, `npx tsc`).
2. **Run** the full command in a clean environment. Do not rely on cached results.
3. **Read** the complete output. Check the exit code and count of failures or warnings.
4. **Verify** that the output matches the claim.
   - If it does not, report the actual status with evidence.
   - If it does, state the claim **and** attach the relevant output snippet.
5. Only after step 4 may you assert success.

> Skipping any step is a false claim.

## Common Verification Commands
| Domain | Command | Success Indicator |
|--------|---------|-------------------|
| Node.js / TypeScript tests | `npm test` or `npx jest` | Exit code 0, all tests pass |
| Node.js / TypeScript lint | `npm run lint` or `npx eslint "src/**/*.ts" --fix` | Exit code 0, no errors |
| Node.js / TypeScript types | `npx tsc --noEmit` | Exit code 0, no type errors |
| Node.js / Security audit | `npm audit --audit-level=high` | No high‑severity findings |
| Python lint | `ruff check "src" --fix` | Exit code 0, no lint errors |
| Python type check | `mypy "src"` | Exit code 0, no type errors |
| Python security scan | `bandit -r "src" -ll` | Exit code 0, no issues |
| Build (any language) | Language‑specific build command (e.g., `npm run build`, `make`) | Exit code 0 |
| Regression test (TDD) | Run test, revert change, run again (must fail), restore, run again (must pass) | Both passes and expected failure observed |

## Red Flags – Stop Immediately
- Using words like *should*, *probably*, *seems*, or *looks good* instead of concrete evidence.
- Expressing satisfaction (“Great!”, “Done!”) before verification.
- Attempting to commit, push, or open a PR without running the required command.
- Trusting an agent’s success report without independent verification.
- Relying on partial output (e.g., only lint results when a build is required).

## Rationalization Prevention
| Excuse | Required Action |
|--------|-----------------|
| “It should work now.” | Run the verification command. |
| “I’m confident.” | Confidence does not replace evidence. |
| “Just this once.” | No exceptions; always verify. |
| “Linter passed.” | Run the build or type check if required. |
| “Agent said success.” | Independently check VCS diff and run the command. |
| “I’m tired.” | Exhaustion is not a reason to skip verification. |
| “Partial check is enough.” | Partial results do not prove full success. |

## Key Patterns for Evidence
- **Tests**
  ```
  ✅ npm test          # 120/120 pass
  ❌ "Should pass now"  # No command run
  ```
- **Regression (Red‑Green)**
  ```
  ✅ Write failing test → Run (FAIL) → Fix code → Run (PASS)
  ❌ "I added a regression test" without confirming red‑green cycle.
  ```
- **Build**
  ```
  ✅ npm run build    # exit 0
  ❌ "Linter passed" (does not guarantee build).
  ```
- **Requirements Checklist**
  ```
  ✅ Re‑read plan → Create checklist → Verify each item → Report gaps.
  ❌ "All tests pass, phase complete" without checklist.
  ```
- **Agent Delegation**
  ```
  ✅ Agent reports success → Check VCS diff → Run verification → Report actual state.
  ❌ Trust agent report without verification.
  ```

## Checklist
- [ ] Identify the exact verification command for the claim.
- [ ] Run the command in a fresh environment.
- [ ] Capture full output and exit code.
- [ ] Confirm output matches the claim (zero failures, no high‑severity issues).
- [ ] Attach a concise excerpt of the output as evidence.
- [ ] Only then state the success claim or proceed to commit/PR.
- [ ] If any step fails, report the failure and fix before repeating.

**Bottom line**: No claim of completion, correctness, or readiness is valid without fresh, verifiable evidence from the appropriate tool.

## Related skills

Load these when the task spans more than this skill.

- [`git-commit`](../git-commit/SKILL.md) — Generate conventional commit messages by analyzing staged changes, suggesting type, scope, and wording, and gu…
- [`git-branch-workflow`](../git-branch-workflow/SKILL.md) — The git-branch-workflow skill creates an isolated Git worktree for a new feature branch, runs project setup an…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
