---
name: git-workflow
description: "Git and GitHub workflows: branching (GitHub Flow, trunk-based, GitFlow), Conventional Commits, merge vs rebase, PR templates, conflicts, SemVer releases, changelogs, Git config and hooks, gh CLI, issue triage, Jira, and open-sourcing private repos. Use when choosing a branching strategy, writing commit messages, rebasing, resolving conflicts, tagging releases, triaging issues or PRs, or updating Jira tickets. Sub-skills: github-ops, conventional-commit-review, issue-review, jira-integration, opensource-pipeline, project-flow-ops."
---
# Git Workflow

Run Git branching, commits, PRs, conflicts, and releases safely.

## Core rules
- Do not commit directly to `main`. Use a branch and a PR.
- Keep branches short (days, not weeks). Rebase onto `origin/main` often.
- Keep a PR to one feature or fix, ideally < 500 changed lines.
- Write commits as `<type>(<scope>): <subject>`: imperative, no period, ≤ 50 chars. Body tells why, not what.
- Mark breaking changes with `!` or a `BREAKING CHANGE:` footer.
- Never rebase or force-push a shared, protected, or merged branch.
- After a rebase of your own branch, push with `--force-with-lease`, never `--force`.
- Undo public history with `git revert`, not `reset`.
- Never commit secrets, `.env`, `node_modules/`, `dist/`, or other generated files. Put them in `.gitignore`.
- Tag releases with annotated SemVer tags (`git tag -a vX.Y.Z`).
- Run CI (tests, lint, typecheck) green and self-review before you ask for review.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Continuous deploy, any team size (SaaS, startups) | GitHub Flow | GitFlow overhead |
| 5+ experienced devs, deploy many times per day | Trunk-based + feature flags | Long-lived branches |
| 10+ devs, scheduled or regulated releases | GitFlow (`develop`, `release/*`, `hotfix/*`) | Trunk without flags |

| Situation | Do | Avoid |
|---|---|---|
| Update local or solo branch with `main` | `git rebase origin/main` | Merge commits that add noise |
| Branch pushed and used by others | `git merge` | Rebase (it rewrites history) |
| Feature branch into `main` | Merge via PR (squash if history is messy) | Direct push |
| Bad commit already pushed | `git revert <sha>` | `git push --force origin main` |
| Bad commit only local | `git reset --soft HEAD~1` | `--hard` when you need the changes |
| Conflict in one file | Edit markers, or `--ours` / `--theirs`, then `git add` | Commit with markers left in |

| Change | SemVer bump |
|---|---|
| Breaking change | MAJOR |
| Backward-compatible feature | MINOR |
| Backward-compatible fix | PATCH |

## Load on demand

| Need | Read |
|---|---|
| Strategy details, branch names, PR template, review checklist, conflict steps, fork sync | [references/branching-and-prs.md](references/branching-and-prs.md) |
| Commit type table, `.gitmessage` template, tags, changelog | [references/commits-and-releases.md](references/commits-and-releases.md) |
| Command cheat sheet, undo table, branch cleanup, stash, config, aliases, `.gitignore`, hooks | [references/git-commands.md](references/git-commands.md) |
| `gh` CLI: issue triage, labels, PR status, failed CI runs, releases, Dependabot or secret-scanning alerts | [references/github-ops.md](references/github-ops.md) |
| Draft or review a commit message from the staged diff and repo history | [references/conventional-commit-review.md](references/conventional-commit-review.md) |
| Triage one GitHub issue: verify, find duplicates, score, draft a reply | [references/issue-review.md](references/issue-review.md) |
| Jira tickets via `mcp-atlassian` or REST; acceptance criteria | [references/jira-integration.md](references/jira-integration.md) |
| Make a private project public: fork, sanitize, package, publish | [references/opensource-pipeline.md](references/opensource-pipeline.md) |
| Backlog control: merge, rebuild, close, or park PRs; Linear tracking | [references/project-flow-ops.md](references/project-flow-ops.md) |

## Related skills
- [`code-review`](../code-review/SKILL.md) — review changes before merge
- [`github-actions`](../devops-iac/references/github-actions.md) — CI/CD workflows on GitHub Actions
- [`devops-iac`](../devops-iac/SKILL.md) — pipelines, GitOps, deployment patterns
- [`secure-coding`](../secure-coding/SKILL.md) — secret handling and security checks
