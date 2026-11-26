@REF:blueprint
§CORE{role:1-line_obj→cold_exec_plan(multi_session|PR|agent);src:antbotlab/blueprint;out:`plans/<project>-<objective-slug>.md`}
§D{use⇒dep_PRs|multi_session_refactor/mig|parallel_subagents|ctx_loss_risk;¬use⇒1PR|<3_tool_calls|"just do it"}
§PIPE{
  1_Research:preflight(`git`,`gh auth`,remote,default_branch)→read(struct,plans,mem);
  2_Design:1PR_steps(3-12_typ)→set(deps,par/ser,tier:`strongest`|`default`,rollback/step);
  3_Draft:write`out`∀step(ctx_brief,tasks,verify_cmds,exit⇒cold_exec_w/o_prior);
  4_Review:`strongest`_subagent_audit(completeness,deps,anti_patterns)→fix∀critical;
  5_Register:save→upd_mem_idx→summary(step_count,parallelism);
  vcs:(`git`+`gh`⇒branch/PR/CI)⊕(¬`git`|¬`gh`⇒direct_in_place,¬branches)
}
§TPL{
```markdown
### Step N: <title>
- Depends on: <step ids or none>   Parallel with: <step ids or none>
- Model tier: strongest | default
- Branch: <branch name>            Rollback: <how to revert>

**Context brief:** <goal, files, invariants, decisions so far>
**Tasks:**
1. ...
**Verification:** `<commands>`
**Exit criteria:** <observable conditions; invariants still hold>
```
}
§PAT{cold_start:ctx_brief/step;gate:adversarial_`strongest`_subagent;par_detect:DAG(disjoint_files∧outputs);mutate:{split,insert,skip,reorder,abandon}⇒log(Δ+reason)in_audit_trail}
§EX{
  "migrate database to PostgreSQL"→`plans/myapp-migrate-database-to-postgresql.md`[1:PG_driver+conn_cfg,2:table_migrations,3:repo_layer,4:PG_integ_tests,5:rm_old_db+cfg];
  "extract LLM providers into a plugin system"→[interface(`strongest`)→par(Anthropic,OpenAI;`default`)],inv:("all existing tests pass","no provider imports in core")
}
