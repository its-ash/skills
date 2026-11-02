# Commits, Releases, and Changelogs

Commit-message drafting from a staged diff: [conventional-commit-review.md](conventional-commit-review.md).

## Commit types

| Type | Use for | Example |
|---|---|---|
| `feat` | New feature | `feat(auth): add OAuth2 login` |
| `fix` | Bug fix | `fix(api): handle null response in user endpoint` |
| `docs` | Documentation | `docs(readme): update installation instructions` |
| `style` | Formatting only | `style: fix indentation in login component` |
| `refactor` | No behavior change | `refactor(db): extract connection pool to module` |
| `test` | Tests | `test(auth): add unit tests for token validation` |
| `chore` | Maintenance | `chore(deps): update dependencies` |
| `perf` | Performance | `perf(query): add index to users table` |
| `ci` | CI/CD | `ci: add PostgreSQL service to test workflow` |
| `revert` | Revert | `revert: revert "feat(auth): add OAuth2 login"` |

Bad: `fixed stuff`, `updates`, `WIP`. Good:

```
fix(api): retry requests on 503 Service Unavailable

The external API returns 503 errors during peak hours.
Add exponential backoff retry, max 3 attempts.

Closes #123
```

## Commit template

`.gitmessage` at repo root, enable with `git config commit.template .gitmessage`:

```
# <type>(<scope>): <subject>
# Types: feat, fix, docs, style, refactor, test, chore, perf, ci, revert
# Subject: imperative, no period, max 50 chars
# Body: explain why, not what
# Footer: BREAKING CHANGE, Closes #issue
```

## Semantic versioning

`MAJOR.MINOR.PATCH`: MAJOR = breaking change; MINOR = backward-compatible feature; PATCH = backward-compatible fix. `1.0.0→1.0.1` fix, `1.0.1→1.1.0` feature, `1.1.0→2.0.0` breaking.

## Tags and releases

```bash
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Add user authentication
Fixes:
- Resolve login redirect issue
Breaking Changes:
- None"
git push origin v1.2.0
git tag -l
git tag -d v1.2.0 && git push origin --delete v1.2.0
```

`gh release` flow: [github-ops.md](github-ops.md).

## Changelog

```bash
git log v1.1.0..v1.2.0 --oneline --no-merges
npx conventional-changelog -i CHANGELOG.md -s
```
