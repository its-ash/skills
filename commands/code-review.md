---
description: "Review local changes or GitHub PR (PR#/URL/--pr; /review-pr for multi-agent)."
argument-hint: "[pr-number | pr-url | blank for local review]"
---
@CMD:code-review($ARGUMENTS)
§MODE{$ARGUMENTS∈{pr_num,pr_url,--pr}⇒§PR;else⇒§LOCAL}
§LOCAL{
1:GATHER⇒`git diff --name-only HEAD`;∅⇒STOP("Nothing to review.");
2:REVIEW(full_files):
CRIT:{creds/keys/tokens,SQLi,XSS,in_val,insecure_deps,path_traversal};
HIGH:{fn>50L,file>800L,nesting>4,err_handle,`console.log`,`TODO`/`FIXME`,public_JSDoc};
MED:{mutation(prefer_immut),emoji,missing_tests,a11y};
3:REPORT⇒{sev(CRIT|HIGH|MED|LOW),`file:line`,desc,fix};
4:GATE⇒block_commit⇔(CRIT∨HIGH)∧¬approve_w_sec_vulns
}
§PR{
1:FETCH:
parse:num(`42`)→PR#|URL(`github.com/.../pull/42`)→PR#|branch→`gh pr list --head <branch>`;
run:`gh pr view <NUMBER> --json number,title,body,author,baseRefName,headRefName,changedFiles,additions,deletions`∧`gh pr diff <NUMBER>`;
¬found⇒STOP(err);store_meta;
2:CONTEXT:
rules:`AGENTS.md`,`CLAUDE.md`,`.claude/docs/`,contributing;
plans:`.claude/prds/`,`.claude/plans/`,`.claude/reviews/`,`.claude/PRPs/{prds,plans,reports,reviews}/`;
intent:PR_desc(goals,issues,test_plans);files:categorize(src|test|cfg|docs);
3:REVIEW:
head_files:`gh pr diff <NUMBER> --name-only | while IFS= read -r file; do gh api "repos/{owner}/{repo}/contents/$file?ref=<head-branch>" --jq '.content' | base64 -d; done`;
chk:{Correct:{logic,off-by-1,null,edges,races},Types:{mismatch,unsafe_cast,`any`,generics},Pattern:{naming,struct,err_handle,imports},Sec:{inj,auth,secrets,SSRF,path_traversal,XSS},Perf:{N+1,idx,unbounded_loops,mem_leak,payloads},Complete:{tests,err_handle,migrations,docs},Maint:{dead_code,magic_nums,nesting,naming,types}};
sev:{CRIT:sec/data_loss(must_fix),HIGH:bug/logic(should_fix),MED:quality/best_prac(fix_rec),LOW:nit(opt)};
4:VALIDATE(detect→run∧record_pass/fail):
Node/TS(`package.json`):`npm run typecheck 2>/dev/null || npx tsc --noEmit 2>/dev/null`;`npm run lint`;`npm test`;`npm run build`;
Rust(`Cargo.toml`):`cargo clippy -- -D warnings`;`cargo test`;`cargo build`;
Go(`go.mod`):`go vet ./...`;`go test ./...`;`go build ./...`;
Py(`pyproject.toml`):`uv run ruff check .`;`uv run pytest`;
5:DECIDE:
0_CRIT/HIGH∧val=pass⇒APPROVE;
MED/LOW_only∧val=pass⇒APPROVE(w/comments);
HIGH∨val=fail⇒REQUEST CHANGES;
CRIT⇒BLOCK(pre_merge);
special:{draft⇒COMMENT;docs/cfg_only⇒light_correctness;`--approve`/`--request-changes`⇒override∧report_all};
6:REPORT:
path:`.claude/reviews/pr-<NUMBER>-review.md`(⊕`.claude/PRPs/reviews/`_if_legacy);
tpl:`# PR Review: #<NUMBER> — <TITLE>`,Reviewed,Author,`Branch: <head> → <base>`,Decision,Summary(1-2s),Findings(CRITICAL|HIGH|MEDIUM|LOW∨"None"),Validation Results(Type check|Lint|Tests|Build:Pass/Fail/Skipped),Files Reviewed(Added/Modified/Deleted);
7:PUBLISH:
APPROVE⇒`gh pr review <NUMBER> --approve --body "<summary>"`;
REQ_CHG⇒`gh pr review <NUMBER> --request-changes --body "<summary+fixes>"`;
COMMENT⇒`gh pr review <NUMBER> --comment --body "<summary>"`;
inline_1:`gh api "repos/{owner}/{repo}/pulls/<NUMBER>/comments" -f body="<comment>" -f path="<file>" -F line=<line-number> -f side="RIGHT" -f commit_id="$(gh pr view <NUMBER> --json headRefOid --jq .headRefOid)"`;
inline_batch:`gh api "repos/{owner}/{repo}/pulls/<NUMBER>/reviews" -f event="COMMENT" -f body="<overall summary>" --input comments.json`# `[{"path":"file","line":N,"body":"comment"}]`;
8:OUT:```
PR #<NUMBER>: <TITLE>
Decision: <APPROVE|REQUEST_CHANGES|BLOCK>

Issues: <critical_count> critical, <high_count> high, <medium_count> medium, <low_count> low
Validation: <pass_count>/<total_count> checks passed

Artifacts:
  Review: .claude/reviews/pr-<NUMBER>-review.md
  GitHub: <PR URL>

Next steps:
  - <contextual suggestions based on decision>
```
}
§EDGE{¬`gh`⇒local_only(read_diff,skip_publish)+warn;diverged⇒suggest(`git fetch origin && git rebase origin/<base>`);files>50⇒warn_scope→prio(src→tests→cfg/docs)}
