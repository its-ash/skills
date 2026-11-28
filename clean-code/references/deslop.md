@REF:deslop
§REL{../SKILL.md:mandatory_post_Δ_pass;coding-standards.md:TS_JS_defaults;codehealth-mcp.md:structural_delta_gate;../../code-review/references/verification-loop.md:full_verify_gate}
§R{
  trigger:mandatory_pass_on_∀_non_trivial_Δ_pre_done(inspect_branch_diff+staged_diff);
  scope:preserve_requested_behavior;strip_ONLY_AI_slop+unintended_scope_creep;
  tooling:detect_and_run_project_native_cmds(package.json|pyproject.toml|go.mod|Cargo.toml|Makefile)¬invent_cmds;
  report:1-3_concise_sentences(concrete_removals+verified_checks,e.g."Removed 3 narrating comments, 1 shallow wrapper, 2 unused exports; lint/typecheck/tests pass.");
}
§CMD{
  base_diff:`BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo main); git diff "$BASE"...HEAD`;
  staged_diff:`git diff --cached`;
  TS_JS[proj_subset]:`(pnpm|npm|bun) run lint && tsc --noEmit && (biome check .|oxlint) && npx knip && (vitest|jest|bun test)`;
  Python[proj_subset]:`ruff check . && ruff format --check . && (ty check|basedpyright|pyrefly|mypy .) && pytest`(+`vulture`_if_configured);
  Go[proj_subset]:`golangci-lint run && go vet ./... && go test -race ./...`;
  Rust[proj_subset]:`cargo fmt --check && cargo clippy --all-targets -- -D warnings && cargo test`;
}
§PAT[slop_catalog_rm_keep_Δ]{
  excess_cmt:narrating_WHAT_or_diff_history("// Added check","// Refactored",trivial_JSDoc)⇒del(keep_WHY_only);
  overcheck:redundant_try/catch|duplicate_null_or_type_chk_on_already_validated_internal_paths⇒del;
  type_escape:TS(`as any`|`@ts-ignore`),Py(`cast(Any,...)`|`# type: ignore`)_unjustified⇒fix_type_or_narrow;
  inline_import:Py_mid_fn_import(unless_verified_circular_import)⇒move_to_top;
  shallow_wrapper:1-3L_pass_through_fn/cls_adding_indirection_without_abstraction⇒inline;
  speculative_abstraction:1_impl_factory|unused_option_flags|premature_generics⇒delete_keep_direct;
  dead_code:orphaned_helpers|unused_exports|unreachable_branches|unused_deps_post_refactor⇒prune(verify_via_knip|ruff|golangci-lint|clippy);
  swallowed_err:empty_catch|catch_return_null|log_and_rethrow|dropped_Error.cause⇒propagate_with_cause_or_handle_at_boundary;
  verbose_loop_bloat:deeply_nested_AI_loops_or_else_chains⇒flatten_via_guards+stdlib(toSorted,comprehensions,early_returns);
  style_drift:fmt|naming|err_pat_diverging_from_surrounding_file⇒match_local_exemplar;
  scope_creep:unrelated_drive_by_edits_or_reformats_outside_task⇒revert_unrelated_hunks;
  mock_leakage:tests_asserting_private_internals_or_over_mocking⇒simplify_to_observable_behavior;
}
§D{
  uncertain_dead_export⇒verify_dynamic_imports_routes_entrypoints_before_delete¬blind_rm;
  complexity_spike_in_diff⇒extract_cohesive_unit_keeping_deep_module¬micro_split_lines;
  cleanup_modifies_code⇒re_run_full_verify_suite_after_deslop¬skip_recheck;
}
§ANTI{
  claim_clean_without_reading_diff;skip_typecheck_or_tests_after_deslop;add_new_abstractions_during_deslop;leave_TODO_or_debug_logs
}
§CHK[fix_failures_pre_done]{
  Goal:exact_req_met∧¬scope_creep?;
  Impact:importers∧imports∧tests∧shared_callers_updated?;
  Slop:cmts∧overchecks∧type_escapes∧shallow_wrappers∧dead_code∧style_drift_stripped?;
  Errors:cause_preserved∧¬swallowed?;
  Verify:proj_fmt∧lint∧types∧tests_all_green_post_deslop?
}
