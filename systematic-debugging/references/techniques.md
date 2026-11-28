@REF:techniques
§R{
  confirm_root_cause≺apply_edit∧verify(every_frame,val,line_from_live_output);
  never_echo_secrets@boundary⇒emit_SET|UNSET_or_hash_prefix_only;
  automate_bisect⇒minimal_repro_script∧`--first-parent`∧exit_125_on_unbuildable_or_flaky;
  flaky_tests⇒shuffle+pin_seed∧fix_shared_state_or_race¬mask_with_retries_or_sleeps
}
§D{
  Syntax:parse|unexpected_token⇒check(typo,delimiter,encoding,runtime_syntax_version);
  Type:`TypeError`|mismatch⇒check(null|undefined,contract,coercion,runtime_schema);
  Ref:`NameError`|`ReferenceError`⇒check(scope,hoisting,circular_import,shadowing);
  Runtime:uncaught_exc⇒check(preconditions,invariants,null_guard,bad_op);
  Net:timeout|`ECONNREFUSED`|4xx|5xx⇒check(URL,DNS,TLS,socket_exhaustion,upstream_health);
  Perm:`EACCES`|`PermissionError`|TCC⇒check(uid/gid,ACL,sandbox,keychain,codesign);
  Dep:`ModuleNotFound`|ver_conflict⇒check(lockfile,peer_dep,venv_or_node_ver,PATH);
  Cfg:missing_env|bad_cfg⇒check(env_propagation,layer_override,fallback_default);
  DB:conn_refused|deadlock|query_err⇒check(pool_exhaustion,creds,lock_order,query_plan);
  Mem:OOM|heap_exhaust|SIGKILL⇒check(retained_closures,unbounded_cache,cgroup_mem_limit);
  Conc:race|deadlock|heisenbug⇒check(unsynced_shared_mut,lock_order,async_reentrancy)
}
§PAT{
  boundary_probe:log(entry_exit_IO,∀layer)⇒first_corrupted_boundary≡fault_zone;
  safe_env_probe:`echo "VAR: ${VAR:+SET}${VAR:-UNSET}"`∧`env | grep -q '^VAR=' || echo "VAR missing"`;
  macos_signing_probe:`security list-keychains; security find-identity -v`→`codesign --sign "$IDENTITY" --verbose=4 "$APP"`;
  binary_search_code:disable_50%_path→rerun→recurse_on_failing_half;
  minimal_repro:empty_file→add_minimum_deps_until_fail⇒isolates_from_app_noise;
  delta_debugging:shrink_large_failing_input(`shrinkray`|Hypothesis_shrinking|creduce)⇒minimal_repro;
  rubber_duck:state_each_line_assumption_explicitly→verify_first_unproven_assumption;
  flaky_bisect_guard:run_micro_repro_3x⇒all_fail→exit_1;all_pass→exit_0;mixed→exit_125(skip);
  build_guard_bisect:compile_fail⇒exit_125(skip_unbuildable_commit)¬mark_bad;
  diff_working_ref:diff(broken,known_working,line_by_line)⇒list_∀delta≺edit
}
§CMD{
  bisect_manual:`git bisect start --first-parent <bad> <good>`→`git bisect good|bad|skip`→`git bisect reset`;
  bisect_auto:`git bisect start --first-parent HEAD <last-good>`→`git bisect run ./repro.sh`→`git bisect reset`;
  bisect_exit_codes:`0`=good|`1..127¬125`=bad|`125`=skip(build_fail∨flaky_ambiguous);
  bisect_inspect:`git bisect log`∧`git bisect visualize --oneline`;
  vitest_flaky:`npx vitest run --sequence.shuffle --sequence.seed=<N> --retry=0`;
  pytest_debug:`pytest --lf --pdb`∧`pytest --randomly-seed=<N>`∧`pytest --durations=10`;
  go_flaky:`go test -race -shuffle=on -count=10 ./...`∧`go test -shuffle=<N> ./...`;
  playwright_trace:`npx playwright test --trace=retain-on-failure`→`npx playwright show-trace trace.zip`
}
§ANTI{
  shotgun_edits⇒changing_multiple_files_hides_causality∧introduces_regressions;
  symptom_masking⇒adding_retries|sleeps|broad_try_catch_hides_root_cause;
  full_suite_bisect⇒slow∧noisy_merge_commits⇒use_micro_repro_script+`--first-parent`;
  confirmation_bias⇒trusting_assumed_stack_or_memory_without_verifying_live_output;
  secret_leak_in_logs⇒printing_raw_tokens_in_CI⇒emit_SET|UNSET_only;
  sunk_cost_patching⇒≥3_failed_fixes_without_stepping_back_to_audit_architecture
}
§CHK{
  1:read_full_error(msg,stack,codes,source_maps);
  2:establish_deterministic_repro(steps|seed|script);
  3:check_recent_Δ(`git diff`,deps,lockfile,cfg,env);
  4:instrument_boundaries(SET|UNSET,IO,trace_id);
  5:trace_bad_value_up_stack→origin;
  6:diff_against_working_example;
  7:write_1_hypothesis→test_with_1_minimal_Δ;
  8:write_failing_regression_test;
  9:apply_1_root_cause_fix(¬unrelated_Δ);
  10:verify(new_test_pass∧full_suite_pass);
  11:if_failed_fixes≥3⇒STOP→audit_architecture;
  12:remove_temp_probes∧record_systemic_root_cause
}
