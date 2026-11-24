---
name: clean-code
description: "AUTO_INVOKE(silent)⇔prompt∈{clean_code,refactor,lint,deslop,AI_slop,git_diff,PR_review,SRP,KISS,YAGNI,DRY,SOLID,dead_code,magic_number,complexity,nesting,guard_clause,naming,any_cast,inline_import,style_drift,legacy_style,CodeScene,Code_Health_MCP,unused_code,god_function}|SUB:{coding-standards,inherit-legacy-style,codehealth-mcp}"
---
@SKL:clean-code
§R{
  ∀fn∨cls⇒1_resp(SRP)∧1_abstraction_level_per_fn;
  KISS(simplest_working)∧YAGNI(¬unused_features);
  DRY(extract_real_dup)¬abstract_one_off;
  touched_code⇒leave_cleaner_than_found;
  fn_len≤20(ideal:5-10)∧args≤3(prefer:0-2)∧¬unexpected_input_mutation;
  guard_clauses∧early_returns∧nesting≤2;
  naming:{fn:verb+noun(getUserById),bool:question(isActive,hasPermission,canEdit),const:SCREAMING_SNAKE}∧needs_cmt⇒rename;
  magic_numbers→named_consts;
  colocate_related_code∧compose_small_fns;
  pre_edit(file)⇒find({importers,imports,covering_tests,is_shared})∧update_∀_dependents_same_task;
  post_Δ⇒deslop(git diff main...HEAD):strip({excess_cmts,abnormal_defensive_checks,any_casts,inline_imports,style_drift});
  pre_done⇒run_project({lint,type,test});
}
§D{
  helper_wraps_1_liner⇒inline¬new_fn;
  2_obj_types_to_build⇒direct_instantiation¬factory;
  utils_file_with_1_fn⇒colocate_where_used¬catch_all_utils_mod;
  god_fn⇒split_by_resp¬add(flags∨params);
  deep_if_nesting⇒guard_clauses¬else_chains;
  obvious_cmt⇒delete¬cmt_every_line;
  type_err⇒fix_type¬(as any∨cast(Any,...));
  req_unclear⇒ask_1_Q¬(assume∧build);
}
§REF{
  deslop_steps,slop_tbl,report_fmt,completion_self_check,verify_cmds→references/deslop.md;
  TS_JS_examples,naming,immutability,err_handle,async,types,file_layout,cmts,smells→references/coding-standards.md;
  legacy_codebase,extract_unwritten_conv(.ai-style-rules.md),stop_style_drift→references/inherit-legacy-style.md;
  CodeScene_Code_Health_MCP,score_pre_post_edits,gate_commits_PRs→references/codehealth-mcp.md;
}
§REL{
  ../code-review/SKILL.md:correctness,sec,readiness_review;
  ../software-architecture/SKILL.md:patterns,arch_decisions;
  ../unit-testing-patterns/SKILL.md:Jest,pytest_unit_tests;
  ../systematic-debugging/SKILL.md:root_cause,bugs,test_failures;
}
