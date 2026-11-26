---
description: "Save session state to dated file in ~/.claude/session-data/ for full-context resume"
---
@CMD:save-session
§META{store:"~/.claude/session-data/";consumer:/resume-session}
§WHEN{session_end;pre_context_limit;post_complex_solve;handoff;mid_session(mark_in_progress_clearly)}
§FLOW{
  1:gather:read(modified_files via `git diff`∨recall);review(discussed,attempted,decided);note(errs+resolutions);check(build/test_status)
  2:mkdir:`mkdir -p ~/.claude/session-data`
  3:new_file:`~/.claude/session-data/YYYY-MM-DD-<short-id>-session.tmp`(actual_today_date;¬append_old_file)
    short_id:compat=`[a-zA-Z0-9_-]`,len≥1;prefer:`[a-z0-9-]`,len≥8(e.g.`abc123de`,`a1b2c3d4`,`frontend-worktree-1`,`ChezMoi_2`;avoid:`A`,`test_id1`,`ABC123de`);legacy:`YYYY-MM-DD-session.tmp`(valid,avoid_collisions⇒use_short_id)
  4:populate:∀sec∈§TPL(honest,¬skip;∅⇒exact_default_str|"Nothing yet"|"N/A",except `Environment & Setup Notes`⇒omit_if_∅)
  5:confirm:display_full_file→ask_exact(§GATE_CONFIRM)→wait→edit_if_req
}
§R{
  1_file/session;¬append_to_prev_session
  `What Did NOT Work`≡critical(exact_err/reason⇒¬retry_failed_paths)
  `What WORKED`⇒require_evidence(test/browser/curl_200);∅evidence⇒move_to(`What Has NOT Been Tried Yet`)
}
§GATE_CONFIRM{
```
Session saved to [actual resolved path to the session file]

Does this look accurate? Anything to correct or add before we close?
```
}
§TPL{
```markdown
# Session: YYYY-MM-DD

**Started:** [approximate time if known]
**Last Updated:** [current time]
**Project:** [project name or path]
**Topic:** [one-line summary]

---

## What We Are Building

[1-3 paragraphs: what it does, why needed, system fit — zero-memory readable]

---

## What WORKED (with evidence)

- **[thing]** — confirmed by: [specific evidence]
[∅⇒"Nothing confirmed working yet — all approaches still in progress or untested."]

---

## What Did NOT Work (and why)

- **[approach]** — failed because: [exact reason / error message]
[∅⇒"No failed approaches yet."]

---

## What Has NOT Been Tried Yet

- [specific promising untried approach / idea]
[∅⇒"No specific untried approaches identified."]

---

## Current State of Files

| File | Status | Notes |
| --- | --- | --- |
| `path` | `PASS: Complete` \| `In Progress` \| `FAIL: Broken` \| `Not Started` | [details] |
[∅⇒"No files modified this session."]

---

## Decisions Made

- **[decision]** — reason: [why chosen over alternatives]
[∅⇒"No major decisions made this session."]

---

## Blockers & Open Questions

- [unresolved blocker / question / external dep]
[∅⇒"No active blockers."]

---

## Exact Next Step

[single concrete action for zero-thinking resume]
[∅⇒"Next step not determined — review 'What Has NOT Been Tried Yet' and 'Blockers' sections to decide on direction before starting."]

---

## Environment & Setup Notes

[run cmds, env vars, required services; omit section if standard/none]
```
}
