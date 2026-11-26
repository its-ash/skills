---
description: "Sync docs from SSOT files (scripts, env, routes, exports, infra)."
---
@CMD:update-docs
§SRC{
`package.json`∨`Makefile`∨`Cargo.toml`∨`pyproject.toml`⇒cmd_ref
`.env.example`∨`.env.template`∨`.env.sample`⇒env_docs
`openapi.yaml`∨routes⇒API_ref
src_exports⇒public_API_docs
`Dockerfile`∨`compose.yaml`⇒infra_docs
}
§FLOW{
1:scan(§SRC)
2:scripts→extract(cmds,desc)→table(`Command | Description`)
3:env→extract(vars,purpose)→classify(required/optional)∧doc(fmt,valid_vals)→table(`Variable | Required | Description | Example`)
4:upd(`docs/CONTRIBUTING.md`,{dev_setup(prereqs,install),scripts+purpose,test_proc(run,write),code_style(lint,fmt,pre-commit),PR_checklist})
5:upd(`docs/RUNBOOK.md`,{deploy_steps,health_checks+monitoring,common_issues+fixes,rollback,alerting+escalation})
6:stale→find(docs≥90d)→xref(recent_src_Δ)→flag(manual_review)
}
§R{
SSOT:gen_from_code∧¬manual_edit(gen_sections)
preserve:hand_written_prose∧only_upd(gen_sections)
mark:`<!-- AUTO-GENERATED -->`
¬create_new_docs_unprompted(only_if_cmd_explicit)
}
§OUT{
```text
Documentation Update
---
Updated: <path> (<what>)
Flagged: <path> (<N> days stale)
Skipped: <path> (no changes detected)
```
}
