# Deslop Workflow and Completion Check

Detail for the mandatory pass in [`../SKILL.md`](../SKILL.md). Run it after every code change.

## 1. Get the diff

```bash
git diff main...HEAD
```

## 2. Remove slop, keep functional changes

| Slop | Signal | Fix |
|---|---|---|
| Excessive comments | A human would not write it, or it differs from the file's comment style (e.g. "This function returns the user" above `getUser()`) | Delete |
| Defensive over-checking | Extra `try/catch`, null checks, or validation that is abnormal for that area, esp. on already-validated paths | Delete |
| Type escape hatches | TS `as any`, Python `cast(Any, ...)` to silence errors | Fix the type |
| Inline imports | Python imports inside functions | Move to top with other imports |
| Style drift | Formatting, naming, or patterns unlike the surrounding file | Match the file |

## 3. Report

One to three sentences, e.g.:
```
Removed 3 inline comments, 1 unnecessary try/catch, and moved 2 inline imports to module top in user_service.py
```

## Self-check before "done"

Fix any failure before you finish.

| Check | Question |
|---|---|
| Goal | Did I do exactly what the user asked? |
| Files | Did I edit every file that needs it (importers, importees, tests, shared users)? |
| Works | Did I run or verify the change? |
| Clean | Do lint and type checks pass? |
| Edges | Did I miss an edge case? |
| Deslop | Did I review the diff and remove slop? |

## Verification commands

Use the project's configured tooling. Do not invent scripts.

| Stack | Command |
|---|---|
| TS/JS | `npm run lint && npm run typecheck && npm test` |
| Python | `ruff check . && mypy . && pytest` |
| Go | `go vet ./... && go test ./...` |
