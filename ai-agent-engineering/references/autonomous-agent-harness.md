@REF:autonomous-agent-harness
§CORE{
  role:ClaudeCode_autonomous_harness(persistent_mem+crons+computer_use+task_queue);
  scope:setup_pattern(¬bundled_always_on_runtime);replaces:{Hermes,AutoGPT}
}
§R{
  consent:explicit_user_req∧approval(capability∧target_ws)req∀{schedule,remote_dispatch,mem_write,computer_use,ext_post,3p_mod,priv_comms};
  dry_run:prefer(dry_run_plan∧local_queue_file)before(recurring|event_driven);
  hygiene:exclude{creds,priv_ws_exports,personal_datasets,acct_automations}from(shared_artifacts);
  pkg_sec:¬register(guessed|unpublished_npm_pkg)∵`npx -y`execs_future_pub;verify(pkg∧publisher∧ver);sched+comp_use¬need(3_prev_unpublished_pkgs);
  session_scope:native_cron=shares_interactive_session;ext_sched=new_session_unless_explicit_resume;
  limits:comp_use_needs_explicit_perms(¬assume);cli_auto_consumes_usage+provider_limits⇒pick_safe_intervals;
  mem_bound:keep_concise∧archive_old(¬unbounded_growth);
  verify:always_check_cron_success∧add_err_handling_to_cron_prompts
}
§WHEN{
  continuous|scheduled_agent;periodic_workflows;cross_session_assistant;prompts∈{"run this every day","check on this regularly","keep monitoring"};replace:{Hermes,AutoGPT};comp_use+cron
}
§ARCH{
  runtime:{Crons/Schedule,Dispatch/Remote,MemoryStore,ComputerUse}→layer1:{skills/,agents/,commands/,hooks/}→mcp:{memory,github,exa,supabase,browser-use}
}
§PAT{
  mem:{
    short:TodoWrite(in_session);
    med:~/.claude/projects/*/memory/*.md(frontmatter;user_prefs,feedback,proj_ctx;auto_load_start);
    long:mcp_memory_kg({mcp__memory__create_entities,mcp__memory__create_relations,mcp__memory__add_observations};entities,relations,observations;cross_session)
  };
  cron:{
    native:[scheduled tasks](https://code.claude.com/docs/en/scheduled-tasks)(session_scoped;no_mcp_for_/loop)⇒`/loop 30m Review open PRs in this repository and summarize CI failures.`;
    headless:`cd "/path/to/repo" && claude -p "Review open PRs and summarize"`(via_OS_cron|CI_sched;cfg_auth+tool_perms_sep);
    exprs:{standup:`0 9 * * 1-5`(PRs,issues,deploy);weekly:`0 10 * * 1`(quality,cov);hourly:`0 * * * *`(prod_health,err_rate);nightly:`0 2 * * *`(full_tests,sec_scan);pre_mtg:`*/30 * * * *`(mtg_ctx)}
  };
  dispatch:{
    entrypoint:[programmatic CLI mode](https://code.claude.com/docs/en/headless)(CI_job|webhook_receiver→`claude -p`in_owned_ws;¬public_Anthropic_dispatch_endpoint);
    ci:`cd "/path/to/repo" && claude -p "Build failed on main. Diagnose the failure."`;
    webhook:GH_webhook→auth_CI_runner→`claude -p`→reviewable_result;
    agent2agent:`claude -p "Analyze the output of the security scan and create issues for findings"`
  };
  computer_use:{
    req:[computer-use tool and reference environment](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool)(sep_cfg_app_in_isolated_desktop;MCP_pkg_name_alone=insufficient);
    caps:{browser(nav,click,forms,screenshot),desktop(apps,type,mouse),non_cli_fs};
    use:{web_UI_test,form_entry,screenshot_mon,multi_app}
  };
  task_queue:{
    path:~/.claude/projects/*/memory/task-queue.md;
    tpl:`---\nname: task-queue\ntype: project\ndescription: Persistent task queue for autonomous operation\n---\n## Active Tasks\n- [ ] PR #123: Review and approve if CI green\n- [ ] Monitor deploy: check /health every 30 min for 2 hours\n## Completed\n- [x] Daily standup: reviewed 3 PRs, 2 issues`
  }
}
§HERMES_MAP{
  Gateway/Router⇒CLI+ext_scheduler(auth_runner_starts_sessions);
  MemorySystem⇒Claude_mem+MCP_mem_srv(persistence+KG);
  ToolRegistry⇒MCP_servers(dynamic_providers);
  Orchestration⇒skills+agents;
  ComputerUse⇒sep_cfg_integration(isolated_browser|desktop);
  ContextManager⇒session_resume+mem_files;
  TaskQueue⇒TodoWrite+mem_files
}
§CFG{
  step1_mcp_opt:{
    pkg:`@modelcontextprotocol/server-memory@2026.8.31`([MCP reference memory server](https://github.com/modelcontextprotocol/servers/tree/main/src/memory);npm_verified:2026-09-07;ref_impl¬bundled);
    target:~/.claude.json(merge_preserving_existing;MEMORY_FILE_PATH=abs_private_path);
    docs:[Claude Code MCP configuration](https://code.claude.com/docs/en/mcp)(CLI_reg∧Windows`cmd /c npx`);
    json:```json
{"mcpServers":{"memory":{"command":"npx","args":["-y","@modelcontextprotocol/server-memory@2026.8.31"],"env":{"MEMORY_FILE_PATH":"/absolute/path/to/private/memory.jsonl"}}}}
```
  };
  step2_cron:interactive=`/loop 30m Review open PRs in this repository and summarize CI failures.`;persistent=OS_cron|GH_Actions→`claude -p`(note:`claude -p`req_sched¬provision_daemon;set_sched+ws+actions_explicitly);
  step3_init_kg:`claude -p "Create memory entities for: me (user profile), my projects, my key contacts. Add observations about current priorities."`;
  step4_comp_use_opt:follow_ref_env|reviewed_browser_int→min_perms→verify_harmless_in_isolated_env→schedule
}
§EX{
  pr_reviewer:`*/30`work_hrs→check_new_PRs→∀PR:(pull_branch→tests→code_reviewer→post_GH_MCP_comments)→upd_mem;
  research:`0 6 * * *`→read_saved_queries(mem)→Exa_search→summarize→diff_yesterday→write_digest(mem)→flag_high_pri;
  meeting_prep:`T-30m`→read_cal_event→search_mem(attendees)→pull_email/Slack→draft_talking_points+agenda→write_prep(mem)
}
