@REF:inherit-legacy-style
§META{goal:stop_AI_style_drift_in_legacy(all_lang/fw);out:.ai-style-rules.md+opt_CLAUDE.md}
§REL{../../code-review/SKILL.md:diff_correctness_style;../SKILL.md:deslop_naming}
§USE{AI_onboarding_legacy,prevent_AI_style_drift,extract_unwritten_rules}
§PRE{git:recommended(non_git⇒file_timestamps_for_incremental);fs:RW_root}
§R{
  step0_detect:check_root(".ai-style-rules.md")⇒(¬exists→BranchA_FullScan ⊕ exists→BranchB_IncrementalSniff);announce(mode+tier,1_line)∧proceed∧¬ask_mode;
  per_turn_enforce:when(.ai-style-rules.md∈ctx_via_CLAUDE.md)⇒∀code_task_open_with_compliance_decl(exemplar_followed∧DONTs_avoided)
}
§PAT[BranchA_FullScan]{
  1_scale:tier(src_count){
    Small(≲50):full_close_read_every_src;
    Medium(50-500):infra=full_read∧business=sample(2-3/dim);
    Large(≳500):strict_sample+budget_cap∧--stat_first→targeted_reads
  };
  2_dims[4]:{
    File_Anatomy:in_file_order(imports→types→main_logic→helpers→export);
    State_Control_Flow:naming(async_state,pagination,flags);
    Infrastructure:cross_cutting_locs(interceptors,formatters,middleware);
    Error_Handling:try/catch|global_interceptor|Result_return∧null_check_habits
  };
  3_signal_thresh:{
    weak(minority<5%∧count<10,e.g.843v8)⇒auto_suppress(majority_wins,minority→DONTs);
    strong(near_even_split∨semantic_fork_core_dim)⇒grill;
    small_proj_exc(sources≲50):3v2≠majority⇒grill;
    doubt⇒lean_ask
  };
  4_grilling_protocol[1_at_a_time,¬stack,suspend_until_answer]:{
    fmt:"Evidence: pathA uses X, pathB uses Y | WARNING: mixing fractures style | Choose: 1=follow X, 2=follow Y, 3=evolution(update rules), 4=new rule"
  };
  5_gen:.ai-style-rules.md{
    header:commit_fingerprint+scale_tier;
    sections[mandatory]:{"[Golden Files]":exemplar_paths+what_demo,"[Naming & State-Control Rules]":concrete_checkable,"[DONTs]":anti_patterns_¬propagate}
  };
  6_hook_ask:{
    1_Soft[recommended]:write("@.ai-style-rules.md")→CLAUDE.md;
    2_Hard:Soft+PreToolUse_hook(Write|Edit|MultiEdit)→.claude/settings.json;
    3_No_hook:keep_file_only
  }
}
§PAT[BranchB_IncrementalSniff]{
  1:read(.ai-style-rules.md)∧(has_commit_fingerprint⇒`git diff <last_hash> HEAD --stat`);
  2:`git log -3 --stat`→targeted_reads(suspect_files);
  3:oversized_diff(>hundreds_files)⇒`--stat`_only+sample_largest_Δ;
  4:compare(new_code,recorded_rules)→conflicts⇒4_grilling_protocol;
  5:append_EOF("### [YYYY-MM-DD] Style Evolution Log")∧¬overwrite_old_rules
}
§CMD{scale_count:git ls-files | grep -cE '\.(js|ts|jsx|tsx|vue|py|go|rs|java|kt|rb|php|cs|swift|c|cpp|h)$'}
§ANTI{
  ¬skip_scale(sample_30_starves,full_5000_blows_up);
  ¬stack_conflict_Qs;
  ¬overwrite_old_rules_in_BranchB;
  ¬default_hard_hook_without_asking;
  ¬judge_syntax_or_tech_stack(meta_arch_only);
  ¬copy_bugs_from_exemplars(reuse_struct,flag_defects)
}
