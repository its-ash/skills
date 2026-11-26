@REF:intent-driven-development
§USE{
  ON:clarify_feature∨define_AC∨derisk_pre_impl∨touches∈{sec,auth,persistent_data,migration,ext_API,compliance}∨handoff_artifact∨ambiguous(outcome¬observable∨¬testable)∨explicit_req;
  OFF:trivial_edit∨1L_fix∨active_debug∨code_review∨clear_AC_impl
}
§R{
  1:inspect(repo,docs,issues,design,schemas,test_infra)→discover_tech_facts_PRE_Q;
  2:¬infer(biz_rules,compliance,reg,SLA,pricing,retention,prio,target_users)from_code;treat=unknown→record∈Assumptions(confirm)until(user∨authoritative_artifact∈{PRD,contract,policy});
  3:ask_MIN(required∧uninferable∧Δscope|behavior);group_short_Qs;¬ask_generic_irrelevant_risks;
  4:¬block_impl_default;clear_impl⇒brief(assumptions+AC)→proceed|handoff;
  5:confirm_REQUIRED⇔unresolved∈{sec_exposure,data_loss,irreversible_mig,contract|API_break,meaningful_cost,destructive_ext};
  6:¬write_repo_doc∨¬mutate_files∨¬branch∨¬commit∨¬start_other_wf UNLESS(user_req∨repo_wf_req);save_brief⇔req(use_repo_path∨ask|state_dest_pre_write);
  7:auto_test=evidence(¬truth);prefer_reliable_proportionate_auto;allow_manual∈{UX,a11y,sec,legal,ops}when_auto_insufficient;
  8:¬real(secrets,creds,tokens,keys,PII,prod_payloads)∈AC|fixtures|examples|artifacts→redacted|synthetic;
  9:¬run(destructive_test,mig,sec_probe,load_test,paid_ext_call,prod_live_op)WITHOUT(explicit_auth∧safe_env);
  10:mid_impl_AC_fail(arch|platform|ext_constraint)⇒¬drop∧¬silent_workaround;mark`[revised]`+state_constraint+upd(scope|verif)+inc(rev#)+re_present_Δ_only;reconfirm⇔Δblocking_dec∨reduces_safety|correctness
}
§DEPTH{
  QuickCapture:clear_non_trivial∧risk∈{low,mod}⇒{Goal,In/Out_scope,Assumptions,AC(3-7)+verif,Blocking_Qs?};¬delay_impl UNLESS(R5∨user_req_spec_1st);
  FullBrief:ambiguous∨cross_sys∨sec∨data_Δ∨mig∨compliance∨high_cost∨handoff⇒full_§TPL+confirm_blockers_pre_risky_impl;
  SpecReview:user_gave(PRD|issue|plan|AC)⇒review_in_place(¬restart_discovery)→flag(missing_scope,unsafe_assumptions,contradictions,unverifiable_reqs)→return_corrected|supplemental_AC
}
§FLOW{
  1:goal_risk→extract|ask(observable_outcome,affected_actors,main_fail_conseq,applicable∈{sec/privacy,data,compat/API,mig,ext_deps,cost,concurrency,perf,UX/a11y});
  2:ctx_discover→inspect_needed(behavior,files/interfaces,conventions/docs/contracts/schemas/mig_hist,verif_infra+cmds,ext_deps+isolation);separate(discovered_facts vs assumptions);uninspectable⇒state_unknown+focused_Qs;
  3:scope→Goal(1_sent_outcome),In_scope,Out_scope(excluded_adjacent),Assumptions,Blocking_decisions;
  4:AC→ID=`AC-NNN`(`AC-001`..);1:1_AC↔test¬req;fields:{Scenario,Action(single_trigger),Expected(observable),Must_not(if_meaningful),Verification(auto_test|integration|manual_UX|a11y|sec_review|ops|stakeholder),Env/safety(if_data|svc|cost|secrets),Priority(Required|Important|Optional)};ban_vague∈{"correctly","securely","fast","intuitive","robust"}UNLESS(observable_evidence∨marked_human_judgment);
  5:boundaries(relevant_only)→{Happy_path:workflow|state; Validation:reject_malformed|boundary∧¬mutate; Authz/privacy:deny∧¬sensitive_disclosure; Persistence/mig:backward_read,mig,rollback|backup; Compat:API|file|event|client_contract_valid; Failure_recov:net|svc|async_fail⇒¬partial_state,retry|degraded; Idemp/conc:repeats|simultaneous⇒¬dup|invalid_state; Perf:cond+threshold; UX/a11y:kbd,feedback,err_recov,visual|manual};
  6:deliver→spec_req⇒present_brief+ask_blockers_only; clear_impl⇒compact_AC_summary+impl; handoff⇒full_ctx+verif_detail(¬invent_reqs)
}
§TPL{
  ```markdown
  # Acceptance Brief: <Change Name>
  **Status:** Draft | Approved | Implemented | Verified
  **Revision:** <n> | **Prepared for:** <target> | **Approval required before risky work:** Yes | No - <reason>
  ## Revision Log: Rev | Date | Changed criteria | Reason
  ## Goal: <1 observable outcome sentence>
  ## Scope: In scope (<behaviors>) | Out of scope (<excluded>)
  ## Context: Discovered facts (tech/verified) | Product/business constraints (user/artifact only, else "none supplied yet") | Assumptions | Dependencies & constraints
  ## Risk Review: Security/privacy | Persistent data/migration | External effects/cost | Compatibility/API | UX/accessibility → Yes/No + handling
  ## Acceptance Criteria
  ### AC-001: <observable behavior>
  - Scenario | Action | Expected | Must not | Verification | Environment/safety | Priority(Required|Important|Optional)
  ## Blocking Decisions: - [ ] <only safety/correctness blockers>
  ## Verification Plan: AC-001 | <cmd/evidence> | Pending
  ```
}
§EX{
  Quick("CSV export"):Goal=auth_user_downloads_filtered_CSV(date_filename);Out=sched,email,xlsx;Assump=<10k_rows,¬PII;AC-001(auth+≥1row→click"Export CSV"→cols[id,name,created_at]→¬internal|other_user_rows→integration_test+manual_schema_check→Required);
  Full("Auth→OAuth"):auth+ext_dep+sessions⇒RiskReview+session_invalidation_blocker+rollback_AC;
  FAIL_AC:`AC-001: The export works correctly and is secure.`(vague,¬scenario/trigger/expected/verif/must_not);
  FAIL_CTX:`Discovered facts: free tier limited to 100 exports/mo.`(biz_rule⇒Product/biz_constraints|Assumptions)
}
§CHK{
  ∀req_AC∈{scenario,observable_expected,named_verif};
  vague_terms∈{observable_evidence,human_judgment};
  biz_constraints∈{supplied,assumed}∧¬inferred_from_code;
  explicit(scope,out_of_scope);
  blockers=safety|correctness_ONLY(¬prefs);
  Goal=outcome(¬impl_choice);
  relevant_risks_covered;safe_env_for_risky_ops;¬secrets|prod_data;¬unrequested_repo_mutation|impl_block
}
§REL{../../unit-testing-patterns/SKILL.md:test_design_from_AC(¬assume_tool_installed)}
