---
name: systematic-debugging
description: "AUTO_INVOKE(silent)⇔prompt∈{debug,bug,root-cause,stack-trace,assertion-error,segfault,memory-leak,OOM,flaky-test,CI-failure,data-corruption,race-condition,deadlock,heisenbug,off-by-one,NPE,null-pointer,dependency-conflict,perf-regression,repro,git-bisect,binary-search,delta-debugging,boundary-log,hypothesis,minimal-repro,regression-test,crash,error-class,sanitizer,ASan,TSan,UBSan,rr,eBPF,bpftrace,flamegraph,off-cpu,heap-snapshot,memray,pdb,Tachyon,Playwright-trace,diagnostics_channel}|SUB:{techniques,runtime-diagnostics}"
---
@SKL:systematic-debugging
§R{
  confirm(root_cause)≺fix_symptom∧verify(every_frame,val,assumption_against_live_output);
  read_full_error⇒(message,stack_trace,line_numbers,codes,source_maps);
  repro(reliable)∧write(repro_steps);¬repro⇒gather_more_data∧¬guess;
  check_recent_Δ_first⇒(`git diff`,new_deps,lockfile,config,env);
  multi_component_sys⇒log(IO,∀boundary,SET|UNSET,¬secrets)∧correlate(OTel_trace_id);
  trace(bad_val,up_call_stack→origin)∧fix_at(origin);
  compare(working_example_in_repo)⇒list(∀diff)∧read_full_ref_before_adapt;
  state(1_written_hypothesis)∧test_with(1_Δ⊕1_probe)∧¬combine_fixes;
  hypothesis_wrong⇒new_hypothesis;stuck⇒report_stuck∧(research∨ask);
  write(failing_regression_test)≺apply_fix;
  apply(1_root_cause_fix)∧¬unrelated_Δ∧verify(pass(new_test)∧pass(full_suite));
  failed_fixes≥3⇒stop∧inspect(coupling,hidden_shared_state,design_flaws)∧discuss≺large_refactor;
  concurrency∨mem_corrupt⇒run(ASan|TSan|UBSan|go_-race|miri)∧deterministic_replay(rr|seed);
  live_prod_triage⇒non_disruptive_attach(pdb_-p|Tachyon|heapsnapshot_signal|bpftrace|OTel)¬blind_restart;
  perf_regression⇒measure(baseline,now)∧split(on_cpu,off_cpu_wall_clock,pre_queue_wait)¬guess
}
§D{
  phase1_investigate⇒error_text,repro,recent_Δ,boundary_logs,trace_data_flow¬edit_code_first;
  phase2_pattern⇒diff(broken,working,line_by_line)¬skim_reference;
  phase3_hypothesis⇒1_hypothesis+1_minimal_Δ¬shotgun_edits;
  phase4_implement⇒failing_test→single_fix→full_suite¬fix_without_test;
  worked_before∧now_broken⇒`git bisect start --first-parent`+`run`(exit_125=skip)¬manual_log_scan;
  large_path∨huge_failing_input⇒binary_search(50%)∨delta_debug(shrinkray|Hypothesis)¬logs_everywhere;
  complex_context⇒minimal_repro(empty_file→fail)¬debug_inside_full_app;
  CI_only_failure⇒print(env,config,per_layer,SET|UNSET,¬values)+CI_artifacts(Playwright_trace)¬assume(local≡CI);
  flaky_test⇒shuffle+pin_seed(Vitest|pytest-randomly|go_-shuffle)∧check(races,shared_state)¬add(retries∨sleeps);
  mem_leak⇒V8(3_snapshot|--heap-prof|--heapsnapshot-signal)∨Py(memray)¬guess_retained_obj;
  race∨UB∨heisenbug⇒sanitizers(TSan|ASan+UBSan|go_-race|miri)∨`rr record/replay`¬printf_only;
  perf_or_tail_latency⇒split(on_cpu,off_cpu_wall_clock)+eBPF/OTel_pre_queue¬optimize_hot_cpu_only;
  live_prod_hang∨slow⇒live_attach(`pdb -p`|`profiling.sampling attach`|`bpftrace`|`ss -tin`)¬restart_losing_state;
  unknown_error_class⇒error_class_map(references/techniques.md)¬deep_dive_before_narrowing
}
§REF{
  error_class,boundary_log,bisect,first_parent,exit_125,delta_debug,shrinkray,flaky_test,seed,Playwright_trace,anti_patterns,checklist→references/techniques.md;
  Node_22_24_26,inspect_wait,diagnostics_channel,heap_prof,heapsnapshot_signal,Python_3.14_3.15,pdb_attach,Tachyon,faulthandler,memray,uv_tree,ASan,TSan,UBSan,rr,go_race,miri,ss,eBPF,bpftrace,OTel,off_cpu→references/runtime-diagnostics.md
}
§REL{
  ../unit-testing-patterns/SKILL.md:write_failing_regression_test;
  ../devops-iac/references/observability.md:prod(logs,metrics,traces,OTel);
  ../web-quality-audit/references/performance.md:DevTools_traces_web_slowness;
  ../code-review/SKILL.md:review_fix_before_merge;
  ../ai-agent-engineering/SKILL.md:debug_failed_agent_runs;
  ../git-workflow/SKILL.md:git_history_bisect_revert
}
