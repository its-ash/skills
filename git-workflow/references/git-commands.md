@REF:git-commands

§CMD
new_br:`git checkout -b feature/name`
push_new:`git push -u origin feature/name`
stage_hunks:`git add -p`
graph:`git log --oneline --graph`
rebase_pr:`git fetch origin && git rebase origin/main`
push_rebased:`git push --force-with-lease origin feature/name`
stash:`git stash push -m "msg"`|`git stash list`|`git stash pop`|`git stash apply stash@{2}`|`git stash drop stash@{0}`
undo_soft(keep_Δ):`git reset --soft HEAD~1`
undo_hard(drop_Δ):`git reset --hard HEAD~1`
undo_pushed:`git revert HEAD && git push`
restore_file:`git checkout HEAD -- path/to/file`
amend_msg:`git commit --amend -m "New message"`
amend_file:`git add file && git commit --amend --no-edit`
prune_merged:`git branch --merged main | grep -v "^\*\|main" | xargs -n 1 git branch -d`
prune_remote:`git fetch -p`
del_local:`git branch -d feature/x` (merged; `-D` force)
del_remote:`git push origin --delete feature/x`

§CFG
```bash
git config --global init.defaultBranch main && git config --global pull.rebase true && git config --global push.default current && git config --global help.autocorrect 1 && git config --global diff.algorithm histogram && git config --global color.ui auto
```
`~/.gitconfig` `[alias]`: `co=checkout`, `br=branch`, `st=status`, `unstage=reset HEAD --`, `last=log -1 HEAD`, `visual=log --oneline --graph --all`, `amend=commit --amend --no-edit`, `undo=reset --soft HEAD~1`, `contributors=shortlog -sn`

§IGNORE
`.gitignore`: `node_modules/`, `vendor/`, `dist/`, `build/`, `*.o`, `*.exe`, `.env`, `.env.local`, `.env.*.local`, `.idea/`, `.vscode/`, `*.swp`, `.DS_Store`, `Thumbs.db`, `*.log`, `logs/`, `coverage/`, `.cache/`, `*.tsbuildinfo`

§HOOKS
`.git/hooks/pre-commit`:
```bash
#!/bin/bash
npm run lint || exit 1
npm test || exit 1
git diff --cached | grep -E '(password|api_key|secret)' && exit 1
```
`.git/hooks/pre-push`:
```bash
#!/bin/bash
npm run test:all || exit 1
git diff origin/main | grep -E 'console\.log' && exit 1
```
