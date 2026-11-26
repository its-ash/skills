---
description: "Create GitHub PR: validate, discover templates/artifacts, push, verify"
argument-hint: "[base-branch] (default: main)"
---

@CMD:pr
§ARGS($ARGUMENTS): extract `--draft`; rest⇒`<base>`(∅⇒`main`)
§GATE(1_VALIDATE):
  `git branch --show-current`; `git status --short`; `git log origin/<base>..HEAD --oneline`
  ¬cmd(`gh`)⇒STOP:"Install gh: https://cli.github.com/"
  ¬gh_auth⇒STOP:"Run `gh auth login`"
  `branch==<base>`⇒STOP:"Switch to feature branch"
  `status≠∅`⇒WARN:"Uncommitted changes; commit/stash first"
  `log_ahead==∅`⇒STOP:"No commits ahead of `<base>`"
  `gh pr list --head <branch> --json number`≠∅⇒STOP:"PR #<number> exists (`gh pr view <number> --web`)"
§FLOW:
  2_DISCOVER:
    tpl(order): `.github/PULL_REQUEST_TEMPLATE/`(multi⇒ask_user∨`default.md`)→`.github/PULL_REQUEST_TEMPLATE.md`→`.github/pull_request_template.md`→`docs/pull_request_template.md`; found⇒read∧use_struct
    commits: `git log origin/<base>..HEAD --format="%h %s" --reverse`→title=conventional(`feat:|fix:...`;multi⇒dominant;1⇒as_is); summary=group(type,area)
    files: `git diff origin/<base>..HEAD --stat`; `git diff origin/<base>..HEAD --name-only`→cat∈{source,tests,docs,config,migrations}; `changedFiles>20`⇒WARN_size∧suggest_split
    artifacts(/plan-prd,/plan,PRP): `.claude/prds/`,`.claude/plans/`,`.claude/PRPs/prds/`,`.claude/PRPs/plans/`,`.claude/PRPs/reports/`→ref_in_body_if_exists
  3_PUSH:
    `git push -u origin HEAD`
    diverged⇒`git fetch origin && git rebase origin/<base> && git push -u origin HEAD`(or `git push --force-with-lease`,¬`--force`); conflict⇒STOP∧inform_user
  4_CREATE:
    tpl⇒fill(commits+files)∧keep_sections(unused⇒"N/A",¬del)
    ¬tpl⇒`## Summary`(1-2sent:what+why)/`## Changes`(bullets_by_area)/`## Files Changed`(Added|Modified|Deleted)/`## Testing`(how|"Needs testing")/`## Related Issues`(Closes|Fixes|Relates to #N|"None")
    `gh pr create --title "<PR title>" --base <base-branch> --body "<PR body>"`(+`--draft` if parsed)
  5_VERIFY:
    `gh pr view --json number,url,title,state,baseRefName,headRefName,additions,deletions,changedFiles`
    `gh pr checks --json name,status,conclusion 2>/dev/null || true`
§OUT(6_OUTPUT):
  PR #<number>: <title> | URL: <url> | Branch: <head>→<base> | +<additions> -<deletions> (<changedFiles> files)
  CI: <summary|"pending"|"none configured"> | Artifacts: <linked PRDs/plans>
  Next: `gh pr view <number> --web` | `/code-review <number>` | `gh pr merge <number>`
