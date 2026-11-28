@REF:eval-harness
§GOAL{EDD:evals_before_code,graders,head_to_head_agent_cmp,self_score_deliverable}
§WHEN{setup_EDD;pass_fail_criteria;pass@k_reliability;regression_suite(prompt|agent_Δ);model_benchmarks;cmp_agents(Claude_Code,Aider,Codex);self_rate_deliverable}
§PHIL{evals=unit_tests_of_AI:define_before_impl→run_continuously→track_regressions_per_Δ→measure_pass@k_and_pass^k}
§ANATOMY{
  Task(spec+fixtures)→Trial(1_stochastic_run)→Transcript(full_prompts,tool_calls,reasoning)→Outcome(final_env_state/artifacts)→Grader;
  rule:grade_Outcome(final_state)>rigid_trajectory(agents_take_valid_alt_paths);inspect_Transcripts_to_diagnose_fails∧calibrate_judges
}
§EVAL_TYPES{
  Capability:`[CAPABILITY EVAL: <name>]`{Task,Success Criteria[- [ ]],Expected Output}(starts_low_pass_rate_for_hill_climbing→graduate_solved_to_Regression);
  Regression:`[REGRESSION EVAL: <name>]`{Baseline(SHA|checkpoint),Tests(PASS/FAIL),Result(X/Y_vs_prev_Y/Y)}(target:near_100%_pass^k)
}
§GRADERS{
  1:Code(deterministic,preferred,fast,cheap_but_brittle_on_open_ended):`grep -q "<pat>" <file> && echo PASS || echo FAIL`;`npm test -- --testPathPattern="<pat>"`;`npm run build`;
  2:Rule:regex|schema_constraints;
  3:Model(LLM_judge_rubric,semantic/nuance):eval(solves_problem,well_structured,edge_cases,err_handle)⇒Score(1-5)+Reasoning;calibrate_regularly_vs_Human_gold_spot_checks;
  4:Human(mandatory_for_sec|ambiguous|judge_calibration):`[HUMAN REVIEW REQUIRED]`{Change,Reason,Risk(LOW|MEDIUM|HIGH)}
}
§METRICS{
  pass@k:≥1_success_in_k_trials(`pass@1`=direct,`pass@3`=practical_w/_retries,target:`pass@3 > 90%`|`>= 0.90`);
  pass^k:all_k_trials_pass(stability/release_critical,target:`pass^3 = 100%`|`1.00`)
}
§WF{
  1:Define_before_code⇒`.claude/evals/<feature>.md`;
  2:Implement;
  3:Evaluate(run_capability+`npm test -- --testPathPattern="existing"`)⇒log(`.claude/evals/<feature>.log`);
  4:Report(cap_pass@k,reg_pass^k,status=`READY FOR REVIEW`|`SHIP IT`)
}
§STORE{`.claude/evals/<feature>.md`(def);`.claude/evals/<feature>.log`(run_history);`.claude/evals/baseline.json`(reg_baselines);`docs/releases/<version>/eval-summary.md`(release_snap)}
§BEST_ANTI{
  best:[define_before_code,run_frequently,track_pass@k_over_time,deterministic_code>probabilistic,human_review_for_sec,keep_fast,version_w/_code];
  anti:[overfit_prompts_to_examples,happy_path_only,ignore_cost/latency_drift,flaky_graders_in_release_gates]
}
§HEAD_TO_HEAD{
  when:choose_coding_agent∨measure(pass_rate,cost,time)_after_setup_Δ;
  task_yaml:`tasks/<name>.yaml`{name,description,repo,files,prompt,judge:[{type:pytest,command},{type:grep,pattern,files},{type:llm,prompt}],commit:pinned_SHA};
  run:[
    1:`git worktree add ../run-<agent>-<n> <sha>`(isolated);
    2:prompt_agent;
    3:run_judges;
    4:record(pass_rate,cost_USD,wall_clock_sec,consistency(e.g.3/3=100%))
  ];
  tool:[agent-eval](https://github.com/joaquinhuigomez/agent-eval)(read_source_before_install);
  rules:[start_3-5_real_workload_tasks(¬toys),≥3_trials/agent,pin_commit,≥1_deterministic_judge/task,track_cost_w/_pass_rate(95%_at_10x_cost_may_lose),version_task_YAMLs_as_fixtures]
}
§SELF_SCORE{
  type:reflection_step≠pass_fail_gate;
  when:code(≥3_files∨≥50_lines) ∨ multi_step_wf ∨ debug(≥3_attempts) ∨ design_doc ∨ "rate_yourself";
  axes:{
    Accuracy:facts/claims/outputs_correct(catches:hallucinations,wrong_APIs,bad_syntax);
    Completeness:covered_all_user_asks(catches:missed_edges,unhandled_errs,skipped_subtasks);
    Clarity:understandable+structured(catches:undefined_jargon,missing_ctx,rambling);
    Actionability:immediately_usable(catches:vague_suggestions,missing_steps,no_verify_path);
    Conciseness:min_words/tokens(catches:redundancy,over_expl,filler)
  };
  scale:{5:exceptional_no_reasonable_improv,4:good_minor_nits,3:adequate_notable_weakness_≥1_axis,2:weak_clear_gap_usability/correctness,1:poor_misses_req|major_errs};
  evidence_rule:∀score<5⇒cite_specific_evidence("show_gap,¬just_name");
  proc:[
    1:collect(orig_req,deliverable,tool_outputs(tests,exit_codes,lint),user_corrections);
    2:score_each_axis_independently(¬pick_avg_first);
    3:report(1_line_summary,scorecard+evidence,overall_avg_1_dec,1-3_ranked_improvements,"Would the user agree?");
    4:if(axis≤3)⇒(small_fix⇒fix_now ⊕ else⇒flag(cause,evidence,specific_fix))
  ];
  anti:[all_5s_wo_proof,penalize_unrequested_scope,re_argue_decided_design,personal_pref_as_evidence,guessing_instead_of_test/lint_output]
}
§REL{`references/agent-architecture-audit.md`;`references/agent-introspection-debugging.md`}
