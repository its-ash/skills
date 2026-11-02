# Git Commands, Config, and Hooks

## Quick reference

| Task | Command |
|---|---|
| New branch | `git checkout -b feature/name` |
| Push new branch | `git push -u origin feature/name` |
| Stage hunks | `git add -p` |
| History graph | `git log --oneline --graph` |
| Update branch before PR | `git fetch origin && git rebase origin/main` |
| Push after rebase | `git push --force-with-lease origin feature/name` |
| Stash | `git stash push -m "msg"`, `git stash list`, `git stash pop`, `git stash apply stash@{2}`, `git stash drop stash@{0}` |

## Undo

| Goal | Command |
|---|---|
| Undo last commit, keep changes | `git reset --soft HEAD~1` |
| Undo last commit, drop changes | `git reset --hard HEAD~1` |
| Undo pushed commit | `git revert HEAD && git push` |
| Restore one file | `git checkout HEAD -- path/to/file` |
| Fix last message | `git commit --amend -m "New message"` |
| Add forgotten file | `git add file && git commit --amend --no-edit` |

## Branch cleanup

```bash
git branch --merged main | grep -v "^\*\|main" | xargs -n 1 git branch -d
git fetch -p                               # prune deleted remote refs
git branch -d feature/x                    # safe (merged only); -D forces
git push origin --delete feature/x
```

## Config

```bash
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global push.default current
git config --global help.autocorrect 1
git config --global diff.algorithm histogram
git config --global color.ui auto
```

Aliases (`~/.gitconfig`):

```ini
[alias]
    co = checkout
    br = branch
    st = status
    unstage = reset HEAD --
    last = log -1 HEAD
    visual = log --oneline --graph --all
    amend = commit --amend --no-edit
    undo = reset --soft HEAD~1
    contributors = shortlog -sn
```

## .gitignore baseline

```gitignore
node_modules/
vendor/
dist/
build/
*.o
*.exe
.env
.env.local
.env.*.local
.idea/
.vscode/
*.swp
.DS_Store
Thumbs.db
*.log
logs/
coverage/
.cache/
*.tsbuildinfo
```

## Hooks

`.git/hooks/pre-commit`:

```bash
#!/bin/bash
npm run lint || exit 1
npm test || exit 1
if git diff --cached | grep -E '(password|api_key|secret)'; then
  echo "Possible secret detected. Commit aborted."; exit 1
fi
```

`.git/hooks/pre-push`:

```bash
#!/bin/bash
npm run test:all || exit 1
if git diff origin/main | grep -E 'console\.log'; then
  echo "Remove console.log statements before pushing."; exit 1
fi
```
