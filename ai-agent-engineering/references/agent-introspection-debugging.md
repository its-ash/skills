@REF:agent-introspection-debugging
§USE{self_debug_wf(¬hidden_runtime)⇔{max_tool|loop_limit,repeat_retries¬progress,ctx_growth|prompt_drift,fs|env_mismatch,recoverable_tool_fail};scope_in:{cap_pre_retry,diag_agent_pats,contained_rec,human_debug_rpt};¬primary∈{post_Δ_verify→tests∧references/eval-harness.md,fw_debug→systematic-debugging/SKILL.md,unenforceable_runtime_promises}}
§LOOP{
P1_cap(pre_rec):{collect:{err(type,msg,stack?),last_tool_seq,intended_act,ctx_pressure(repeat_prompts|oversized_logs|dup_plans|runaway_notes),env_assume(cwd,branch,svc_state,expected_files)};tpl:{session/task,goal_in_progress,error,last_ok_step,last_failed_tool/cmd,repeat_pat,env_assumptions_to_verify}};
P2_diag(match_pre_Δ):{max_calls|repeat_cmd⇒loop|no_exit_obs→inspect_last_N;ctx_overflow|degraded⇒unbounded_notes|repeat_plans|big_logs→inspect_dup∧low_sig;ECONNREFUSED|timeout⇒svc_down|bad_port→check_health∧URL∧port;429|quota⇒retry_storm|no_backoff→count_calls∧spacing;missing_file_post_write|stale_diff⇒race|bad_cwd|branch_drift→check_path∧cwd∧git_status∧exists;tests_fail_post_fix⇒bad_hyp→isolate_test∧re_derive;Q:[class∈{logic,state,env,policy},obj_drift?,determ∨transient?,min_reversible_check?]};
P3_rec(min_surface_Δ):{acts∈{stop_retries∧restate_hyp,trim_low_sig(keep:goal,blockers,evid),verify_actual(fs,branch,proc),narrow→1(cmd|file|test),speculate→direct_obs,high_risk|ext_block⇒escalate_human};¬claim_unbacked_auto_heal("reset agent state"|"update harness config")∨actual_tool_exec;chk:{diag_chosen,smallest_act,why_safe,proof_evid}};
P4_rpt:{session/task,failure,root_cause,recovery_act,result∈{success,partial,blocked},burn_risk(tok|time),follow_up,preventive_rule}
}
§HEUR{order:[1:restate_goal_1_sent,2:verify_world_state(¬mem),3:shrink_scope,4:1_discrim_check,5:retry];bad:retry×3_reword;good:cap→classify→1_check→replan_if_supported}
§OUT{¬"I fixed it"_only;req:[fail_pat,root_cause_hyp,recovery_act,evid(better|blocked)]}
§REL{post_code_Δ⇒rerun_tests∧verify;repeat_pat⇒encode(rule|skill);decision_ambig⇒references/council.md;stack_bug⇒references/agent-architecture-audit.md}
