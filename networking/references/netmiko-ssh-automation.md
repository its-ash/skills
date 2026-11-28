@REF:netmiko-ssh-automation
# Python network automation (Netmiko 4.x/4.8.x, Scrapli, Nornir, Batfish): default=read-only `show` audit; cfg Δ requires shift-left check, maint_window, archive rollback.
§D{tools}
multi_vendor_sync_SSH⇒Netmiko_4.8+(ConnectHandler,TextFSM/Genie)
high_perf_async_SSH_NETCONF⇒Scrapli(asyncssh|system_ssh)
fleet_scale_orchestration⇒Nornir(inventory+Netmiko/Scrapli_tasks)¬ad_hoc_threads_at_scale
pre_deploy_static_verify⇒Batfish(model_ACLs,routing,reachability)≺push
YANG_capable(IOS-XE_17+,NX-OS,EOS,JunOS)⇒NETCONF|RESTCONF|gNMI≻CLI_scraping
§R{safety}
default≡READ_ONLY(`send_command()`)
inventory=small+explicit(¬CIDR_sweep; doc_ex=192.0.2.10; prod∈ignored_inventory∨NetBox/Nautobot)
creds∈{env,vault,getpass}(¬hardcode,¬log/exc,¬log_unsanitized_cfg)
always_set_timeouts(conn,auth,banner,read_timeout_override)∧bound_concurrency(AAA/dev_limit)
`send_config_set()` behind explicit_flag+dry_run+Batfish_pass; `save_config()`=separate_approval post_verify
§PAT{readonly}
```python
import os; from getpass import getpass; from netmiko import ConnectHandler
from netmiko.exceptions import NetmikoAuthenticationException, NetmikoTimeoutException, ReadTimeout
dev={"device_type":"cisco_ios","host":"192.0.2.10","username":os.environ.get("NETMIKO_USERNAME") or input("User:"),"password":os.environ.get("NETMIKO_PASSWORD") or getpass(),"secret":os.environ.get("NETMIKO_ENABLE_SECRET"),"conn_timeout":10,"auth_timeout":20,"banner_timeout":15,"read_timeout_override":30}
try:
    with ConnectHandler(**dev) as c:
        if dev.get("secret") and not c.check_enable_mode(): c.enable()
        print(c.send_command("show ip interface brief", read_timeout=30))
except (NetmikoAuthenticationException, NetmikoTimeoutException, ReadTimeout) as e: print(type(e).__name__)
```
§PAT{batch}
small_batch:`ThreadPoolExecutor(max_workers=8)`+`as_completed` (low max_workers per AAA limit; fleet⇒Nornir); `read_timeout=45`; per-host `{"host":h,"ok":True,"output":out}|{"host":h,"ok":False,"error":type(e).__name__}` (¬abort_batch)
§PAT{parsing}
`parsed=c.send_command("show ip interface brief",use_textfsm=True,raise_parsing_error=False,read_timeout=30)` (or `use_genie=True` / TTP); `isinstance(parsed,str)`⇒template_miss→store_raw; keep raw on blocking decisions
§PAT{guarded_cfg}
# Shift-left: Batfish_validate(candidate) → gate `os.environ.get("APPLY_NETWORK_CHANGES")=="1"` (false⇒dry_run)
# Live IOS-XE 17.x apply: `c.enable()` → `c.send_command("archive config")` (snapshot) → `before=c.send_command("show running-config interface GigabitEthernet0/1")` → `c.send_config_set(cmds)` → `diff=c.send_command("show archive config differences nvram:startup-config system:running-config")` → post_verify; on_fail⇒`c.send_command("configure replace <archive_file> force")` (or timed `configure replace ... time 5`+`configure confirm`); `c.save_config()` ONLY post_verify
§CHK{review}
explicit_inventory | ¬creds∈{src,logs,exc} | timeouts(conn,auth,read) | per_dev_err(¬abort) | ¬CIDR∧bounded_concurrency | Batfish/linter_pre_gate | archive_snapshot+rollback | cfg_Δ_dry_run/flag | `save_config()`_post_verify
§ANTI
hardcode({pw,secret,privkey}) | default_cfg_push | push_without_archive_rollback | CIDR_scan | log_unsanitized_cfg | parser_ok≡state_ok
§REL
[../SKILL.md](../SKILL.md) | [cisco-ios-patterns.md](cisco-ios-patterns.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md)
