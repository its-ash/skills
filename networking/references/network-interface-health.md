@REF:network-interface-health
# Interface error, optical DOM, ring-drop & duplex triage (IOS/IOS-XE switches/routers + Linux hosts).
§D{use}
pkt_loss | lat_spike | flaky_reach | CRCs | runts | giants | drops | resets | flaps | optical_DOM | both_ends≺HW_swap | chg_pre/post | rising(ifInErrors,ifOutErrors,ifOutDiscards)
§R{baseline}
trend≻absolute_counter⇒capture_baseline→wait(interval)→capture_post→compare(Δ)
check_both_ends_of_link≺swap_HW; never_clear_counters_before_baseline
§CMD{collect}
IOS-XE:show interfaces <if> | show interfaces <if> status | show interfaces <if> transceiver detail | show logging | include <if>|changed state|line protocol | show interfaces <if> | include duplex|speed
Linux:ip -s -d link show <if> | ethtool <if> | ethtool -S <if> | ethtool -m <if> | ethtool -g <if> | ethtool --show-fec <if>
§CFG{counters}
CRC:RX_csum_fail⇐bad_cable|dirty_fiber|marginal_optic(chk_DOM_Rx_dBm)|duplex_mismatch
in_err:agg_RX_err⇒drill_subcounters(CRC,frame,overrun,ignored)
runts:<64B_Eth⇐duplex_mismatch|collision|faulty_NIC
giants:>MTU⇐MTU_mismatch|unconfigured_jumbo_frames
in_drops:RX_drop⇐microburst|oversub|CPU_CoPP|Linux_ring_buffer(`rx_missed_errors`,`rx_no_buffer_count`→chk `ethtool -g`)
out_drops:TX_drop⇐congestion|QoS_policer/shaper|oversubscribed_uplink(¬cable_fault_1st)
resets:HW_rst⇐link_flap|keepalive|driver|optic|power
collisions:Eth_coll⇐half_duplex|failed_auto_neg
FEC(25G/100G+):rising_uncorrected_FEC_codewords⇒degraded_optic/fiber/FEC_mode_mismatch
§PAT{diagnose}
CRC|in_err:1:confirm_increasing(¬historical)→2:check_both_ends(RX_err⇒upstream_TX/cable/optic)→3:check_DOM_Rx/Tx_dBm(`transceiver detail`/`ethtool -m`)→4:swap(patch_cable|clean_fiber|optic)→5:verify_speed/duplex/FEC_both_ends→6:correlate_flap_logs
drops:1:separate(in_vs_out)→2:rate_vs_link_cap→3:QoS,queue_depth,ring_buffer,uplink_oversub→4:fix_congestion_1st(queue/ring_tune=2nd)
duplex_speed:auto-neg_both_ends_default; fixed⇒both_ends+documented; ¬mix(fixed,auto)
§PAT{parser}
# Slice header→next_header (¬fixed char window⇒no missed/misassigned counters):
```python
import re;from typing import Any
HEADER_RE=re.compile(r"^(?P<name>\S+) is (?P<status>(?:administratively )?down|up), line protocol is (?P<protocol>up|down)",re.I|re.M)
ERROR_RE=re.compile(r"(?P<input>\d+) input errors, (?P<crc>\d+) CRC",re.I);DROP_RE=re.compile(r"(?P<output>\d+) output errors",re.I);DUPLEX_RE=re.compile(r"(?P<duplex>Full|Half|Auto)-duplex,\s+(?P<speed>[^,]+)",re.I)
def parse_show_interfaces(raw:str)->list[dict[str,Any]]:
  hs=list(HEADER_RE.finditer(raw))
  return[{"name":h.group("name"),"status":h.group("status"),"protocol":h.group("protocol"),"duplex":dx.group("duplex")if dx else"unknown","speed":dx.group("speed").strip()if dx else"unknown","input_errors":int(e.group("input"))if e else 0,"crc_errors":int(e.group("crc"))if e else 0,"output_errors":int(d.group("output"))if d else 0}for i,h in enumerate(hs)for b in[raw[h.start():(hs[i+1].start()if i+1<len(hs)else len(raw))]]for e,d,dx in[(ERROR_RE.search(b),DROP_RE.search(b),DUPLEX_RE.search(b))]]
```
§PAT{playbooks}
CRC_1_port:cap(local,remote,DOM)→swap(cable|clean_fiber|optic)≺(routing|ACL)→clear_ONLY_post_baseline→recheck@interval
WAN_slow_LAN_ok:chk_WAN(drops,err,MTU/MSS)→chk_LAN_uplink(util,out_drops)→chk_gw_CPU(WAN_clean∧low_tput)→wired_test_vs_WiFi≺ISP_ticket
§ANTI
clear_counters≺baseline | inspect_1_side_only | historical_CRC≡active_fault | skip_DOM_on_fiber_CRC | mix(auto,fixed) | blame_cable_for_out_drops≺congestion
§REL
[../SKILL.md](../SKILL.md) | [network-config-validation.md](network-config-validation.md) | [cisco-ios-patterns.md](cisco-ios-patterns.md) | [network-bgp-diagnostics.md](network-bgp-diagnostics.md)
