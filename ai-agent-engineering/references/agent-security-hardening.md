@REF:agent-security-hardening
§R{untrusted∈{model_out,retrieved,tool_out,mem,cross_agent_msg};ext:default_read_only∧grant_write_sep;validate@action_boundary(even_if_upstream_prompt|schema_ok);fail_closed≺side_effect⇔¬proven(id|dest|owner|containment);irreversible(delete|publish|cred_rotate):real_entry_authz(principal,exact_op,res_scope)∧(confirm∨valid_scoped_preapproval),missing|invalid⇒block;bounds:gov_hard_bounds∧stricter(deploy_cfg),neither⇒mark_req_decision∧test_reject_unbounded(¬invent)}
§USE{in:{agent,tool_gw,mem_svc,a2a,model_out→cmd|path|URL|cred|API_mut,iso(tenant|proj|session|ws),harden(tmp|logs|tool_resp|ingest),prod|full_auto|migrate|deploy|data_Δ→Guard_Modes};¬use:{app_auth|SQLi|XSS|CSRF|API_sec→secure-coding/SKILL.md,repo_scan→secure-coding/references/web-vulnerability-testing.md,host|ctr|fw|cloud→devops-iac/SKILL.md,pentest|exploit|unauth⇒FORBIDDEN}}
§WF{
1_bounds:map(src→parser→validator→side_effect)∀{user_in,model_out,retrieved,mem,env,tool_res,agent_msg};record:{authz(id,scope),exact_val_pre,max_in_out,audit_evid,interrupt_rec};done⇔1_named_authz_bound/op;
2_id_env_url:{id:allowlist(fn|key|sel|arg),HARD_MAX_AGENT_ID_LENGTH=64(deploy_cfg≤64,¬raise),CLI_arg⇒argv_API∧after_`--`(char_val≠arg_sep);env:reject(None|ws_only)≺client_init;url:parse∧allow_req_schemes∧req_host∧¬embed_creds∧block_priv_net(if_attacker_ctrl)∧pin_or_verify_peer_addr@connect_∀hop(anti_DNS_rebind),cred_req⇒HTTPS+cert_verify≺attach,¬auto_cross_origin_cred_fwd,origin|scheme_Δ⇒strip_creds∧(reauthz∨reject),reval(dest,peer_addr,transport)∀hop;done⇔tests_reject(empty,oversized,malformed,traversal,cred_bearing,unauth_dest)∧prove_anti(DNS_rebind,cross_origin_cred_leak)};
3_fs:{reject_pre_join(abs,"..",Win_unsafe∈{CON,PRN,AUX,NUL,COM1-9¹²³,LPT1-9¹²³}(+ext),trailing("."|" "),":"_ADS);resolve(ws∧cand)∧prove_contain;symlink_race:open_rel_trusted_dirfd∧¬symlinks∧excl_create∧verify_post_open(owner,perms);done⇔tests(sibling_prefix,nested_..,abs,symlink_escape,reserved_dev,trailing_dot_space,ADS,valid_nested)};
4_tmp_creds:{file=0o600,dir=0o700,user_priv_runtime_dir≻shared_tmp,atomic_unpred_name(¬check_then_create),finally_cleanup(keep_redacted_err_on_fail),¬secrets∈{args,ctx,logs,traces,exc_text,tool_resp},secret_store|scoped_env_inj∧rotate_exposed,zeroize:best_effort(mut_buf_ok,immut_str_unreliable);done⇔tests(file_mode,forced_err_cleanup,log_cap_no_secret)};
5_tool_out:{bounded_byte_read(¬unbounded_stream),keep_struct∧strip_ctrl_chars∧trunc_marker(orig_bytes)∧forensic_hash?,malformed≠empty_ok⇒typed_fail(tool,bound,reason,¬echo_sens);done⇔determ_tests(oversized,bad_enc,ctrl_seq,malformed_struct,normal)}
}
§CODE{
```python
import re
from pathlib import Path
SAFE_AGENT_ID_CHARS=re.compile(r"^[A-Za-z0-9_][A-Za-z0-9_-]*$")
HARD_MAX_AGENT_ID_LENGTH=64
def require_agent_id(value:object,*,max_length:int)->str:
 if isinstance(max_length,bool) or not isinstance(max_length,int) or not 1<=max_length<=HARD_MAX_AGENT_ID_LENGTH:raise RuntimeError("configured agent ID limit must be between 1 and 64")
 if not isinstance(value,str) or len(value)>max_length or not SAFE_AGENT_ID_CHARS.fullmatch(value):raise ValueError("invalid agent identifier")
 return value
def require_env(name:str,environ:dict[str,str])->str:
 value=environ.get(name)
 if value is None or not value.strip():raise RuntimeError(f"{name} is required")
 return value
WINDOWS_RESERVED_NAME=re.compile(r"(CON|PRN|AUX|NUL|COM[1-9¹²³]|LPT[1-9¹²³])(\..*)?",re.IGNORECASE)
def workspace_path(workspace:Path,requested:str)->Path:
 relative=Path(requested.replace("\\","/"))
 if relative.is_absolute() or ".." in relative.parts:raise ValueError("path must be workspace-relative")
 for part in relative.parts:
  if ":" in part or part.endswith((".", " ")) or WINDOWS_RESERVED_NAME.fullmatch(part):raise ValueError("path component is not portable")
 root=workspace.resolve(strict=True)
 candidate=(root/relative).resolve(strict=False)
 if not candidate.is_relative_to(root):raise ValueError("path escapes workspace")
 return candidate
```
}
§GATE{real_entry:[1:untrusted_instr=data(¬tool|write),2:irreversible¬(op_res_authz∧(confirm|scoped_preapproval))⇒0_side_eff,3:cross_tenant|cross_ws_id_rejected@bound,4:traversal|symlink_escape⇒fs_unchanged,5:forced_fail⇒0_cred_tmp|logs,6:oversized|malformed_out⇒explicit_bounded_err];report:{cmd,exit_status,rejected_in,no_side_eff};mock_only≠proof(OS_perms,symlinks,subproc_iso,net_egress)}
§ISSUES{prompt_only_val⇒determ_code_pre_side_eff∧test_violating_model_out;prefix_escape(/work/app vs /work/application)⇒resolve∧comp_contain∧test_symlinks;post_log_redact⇒redact_pre(logger,tracer,exc,ctx)∧sentinel_cap_test}
§GUARD{advisory(¬enforced):careful(stop,explain,ask_confirm,safer_alt)⇐{`rm -rf`(esp `/`,`~`,root),`git push --force`,`git reset --hard`,`git checkout .`,`DROP TABLE`,`DROP DATABASE`,`docker system prune`,`kubectl delete`,`chmod 777`,`sudo rm`,`npm publish`,`--no-verify`};freeze:lock_edits→1_tree(e.g.`src/components/`)∧explain_outside;guard:careful∧freeze(e.g.write→`src/api/`,read_any)until_stopped;hard_enforce:Claude_Code_deny_rules(https://code.claude.com/docs/en/permissions,e.g.`Bash(rm -rf *)`)∨PreToolUse_hook(https://code.claude.com/docs/en/hooks);no_prompt_sess(e.g.`codex -a never`)⇒careful_on_default}
§REL{references/agent-harness-construction.md,references/mcp-dependency-review.md,references/enterprise-agent-ops.md}
