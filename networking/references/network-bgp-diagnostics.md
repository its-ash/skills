@REF:network-bgp-diagnostics
# BGP triage & modern security baseline (RFC 8212 default-deny eBGP, RPKI ROV RFC 6811/8210); read-only default; policy/reset⇒change window.
§D{use}
BGP∈{down,flapping,Est∧0_pfx,RPKI_drop,unexp_adv,pre/post_chg,parser_rev} | ro_def; pol|reset⇒chg_win
§PAT{triage_flow}
1:id(nbr,AF,VRF,loc/rem_ASN)→2:cap(summary,last_reset,RPKI_state)→3:reach(peer_src)→4:rt_pol(RFC8212,RPKI,pfx-list,rt-map)≺xport→5:cmp(adv,rcvd,inst)
VRF|IPv6|VPNv4|EVPN⇒explicit_AF_cmds(`show bgp ipv6 unicast summary`, `show bgp vpnv4 unicast vrf <v> summary`)∧¬glob_IPv4_ucast
§CMD{ro_triage}
show bgp ipv4 unicast summary | show bgp neighbors <peer> | show ip route <peer> | show tcp brief | include <peer>|:179
show logging | include BGP|<peer> | show running-config | section router bgp | show ip prefix-list | show route-map
§D{states}
Est+pfx⇒up→chk(pol,RIB,RPKI);
Est+0⇒chk(RFC8212_missing_eBGP_in/out_pol,in_pol_drop,RPKI_invalid,max-pfx,peer_adv,AFI/SAFI);
Active⇒TCP_incomplete→chk(rtg,update-source,eBGP_multihop/GTSM,ACL,reach);
Connect⇒TCP_in_progress→chk(path,rem_listen_179);
OpenSent|OpenConfirm⇒TCP_ok→chk(ASN,MD5/TCP-AO_auth,timers,caps,logs);
Idle⇒chk(shutdown,no_cfg,max-pfx_teardown,pol_blk,backoff)
§CMD{transport}
ping <peer> source <local-src> | traceroute <peer> source <local-src>
show bgp neighbors <peer> | include BGP state|Last reset|Local host|Foreign host
loopback_peering⇒bidir_route∧update-source∧ebgp-multihop; ¬disable(ACL|fw)→inspect(hits,logs,path)
§CFG{rfc8212_rpki}
# RFC 8212: eBGP MUST have explicit inbound & outbound policy (no silent permit-all)
# RPKI ROV (IOS-XE): connect RTR validator (Routinator/Fort/OctoRPKI on TCP 323|8282); DROP Invalid ONLY (permit Valid + NotFound)
router bgp 65001 / bgp rpki server tcp 10.0.0.50 port 8282 refresh 300
route-map RM-eBGP-IN deny 10 / match rpki invalid / route-map RM-eBGP-IN permit 20
# IOS-XE caveat: RPKI affects best-path by default; add `bgp bestpath prefix-validate disable` if enforcing strictly via route-map
§CMD{policy_rpki}
show bgp neighbors <peer> advertised-routes | show bgp neighbors <peer> routes | show ip prefix-list <name> | show route-map <name>
show ip bgp rpki servers | show ip bgp rpki table | show ip bgp ipv4 unicast <prefix/len> # origin codes: V=Valid, I=Invalid, blank=NotFound
show bgp regexp _65001_ | show bgp regexp ^65001$ # _65001_≡exact_AS; raw 65001⇒overmatches(165001,650010)
# `received-routes` requires `soft-reconfiguration inbound` (extra RAM)→¬enable_during_triage_wo_approval; prefer RFC 2918 Route-Refresh
§PAT{parser}
# Structured (TextFSM/Genie/NETCONF/BMP)≻regex; store raw alongside parsed. Regex below is IPv4-only (IPv6 wraps lines on IOS/IOS-XE⇒use TextFSM/Genie):
```python
import re;from typing import Any
BGP_SUMMARY_RE=re.compile(r"^(?P<neighbor>\d{1,3}(?:\.\d{1,3}){3})\s+(?P<version>\d+)\s+(?P<remote_as>\d+)\s+(?P<msg_rcvd>\d+)\s+(?P<msg_sent>\d+)\s+(?P<table_version>\d+)\s+(?P<input_queue>\d+)\s+(?P<output_queue>\d+)\s+(?P<uptime>\S+)\s+(?P<state_or_prefixes>\S+)$",re.M)
def parse_bgp_summary(raw:str)->list[dict[str,Any]]:return[{"neighbor":m.group("neighbor"),"remote_as":int(m.group("remote_as")),"state":"Established"if(v:=m.group("state_or_prefixes")).isdigit()else v,"prefixes_received":int(v)if v.isdigit()else None,"uptime":m.group("uptime")}for m in BGP_SUMMARY_RE.finditer(raw)]
```
§R{chg_win}
¬auto:{hard_clear_bgp,mod(auth,timers,update-source,route-map,prefix-list),enable_soft-reconfig,relax(fw,ACL,CoPP)}
approved_refresh⇒`clear ip bgp <peer> soft in` (Route-Refresh)∧doc; stalled_RTR⇒`clear ip bgp rpki server`
§ANTI
Active≡remote_down | drop_RPKI_NotFound | forget_RFC8212_on_Est_0_pfx | ignore(VRF,AFI/SAFI,update-source) | AS_regex_no_bounds | hard_reset≺(reset_reason∧logs) | no_received-routes≡0_advertised
§REL
[../SKILL.md](../SKILL.md) | [cisco-ios-patterns.md](cisco-ios-patterns.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md)
