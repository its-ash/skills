# Review Checklist

Check each area for every changed file. Verify each suspect issue in the surrounding code and tests before you report it.

## Context and scope
- Know the problem the change solves and how data flows through it.
- Check for conflicts with current requirements or architecture.
- Flag for senior review: database schemas, API contracts, frameworks, performance-critical paths, security-sensitive code.
- Prefer small changes. Large changes hide defects.

## Functionality
- Solves the stated problem; meets acceptance criteria.
- Edge and error cases handled; user input validated.
- No off-by-one errors. Loops end. Recursion has a base case.
- State management correct.
- Errors caught, messages clear, no sensitive data exposed.
- Failed operations roll back where needed. Logging fits the need.

## Security
- Injection: SQL, command, template, header.
- XSS: all template output escaped.
- Authentication: protected operations require auth.
- Authorization and IDOR: verify access control, not only authentication.
- CSRF: state-changing operations protected.
- Race conditions: TOCTOU in read-then-write code.
- Session: fixation, expiry, secure flags.
- Crypto: secure randomness, correct algorithms, no secrets in logs.
- Information disclosure: errors, logs, timing.
- DoS: unbounded work, missing rate limits, resource exhaustion.
- Business logic: state machine violations, numeric overflow.
- Parameterized queries only. Secrets from env; fail if missing. bcrypt or equal for passwords (no MD5/SHA1). Schema or allowlist for all input. Remove unused dependencies.

```javascript
// Bad
db.query(`SELECT * FROM users WHERE email = '${email}'`);
// Good
db.query('SELECT * FROM users WHERE email = $1', [email]);
```

## Performance
- No unnecessary loops, queries, or allocations.
- N+1 queries: fix with joins or prefetch. Index foreign keys and frequent filters.
- Cache repeated reads with a clear TTL.
- No unbounded O(n²) work. Move blocking work to async paths.
- No memory leaks or unbounded growth.
- Frontend: small bundle, code splitting, optimized images.
- Typical goals (not universal rules): API response < 200 ms, gzipped bundle < 200 KB.

```python
# Bad: N+1
for user in users: print(user.profile.name)
# Good
users = User.objects.prefetch_related('profile')
```

## Code quality
- Cyclomatic complexity ≤ 10 per function; refactor above.
- No god classes (> 500 lines or > 20 methods).
- No circular dependencies or tight coupling.
- No dead or commented-out code, no magic numbers, no duplication.
- Follow project conventions. For naming and function design, see [`clean-code`](../../clean-code/SKILL.md).

```typescript
// Bad: missing dependency
useEffect(() => { fetchData(userId); }, []);
// Good
useEffect(() => { fetchData(userId); }, [userId]);
```

## Tests
- New code has tests that cover edge and error cases.
- Tests are meaningful, not over-branched, and pass in CI.
- Coverage ≥ 80% on critical code is a common minimum.
- Critical paths have integration and e2e tests where they fit.

## Documentation and Git
- Comments explain why, not what.
- API docs, README, and migration notes updated. Breaking changes documented.
- Clear commit messages. Branch current with base. No conflicts, no stray files, correct `.gitignore`.

## Design
- Component interactions make sense and match existing architecture.
- Backward compatibility kept, or a migration path exists.
- Long-term maintenance cost acceptable.

## Production readiness audit
| Area | Check |
|---|---|
| Architecture | Circular deps, tight coupling, god classes, poor module boundaries |
| Security | SQLi, XSS, hardcoded secrets, missing auth/authz, weak hashing, missing validation, CSRF, insecure deps |
| Performance | N+1, missing indexes, sync work that must be async, no caching, slow algorithms, large bundles, unoptimized images, leaks |
| Quality | High complexity, duplication, magic numbers, poor naming, missing error handling, dead code, TODO/FIXME |
| Testing | Critical paths untested, coverage < 80%, no edge cases, flaky tests, no integration tests |
| Infrastructure | Env vars, logging, error tracking, health checks, monitoring, rate limiting, docs, CI/CD |

## Pitfalls
- Missing edge cases: ask "null, empty, or unauthorized?"
- Run scanners (`npm audit`, Snyk); check OWASP Top 10.
- Too many findings: report Critical and High first.
- False positives: verify context before you report.
- No follow-up: track findings as issues with owners.
