@REF:netmiko-ssh-automation
# Python Netmiko SSH: default=read-only `show` audit; cfg Δ requires maint_window, peer_review, rollback.
§R{safety}
default≡READ_ONLY(`send_command()`); inventory=small+explicit(¬CIDR_sweep; ex=192.0.2.10; real∈ignored_file∨secrets); creds∈{env,vault,getpass}(¬hardcode,¬log/exc,¬log_unsanitized_cfg); set_timeouts; bound_concurrency(AAA/dev_limit); `send_config_set()` behind explicit_flag+dry_run; `save_config()`=separate_approval post_verify
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
`ThreadPoolExecutor(max_workers=8)`+`as_completed` (keep max_workers low per estate/AAA); `read_timeout=45`; per-host `{"host":h,"ok":True,"output":out}|{"host":h,"ok":False,"error":type(e).__name__}` (¬abort_batch)
§PAT{parsing}
`parsed=c.send_command("show ip interface brief",use_textfsm=True,raise_parsing_error=False,read_timeout=30)` (or TTP/Genie); `isinstance(parsed,str)`⇒no_match→store_raw; keep raw on blocking decisions
§PAT{guarded_cfg}
`os.environ.get("APPLY_NETWORK_CHANGES")=="1"` (false⇒dry_run; true⇒`c.enable()`, `before=c.send_command("show running-config interface GigabitEthernet0/1")`, `c.send_config_set(cmds)`, `after=c.send_command(...)`, verify pre-`save_config()`; prod: rollback+before/after evidence)
§CHK{review}
explicit_inventory | ¬creds∈{src,logs,exc} | timeouts(conn,auth,read) | per_dev_err(¬abort) | ¬CIDR∧bounded_concurrency | cfg_Δ_dry_run/flag | `save_config()`_post_verify
§ANTI
hardcode({pw,secret,privkey}) | default_cfg_push | CIDR_scan | log_unsanitized_cfg | parser_ok≡state_ok
§REL
[cisco-ios-patterns.md](cisco-ios-patterns.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md)
