---
name: git-branch-workflow
description: "The git-branch-workflow skill creates an isolated Git worktree for a new feature branch, auto-detects project setup and dependencies, runs baseline tests to verify a clean state, then guides finishing the branch with options to merge locally, push and open a pull request, keep the worktree, or discard all changes. Use when you need git worktree, feature branch, isolated development environment, project setup auto-detection, baseline test verification, merge locally, create pull request, push branch, discard changes, finish development branch, clean baseline verification, safety verification, worktree directory selection, determine base branch, execute merge option."
---

# git-branch-workflow

Create an isolated workspace for a feature branch, verify a clean baseline, and finish the work with a clear, safe merge or cleanup process.

## When to use
- Starting a new feature, bug‑fix, or experiment that must not disturb the current checkout.
- After implementation is complete and you need to integrate, push, keep, or discard the branch.
- When you want a repeatable, safe workflow that enforces test verification and worktree cleanup.

## Workflow Overview
1. **Select worktree directory** – follow priority: existing project‑local folder, CLAUDE.md preference, then ask the user.
2. **Verify directory is ignored** (for project‑local locations).
3. **Create the worktree** on a new branch.
4. **Run project‑specific setup** (install dependencies).
5. **Run baseline tests** and confirm a clean state.
6. **Finish the branch** – choose one of four options (merge, PR, keep, discard).
7. **Clean up the worktree** when appropriate.

---

## 1. Select Worktree Directory
```bash
# Check for existing directories (project‑local)
if [ -d .worktrees ]; then
  LOCATION=.worktrees
elif [ -d worktrees ]; then
  LOCATION=worktrees
fi
```
- If both exist, prefer `.worktrees`.
- If none exist, look for a preference in `CLAUDE.md`:
```bash
grep -i "worktree.*director" CLAUDE.md 2>/dev/null || true
```
- If still unknown, ask the user:
```
No worktree directory found. Where should I create worktrees?
1) .worktrees/  (project‑local, hidden)
2) ~/.config/superpowers/worktrees/<project>/  (global)
Choose 1 or 2:
```

## 2. Safety Verification (Project‑Local Only)
```bash
# Verify the directory is ignored by Git
if git check-ignore -q .worktrees || git check-ignore -q worktrees; then
  echo "Directory is ignored – safe to use."
else
  echo "Directory not ignored. Adding to .gitignore..."
  echo ".worktrees/" >> .gitignore
  git add .gitignore
  git commit -m "Add .worktrees to .gitignore"
fi
```
- Global directories (`~/.config/...`) are outside the repository and need no ignore check.

## 3. Create the Worktree
```bash
# Detect project name for global path
project=$(basename "$(git rev-parse --show-toplevel)")

# Build full path
case $LOCATION in
  .worktrees|worktrees)
    path="$LOCATION/$BRANCH_NAME"
    ;;
  *)
    path="$HOME/.config/superpowers/worktrees/$project/$BRANCH_NAME"
    ;;
esac

# Create worktree and switch to it
git worktree add "$path" -b "$BRANCH_NAME"
cd "$path"
```
- `$BRANCH_NAME` is the name of the feature branch you want to work on.

## 4. Project Setup (auto‑detect)
```bash
# Node.js
if [ -f package.json ]; then npm install; fi
# Rust
if [ -f Cargo.toml ]; then cargo build; fi
# Python (pip)
if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
# Python (poetry)
if [ -f pyproject.toml ]; then poetry install; fi
# Go
if [ -f go.mod ]; then go mod download; fi
```
- Skip any step if the corresponding file is missing.

## 5. Verify Clean Baseline
```bash
# Run the appropriate test command
if [ -f package.json ]; then npm test; elif [ -f Cargo.toml ]; then cargo test; elif [ -f pytest.ini ] || [ -f conftest.py ]; then pytest; elif [ -f go.mod ]; then go test ./...; else echo "No test suite detected"; fi
```
- If tests fail, report the failures and **stop**. Ask the user whether to continue fixing or abort.
- If tests pass, announce readiness:
```
Worktree ready at $path
Baseline tests passed (N tests, 0 failures)
Ready to implement <feature description>
```

---

## 6. Finish Development Branch
### Step 6.1 – Verify Tests Again
Run the same test suite on the current branch. Do **not** proceed if any test fails.

