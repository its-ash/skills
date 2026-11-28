@REF:growth-log
§R{
  goal:extract_pattern(cause+transferable_rule+signal),¬diary;
  tool_agnostic(Markdown,Notion,Obsidian,txt);
  use∈{complex_task(multi-file_Δ,feature,arch_Δ),failure/mistake/"harder than expected",periodic_review,delivery_gate};
  gate:skip_trivial(typos,1-line,no-debug_cfg);write⇔(debug∨redo∨rollback∨non-obvious_decision);
  hygiene:NEVER_log_secrets,tokens,PII,or_raw_sensitive_logs⇒redact@capture;
  promote:recurring_pattern(≥2_occurrences)⇒graduate→automated_check(linter/test/CI)∨scoped_harness_rule(`.claude/rules/`,`.cursor/rules/`,`AGENTS.md`)∨skill
}
§D{
  rules:{
    1_failures>wins:2h_bug>3_1st-try_wins;ex:browser_`SameSite=Lax`_default_drops_cross-origin_auth⇒`SameSite=None; Secure`(signal:auth_fails_post-upgrade|cross-origin);ex:CSV_empty_rows_counted⇒`df.dropna(how='all', inplace=True)`_pre-count;
    2_merge_dups(Bole):search_cause_keywords_first;same_cause+new_symptom⇒merge(add_ex:missed_index+ratings→post-task_capture_gap);new_cause⇒new_entry;
    3_transferable:answer_`"Next time I face similar situation, what do I do differently?"`;steps:[1:1-sent_event,2:"why?"×3-5→cause,3:generalize(¬"Chrome 128 bug"→"browser default Δ breaks behavior"),4:`"Next time I see [signal], I will [action]."`,5:observable_signal]
  };
  sizing:1_entry/cause;4-8_sent;time∈[30s,2m](>2m⇒narrating,<30s⇒shallow);
  types:{
    Failure(broke/debug/rework):Root_cause|`"Config inheritance is not behavior inheritance across sessions"`;
    Methodology(repeatable):Context+pattern|`"Slides to open-book study guide: three-layer structure"`;
    Pattern_discovery(insight):Pattern|`"PR description: describe the gap, not the feature"`;
    Capability_change(skill_Δ):Context(before→after)|`"Git: from clone and push to an independent PR with 12 commits"`
  };
  storage:`growth-log/YYYY-MM-DD.md`∨Notion/Obsidian(1_convention;searchability>fmt);
  gate_note:Stop_hook_checking_learning_Δ_needs_method(enforcement∧¬method⇒empty_timestamps;method∧¬enforcement⇒forgotten_captures)
}
§CFG{
  tpl:`## [Title: pattern,¬event]`|`### Context`(goal+fail|surprise)|`### Root Cause / Core Insight`(mechanism,¬symptom)|`### The Pattern (transferable)`(`Next time [situation], I will [action].`+`Signal to recognize: [observable]`)|`### Related`(`[entry-name](../path/to/related-entry.md)`)
}
§CHK{
  title=pattern(¬event);
  `"Next time I will..."`∧specific_observable_signal;
  dup_search_first∧cause≠symptom;
  related_linked∧4-8_sent∧0_secrets;
  recurring_≥2⇒promoted_to_test/linter/scoped_rule
}
§ANTI{
  event_title(`"Fixed bug in payment module"`);
  copy_commit_msg(commit=what,log=why);
  entry/commit_or_no_transferable_sentence;
  dup_pattern_under_diff_titles;
  unread_graveyard(never_graduating_repeat_failures_into_CI_or_rules)
}
§REL{
  [../SKILL.md](../SKILL.md):docs_governance_router;
  [living-docs-governance.md](living-docs-governance.md):promote_durable_rules_to_harness
}
