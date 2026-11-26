@REF:team-agent-orchestration
§WHEN{
  multi∈{agents,tools,harnesses,branches,worktrees};
  kw∈{team_orchestration,agent_Kanban,squad,conductor,control_pane,tmux,dmux,Zellij,Codex,Claude_Code,"run in parallel","split this work","use dmux"};
  shared_state(people+agents)∨fan_out_¬mergeable;
  ref:{[parallel-execution-optimizer.md](parallel-execution-optimizer.md)(dep_graph+lane_matrix),[blueprint.md](blueprint.md)(multi_PR)}
}
§MODEL{contract:{Owner,Scope(files,branch,tools,forbidden),State(backlog|ready|running|review|blocked|merged|archived),Evidence(tests,screenshots,logs,notes,evals),MergeGate}}
§KANBAN{
  Backlog:unshaped|exit:acceptance_written;
  Ready:assignable|exit:owner+branch/wt;
  Running:active|exit:handoff+changed_files;
  Review:done_unmerged|exit:tests+diff+risk_pass;
  Blocked:ext_wait/fail_gate|exit:owner+next_act;
  Merged:integrated|exit:PR_merged|main_upd;
  Archived:obsolete|exit:reason;
  card:```json
{"id":"agent-card-001","title":"Build dynamic workflow skill","owner":"codex","state":"running","branch":"feature/dynamic-workflow","worktree":".","acceptance":["Skill exists","Tests cover required concepts"],"merge_gate":"lint, focused tests, and catalog check pass","handoff":"path/to/handoff.md"}
```
}
§FLOW{
  1_Shape:cards(owners+gates)→2_Mode(single|subagents|tmux/dmux|wt_fanout|desktop)→3_Bounds(1_owner/card,distinct_files,¬overlap_wo_integrator)→4_Run(evidence+handoff,¬code_only)→5_RevSeq(tests→diff→sec/risk→polish)→6_Merge(1_integrator+upd_ctrl)→7_Promote(repeat→shared_skill);
  local_harness:{under_owner,in/out_on_card,eval_req(Running→Review),promote_on_repeat}
}
§CTRL{
  show:{items+state,owner/harness/branch/wt/heartbeat,links(handoff,tests,shots,PR),blockers(owner+unblock),gate_readiness(¬vibes),skill_cands};
  gate:¬automate_until_known(owner,delta,failed_gate,safe_merge)
}
§PANES{
  dmux(`https://github.com/standardagents/dmux`):3rd_party_tmux_mgr(Claude_Code,Codex,OpenCode,Cline,Gemini,Qwen)[vet_first];keys:`n`(new+prompt),`m`(merge);
  pat:{res_impl:P1→file+P2_build→merge;multi_file:schema/API/UI→main;test_fix:watcher→fixer;cross_harness:Claude_sec+Codex_refac;rev_pipe:sec/perf/cov→report};
  wt:`git worktree add -b feat/auth ../feature-auth HEAD` ... `git merge feat/auth`;
  layout:1_branch_wt/worker+`.orchestration/<session>/{task.md,handoff.md,status.md}`+1_tmux_pane/worker+free_main_orch;
  rules:{indep_only,distinct_files,rev_pre_merge,wt_on_overlap,panes<5-6};
  fix:{hung⇒switch|`tmux capture-pane -pt <session>:0.<pane-index>`,conflicts⇒wt,tokens⇒<panes,no_tmux⇒`brew install tmux`|`apt install tmux`}
}
§FAIL{agent_soup(¬owner/gate);invisible(chat_only);board_theater(¬acceptance);overlap_writes(¬wt);no_artifact(docs_only)}
§OUT{board_deltas,branches(merged/pending),tests+evals,blockers(owner+act),skill_cands}
