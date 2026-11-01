---
name: code-review
description: "Reviews code changes for correctness, security, performance, maintainability, test coverage, and production readiness across pull requests, branch audits, and codebase inspections. Use when opening a pull request, PR, or merge request; running git diff, lint, or static analysis; hunting bugs, vulnerabilities, or code smells; assessing refactors, dependency updates, or breaking changes; checking test coverage gaps, documentation updates, or CI failures; resolving review comments, nits, or change requests; verifying deployment readiness after an incident or postmortem; conducting onboarding reviews or pair programming; and deciding LGTM, approval, or blocker status before merge. Sub-skills: code-review-feedback, click-path-audit, change-impact, verification-loop."
---

# Code Review

Review code changes for correctness, security, performance, maintainability, tests, documentation, and production readiness. Use for pull requests, branch audits, and codebase quality assessments.

## When to use

- Reviewing pull requests or proposed code changes.
- Auditing local branch changes for bugs and security issues.
- Establishing or applying team code review standards.
- Assessing whether a codebase is production-ready.
- Providing constructive feedback on code quality.

## Review workflow

1. Read the change description, linked issues, and requirements.
2. Get the full diff with `git diff master...HEAD`; if truncated, read each changed file.
3. List every modified file before reviewing.
4. Map the attack surface: user inputs, database queries, auth checks, session/state, external calls, crypto.
5. Review functionality, security, performance, quality, tests, documentation, and Git hygiene.
6. Verify each suspected issue in surrounding code and tests.
7. Run available automated checks, such as `npm test`, `npm run lint`, and `npm audit`.
8. Report findings by severity; do not make changes unless asked.

## Context and scope

- Understand what problem the change solves and how data flows through it.
- Check whether the change conflicts with current requirements or architecture.
- Flag for senior review when it changes database schemas, API contracts, frameworks, performance-critical paths, or security-sensitive functionality.
- Prefer small changes; large changes are harder to review thoroughly.

## Functionality

- Code solves the stated problem and meets acceptance criteria.
- Edge cases and error cases are handled.
- User input is validated.
- Conditions have no off-by-one errors.
- Loops terminate and recursion has base cases.
- State management is correct.
- Errors are caught, messages are clear, and no sensitive data is exposed.
- Failed operations roll back where needed.
- Logging is appropriate.

## Security

Check every changed file for:

- Injection: SQL, command, template, header.
- XSS: all template output escaped.
- Authentication: protected operations require auth.
- Authorization and IDOR: access control verified, not only authentication.
- CSRF: state-changing operations protected.
- Race conditions: TOCTOU in read-then-write patterns.
- Session: fixation, expiration, secure flags.
- Cryptography: secure randomness, proper algorithms, no secrets in logs.
- Information disclosure: errors, logs, timing.
- Denial of service: unbounded work, missing rate limits, resource exhaustion.
- Business logic: edge cases, state machine violations, numeric overflow.

Additional security rules:

- Use parameterized queries; never concatenate user input into SQL.
- Never hardcode secrets; load them from environment variables and fail if missing.
- Hash passwords with bcrypt or equivalent; do not use MD5 or SHA1.
- Validate all inputs with an explicit schema or allowlist.
- Keep dependencies updated and remove unused ones.

Examples:

```javascript
// Bad: SQL injection risk
const query = `SELECT * FROM users WHERE email = '${email}'`;
db.query(query);

// Good: parameterized query
const query = 'SELECT * FROM users WHERE email = $1';
db.query(query, [email]);
```

```javascript
// Bad: hardcoded secret
const API_KEY = 'sk_live_abc123xyz';

// Good: environment variable
const API_KEY = process.env.API_KEY;
if (!API_KEY) throw new Error('API_KEY environment variable is required');
```

## Performance

- Avoid unnecessary loops, database queries, and allocations.
- Fix N+1 query problems with joins or prefetching.
- Add indexes for foreign keys and frequent filters.
- Use caching for repeated reads with a clear TTL.
- Prefer efficient algorithms; avoid unbounded O(n²) work.
- Move blocking work to async paths where appropriate.
- Check for memory leaks and unbounded growth.
- For frontends, reduce bundle size, split code, and optimize images.

Common targets from production audits: API response under 200 ms and gzipped bundle under 200 KB. Treat these as goals, not universal rules.

## Code quality

- Code is readable and easy to understand.
- Names are descriptive; avoid abbreviations and magic numbers.
- Functions are small and focused; extract helpers when needed.
- Follow DRY and separation of concerns.
- Remove dead code and commented-out code.
- Keep cyclomatic complexity low; refactor functions above 10.
- Avoid god classes over 500 lines or 20 methods.
- Remove circular dependencies and tight coupling.
- Follow project conventions and consistent formatting.

Examples:

```javascript
// Bad: unclear naming
function calc(a, b, c) {
  return a * b + c;
}

// Good: descriptive naming
function calculateTotalPrice(quantity, unitPrice, tax) {
  return quantity * unitPrice + tax;
}
```

```javascript
// Bad: one function does too much
function processOrder(order) {
  if (!order.items) throw new Error('No items');
  let total = 0;
  for (const item of order.items) total += item.price * item.quantity;
  if (order.coupon) total *= 0.9;
  const payment = stripe.charge(total);
  sendEmail(order.email, 'Order confirmed');
  updateInventory(order.items);
  return { orderId: order.id, total };
}

// Good: separated concerns
function processOrder(order) {
  validateOrder(order);
  const total = calculateOrderTotal(order);
  const payment = processPayment(total);
  sendOrderConfirmation(order.email);
  updateInventory(order.items);
  return { orderId: order.id, total };
}
```

