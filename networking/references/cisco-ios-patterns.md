@REF:cisco-ios-patterns
# Cisco IOS / IOS-XE (17.15/17.18 LTS): modes, read-only show, archive+revert_timer rollback, wildcard ACLs, SSH/SNMPv3 hardening.
§D{use}
IOS/IOS-XE_rev | chg_win | ro_triage | ACL_wc/dir | modes(glob/if/rtg/line) | archive_revert_rb | mgmt_hardening
§R{workflow}
patterns≠prod⇒chk(plat,IOS-XE_ver,if,curr,rb,OOB)≺apply
wf:1:ro_evidence→2:archive_snapshot→3:revert_timer(configure_terminal_revert_timer_5)→4:minΔ∈maint→5:show_archive_config_differences∧verify→6:configure_confirm→7:copy_running-config_startup-config
running=RAM; startup=NVRAM(reload); ¬save_until_verified
§CFG{modes}
Router>enable→Router#show running-config|configure terminal revert timer 5→(config)#interface GigabitEthernet0/1→(config-if)#description UPLINK-TO-CORE|no shutdown|exit→end→show archive config differences nvram:startup-config system:running-config→configure confirm
§CFG{archive_rb}
# Prerequisite on IOS-XE 17.x for non-disruptive atomic rollback (replaces crude `reload in`):
archive / path bootflash:cfg-archive / maximum 10 / time-period 1440
# Timed live edit: `configure terminal revert timer 5` → validate → `configure confirm` (or manual abort: `configure revert now`)
# Atomic file rollback: `configure replace bootflash:cfg-archive-1 time 5` → validate → `configure confirm`
§CMD{ro_audit}
# Read-only; sanitize secrets/customer/topo before sharing:
show version | show inventory | show processes cpu sorted | show memory statistics | show logging
show running-config | section line vty | show running-config | section interface | show running-config | section router bgp
show ip interface brief | show interfaces | show interfaces status | show interfaces transceiver detail
show vlan brief | show mac address-table | show spanning-tree | show ip route | show ip protocols
show ip access-lists | show route-map | show ip prefix-list | show archive | show archive config differences
§CFG{wildcard}
# ACL/routing uses wildcard≠subnet_mask (subnet⇒overmatch); implicit_deny@end; explicit `deny ip any any log` if obs∧log-rate-safe:
255.255.255.255⇔0.0.0.0 | 255.255.255.252⇔0.0.0.3 | 255.255.255.0⇔0.0.0.255 | 255.255.0.0⇔0.0.255.255
ip access-list extended WEB-IN / 10 permit tcp 192.0.2.0 0.0.0.255 any eq 443 / 999 deny ip any any log
§CHK{acl}
dir∈{in,out} | mgmt∈jump/mgmt_subnet | permit(rtg,DNS,NTP,mon,app) | verify_hits(test_src≠ping) | revert_timer+OOB/con | ¬rm_ACL_to_dbg⇒read(hits,logs,routes)
§CFG{if_hygiene}
interface GigabitEthernet0/1 / description UPLINK-TO-CORE / switchport mode trunk / switchport trunk allowed vlan 10,20,30 / switchport trunk native vlan 999 / no shutdown
routed_if:chk(mask,peer,ARP,rtg)≺assume(up/up⇒forwarding)
§CFG{harden_iosxe}
# Modern IOS-XE 17.x crypto baseline (drop SHA-1, MD5, CBC, 3DES, Telnet, HTTP UI):
SSH:crypto key generate rsa modulus 4096 | ip ssh version 2 | ip ssh dh-min-size 2048 | ip ssh server algorithm encryption aes128-ctr aes256-ctr aes128-gcm@openssh.com aes256-gcm@openssh.com | ip ssh server algorithm mac hmac-sha2-256 hmac-sha2-512 hmac-sha2-256-etm@openssh.com hmac-sha2-512-etm@openssh.com | ip ssh server algorithm hostkey rsa-sha2-256 rsa-sha2-512 ecdsa-sha2-nistp256 | ip ssh server algorithm kex curve25519-sha256@libssh.org ecdh-sha2-nistp256 ecdh-sha2-nistp384
SNMPv3:snmp-server view MON 1.3.6.1.2.1 included | snmp-server group MON-GRP v3 priv read MON access-class NMS-HOSTS | snmp-server user nms MON-GRP v3 auth sha256 <AUTH> priv aes 128 <PRIV>
VTY+UI:line vty 0 15 / transport input ssh / transport output none / exec-timeout 10 0 / access-class ACL-MGMT in / logging synchronous | no ip http server | no ip http secure-server
§CMD{verify}
show archive config differences nvram:startup-config system:running-config | show running-config | section interface GigabitEthernet0/1 | show interfaces GigabitEthernet0/1 | show logging | include GigabitEthernet0/1|changed state|line protocol | show ip route <prefix> | show ip access-lists <name>
rtgΔ⇒pre/post(nbr,routes); ACLΔ⇒hits(test_src≠ping)
§ANTI
no_diff_apply | save≺verify | omit_revert_timer_remote_Δ | subnet_as_wildcard | wrong_ACL_dir | disable(ACL|rt_pol|auth)_to_dbg | SSHv1/SHA1/CBC | SNMPv2c/MD5 | exposed_ip_http_server | paste_raw_cfg
§REL
[../SKILL.md](../SKILL.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md) | [network-bgp-diagnostics.md](network-bgp-diagnostics.md) | [netmiko-ssh-automation.md](netmiko-ssh-automation.md)
