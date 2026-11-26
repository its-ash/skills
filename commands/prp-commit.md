---
description: "Smart commit with natural-language, glob, or filter file targeting"
argument-hint: "[target description] (blank = all changes)"
---

@CMD:prp-commit
§ARGS($ARGUMENTS): target_desc (∅⇒all_changes)
§FLOW:
  1_ASSESS:
    `git status --short`
    ∅⇒STOP:"Nothing to commit."
    show_summary(added,modified,deleted,untracked)
  2_INTERPRET_STAGE($ARGUMENTS→cmd):
    ∅⇒`git add -A`
    `staged`⇒no-op(keep_staged)
    glob(`*.ts`,`*.py`,...)⇒`git add '*.ts'`
    `except tests`⇒`git add -A && git reset -- '**/*.test.*' '**/*.spec.*' '**/test_*' 2>/dev/null || true`
    `only new files`⇒`git ls-files --others --exclude-standard | grep . && git ls-files --others --exclude-standard | xargs git add`
    NL_desc(e.g.`the auth changes`)⇒xref `git status`+`git diff`→show(matched_files+why)→`git add <matched files>`
    specific_files⇒`git add <files>`
    verify: `git diff --cached --stat`; ∅⇒STOP:"No files matched your description."
  3_COMMIT:
    fmt: `{type}: {description}`; `type∈{feat,fix,refactor,docs,test,chore,perf,ci}`
    rules: imperative("add"¬"added") ∧ lowercase_after_colon ∧ ¬trailing_period ∧ `<72c` ∧ WHAT¬HOW
    run: `git commit -m "{type}: {description}"`
§OUT(4_OUTPUT):
  Committed: {hash_short}
  Message: {type}: {description}
  Files: {count} file(s) changed
  Next steps: `git push` | `/prp-pr` | `/code-review`
