@REF:module-regression
§USE{
  ON:mods≥3_interdep∨prior(A_broke_B)∨ext_behavior_Δ∨existing_tests|reconcile_to_org_by_dep;
  OFF:small_repo(¬cross_mod_deps);
  ADOPT:<3mods∨(¬cross_refs∧¬prior_break)⇒skip;1st(A_broke_B)⇒init_same_day;existing_cmds⇒org_by_mod+validate_deps
}
§ANTI{small_no_dep_ledger;manual_dep_guess∨1scan=forever;model_review_instead_of_exit_codes}
§REL{
  ../../unit-testing-patterns/references/test-collaboration.md:TEST-IDs,assets,defect_ev;
  ../../unit-testing-patterns/references/ai-regression-testing.md:exec_defect_tests;
  ../../backend-development/references/contract-first.md:cross_svc|client_contracts;
  module-governance.md:bounds+owners;
  fitness-and-c4.md:dep_graph_&_fitness_scans;
  ../../code-review/references/change-impact.md:blast_radius
}
§R{
  1_Verdict=exit_code:no_exec_cmd=gap(¬pass);
  2_Auditor_RO:report_only(¬fix);author_fixes→rerun;
  3_No_red_delivery:red_downstream⇒Δincomplete;
  4_Defect_ev:fix⇒create|link_TEST-ID+(test|lint|schema|manual_exit);code_only=incomplete
}
§SCHEMA{
  loc:root∨`docs/`∧link∈proj_map|rules(¬orphan);
  fields:{
    Downstream_consumers:dep_graph|build|repro_import_call_scan(eco_specific,¬universal:TS=`depcruise --output-type json`,Py=`tach show`/`lint-imports`,Go=`go list -deps`,Java=`Spring_Modulith`/`ArchUnit`,Rust=`cargo-modules`);unproven_edge=`unverified`(blocks_green_till_human_confirms∨included);
    Dependency_evidence:`<scan|graph_cmd>`;refresh_via_repro_scan_only(rerun_on_dep_Δ,¬hand_edit);
    Regression_acceptance_cmd:exec(tests,reconcile,golden_diff);prefer_reconcile(golden,upstream_totals,accounting)>assertions|mocks;none=`MISSING`(¬fake_green);
    Propagation_rule:downstream_set+exempt_cond(ext_Δ→run;internal+green_mod→exempt);
    Related_test_points:`TEST-ID`s∈`TESTS.md`(`TEST-ORDER-001`,`TEST-REFUND-003`);
    Last_green_commit:`<commit>`
  }
}
§FLOW{
  NOTE:session_plans+reports;trusted_host_runs_in_auth(ask_only_new_auth);exit_code=evidence(¬merge|release_auth);
  1:list_Δ→base(PR_merge_base∨last_green);union(`git diff --name-only <base> HEAD`,`git diff --name-only`,`git diff --cached --name-only`,`git status -s`+untracked)→mods(clean_tree≠no_Δ);
  2:resolve_prop→downstream+rule;
  3:pre_exec_review→cmds=untrusted;show(bounded_cmds,risks,workspace,timeout,env,net);chk_auth(else_ask);trusted_host_only(else`NOT RUN`);
  4:run→exec(mod+req_downstream)→log(cmd,exit);
  5:gate→all_0∧¬affected_unverified⇒ok;fail|unverified⇒incomplete(fix|confirm→step3);attr:(green_base∧only_A_Δ∧B_red)⇒inspect_B→trace_field→A;(B_red_pre_Δ)⇒debt(¬blame_A);small_Δ⇒clear_attr;upd_Last_green_commit;
  6:report→mods,cmds,output,exits,exemptions+reasons
}
§BND{
  Contract-first:cross_svc|client_fields|`CONTRACT.md`|integ_reconcile;
  Test_collab:assets,test_pts,bug_ev|`TESTS.md`|req,bug,test_Δ,delivery;
  Mod_regression:intra_repo_cross_mod|`REGRESSION.md`|post_relevant_Δ
}
§TPL{
  ```markdown
  # REGRESSION.md — Module Regression Ledger
  > Run mod + req downstream; deliver iff all exit=0. Prefer reconciliation>mocks. No cmd=`MISSING`.
  > Downstream evidence last refreshed: `<YYYY-MM-DD>` using `<verified repository scan command>`
  ## Module 01 — Data Ingestion
  - Downstream consumers: `02-cleaning`, `03-shop-mapping`
  - Dependency evidence: `MISSING` — replace after verification
  - Regression acceptance command: `MISSING` — replace after verification
  - Propagation rule: col/format Δ→02,03; internal log+green mod→exempt
  - Last green commit: `<commit>`
  ## Module 02 — Cleaning
  - Downstream consumers: `05-aggregation`
  - Dependency evidence: `MISSING` — replace after verification
  - Regression acceptance command: `MISSING` — replace after verification
  - Propagation rule: ext_behavior_Δ→05
  - Related test points: `TEST-ORDER-001`, `TEST-AMOUNT-002`
  - Last green commit: `<commit>`
  ```
}
