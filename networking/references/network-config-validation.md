@REF:network-config-validation
# Pre-change & CI validation gate (IOS/IOS-XE snippets & generated configs): tiered shift-left checks (linter→Batfish→device diff).
§D{tiers}
T1_fast_gate⇒regex+block_linter(danger_cmds,dup_IP,overlap,VTY,SSH/SNMPv3_crypto,HTTP_UI)
T2_semantic_model⇒Batfish(offline_multi-dev_forwarding,ACL_reachability/shadow,BGP_policy,routing_loops)
T3_device_preview⇒IOS-XE `show archive config differences` + `configure terminal revert timer`
# Layered evidence≠complete_parser→always pair with eng review(intent,syntax,rollback)
§PAT{flow}
1:destructive_cmds→2:creds∧mgmt_crypto(SSH,SNMPv3,VTY,HTTP_UI)→3:dup_IP∧subnet_overlap→4:undef_refs(ACL,route-map,prefix-list,if)→5:rollback_readiness(archive)∧hygiene(NTP,ts,rem_log,banner)
§PAT{danger}
DANGEROUS_PATTERNS(re.I):`\breload\b`("downtime");`\berase\s+(startup|nvram|flash)`("erases persistent storage");`\bformat\b`("formats filesystem");`\bno\s+router\s+(bgp|ospf|eigrp)\b`("removes routing process");`\bno\s+interface\s+\S+`("removes interface cfg");`\baaa\s+new-model\b`("changes auth behavior");`\bcrypto\s+key\s+(zeroize|generate)\b`("changes SSH host keys")
fn:`find_dangerous_commands(lines:list[str])->list[dict[str,str|int]]`→`{line(1-based),command(strip),reason}`
§PAT{ip_overlap}
`IP_ADDRESS_RE=re.compile(r"^\s*ip address\s+(?P<ip>\d{1,3}(?:\.\d{1,3}){3})\s+(?P<mask>\d{1,3}(?:\.\d{1,3}){3})\b",re.I|re.M)`
fns:`extract_interfaces(config:str)->list[dict[str,str]]`(track `interface `hdr→`ipaddress.ip_interface(f"{ip}/{mask}").network`→`{interface,ip,network}`);`find_duplicate_ips(config:str)->list[str]`(`sorted` `Counter` `count>1`);`find_subnet_overlaps(config:str)->list[tuple[str,str]]`(pairwise `ip_network` `left.overlaps(right)`)
§PAT{vty_blocks}
# Block-scoped (¬cross-section regex):
`iter_blocks(config:str,starts_with:str)->list[str]`(start@`starts_with`,flush@non-empty line `not l.startswith(" ")`)
`check_vty_blocks(config:str)->list[str]`∀`line vty` blk:flag `transport\s+input\s+.*telnet`("require SSH only"),missing `\baccess-class\s+\S+\s+in\b`("no inbound VTY ACL"),missing `\bexec-timeout\s+\d+\s+\d+\b`("no exec-timeout"),missing `\btransport\s+output\s+none\b`("restrict outbound jump from VTY")
§PAT{sec_hyg}
SECURITY_PATTERNS(re.I)→`check_security(config:str)->list[str]`:
`\bsnmp-server community\s+(public|private)\b`("default SNMP community")
`\bsnmp-server community\s+\S+`("SNMPv2c community; use SNMPv3 authPriv SHA256+AES")
`\bsnmp-server user\s+\S+\s+\S+\s+v3\s+auth\s+(md5|sha\b)`("weak SNMPv3 auth; use sha256")
`\bip ssh version 1\b`("SSHv1 enabled")
`\bip ssh server algorithm\b.*\b(hmac-sha1|cbc|3des|diffie-hellman-group1-sha1|ssh-rsa)\b`("weak SSH algo; enforce SHA2+CTR/GCM")
`\bip http (secure-)?server\b`("unneeded IOS-XE WebUI CVE surface; disable unless scoped")
`\benable password\b`("weak enable password; use enable secret Type 8/9")
`\busername\s+\S+\s+password\b`("local user uses password/Type-7; use secret")
BEST_PRACTICE_PATTERNS(re.I)→`check_missing_hygiene(config:str)->list[str]`:
`\bntp server\b`("NTP") | `\bservice timestamps\b`("log timestamps") | `\blogging\s+\S+`("syslog/buffer") | `\bsnmp-server group\s+\S+\s+v3\s+priv\b`("SNMPv3 authPriv") | `\barchive\b`("config archive rollback") | `\bbanner\s+(login|motd)\b`("login banner")
§CHK{pre_push}
chg_win:1:danger(snip)→2:dup_IP∧overlap(full_cand)→3:exists(ACL,rt_map,pfx)→4:Batfish(if_multi-dev/ACL/BGP)→5:archive+revert_timer+OOB≺mgmt_Δ
auto_gate:fail_closed(danger|weak_cred|exposed_HTTP_UI)∧warn(out_of_scope_hygiene)≺(Netmiko|Scrapli|Nornir|Ansible|API)
§ANTI
regex≡full_parser | apply_no_dry_diff | allow_SNMPv2c/MD5/SHA1 | leave_ip_http_server_on | VTY_regex_spanning_blocks | disable_ACL_dbg≠hits/logs
§REL
[../SKILL.md](../SKILL.md) | [cisco-ios-patterns.md](cisco-ios-patterns.md) | [netmiko-ssh-automation.md](netmiko-ssh-automation.md) | [network-interface-health.md](network-interface-health.md) | [network-bgp-diagnostics.md](network-bgp-diagnostics.md)
