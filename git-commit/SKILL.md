---
name: git-commit
description: "Generate conventional commit messages by analyzing staged changes, suggesting type, scope, and wording, and guiding staging, committing, amending, and optional pushing. Use when running git add, git commit, git commit --amend, git push, fixing commit messages, writing feat, fix, chore, docs, refactor, test, or style messages, resolving staged diff or commit-msg hook issues, and amending the last commit."
---

# Git Commit Helper

Create clear, conventional commit messages by examining the current Git diff. The skill walks you through reviewing changes, picking a type and scope, writing an imperative summary, adding a body that explains **why**, and handling breaking changes, amends, and pushes.

## When to use
- You need a commit message for staged changes.
- You want to follow Conventional Commits or Sentry‑style conventions.
- You are ready to push a completed feature, bug‑fix, or refactor.
- You need to amend or split a commit.

## Workflow
1. **Review the current state**
   ```bash
   git status                # files changed
   git diff --stat           # summary of changes
   git diff --cached --stat  # staged changes summary
   ```
2. **Stage the appropriate files**
   - Stage all: `git add .`
   - Stage interactively: `git add -p`
3. **Inspect the staged diff**
   ```bash
   git diff --cached          # full staged diff
   ```
4. **Determine type and scope** (see table below).  Override with arguments if you already know them.
5. **Compose the message**
   - Subject line ≤ 72 characters, imperative, capitalized, no period.
   - Optional body explains *why* the change was made.
   - Optional footer for breaking changes or issue references.
6. **Confirm and commit**
   ```bash
   git commit -m "type(scope): short summary"
   ```
   Review the commit:
   ```bash
   git log --oneline -1
   ```
7. **(Optional) Push**
   ```bash
   git push -u origin $(git rev-parse --abbrev-ref HEAD)
   ```

## Commit message format
```
<type>(<scope>): <subject>

<body>

<footer>
```
- `<type>`: required, one of the types listed.
- `<scope>`: optional, a short identifier of the affected area.
- `<subject>`: imperative summary.
- `<body>`: explains *why* the change was needed.
- `<footer>`: breaking‑change notice or issue references.

## Types and typical scopes
| Type | Meaning | Typical scopes |
|------|---------|----------------|
| **feat** | New feature | `ui`, `api`, `auth`, `db` |
| **fix** | Bug fix | `api`, `ui`, `db`, `config` |
| **docs** | Documentation only | `readme`, `changelog` |
| **style** | Formatting, whitespace, lint fixes | *none* |
| **refactor** | Code restructuring without behavior change | `core`, `service`, `utils` |
| **test** | Add or modify tests | `tests` |
| **chore** | Maintenance tasks (deps, CI) | `ci`, `build`, *none* |
| **perf** | Performance improvement | `api`, `db` |
| **build** | Build system changes | `webpack`, `npm`, `docker` |
| **ci** | CI/CD configuration | `github-actions`, `gitlab-ci` |
| **meta** | Repository metadata | *none* |
| **license** | License file changes | *none* |

## Guidelines
### DO
- Use imperative mood: `add`, `fix`, `refactor`.
- Keep the subject ≤ 72 characters.
- Capitalize the first word.
- Omit the period at the end of the subject.
- Explain **why** the change was made in the body.
- Reference related issues in the footer (`Fixes #123`, `Refs GH-456`).
- Mark breaking changes with `!` after the scope and add a `BREAKING CHANGE:` line.

### DON'T
- Use vague summaries like `update` or `fix stuff`.
- Include implementation details in the subject.
- Write the subject in past tense.
- End the subject with a period.
- Mix unrelated changes in one commit.

## Multi‑file commits
When several related files are changed, keep a single commit that describes the overall purpose.
```text
refactor(auth): restructure authentication module

- Move logic from controllers to service layer
- Extract validation into separate validators
- Update tests for new structure
- Add integration tests for auth flow

BREAKING CHANGE: Auth service now requires a config object
```

## Breaking changes
Add an exclamation mark after the scope and a `BREAKING CHANGE:` paragraph.
```text
feat(api)!: change response format

BREAKING CHANGE: All API responses now follow JSON:API spec.
```

## Amending commits
- Edit only the message:
  ```bash
  git commit --amend
  ```
- Add more changes and keep the existing message:
  ```bash
  git add <file>
  git commit --amend --no-edit
  ```

## Pushing after commit
Push the current branch and set the upstream if needed:
```bash
git push -u origin $(git rev-parse --abbrev-ref HEAD)
```
If you need to push a specific commit range, use `git push origin <branch>`.

## Checklist before committing
- [ ] Type matches the nature of the change.
- [ ] Scope (if any) accurately identifies the affected area.
- [ ] Subject ≤ 72 characters, imperative, capitalized, no period.
- [ ] Body explains *why* the change was made (skip if trivial).
- [ ] Breaking changes are clearly marked.
- [ ] Issue numbers are referenced in the footer when relevant.
- [ ] The commit is atomic – one logical change only.
- [ ] All relevant files are staged; unrelated files are left unstaged.
- [ ] Tests pass and the repository builds.

## Related skills

Load these when the task spans more than this skill.

- [`git-branch-workflow`](../git-branch-workflow/SKILL.md) — The git-branch-workflow skill creates an isolated Git worktree for a new feature branch, runs project setup an…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`clean-code`](../clean-code/SKILL.md) — Pragmatic clean code standards for AI-assisted development. Covers naming, function design, code structure, an…
- [`jira`](../jira/SKILL.md) — Interact with Jira issues using the jira CLI or Atlassian MCP tools. Use when the user mentions an issue key (…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
