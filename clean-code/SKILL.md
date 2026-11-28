---
name: clean-code
description: "AUTO_INVOKE(silent)⇔prompt∈{clean_code,refactor,lint,deslop,AI_slop,git_diff,PR_review,SRP,KISS,YAGNI,DRY,SOLID,dead_code,unused_code,magic_number,complexity,cognitive_complexity,nesting,guard_clause,naming,deep_module,shallow_wrapper,any_cast,inline_import,style_drift,legacy_style,god_function,Knip,Biome,Oxlint,Ruff,golangci-lint,AGENTS.md,CodeScene,Code_Health_MCP,cs-mcp}|SUB:{deslop,coding-standards,inherit-legacy-style,codehealth-mcp}"
---
@SKL:clean-code
§R{
  ∀fn∨cls⇒1_resp(SRP)∧1_abstraction_level∧deep_module(simple_API_hiding_real_logic)¬shallow_pass_through;
  KISS(simplest_working)∧YAGNI(¬speculative_abstraction∨unused_flags)∧DRY(extract_at_3rd_real_dup¬one_off);
  complexity:cognitive≤15∧nesting≤2(guard_clauses∧early_returns)∧args≤3(else→options_obj)∧¬unexpected_input_mutation;
  fn_size:cohesive(typical≤30L;split_on_complexity∨multi_resp,¬micro_split_into_trivial_wrappers);
  naming:{fn:verb+noun(getUserById),bool:question(isActive,hasAccess,canEdit),const:SCREAMING_SNAKE}∧needs_cmt⇒rename;
  magic_numbers→named_consts∧colocate_related_code∧compose_small_pure_fns;
  errors:preserve_cause(new Error(msg,{cause:e})|raise...from e|fmt.Errorf("%w",err))∧¬swallow∧¬log_and_rethrow;
  touched_code⇒leave_cleaner_than_found∧¬drive_by_refactors_outside_task_scope;
  pre_edit(file)⇒map({importers,imports,covering_tests,is_shared})∧update_∀_dependents_same_task;
  safe_refactor(legacy|hotspot)⇒characterization_tests_first→text_plan(extracts+dataflow)→small_verified_steps;
  dead_code:prune_orphaned({files,exports,imports,deps})_via_proj_tools(knip|ruff|vulture|golangci-lint|clippy);
  style_guard:match_local_conventions∧keep_instruction_files(AGENTS.md|CLAUDE.md)≤150-200L(¬prose_style_guides;enforce_via_linter);
  post_Δ⇒deslop(git diff <base>...HEAD):strip({excess_cmts,overchecks,any_casts,inline_imports,shallow_wrappers,dead_code,style_drift});
  code_health(opt_in_MCP):pre_edit(code_health_review)→post_edit(code_health_score≥baseline)→pre_commit(pre_commit_code_health_safeguard);
  pre_done⇒run_project_native({fmt_check,lint,typecheck,dead_code?,test})∧fix_all_before_reporting;
}
§D{
  helper_wraps_1_liner⇒inline¬shallow_wrapper;
  2_obj_types_to_build⇒direct_instantiation¬factory;
  utils_file_with_1_fn⇒colocate_where_used¬catch_all_utils_mod;
  god_fn∨cognitive_complexity>15⇒split_by_resp¬add(flags∨params);
  deep_if_nesting⇒guard_clauses¬else_chains;
  obvious_or_diff_narrating_cmt⇒delete¬cmt_WHAT(cmt_WHY_only);
  type_err⇒fix_type∨narrow(unknown)¬(as any∨cast(Any,...)∨# type: ignore);
  mechanical_style_rule⇒linter_config(Biome|Oxlint|ESLint10|Ruff|golangci-lint)¬AGENTS.md_prose;
  legacy_hotspot_score<5⇒minimal_scoped_diff+characterization_tests¬broad_rewrite;
  req_unclear⇒ask_1_blocking_Q¬(assume∧build);
}
§REF{
  deslop_steps,AI_slop_catalog,dead_code,verify_cmds,report_fmt,completion_chk→references/deslop.md;
  TS_JS_standards,Biome_v2,Oxlint,ESLint10,TS7,Knip,Zod_v4,ES2023_immutability,React_Compiler,err_cause,smells→references/coding-standards.md;
  legacy_codebase,unwritten_conv(.ai-style-rules.md),AGENTS.md_budget,stop_style_drift,incremental_sniff→references/inherit-legacy-style.md;
  CodeScene_Code_Health_MCP,cs-mcp,OAuth_PAT,standalone_tools,score_gates,pre_commit_PR_checks→references/codehealth-mcp.md;
}
§REL{
  ../code-review/SKILL.md:correctness,sec,PR_readiness_review;
  ../software-architecture/SKILL.md:module_boundaries,patterns,ADRs;
  ../typescript/SKILL.md:TS7_types,strict_tsconfig,Zod_v4,JS_TS_tooling;
  ../unit-testing-patterns/SKILL.md:characterization_tests,Vitest,Jest,pytest;
  ../systematic-debugging/SKILL.md:root_cause,bugs,test_failures;
}
