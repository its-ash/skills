@REF:cisco-ios-patterns
§USE{IOS/XE_rev|chg_win|ro|ACL_wc/dir|modes(glob/if/rtg/line)|run_vs_start}
§R{patterns≠prod⇒chk(plat,if,curr,rb,OOB)≺apply;wf:1:ro→2:cand→3:¬lock→4:minΔ∈maint→5:cmp∧val≺copy running-config startup-config;running=mem;startup=reload;¬save_on_ok}
§MODES{Router>enable→Router#show running-config|configure terminal→(config)#interface GigabitEthernet0/1→(config-if)#description UPLINK-TO-CORE|no shutdown|exit→end→show running-config interface GigabitEthernet0/1}
§CMD[ro,sec_only,¬secrets/cust/topo]{show version;show inventory;show processes cpu sorted;show memory statistics;show logging;show running-config | section line vty;show running-config | section interface;show running-config | section router bgp;show ip interface brief;show interfaces;show interfaces status;show vlan brief;show mac address-table;show spanning-tree;show ip route;show ip protocols;show ip access-lists;show route-map;show ip prefix-list}
§WILDCARD{ACL/rtg=wc≠sub(sub⇒overmatch):255.255.255.255⇔0.0.0.0;255.255.255.252⇔0.0.0.3;255.255.255.0⇔0.0.0.255;255.255.0.0⇔0.0.255.255;imp_deny;add_deny ip any any log_if_obs∧log_safe;ip access-list extended WEB-IN/10 permit tcp 192.0.2.0 0.0.0.255 any eq 443/999 deny ip any any log}
§CHK[ACL]{dir∈{in,out};mgmt∈jump/mgmt;permit(rtg,DNS,NTP,mon,app);hits(test_src);rb+OOB/con;¬rm_ACL⇒read(hits,logs,routes)}
§IF_HYG{interface GigabitEthernet0/1:description UPLINK-TO-CORE;switchport mode trunk;switchport trunk allowed vlan 10,20,30;switchport trunk native vlan 999;no shutdown;routed:chk(mask,peer,rtg)≺assume(up⇒fwd)}
§VERIFY{show running-config | section interface GigabitEthernet0/1;show interfaces GigabitEthernet0/1;show logging | include GigabitEthernet0/1|changed state|line protocol;show ip route <prefix>;show ip access-lists <name>;rtgΔ⇒pre/post(nbr,routes);ACLΔ⇒hits(test_src≠ping)}
§ANTI{no_diff_apply;save≺post;sub_as_wc;bad_dir;dis(ACL|rt_pol|auth)_dbg;paste_raw_cfg}
§REL{[network-config-validation.md](network-config-validation.md),[network-interface-health.md](network-interface-health.md),[network-bgp-diagnostics.md](network-bgp-diagnostics.md),[netmiko-ssh-automation.md](netmiko-ssh-automation.md)}
