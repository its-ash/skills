---
description: "Load latest session file from ~/.claude/session-data/ and resume with full context."
---
@CMD:resume-session
§ARGS{
∅ ⇒ latest_ranked in `~/.claude/session-data/`;
`YYYY-MM-DD` ⇒ search `~/.claude/session-data/` then `~/.claude/sessions/` for `YYYY-MM-DD-session.tmp`∨`YYYY-MM-DD-<shortid>-session.tmp`, rank_all;
`<filepath>` ⇒ read_exact_file(¬rank, ¬substitute_even_if_empty∨older)
}
§RANK{ // ONLY ∅ ∧ date; NEVER explicit_<filepath>
1:reject(unreadable∨empty∨whitespace∨only(headings,metadata,separators,placeholders:`[Session context goes here]`,`- [ ]`,lone `-`,`[relevant files]`));
2:reject(summary_with ≤1_task ∧ ∅(files-modified,tools-used,completed,in-progress,notes,context-to-load)); // 1-msg summarizer echo filter
3:keep(substantive:completed∨in-progress∨concrete_next_notes∨concrete_context_paths∨>1_task∨modified_files∨tools_used);
4:prefer(newest_mtime);
5:tie_break(eq_mtime):>populated_sections → >non-placeholder_content → >byte_size → lexicographically_smaller_resolved_path // post-strip headings/meta/sep/placeholders
}
§FLOW{
1:locate:apply_§ARGS(+§RANK if ∅∨date);
  no_dir∨no_match(∅)⇒emit("No session files found in ~/.claude/session-data/\nRun /save-session at the end of a session to create one.")∧STOP;
  all_rejected(∅∨date)⇒emit("Session files were found but appear empty or unreadable. You may need to create a new one with /save-session.")∧STOP;
  explicit_<filepath> missing∨empty/unreadable⇒report_error(¬substitute)∧STOP;
2:read_entire_file(¬summarize_yet);
3:edge_checks:{
  ref_file∉disk ⇒ emit("WARNING: `<path>` referenced in session but not found on disk.");
  age>7d ⇒ emit("WARNING: This session is from N days ago (threshold: 7 days). Things may have changed.")∧proceed
};
4:emit_§OUT(exact_format);
5:wait_for_user
}
§GATE{
post_briefing:¬start_work_auto ∧ ¬touch_files ∧ wait_for_user;
next_step_defined ∧ user∈{"continue","yes",similar} ⇒ execute_exact_next_step;
¬next_step_defined ⇒ ask_where_to_start(+optional_suggestion_from "What Has NOT Been Tried Yet")
}
§R{
read_only(session_file)⇒¬modify;
§OUT_sections=FIXED(¬skip_empty; `WHAT NOT TO RETRY` always_shown, "None" if ∅);
counterpart:`/save-session`(suggest_at_session_end)
}
§OUT{
```text
SESSION LOADED: [actual resolved path to the file]
════════════════════════════════════════════════

PROJECT: [project name / topic from file]

WHAT WE'RE BUILDING:
[2-3 sentence summary in your own words]

CURRENT STATE:
PASS: Working: [count] items confirmed
 In Progress: [list files that are in progress]
 Not Started: [list planned but untouched]

WHAT NOT TO RETRY:
[list every failed approach with its reason — or "None"]

OPEN QUESTIONS / BLOCKERS:
[list any blockers or unanswered questions]

NEXT STEP:
[exact next step if defined in the file | "No next step defined — recommend reviewing 'What Has NOT Been Tried Yet' together before starting"]

════════════════════════════════════════════════
Ready to continue. What would you like to do?
```
}
