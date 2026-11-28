@REF:inherit-legacy-style
§REL{../SKILL.md:deslop_naming;coding-standards.md:modern_defaults;../../code-review/SKILL.md:diff_correctness_style}
§R{
  goal:stop_AI_style_drift_in_legacy_repos(all_lang/fw);out:`.ai-style-rules.md`+opt_cross_agent_link(`AGENTS.md`|`CLAUDE.md`);
  instruction_budget[CRIT]:keep_`.ai-style-rules.md`≤150L∧root_`AGENTS.md`/`CLAUDE.md`≤150-200L(bloated_rule_files_add_14-22%_token_overhead_and_drop_accuracy);record_ONLY_non_obvious_local_conventions;
  linter_offload:delegate_mechanical_fmt/syntax_to_linters(`biome.json`|`.oxlintrc.json`|`eslint.config.*`|`ruff.toml`|`.golangci.yml`)¬prose_rules;
  preconditions:git_recommended(non_git⇒file_mtimes_for_incremental);fs=RW_root;
  step0_detect:check_root(`.ai-style-rules.md`)⇒(¬exists→BranchA_FullScan ⊕ exists→BranchB_IncrementalSniff);announce(mode+tier,1_line)∧proceed∧¬ask_mode;
  per_turn_enforce:when_`.ai-style-rules.md`∈ctx⇒follow_Golden_File_exemplar∧avoid_listed_DONTs;
}
§PAT[BranchA_FullScan]{
  1_scale_tier(src_count):{
    Small(≤50):full_close_read_every_src;
    Medium(50-500):infra=full_read∧business=sample(2-3/dim);
    Large(>500):strict_sample+budget_cap∧`--stat`_first→targeted_reads
  };
  2_dims[4]:{
    File_Anatomy:in_file_order(imports→types→main_logic→helpers→exports);
    State_Control_Flow:naming_and_patterns(async_state,pagination,flags,DI);
    Infrastructure:cross_cutting_locs(interceptors,formatters,middleware,clients);
    Error_Handling:try/catch|global_interceptor|Result_return∧null_check_habits
  };
  3_signal_thresh:{
    weak(minority<5%∧count<10,e.g.843v8)⇒auto_suppress(majority_wins,minority→DONTs);
    strong(near_even_split∨semantic_fork_core_dim)⇒grill;
    small_proj_exc(src≤50):3v2≠majority⇒grill;
    doubt⇒lean_ask
  };
  4_grilling_protocol[1_at_a_time,¬stack,suspend_until_answer]:{
    fmt:"Evidence: pathA uses X, pathB uses Y | WARNING: mixing fractures style | Choose: 1=follow X, 2=follow Y, 3=evolution(update rules), 4=new rule"
  };
  5_gen(`.ai-style-rules.md`,≤150L):{
    header:commit_fingerprint+scale_tier+linter_config_refs;
    sections[mandatory]:{"[Golden Files]":exemplar_paths+what_demo,"[Naming & State-Control Rules]":concrete_checkable,"[DONTs]":anti_patterns_¬propagate}
  };
  6_hook_ask[ask_explicitly]:{
    1_Soft[recommended]:reference_`@.ai-style-rules.md`_in_canonical_`AGENTS.md`(symlink_`ln -s AGENTS.md CLAUDE.md`_or_`.github/copilot-instructions.md`_as_needed);
    2_Hard:Soft+`PreToolUse`_hook(`Write|Edit|MultiEdit`)→`.claude/settings.json`;
    3_No_hook:keep_`.ai-style-rules.md`_standalone
  };
}
§PAT[BranchB_IncrementalSniff]{
  1:read(`.ai-style-rules.md`)∧(has_commit_fingerprint⇒`git diff <last_hash> HEAD --stat`);
  2:`git log -3 --stat`→targeted_reads(suspect_or_high_churn_files);
  3:oversized_diff(>hundreds_files)⇒`--stat`_only+sample_largest_Δ;
  4:compare(new_code,recorded_rules)→conflicts⇒4_grilling_protocol;
  5:append_EOF(`### [YYYY-MM-DD] Style Evolution Log`)+update_commit_fingerprint∧¬overwrite_old_rules;
}
§CMD{
  scale_count:`git ls-files | grep -cE '\.(js|mjs|cjs|ts|mts|cts|jsx|tsx|vue|svelte|astro|py|go|rs|java|kt|rb|php|cs|swift|dart|c|cpp|h|hpp)$'`;
  non_git_recent:`find . -maxdepth 4 -type f -mtime -14`;
  symlink_sot:`ln -s AGENTS.md CLAUDE.md`;
}
§D{
  mechanical_fmt_rule(tabs,semis,quotes)⇒defer_to_repo_linter¬write_in_.ai-style-rules.md;
  multi_agent_repo⇒AGENTS.md_canonical_anchor+symlinks¬divergent_duplicate_files;
  exemplar_contains_bug⇒reuse_structural_pattern_only∧flag_defect¬copy_bug;
  rules_exceed_150L⇒prune_obvious_or_linter_covered_rules¬grow_unbounded;
}
§ANTI{
  skip_scale_tier(sample_30_starves,full_5000_blows_up);stack_conflict_Qs;overwrite_old_rules_in_BranchB;default_hard_hook_without_asking;judge_legacy_tech_stack(meta_arch_only);copy_bugs_from_exemplars;bloat_AGENTS.md_above_200L
}
§CHK{
  mode_and_tier_announced∧scale_budget_respected∧conflicts_resolved_1_by_1∧rules_≤150L∧linter_rules_excluded∧hook_choice_confirmed
}