### Step 6.2 – Determine Base Branch
```bash
base=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)
if [ -z "$base" ]; then
  echo "Unable to detect base branch. Please specify (e.g., main or master):"
  read base
fi
```

### Step 6.3 – Present Exact Options
```
Implementation complete. What would you like to do?

1) Merge back to $base locally
2) Push and create a Pull Request
3) Keep the branch as‑is (handle later)
4) Discard this work

Enter 1, 2, 3, or 4:
```
- Do **not** add extra explanation. Keep the list concise.

### Step 6.4 – Execute the Chosen Option
#### Option 1 – Merge Locally
```bash
git checkout $base
git pull
git merge $BRANCH_NAME
# Run tests on the merged result
<test command>
if [ $? -eq 0 ]; then
  git branch -d $BRANCH_NAME
fi
```
- After a successful merge, proceed to worktree cleanup (Step 7).

#### Option 2 – Push and Create PR
```bash
git push -u origin $BRANCH_NAME
# Create PR with GitHub CLI (gh). Adjust title/body as needed.
gh pr create --title "<Title>" --body "## Summary\n- <bullet 1>\n- <bullet 2>\n\n## Test Plan\n- [ ] Verify tests pass"
```
- After pushing, clean up the worktree (Step 7).

#### Option 3 – Keep As‑Is
- Report the branch name and worktree path.
- Do **not** delete the worktree.

#### Option 4 – Discard Work
```bash
echo "This will permanently delete the branch and its worktree. Type 'discard' to confirm:"
read confirm
if [ "$confirm" = "discard" ]; then
  git checkout $base
  git branch -D $BRANCH_NAME
else
  echo "Discard cancelled."
  exit 1
fi
```
- After confirmation, clean up the worktree (Step 7).

---

## 7. Worktree Cleanup (Options 1, 2, and 4)
```bash
# Detect if the current directory is a worktree
current=$(git rev-parse --show-toplevel)
if git worktree list | grep -q "$current"; then
  git worktree remove "$current"
  echo "Worktree $current removed."
fi
```
- Option 3 leaves the worktree untouched.

---

## Rules & Best Practices
- **Always verify** that a project‑local worktree directory is ignored before creation.
- **Never merge or push** if the test suite fails.
- **Present exactly four options** when finishing a branch; do not ask open‑ended questions.
- **Require explicit confirmation** (`discard`) before deleting a branch.
- **Run baseline tests** both after worktree creation and before any final action.
- **Clean up worktrees** for merge, PR, or discard actions to avoid orphaned directories.
- **Prefer `.worktrees`** over `worktrees` when both exist.
- **Commit the ignore rule** immediately if the directory was not ignored.

## Common Pitfalls & Fixes
| Pitfall | Why it hurts | Fix |
|---------|--------------|-----|
| Skipping ignore check | Worktree files become tracked, polluting the repo. | Run `git check-ignore` and add to `.gitignore` if missing. |
| Assuming directory location | Inconsistent project layout. | Follow the priority order: existing → CLAUDE.md → ask. |
| Proceeding with failing tests | New bugs are hidden. | Stop, report failures, and fix before continuing. |
| Auto‑deleting worktree for Option 3 | Lost work that the user wanted to keep. | Only clean up for Options 1, 2, 4. |
| Not confirming discard | Accidental data loss. | Require the literal word `discard` before deletion. |

## Checklist
- [ ] Identify or ask for worktree directory.
- [ ] Verify directory is ignored (project‑local).
- [ ] Create worktree with `git worktree add` and switch to it.
- [ ] Run language‑specific dependency install.
- [ ] Run baseline tests; abort on failure.
- [ ] After development, run tests again.
- [ ] Determine base branch (`main` or `master`).
- [ ] Present four finish options and capture user choice.
- [ ] Execute chosen option (merge, PR, keep, discard).
- [ ] If option requires, clean up the worktree.
- [ ] Report final status to the user.

## Related skills

Load these when the task spans more than this skill.

- [`git-commit`](../git-commit/SKILL.md) — Generate conventional commit messages by analyzing staged changes, suggesting type, scope, and wording, and gu…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`deployment-procedures`](../deployment-procedures/SKILL.md) — Provides a concise, platform‑agnostic procedure for safely deploying production services, covering pre‑checks,…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`jira`](../jira/SKILL.md) — Interact with Jira issues using the jira CLI or Atlassian MCP tools. Use when the user mentions an issue key (…
