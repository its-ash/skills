@REF:agent-architecture-audit
§USE{req∈{prod_release,ship(tool_call|memory|multi_step),wrapper_degrade,rpt("getting worse"|"tools flaky"),playground_ok∧wrapper_fail,debug>15m};¬use∈{single_run→references/agent-introspection-debugging.md,code_review→code-review/SKILL.md,sec→references/agent-security-hardening.md∨secure-coding/SKILL.md,bench→references/eval-harness.md,new_feat}}
§STK[1..12]{1:sys_prompt(conflict,bloat);2:session_hist(stale_ctx_inj);3:long_term_mem(cross_session_pollute,old_topic_leak);4:distill(artifact→pseudo_fact);5:active_recall(redundant_resummary_waste);6:tool_select(wrong_route,skip_req);7:tool_exec(hallucinated_exec);8:tool_interp(misread|ignore_out);9:ans_shape(fmt_corrupt);10:platform_render(UI|API|CLI_mutate);11:hidden_repair(silent_fallback|retry_2nd_LLM);12:persist(expired_state|cache→live_evid)}
§PAT{1_wrapper_regress:playground|api_ok∧wrapper_fail|post_prompt_degrade|confidently_wrong|"worked_before_update";2_mem_contam:old_topic_leak|user_corr_overwritten|same_session_pseudo_fact|unbounded_growth;3_tool_disc_fail:"must use tool X"∈prompt_only∧skip|hallucinated_res|tool_overlap|wrong_call∨skip_must;4_render_corrupt:logs_ok≠user_out|md|json|stream_corrupt|silent_fallback_replace|term≠UI;5_hidden_layers:uncontracted(repair|retry|sum|recall)|invisible_2nd_LLM|uncoord_multi_agent|silent_smooth}
§WF{
P1_scope:{target,entrypoints,model_stack,symptoms,time_window,layers⊆1..12};
P2_evid:{src(loop,tool_router,mem_admit,prompt_asm),logs(OTel_GenAI∈{Langfuse,LangSmith},tool_records),cfg(prompt_tpl,tool_schema,provider),mem_files(SOP,KB,session_arch)};
P3_map:∀finding⇒{symptom,mechanism,source_layer∈1..12,root_cause,evidence(file:line|log:row),confidence∈[0.0,1.0]};
P4_fix(code_first,¬prompt_first):1.code_gate_tools→2.rm|narrow_hidden_repair(contracts)→3.dedup_ctx(prompt∧hist∧mem∧distill)→4.mem_admit(user_corr>agent_assert)→5.tighten_distill_trig→6.render_passthrough(¬mutate)→7.typed_json_envelopes(¬prose)
}
§CMD{
```bash
rg "must.*tool|必须.*工具|required.*call" --type md
rg "tool_call|toolCall|tool_use" --type py --type ts
rg "completion|chat\.create|messages\.create|llm\.invoke"
rg "memory.*admit|long.*term.*update|persist.*memory" --type py --type ts
rg "fallback|retry.*llm|repair.*prompt|re-?prompt" --type py --type ts
rg "mutate|rewrite.*response|transform.*output|shap" --type py --type ts
```
}
§SEV{critical:confidently_wrong_ops⇒pre_release;high:freq_degrade(correctness|stability)⇒this_sprint;medium:fragile|wasteful⇒next_cycle;low:cosmetic|maint⇒backlog}
§OUT{order:[severity_ranked(critical→low),arch_diag(layer,what,why),ordered_fix_plan(code_first)];¬compliments∧¬lead_sum;broken⇒state_directly}
§DIAG{1:skip_req_tool∧ans⇒¬code_gated;2:old_conv∈new_turn⇒mem_contam;3:same_info∈(prompt∧mem∧hist)⇒ctx_dup;4:2nd_LLM_pre_deliv⇒hidden_repair_loop;5:internal_out≠user_out⇒render_corrupt;6:"must use tool X"∈prompt_only⇒tool_disc_fail;7:agent_monologue→persist_mem⇒mem_poison}
§ANTI{¬blame_model≺falsify_wrapper;¬blame_mem¬contam_path;¬clean_now_erase_past;¬md_prose_protocol;¬accept_prompt_only_tool_req;direct∧evid_backed∧sev_ranked}
§SCHEMA{
```json
{"schema_version":"agent-architecture-audit.report.v1","executive_verdict":{"overall_health":"high_risk","primary_failure_mode":"string","most_urgent_fix":"string"},"scope":{"target_name":"string","model_stack":["string"],"layers_to_audit":["string"]},"findings":[{"severity":"critical|high|medium|low","title":"string","mechanism":"string","source_layer":"string","root_cause":"string","evidence_refs":["file:line"],"confidence":0.0,"recommended_fix":"string"}],"ordered_fix_plan":[{"order":1,"goal":"string","why_now":"string","expected_effect":"string"}]}
```
}
§REL{references/agent-introspection-debugging.md:runtime_fail(loops,timeouts,state);references/eval-harness.md:bench;references/agent-security-hardening.md:sec_audit;references/agent-harness-construction.md:build_harness}
