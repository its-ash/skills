@REF:network-interface-health
§USE{pkt_loss,lat_spike,flaky_reach,CRCs,runts,giants,drops,resets,flaps,both_ends≺HW_swap,chg_pre/post,rising(ifInErrors,ifOutErrors,ifOutDiscards)}
§R{trend>abs⇒base→wait(iv)→post→cmp(Δ)}
§CMD{IOS:show interfaces <interface>;show interfaces <interface> status;show logging | include <interface>|changed state|line protocol;show interfaces <interface> | include duplex|speed|Linux:ip -s link show <interface>;ethtool <interface>;ethtool -S <interface>}
§CNT{CRC:RX_csum⇐cable|fiber|optic|dup_mis;in_err:agg_RX⇒subcnt;runts:<min_Eth⇐dup_mis|coll|NIC;giants:>MTU⇐MTU|jumbo;in_drops:RX_drop⇐burst|oversub|CPU|q;out_drops:TX_drop⇐cong|QoS|uplink;resets:HW_rst⇐flap|ka|drv|optic|pwr;collisions:Eth_coll⇐half_dup|neg}
§DIAG{CRC|in_err:1:inc(¬hist)→2:both_ends(RX⇒in_sig)→3:swap(cable|fiber|optic)→4:match(spd,dup)_both→5:logs(flap@ts);drops:1:sep(in,out)→2:rate_vs_cap→3:QoS,q_cnt,oversub_up→4:cong_1st(q_tune=2nd);dup_spd:auto-neg_both;fixed⇒both+doc;¬mix(fixed,auto)}
§PAT[parser]{slice(hdr→next_hdr)(¬char_win⇒no_miss/misassign)
```python
import re;from typing import Any
HEADER_RE=re.compile(r"^(?P<name>\S+) is (?P<status>(?:administratively )?down|up), line protocol is (?P<protocol>up|down)",re.I|re.M)
ERROR_RE=re.compile(r"(?P<input>\d+) input errors, (?P<crc>\d+) CRC",re.I);DROP_RE=re.compile(r"(?P<output>\d+) output errors",re.I);DUPLEX_RE=re.compile(r"(?P<duplex>Full|Half|Auto)-duplex,\s+(?P<speed>[^,]+)",re.I)
def parse_show_interfaces(raw:str)->list[dict[str,Any]]:
  hs=list(HEADER_RE.finditer(raw))
  return[{"name":h.group("name"),"status":h.group("status"),"protocol":h.group("protocol"),"duplex":dx.group("duplex")if dx else"unknown","speed":dx.group("speed").strip()if dx else"unknown","input_errors":int(e.group("input"))if e else 0,"crc_errors":int(e.group("crc"))if e else 0,"output_errors":int(d.group("output"))if d else 0}for i,h in enumerate(hs)for b in[raw[h.start():(hs[i+1].start()if i+1<len(hs)else len(raw))]]for e,d,dx in[(ERROR_RE.search(b),DROP_RE.search(b),DUPLEX_RE.search(b))]]
```}
§PB{CRC_1p:cap(loc,rem)→swap(cable|optic)≺(rtg|ACL)→clr_ONLY_post_base→rechk@iv;WAN_slow_LAN_ok:chk_WAN(drops,err)→chk_LAN_up(util,out_drops)→chk_gw_CPU(WAN_ok∧low_tput)→wired_vs_wifi≺ISP}
§ANTI{clr_cnt≺base;1_side;hist_CRC≡active;mix(auto,fixed);out_drops≡cable≺cong}
§REL{[network-config-validation.md](network-config-validation.md),[cisco-ios-patterns.md](cisco-ios-patterns.md),[../SKILL.md](../SKILL.md)}
