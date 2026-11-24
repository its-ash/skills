---
name: systematic-debugging
description: "AUTO_INVOKE(silent)⇔prompt∈{debug,bug,root-cause,stack-trace,assertion-error,segfault,memory-leak,flaky-test,CI-failure,data-corruption,race-condition,off-by-one,NPE,null-pointer,dependency-conflict,perf-regression,repro,git-bisect,binary-search,boundary-log,hypothesis,minimal-repro,regression-test,crash,error-class}|SUB:{∅}"
---
@SKL:systematic-debugging
§R{
  confirm(root_cause)≺fix_symptom;
  read_full_error⇒(message,stack_trace,line_numbers,codes);
  repro(reliable)∧write(repro_steps);¬repro⇒gather_more_data∧¬guess;
  check_recent_Δ_first⇒(`git diff`,new_deps,config,env);
  multi_component_sys⇒log(IO,∀boundary)∧verify(env_propagate∧config_propagate);
  trace(bad_val,up_call_stack→origin)∧fix_at(origin);
  compare(working_example_in_repo)⇒list(∀diff)∧read_full_ref_before_adapt;
  state(1_written_hypothesis)∧test_with(1_Δ⊕1_log_line)∧¬combine_fixes;
  hypothesis_wrong⇒new_hypothesis;stuck⇒report_stuck∧(research∨ask);
  write(failing_test_showing_bug)≺apply_fix;
  apply(1_root_cause_fix)∧¬unrelated_Δ;
  verify⇒pass(new_test)∧pass(full_suite);
  failed_fixes≥3⇒stop∧inspect(coupling,hidden_shared_state,design_flaws)∧discuss≺large_refactor
}
§D{
  phase1_investigate⇒error_text,repro,recent_Δ,boundary_logs,trace_data_flow¬edit_code_first;
  phase2_pattern⇒diff(broken,working,line_by_line)¬skim_reference;
  phase3_hypothesis⇒1_hypothesis+1_minimal_Δ¬shotgun_edits;
  phase4_implement⇒failing_test→single_fix→full_suite¬fix_without_test;
  worked_before∧now_broken⇒`git bisect`¬read_whole_history_manually;
  large_path∧unclear_failure_point⇒binary_search(disable_half,rerun)¬logs_everywhere;
  complex_context⇒minimal_repro(from_empty_file)¬debug_inside_full_app;
  CI_only_failure⇒print(env,config,per_layer,SET|UNSET,¬values)¬assume(local≡CI);
  flaky_test⇒loop_test∧record(seed,order,timing)∧check(shared_state,races)¬add(retries∨sleeps);
  perf_regression⇒profile∧measure(baseline,now)¬optimize_by_intuition;
  unknown_error_class⇒error_class_table(references/techniques.md)¬deep_dive_before_narrowing
}
§REF{
  error_class_table,boundary_logging_ex,bisect,Node_Python_sys_cmds,checklist→references/techniques.md
}
§REL{
  ../unit-testing-patterns/SKILL.md:write_failing_regression_test;
  ../devops-iac/references/observability.md:prod(logs,metrics,traces);
  ../web-quality-audit/references/performance.md:DevTools_traces_web_slowness;
  ../code-review/SKILL.md:review_fix_before_merge;
  ../ai-agent-engineering/SKILL.md:debug_failed_agent_runs
}
