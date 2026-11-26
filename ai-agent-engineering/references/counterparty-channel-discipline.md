@REF:counterparty-channel-discipline
§SCOPE{written_contract(¬2nd_engine,¬exec_guard);separates:{audience,consent,deliv};approval⇒[operator-approval-loop.md](operator-approval-loop.md)}
§WHEN{ext_grp|shared_ch|DM(customer,supplier,partner);unk_DM|sched|attach;speak_iff_addressed∧¬leak∧risky→draft_only}
§TRUST{
  id:auth_adapter+op_policy⇒exact(platform,workspace_id,channel_id);
  non_cred:{labels,text,model_out,metadata,synthetic_flags};
  unk|malformed⇒ext_safe(¬elevate_from_malformed_key|display_name);
  access_first:unk_ch⇒quiet_unsolicited;explicit_in⇒answer_iff(access∧ext_limits);1:1_DM⇒req_consent≠trusted_aud;
  out_class:{ext|unk:[final_biz,safe_err];trusted_int|priv_op:[final,safe_err,ops_facts,allowed_progress];muted|deferred:∅};
  never_ext:{reasoning,raw_exc,stack_traces,secrets,host_paths,sys_cfg,test_status,filing_notices};
  tech_evid⇒access_ctrl_int;int_msgs⇒ops_wo_traces;out_class≠sanitization
}
§CONSENT{
  ext_grp:`require_mention:true`;
  ok:{cur_mention,agent_cmd,direct_reply(actual_cur_author)};
  no:{hist_bot_thread,active_sess,msg_to_human(wo_agent|trusted_op_req),grp_attach_alone,model_self_auth};
  dm_1to1(text|attach)⇒pos_req_in_access(¬grp_DM,¬synthetic);
  bot_src⇒scoped_op_req(even_w/_mention);open_Q⇒explicit_trusted_ch_policy;
  auto_op⇒trusted(int|priv)∧trusted_op_id∧text∧policy;
  pre_model:mute|defer_BEFORE(model,ctx_enrich,media_fetch);
  burst:defer_auth_on_attach_burst;stop|approval_cmd⇒bypass_ONLY_burst(earlier_gates_hold;dispatch_¬model);
  `observe_unmentioned_group_messages:true`:adapter_cap≠model_perm,needs_retention+access_policy,¬enrich|media|out;
  `never_silent_ack:true`:internal_only,¬override_consent;silence=valid
}
§DELIV{
  carry_dec;chk_AFTER(prefix,fmt,fallback)_BEFORE_EVERY(send,edit,stream,override,helper);
  dest_Δ⇒re_resolve;out_perm≠deliv_grant;reuse_runtime;
  sched|tool:needs_trusted(dispatcher|op)_grant+complete_dest_id;missing(target|grant)⇒mute;¬fabricate_signals;unk_valid⇒ext_safe;model|page≠grant;
  err:¬raw_interp,honest_limit("I cannot read that attachment here. Please paste the relevant section.")+min_req(¬unrelated_Q;clarify_needs_own_perm);
  filing⇒verified_int_only(¬ext_ack)
}
§AUTO{
  `default:auto`:after(access∧consent∧deliv)≠unsolicited;ok:[sched,logistics,factual_from_auth_record];
  draft_only:[prices_or_rates,contractual,legal_or_dd,public_posts,unverified_claims,unmeasured_technical_specs]+tier+holds;
  never:[signing,money_movement,credential_entry,package_publication,cross_counterparty_disclosure];
  leak_chk:vs(auth_record,other_protected_terms)_pre_send;suspect⇒block+verified_int_report(¬expose_matched_party);
  comm_approval¬waive(confid|transport)
}
§PROMPT_POLICY{
  prompt:¬interp_labels_into_rules(omit∨untrusted_data;escape≠policy);bind_to_dest_id(¬cross_ch_ctx|grant);
  yaml:illustrative≠universal;map_to_runtime∧verify_consumers(YAML|prompt_test≠enforcement)
}
§TEST{
  use:synthetic_ids+runtime_counters(¬live_fixtures);
  chk:[pre_model_mute/defer,human_addr(-),agent_addr(+),1:1_vs_grp_DM,bot_consent,burst/cmd_prec,unk/malformed_id,grant/target_fail,post_prefix_safe_out(send,edit,stream,standalone),scoped_sched(+)];
  note:policy|prompt_chk=written_contract≠transport_int_test;
  log:{responded|muted|deferred,reason_codes,audience,output_class,consumer_path,opaque_corr_id};
  suppression≠delivered(transport_only);keep(bodies,terms,ch_ids,secrets,receipts)∉public_tests|diag;report_untested_paths
}
§TPL:strict_prompt
Immutable(ext-counterparty ch):
- Reply iff trusted policy permits(hist_thread|attach|model_belief≠consent); else observe silently.
- Biz content from auth record; ¬reveal counterparty ID/terms/prices.
- Never send traces, sys/cfg, raw_exc, reasoning, test_status, secrets, host_paths, filing_notices.
- Limits: `"I cannot read that attachment here. Please paste the relevant section."`(¬invent/conceal).
- ¬interim ack if direct answer possible; silence=valid. Short plain sentences; ¬emojis, ¬em_dashes.
- Internal econ/negot⇒verified internal only. File prices/contractual/legal/commitments for op approval(filing stays internal, ¬send_auth).
- Access, scoped grants, confid, draft-only, holds remain active.
§TPL:policy_keys
`schema:illustrative`, `unknown_audience:external`, `unknown_unsolicited_participation:mute`;
`channels:[{platform,workspace_id,channel_id,audience:external|internal,access:allowed,require_mention:true,open_question_responses:false,operator_messages_are_requests:false}]`;
`participation:{historical_thread_is_consent:false,group_attachments_are_consent:false,bot_requires_scoped_operator_request:true,synthetic_requires_exact_target_and_grant:true,defer_pending_attachment_burst:true,recognized_commands_bypass_only_burst_deferral:true,observe_unmentioned_group_messages:true,observation_requires_retention_and_access_policy:true}`;
`output:{external:[final,safe_error],internal:[final,safe_error,operational,progress],never_silent_ack_internal_only:true,classify_after_final_assembly:true,check_every_send_edit_stream_and_standalone_path:true,raw_diagnostics_are_message_content:false}`;
`autonomy:{default:auto,draft_only:[prices_or_rates,contractual,legal_or_dd,public_posts,unverified_claims,unmeasured_technical_specs],frozen:[synthetic-simulation],never:[signing,money_movement,credential_entry,package_publication,cross_counterparty_disclosure]}`
