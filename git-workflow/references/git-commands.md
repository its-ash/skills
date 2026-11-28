@REF:git-commands

§CMD
new_br:`git switch -c feat/name` (switch existing:`git switch main`)
push_new:`git push -u origin feat/name` (or omit `-u` w/ `push.autoSetupRemote=true`)
stage_hunks:`git add -p`
stage_resolved(Git_2.56+):`git add --resolved` (stages resolved conflicts; blocks stray markers)
graph:`git log --oneline --graph --decorate`
oldest_n(Git_2.55+):`git log --max-count-oldest=10 origin/main..HEAD`
rebase_pr:`git fetch origin && git rebase --update-refs origin/main`
push_rebased:`git push --force-with-lease --force-if-includes origin feat/name` (safer than bare `--force-with-lease`; checks local reflog)
fixup:`git commit --fixup <sha>` → `git rebase -i --autosquash origin/main`
reword_split(Git_2.54+_exp):`git history reword <sha>` | `git history split <sha>` (lightweight edit ¬full rebase)
worktree:`git worktree add ../wt-hotfix -b hotfix/x main` | `git worktree list` | `git worktree remove ../wt-hotfix` | `git worktree prune`
stash:`git stash push -m "msg"`|`git stash list`|`git stash pop`|`git stash apply stash@{2}`|`git stash drop stash@{0}`
undo_soft(keep_Δ):`git reset --soft HEAD~1`
undo_hard(drop_Δ):`git reset --hard HEAD~1`
undo_pushed:`git revert HEAD && git push`
unstage_file:`git restore --staged path/to/file`
restore_file:`git restore --source=HEAD path/to/file` (replaces legacy `git checkout HEAD --`)
amend_msg:`git commit --amend -m "New message"`
amend_file:`git add file && git commit --amend --no-edit`
prune_merged:`git branch --merged main | grep -Ev '^\*|main' | xargs -r -n 1 git branch -d`
prune_remote:`git fetch --prune`
del_local:`git branch -d feat/x` (merged; `-D` force)
del_remote:`git push origin --delete feat/x`
maintenance:`git maintenance start` (bg prefetch, commit-graph, geometric repack in Git 2.52+)

§CFG
Modern `~/.gitconfig` defaults (Git 2.50–2.56+, Git 3.0 ready):
```bash
git config --global init.defaultBranch main && \
git config --global pull.rebase true && \
git config --global push.default simple && \
git config --global push.autoSetupRemote true && \
git config --global push.followTags true && \
git config --global fetch.prune true && \
git config --global fetch.pruneTags true && \
git config --global fetch.all true && \
git config --global merge.conflictStyle zdiff3 && \
git config --global rebase.autoStash true && \
git config --global rebase.autoSquash true && \
git config --global rebase.updateRefs true && \
git config --global diff.algorithm histogram && \
git config --global diff.colorMoved plain && \
git config --global diff.mnemonicPrefix true && \
git config --global diff.renames true && \
git config --global rerere.enabled true && \
git config --global rerere.autoupdate true && \
git config --global branch.sort -committerdate && \
git config --global tag.sort version:refname && \
git config --global column.ui auto && \
git config --global commit.verbose true && \
git config --global help.autocorrect prompt
```
git3_optin:new_repos⇒`--ref-format=reftable` (fast ref backend); `SHA-256` interop rolling out toward Git 3.0
`[alias]`: `sw=switch`, `rs=restore`, `br=branch`, `st=status -sb`, `unstage=restore --staged`, `last=log -1 HEAD`, `visual=log --oneline --graph --all`, `amend=commit --amend --no-edit`, `undo=reset --soft HEAD~1`, `pushf=push --force-with-lease --force-if-includes`, `contributors=shortlog -sn`

§SIGN
SSH commit+tag signing (replaces GPG complexity):
```bash
git config --global gpg.format ssh && \
git config --global user.signingkey ~/.ssh/id_ed25519.pub && \
git config --global commit.gpgsign true && \
git config --global tag.gpgsign true && \
echo "you@example.com $(cat ~/.ssh/id_ed25519.pub)" >> ~/.ssh/allowed_signers && \
git config --global gpg.ssh.allowedSignersFile ~/.ssh/allowed_signers
```
verify:`git log --show-signature -n 5` ∧ upload pub key as **Signing key** on GitHub/GitLab (agent-managed keys⇒`gpg.ssh.defaultKeyCommand`)

§IGNORE
`.gitignore`: `node_modules/`, `vendor/`, `dist/`, `build/`, `*.o`, `*.exe`, `.env`, `.env.local`, `.env.*.local`, `.idea/`, `.vscode/`, `*.swp`, `.DS_Store`, `Thumbs.db`, `*.log`, `logs/`, `coverage/`, `.cache/`, `*.tsbuildinfo`

§HOOKS
D:polyglot/modern⇒`lefthook`(Go,parallel,glob-filtered,zero_runtime_overhead) ≻ `husky`+`lint-staged`; Python/DevOps⇒`prek`(Rust drop-in for `pre-commit`) ∨ `pre-commit`
`lefthook.yml`:
```yaml
pre-commit:
  parallel: true
  commands:
    lint:
      glob: "*.{ts,tsx,js,jsx,py,go,rs}"
      run: npm run lint -- {staged_files}
    secrets:
      run: gitleaks protect --staged --redact
commit-msg:
  commands:
    commitlint:
      run: npx --no -- commitlint --edit {1}
pre-push:
  commands:
    test:
      run: npm test
```
rules:keep `pre-commit` fast(staged lint+`gitleaks`); defer full test suite to `pre-push`/CI; NEVER use naive `grep` as sole secret scanner; commit `lefthook.yml` so hooks are versioned (¬untracked `.git/hooks/*`)

§ANTI
`help.autocorrect 1`(auto-runs_mistyped_cmd) | `git push --force` | `git checkout`_for_branch_and_file_overload | dirty_stash_instead_of_`git worktree` | unversioned_`.git/hooks`_bash_scripts | naive_regex_secret_grep_without_`gitleaks`

§REL
[git-workflow](../SKILL.md);[branching-and-prs.md](branching-and-prs.md);[commits-and-releases.md](commits-and-releases.md);[secure-coding](../../secure-coding/SKILL.md)
