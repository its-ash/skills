---
description: "Alias of /pr for PRP workflow; create PR mid-PRP (else /pr)."
argument-hint: "[base-branch] (default: main)"
---
@CMD:prp-pr
$ARGUMENTS:extract `--draft`;rest→`<base>`(default:`main`)
§FLOW{
1_VALIDATE:
  run:`git branch --show-current`;`git status --short`;`git log origin/<base>..HEAD --oneline`;`gh pr list --head <branch> --json number`
  gate:branch≠<base>|else⇒STOP:"Switch to feature branch"
  gate:`git status --short`≡∅|else⇒WARN:"Uncommitted changes; commit/stash or /prp-commit"
  gate:commits(origin/<base>..HEAD)≠∅|else⇒STOP:"No commits ahead of <base>"
  gate:`gh pr list --head <branch> --json number`≡∅|else⇒STOP:"PR #<number> exists; run gh pr view <number> --web"
2_DISCOVER:
  tpl:[`.github/PULL_REQUEST_TEMPLATE/`(list∧ask∨`default.md`),`.github/PULL_REQUEST_TEMPLATE.md`,`.github/pull_request_template.md`,`docs/pull_request_template.md`]→read∧use first match
  commits:`git log origin/<base>..HEAD --format="%h %s" --reverse`→title:conventional(`feat:`,etc.;multi⇒dominant;1⇒as-is)+summary(by type/area)
  files:`git diff origin/<base>..HEAD --stat`;`git diff origin/<base>..HEAD --name-only`→cat:{source,tests,docs,config,migrations}
  prp:check(`.claude/PRPs/reports/`,`.claude/PRPs/plans/`,`.claude/PRPs/prds/`)→link in body if∃
3_PUSH:
  run:`git push -u origin HEAD`
  diverged⇒`git fetch origin && git rebase origin/<base> && git push --force-with-lease -u origin HEAD`(¬`--force`;conflict⇒STOP∧report)
4_CREATE:
  tpl⇒fill all sections(unused⇒"N/A",keep all)
  ¬tpl⇒body:[`## Summary`(1-2 sent),`## Changes`(bullets by area),`## Files Changed`(Added/Modified/Deleted),`## Testing`(method∨"Needs testing"),`## Related Issues`(`Closes/Fixes/Relates to #N`∨"None")]
  run:`gh pr create --title "<PR title>" --base <base> --body "<PR body>"`(+`--draft` if set)
5_VERIFY:
  run:`gh pr view --json number,url,title,state,baseRefName,headRefName,additions,deletions,changedFiles`
  run:`gh pr checks --json name,status,conclusion 2>/dev/null || true`
}
§EDGE{
¬`gh`⇒STOP:"gh CLI required: https://cli.github.com/"
¬auth⇒STOP:"Run gh auth login"
`.github/PULL_REQUEST_TEMPLATE/` multi-file⇒list∧ask user
changedFiles>20⇒WARN size∧suggest split
}
§OUT{
`PR #<number>: <title>` | `URL: <url>` | `Branch: <head> → <base>` | `Changes: +<additions> -<deletions> across <changedFiles> files`
`CI Checks: <summary|"pending"|"none configured">` | `Artifacts referenced: <PRP reports/plans>`
`Next: gh pr view <number> --web | /code-review <number> | gh pr merge <number>`
}
