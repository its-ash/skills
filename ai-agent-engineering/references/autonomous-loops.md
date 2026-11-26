@REF:autonomous-loops
§CORE{
  refs:{goal_runaway:[loop-design-check.md](loop-design-check.md),eval_graders:[eval-harness.md](eval-harness.md)};
  select:{strict_CI_PR⇒§4;RFC_DAG⇒§6;exploratory_parallel⇒§3;default⇒§1};
  prod_stack:[1:RFC→DAG(§6),2:gates(build+lint+typecheck+tests+de-sloppify(§5)),3:eval_pass_fail(eval-harness.md),4:persist(SHARED_TASK_NOTES|session_file(§2,§4))]
}
§SPECTRUM{
  1_SeqPipeline:Low|daily_dev,scripted;
  2_PersistentREPL:Low|interactive_persist;
  3_InfiniteLoop:Med|parallel_gen,spec_driven;
  4_ContinuousClaudePR:Med|multi_day+CI_gates;
  5_DeSloppify:AddOn|post_impl_cleanup;
  6_RalphinhoDAG:High|large_feat,parallel_units+merge_queue
}
§PAT{
  1_SeqPipeline:{
    cmd:`claude -p`(headless+exit;`--output-format json`|`stream-json`for_parse);
    flow:`set -e`→impl(TDD,¬new_docs)→de-sloppify(cleanup_prev_commit,keep_biz_tests,run_suite)→verify(build+lint+type+test,fix,¬new_feat)→commit(conventional);
    rules:{fresh_ctx/call(¬bleed);seq_FS_handoff;¬neg_instr⇒sep_cleanup_pass(§5);`set -e`propagates_exit};
    route:`--model opus`(Opus 5.5 arch/plan)|`--model sonnet`(Sonnet 5.5 impl)|`--model fable`(Fable 5.1 review,¬author_bias)|`--model haiku`(Haiku 5.5 fmt/test);
    ctx_file:write`.claude-context.md`→`claude -p`read→`rm .claude-context.md`;
    tools:`--allowedTools "Read,Grep,Glob"`(ro_audit)|`"Read,Write,Edit,Bash"`(impl)
  };
  2_PersistentREPL:{
    impl:`set -euo pipefail`;`SESSION_FILE="${HOME}/.claude/sessions/${1:-default}.md"`;loop:`read -r -p "> " msg`→append`## User`→`claude -p`w/_full_file→append`## Assistant`;
    native_alt:`claude -p --continue`|`--resume <session-id>`(use_file_only_for_portable_readable_transcript);
    vs_seq:REPL={interactive:1,persist:builtin,ctx:grows/turn,CI:poor};Seq={interactive:0,persist:manual,ctx:fresh/step,CI:excellent}
  };
  3_InfiniteLoop:{
    credit:@disler;arch:2prompt(Orchestrator→N_SubAgents);
    cmd_file:`.claude/commands/infinite.md`args=`$ARGUMENTS`({1:spec_file,2:output_dir,3:count(`1-N`|"infinite")});
    phases:1_read_spec→2_scan_output_dir(max_iter=N,start=N+1)→3_assign_unique_creative_dir/agent→4_deploy_parallel_Agent_tool(spec+dir_snap+iter#+theme)→5_infinite_mode(waves:3-5_until_low_ctx);
    invoke:`/infinite specs/component-spec.md src/ 5`⊕`/infinite specs/component-spec.md src/ infinite`;
    batch:{1-5:all_simul,6-20:batches_of_5,infinite:waves_3-5(progressive)};
    rule:orchestrator_assigns_dir+iter#(¬self_diff⇒prevents_dupes)
  };
  4_ContinuousClaudePR:{
    credit:@AnandChowdhary;sec:review_repo_before_install(¬`curl|bash`);
    loop:1_branch(`continuous-claude/iteration-N`)→2_`claude -p`→3_opt_review(`claude -p`)→4_commit→5_push+`gh pr create`→6_poll(`gh pr checks`)→7_CI_fail⇒auto_fix(`claude -p`)→8_merge(squash|merge|rebase)→9_main→repeat;
    ctx_bridge:`SHARED_TASK_NOTES.md`(`## Progress` `- [x]`/`- [ ]`, `## Next Steps`;read_start,upd_end);
    ci_fix:`gh run list`→spawn`claude -p`→`gh run view`→fix,commit,push→re-poll(≤`--ci-retry-max`,def=1);
    stop:`--completion-signal "CONTINUOUS_CLAUDE_PROJECT_COMPLETE" --completion-threshold 3`(3_consec_signals);
    flags:{`--prompt "..."`,`--max-runs N`,`--max-cost $X`,`--max-duration 2h`(e.g.`8h`),`--merge-strategy squash|merge|rebase`,`--worktree <name>`(parallel+&+`wait`),`--disable-commits`(dry_run),`--review-prompt "..."`,`--ci-retry-max N`(def:1)}
  };
  5_DeSloppify:{
    add_on:post_Implementer_cleanup_pass;
    problem:LLM_TDD_overwrites{typeof/type_system_tests,redundant_type_checks,framework_tests,obscuring_err_handle};
    anti:¬neg_instr_in_Implementer(causes_hesitation,skips_edge_cases,degrades_quality);
    sol:2_focused_agents>1_constrained;sep`claude -p`removes{lang/fw_tests,redundant_type_checks,impossible_state_guards,`console.log`,commented_code},keeps_biz_tests+runs_suite;
    loop:impl→de-sloppify→verify(build+lint+tests)→commit
  };
  6_RalphinhoDAG:{
    credit:@enitrat;
    flow:RFC/PRD→AI_decomp(WorkUnit_DAG)→RalphLoop(≤3_passes;seq_per_DAG_layer)→[parallel_unit_pipelines(worktree)→MergeQueue(rebase_main→build+test→ff_main+push+del_branch⊕EVICT+ctx→next_pass)];
    unit_ts:`WorkUnit{id:string;name:string;rfcSections:string[];description:string;deps:string[];acceptance:string[];tier:"trivial"|"small"|"medium"|"large"}`;
    decomp_rules:{fewer_cohesive_units(min_merge_risk);min_file_overlap;tests_WITH_impl(¬split);deps_only_if_real_code_dep};
    tiers:{
      trivial:impl→test;
      small:impl→test→code-review;
      medium:research→plan→impl→test→(PRD-review+code-review)→review-fix;
      large:research→plan→impl→test→(PRD-review+code-review)→review-fix→final-review
    };
    stages_models:{Research:Sonnet5.5(ctx_doc);Plan:Opus5.5(steps);Implement:Sonnet5.5;Test:Haiku5.5(build+test_fail_sum);PRD_Review:Sonnet5.5(spec);Code_Review:Opus5.5(qual+sec);Review_Fix:Sonnet5.5;Final_Review:Fable5.1(large_only)};
    bias_rule:sep_process+ctx_window/stage;reviewer≠author;
    merge_queue:{
      overlap:non_overlapping⇒speculative_parallel_land;overlapping⇒1-by-1_rebase;
      evict:conflict|build_test_fail⇒EVICT+capture(`## MERGE CONFLICT — RESOLVE BEFORE NEXT LANDING`,files,diffs,test_out)→next_Ralph_pass_impl
    };
    data_flow:{`research.contextFilePath`→plan;`plan.implementationSteps`→impl;`implement.{filesCreated,whatWasDone}`→test,reviews;`test.failingSummary`→reviews,impl(next);`reviews.{feedback,issues}`→review-fix→impl(next);`final-review.reasoning`→impl(next);`evictionContext`→impl(after_conflict)};
    worktree:`/tmp/workflow-wt-{unit-id}/`(uses`jj`/Jujutsu,¬git;unit_stages_share_wt);
    principles:{deterministic_DAG;human_review@work_plan=max_leverage;sep_ctx/stage;ctx_eviction_recovery;tier_depth;SQLite_resumable;native_opt:ClaudeCode_Workflow_tool_before_custom};
    use_when:interdep_units|parallel_impl|likely_conflicts|multi_day+RFC;else(single_file|quick_iter⇒REPL/seq;non_parallel_RFC⇒ContinuousClaude)
  }
}
§COMB{
  tree:single_focused?⇒Seq|REPL : spec/RFC?⇒(parallel?⇒Ralphinho : ContinuousClaude) : many_vars?⇒InfiniteLoop : Seq+DeSloppify;
  recipes:{Seq+DeSloppify;ContinuousClaude+`--review-prompt`deslop;any+gate(build+lint+type+test;stop_after_2x_same_root_fail);simple_loop+tier_routing(`--model haiku`fix|`--model opus`arch)}
}
§ANTI{
  mistakes:{no_exit_cond(`max-runs`/`max-cost`/`max-duration`/signal);no_ctx_bridge(`SHARED_TASK_NOTES.md`|FS);blind_retry_w/o_err_ctx;neg_instr_vs_cleanup_pass;all_agents_1_ctx(reviewer=author);ignore_parallel_file_overlap};
  fail_modes:{churn_no_progress;repeat_same_root_cause;merge_queue_stall;unbounded_escalation_cost};
  recovery:1_freeze_loop→2_audit(exits,gates,ctx_bridge,cost_limits)→3_reduce_scope_to_failing_unit→4_replay_w/_explicit_acceptance
}
