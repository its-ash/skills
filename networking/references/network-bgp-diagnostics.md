@REF:network-bgp-diagnostics
§USE{BGP∈{down,flapping,Est∧no_rts,unexp_adv,pre/post_chg,parser_rev}|ro_def;pol|reset⇒chg_win}
§FLOW{1:id(nbr,AF,VRF,loc/rem_ASN)→2:cap(summary,last_reset)→3:reach(peer_src)→4:rt_pol≺xport→5:cmp(adv,rcvd,inst)|VRF|IPv6|VPNv4|EVPN⇒plat_AF_cmds∧¬glob_IPv4_ucast}
§CMD[ro]{show bgp summary;show bgp neighbors <peer>;show ip route <peer>;show tcp brief | include <peer>|:179;show logging | include BGP|<peer>;show running-config | section router bgp;show ip prefix-list;show route-map}
§D[st]{Est+pfx⇒up→chk(pol,tbl);Est+0⇒chk(in_pol,max-pfx,adv,AFI/SAFI);Active⇒TCP_inc→chk(rtg,src,ACL,reach);Connect⇒TCP_prog→chk(path,rem_listen);OpenSent|OpenConfirm⇒TCP_ok→chk(ASN,auth,timers,caps,logs);Idle⇒chk(dis,no_cfg,pol_blk,backoff)}
§CMD[xp]{ping <peer> source <local-source>;traceroute <peer> source <local-source>;show bgp neighbors <peer> | include BGP state|Last reset|Local host|Foreign host|lo⇒bidir_rt∧update-source|¬dis(ACL|fw)→hits,logs,path}
§CMD[pol]{show bgp neighbors <peer> advertised-routes;show bgp neighbors <peer> routes;show ip prefix-list <name>;show route-map <name>;show bgp <prefix>|received-routes⇒may_req_cfg→¬add_triage_wo_appr}
§CMD[as]{show bgp regexp _65001_;show bgp regexp ^65001$;show bgp neighbors <peer> advertised-routes | include Network|Path|<prefix>|_65001_≡AS_65001;65001⇒overmatch}
§PAT[parser]{struct>raw∧store(raw,inc)(fmt_varies_plat×AF)
```python
import re;from typing import Any
BGP_SUMMARY_RE=re.compile(r"^(?P<neighbor>\d{1,3}(?:\.\d{1,3}){3})\s+(?P<version>\d+)\s+(?P<remote_as>\d+)\s+(?P<msg_rcvd>\d+)\s+(?P<msg_sent>\d+)\s+(?P<table_version>\d+)\s+(?P<input_queue>\d+)\s+(?P<output_queue>\d+)\s+(?P<uptime>\S+)\s+(?P<state_or_prefixes>\S+)$",re.M)
def parse_bgp_summary(raw:str)->list[dict[str,Any]]:return[{"neighbor":m.group("neighbor"),"remote_as":int(m.group("remote_as")),"state":"Established"if(v:=m.group("state_or_prefixes")).isdigit()else v,"prefixes_received":int(v)if v.isdigit()else None,"uptime":m.group("uptime")}for m in BGP_SUMMARY_RE.finditer(raw)]
```}
§R[chg_win]{¬auto:{clear_bgp,mod(auth,timers,update-source,route-map,prefix-list),add_rcvd_store,relax(fw,ACL,cp_pol)}|appr_reset⇒soft|route-refresh∧doc}
§ANTI{Active≡rem_down;ignore(VRF,AFI/SAFI,update-source);AS_re_no_bounds;hard_reset≺(reset_rsn∧logs);no_rcvd_rts≡0}
§REL{[cisco-ios-patterns.md](cisco-ios-patterns.md),[network-config-validation.md](network-config-validation.md),[network-interface-health.md](network-interface-health.md)}