## Tests

- New code has tests.
- Tests cover edge cases and error cases.
- Tests are meaningful and not over-branched.
- All tests pass in CI.
- Coverage is adequate; 80% is a common minimum for critical code.
- Critical paths have functional, integration, and end-to-end tests where appropriate.

## Documentation and Git

- Comments explain why, not what.
- API documentation, README, and migration notes are updated.
- Breaking changes are documented.
- Commit messages are clear.
- The branch is up to date with the base branch.
- No merge conflicts or unnecessary files are committed.
- `.gitignore` is correct.

## Design assessment

- Component interactions make logical sense.
- The change aligns with existing architecture.
- Backwards compatibility is preserved or a migration path exists.
- Long-term maintenance cost is acceptable.

## Common patterns to flag

Python/Django:

```python
# Bad: N+1 query
for user in users:
    print(user.profile.name)

# Good: prefetch related data
users = User.objects.prefetch_related('profile')
```

TypeScript/React:

```typescript
// Bad: missing dependency
useEffect(() => {
  fetchData(userId);
}, []);

// Good: include all dependencies
useEffect(() => {
  fetchData(userId);
}, [userId]);
```

Security:

```python
# Bad: SQL injection risk
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# Good: parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", [user_id])
```

## Feedback guidelines

- Be polite, empathetic, and specific.
- Provide actionable suggestions, not vague criticism.
- Phrase uncertain points as questions: Have you considered...?
- Approve when only minor issues remain.
- Do not block changes for stylistic preferences.
- The goal is risk reduction, not perfect code.

Use these comment shapes:

```markdown
**Issue:** [problem]

**Current code:**
```javascript
// problematic code
```

**Suggested fix:**
```javascript
// improved code
```

**Why:** [reason]
```

```markdown
**Question:** [question]

**Context:** [why you are asking]

**Suggestion:** [optional]
```

```markdown
**Nice!** [what you liked]

This is great because [reason]
```

## Bug hunt procedure for local changes

1. Gather the full diff and list changed files.
2. Map the attack surface for each file.
3. Check every security item for every file.
4. Verify whether each issue is already handled or tested.
5. Before concluding, list files reviewed, checklist results, and unverified areas.

Report format:

- Prioritize security vulnerabilities, then bugs, then quality.
- Skip stylistic and formatting issues.
- For each issue include: File:Line, Severity, Problem, Evidence, Fix, References.
- If nothing significant is found, say so. Do not invent issues.
- Do not make changes; report findings only.

## Production readiness review

When assessing production readiness, review:

Architecture:
- Circular dependencies, tight coupling, god classes, missing separation of concerns, poor module boundaries.

Security:
- SQL injection, XSS, hardcoded secrets, missing auth/authz, weak hashing, missing validation, CSRF, insecure dependencies.

Performance:
- N+1 queries, missing indexes, sync work that should be async, missing caching, inefficient algorithms, large bundles, unoptimized images, memory leaks.

Quality:
- High complexity, duplication, magic numbers, poor naming, missing error handling, inconsistent formatting, dead code, TODO/FIXME.

Testing:
- Missing tests for critical paths, coverage below 80%, no edge cases, flaky tests, missing integration tests.

Production infrastructure:
- Environment variables, logging, error tracking, health checks, monitoring, rate limiting, documentation, CI/CD.

Audit report shape:

```markdown
# Code Review Report

**Scope:** [PR, branch, or codebase]
**Date:** [date]

## Summary
[overall status and recommendation]

## Findings
### Critical
- [issue]

### High
- [issue]

### Medium
- [issue]

### Low
- [issue]

## Verified clean
- [areas checked with no issues]

## Unverified areas
- [areas not fully checked and why]
```

## Common pitfalls

- Missing edge cases: ask what if the input is null, empty, or unauthorized.
- Security vulnerabilities: run scanners such as `npm audit` or Snyk and check OWASP Top 10.
- Poor test coverage: require tests for all new code.
- Unclear code: request better names, comments, and smaller functions.
- Too many findings: focus on critical and high priority first.
- False positives: verify context before reporting.
- No follow-up: track findings as issues with owners.

## Checklist

- [ ] Full diff and changed files reviewed.
- [ ] Context and requirements understood.
- [ ] Functionality and edge cases checked.
- [ ] Security checklist completed for every changed file.
- [ ] Performance risks checked.
- [ ] Code quality and maintainability checked.
- [ ] Tests reviewed and passing.
- [ ] Documentation and Git hygiene checked.
- [ ] Design and compatibility assessed.
- [ ] Findings prioritized and reported with evidence.
- [ ] Unverified areas disclosed.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/code-review-feedback.md](references/code-review-feedback.md) | Provides a concise workflow for requesting a code review and handling review feedback. Use when you finish a task, feature, or bug fix and need review, and when you receive review comments that must be verified, clarified, or acted upon. |
| [references/click-path-audit.md](references/click-path-audit.md) | A button "does nothing" or UI state is wrong after a shared-store refactor: trace each handler call to find sequential undo, async races, stale closures, and dead paths. |
| [references/change-impact.md](references/change-impact.md) | Before a cross-module, migration, auth, or public-interface change: map the blast radius from real evidence, then compare the plan with the actual diff. |
| [references/verification-loop.md](references/verification-loop.md) | After a feature or refactor and before a PR: run build, types, lint, tests, security grep, and diff review, and write a PASS/FAIL report. |

## Related skills

Load these when the task spans more than this skill.

- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
