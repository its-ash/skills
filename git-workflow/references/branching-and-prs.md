# Branching, PRs, and Conflicts

## Branching strategies

| Strategy | Shape | Rules |
|---|---|---|
| GitHub Flow | `main` + `feature/*`, `fix/*` → PR → `main` | `main` always deployable; branch from `main`; merge after approval + green CI; deploy right after merge. |
| Trunk-based | `main` + branches of 1-2 days max | Commit to `main` or very short branches; hide incomplete work behind feature flags; CI must pass; deploy many times per day. |
| GitFlow | `main` (prod) + `develop` (integration) + `feature/*`, `release/*`, `hotfix/*` | Feature: from `develop`, merge to `develop`. Release: from `develop`, merge to `main` and `develop`. Hotfix: from `main`, merge to `main` and `develop`. |

## Branch names

```
feature/user-authentication     feature/JIRA-123-payment-integration
fix/login-redirect-loop         fix/456-null-pointer-exception
hotfix/critical-security-patch  release/1.2.0
experiment/new-caching-strategy poc/graphql-migration
```

## PR title and description

Title: `<type>(<scope>): <description>`, e.g. `fix(api): resolve race condition in order processing`.

```markdown
## What
## Why
## How
## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing performed
## Screenshots (UI changes: before/after)
## Checklist
- [ ] Self-review done
- [ ] Docs updated
- [ ] No new warnings
- [ ] Tests pass locally
- [ ] Related issues linked

Closes #123
```

## Review checklist

Author: self-review first; CI green (tests, lint, typecheck); < 500 changed lines; one feature or fix; description explains the change.

Reviewer: solves the stated problem; edge cases; readability; enough tests; security; clean history (squash if needed). Full review process: [`code-review`](../../code-review/SKILL.md).

## Conflicts

```bash
git merge feature/user-auth --no-commit --no-ff   # dry-run merge on main
git status                                        # list conflicted files
# edit files: remove <<<<<<< ======= >>>>>>> markers, keep correct content
git mergetool                                     # or use a merge tool
git checkout --ours   path/file                   # keep current-branch side
git checkout --theirs path/file                   # keep incoming side
git add path/file && git commit
```

Prevent: keep branches small and short; `git fetch origin && git rebase origin/main` often; tell the team before you touch shared files; use feature flags, not long branches; merge PRs fast.

## Sync a fork

```bash
git remote add upstream https://github.com/original/repo.git   # once
git fetch upstream && git checkout main && git merge upstream/main && git push origin main
```
