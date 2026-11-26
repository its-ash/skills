@REF:loop-design-check
# Loop Design + Review (goal decidability, Goodhart & runaway prevention)

§D{
  premise:LLM=feed_forward(prompt→tokens)⇒needs_external_feedback_loop_to_act_goal_oriented;
  use⇒repeating_agent_task(write→test→fix→verify) ∨ auditing_loop_for_spinning/Goodhart/wrong_completion;
  ¬use⇒1off_task(do_directly) ∨ plain_timer/poll(`/loop`) ∨ wiring_DAG/recovery_mechanism(see_[autonomous-loops.md](autonomous-loops.md))
}

§REDLINE{
  two_levels(Wiener_1950):Execution(low,machine:measures_delta_from_literal_goal→0) vs Judgment(high,human:is_goal_right,should_change,should_stop);
  rule:machine_cannot_question_own_goal⇒delegating_judgment/sign_off/final_switch⇒fast_wrong_output
}

§WRITE{
  step0_gate(any_miss=veto):[1:repeats≥weekly,2:verification_automatable,3:token_budget_sufficient,4:agent_has_tools_to_run+observe];repo_prereq:reconciliation_baseline(golden_sample/upstream_total)+tests+lint_guard(else_loop_amplifies_errors);
  step1_goal(binary_machine_decidable):{
    bad:vague("make_it_good")⇒comparator_stuck_or_random;
    good:decidable("96_unit_tests_green∧change_list_produced");
    5pt_framework:[1:machine_verifiable_done,2:boundary("must_NOT_do")_w/_done_criterion(anti-Goodhart),3:failure_fallback(retry_cap=N→human_escalate),4:layered_goal,5:prefer_reconciliation(golden_sample/upstream_total/tie_out/diff<0.01)>assertions(tests_can_be_gamed_via_weak_asserts/mocks/swallowed_errs)];
    self_check:domain_naive_reader_can_run_1_command_to_judge_done⇒else_¬decidable
  };
  step2_type:{
    clear_done_test⇒`servo`(`goal`-style,stops_on_goal);
    maintain_state_no_end⇒`regulator`(`loop`-style,never_stops,acts_on_change,deadband_suppresses_noise);
    periodic_sample+exit_cond(e.g.watch_PR_until_CI_green)⇒`regulator_with_exit`;
    must_happen_on_time⇒wrap_in_`/schedule`(cron)
  };
  step3_skeleton:{
    maintenance⇒doc_driven_dispatch(read_doc_on_timer,dispatch_only_on_diff;doc=queue+state_machine+human_UI):[1:problem_col=human_write_only∧result_col=loop_write_only∧state_monotonic(¬rollback),2:exit_code_final(`exit 1`_wins),3:max_loop_state="awaiting_verification"(human_flips_"done")];
    greenfield⇒Plan/Build/Judge:{
      Plan:goal→spec+script_judgeable_acceptance;
      Build:impl_spec(¬edit_acceptance);
      Judge:independent(≠Build)+deterministic(pytest/reconciliation_diff/typecheck/diff,¬"looks_right")⇒pass:stop|fail:return_reason→Build;3_fails→human_escalate
    }
  };
  step4_damping:retry_cap+hard_stop+human_final_switch(prevents_Ralph_Wiggum_oscillation/token_burn);
  step5_rollout:1_manual_run(forces_exact_judge_rule)→2_skill/Claude_Code_subagents(main_loops_P/B/J)→3_cron_auto
}

§CHK{
  5_failure_modes(hit_any⇒reject):
  FM1:platitude_goal("manage_well/make_good")⇒spins/burns_$⇒antibody:decidable_result_cond;
  FM2:self_judging_or_"looks_ok"⇒confident_false_pass⇒antibody:reconcile+exit_codes+independent_judge;
  FM3(worst):only_"all_tests_pass"_w/o_boundaries⇒deletes/weakens_tests(Goodhart)⇒antibody:done_criterion+boundary("must_NOT_do");
  FM4:expects_runtime_clarification("ask_mid_run")⇒never_asks,commits_wrong_answer⇒antibody:front_load_all_clarifications_pre_launch;
  FM5:bloated_`CLAUDE.md`+stale_memory⇒faster_loop_amplifies_errors⇒antibody:layered_memory+periodic_lint;
  3_hard_red_lines(violate_any⇒forbid_auto):
  RL1:judgment_stays_human("done"_flipped_by_human_only);
  RL2:responsibility_¬transfers(unaffordable_failure:wrong_PR_merge/publish/$_misalloc⇒¬auto_exec);
  RL3:self_modifying_loops(rewrite_own_rules)⇒STRICTER_pre_action_human_hard_gate(¬post_hoc_patch)
}

§EX{
  nightly_green_keeper:naive="make_all_tests_pass"(hits_FM3)→fixed:`servo`,retry_cap=3,P/B/J(Judge=independent_CI),goal="all_tests_green∧¬test_file_deleted/weakened∧coverage_¬lowered∧change_list_produced",ambiguous_fixes→left_for_human(fixes_FM4),opens_PR∧¬auto_merge(RL1/RL2)
}

§REFS{
  lineage:Wiener_1950(*The Human Use of Human Beings*),Anatoli(*Loops explained*),Addy(*Loop Engineering*);
  mechanism:[autonomous-loops.md](autonomous-loops.md)
}
