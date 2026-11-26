@REF:homelab-network-readiness
# Plan/review gate for homelab Δ(VLANs,Pi-hole/DNS,FW,VPN). ¬emit copy-paste cfg unless {platform,topology,rollback,console_access,maint_window} known.
§D{use}
split_flat→{trusted,iot,guest,server,mgmt}_VLANs | DHCP→{Pi-hole,AdGuard_Home,Unbound,local_DNS} | add_VPN∈{WireGuard,Tailscale,ZeroTier,OpenVPN,router_native} | lockout_audit∈{gw,switch,AP,DNS,VPN} | staged_migration+evidence
§R{safety}
1st_reply≡READ_ONLY(inventory,risks,plan,validation,rollback); ¬expose(public,{gw_admin,DNS,SSH,NAS_UI,VPN_UI}); ¬emit({FW,NAT,VLAN,DHCP,VPN}_cmds) unless platform∧rollback_known; require(OOB⊕local_console) pre_Δ({mgmt_VLAN,trunks,FW_default,DHCP,DNS}); keep(internet_path) pre_cutover(DNS∨VPN); zones:{IoT,guest,camera,lab_server}≠Trusted unless explicit
§CHK{inventory}
edge:modem/ONT,ISP_rtr(bridged/routing)?; gw:routes,FW,DHCP,VPN?; switch:uplink/access/trunk/unmanaged?; wifi:SSID→VLAN,AP(wired/mesh)?; addr:subnets,VPN_conflicts?; dns_dhcp:lease+resolver?; mgmt:post_Δ_reach(gw,switch,AP)?; recovery:local_revert(DNS,DHCP,VLAN,VPN)?
§CFG{zones}
Trusted:{laptops,phones,admin}⇒svcs+mgmt(needed); Servers:{NAS,Home_Assistant,lab,DNS}⇒narrow_in(Trusted); IoT:{TV,plugs,cams,speakers}⇒net+exceptions_only; Guest:{visitors}⇒net_only∧¬LAN; Management:{gw,switch,AP,ctrl}⇒in(Trusted_admin); VPN:{remote}⇒access≤Trusted; pre_VLAN:{gw_route+FW,switch_tag/untag,AP_SSID→VLAN,operator_port_known,mgmt_ok_post(trunk_Δ,SSID_Δ)}
§R{dns_readiness}
1:reserve_IP(resolver) pre_DHCP; 2:verify(public_DNS∧home.arpa); 3:fallback(gw∨2nd_resolver); 4:canary(1_client∨1_VLAN) pre_all_scopes; 5:doc(bypass_nets+why); 6:verify_¬break({captive_portals,work_VPNs,fw_updates,medical_security_devs}); evidence:{DHCP_lease,DNS_IP,public_ok,home.arpa_ok,block_scoped,admin_blocked(guest,IoT)}
§CFG{vpn_readiness}
split_1_subnet(NAS/lab)⇒narrow_routes; split_trusted(IP/DNS)⇒precise_FW; full_tunnel(untrusted/travel)⇒↑BW+DNS; overlay(identity)⇒ACL_review; pre_port_fwd:{patched,fwd→VPN_svc_only(¬admin_UI),DDNS+public_IP+CGNAT_known,per_peer_revoke,logs_who_when}
§PAT{change_seq}
1:snapshot({topology,IP_plan,DHCP,DNS,FW})→2:reserve_IPs({gw,DNS,ctrl,AP,NAS,VPN})→3:create_VLAN(¬move_crit)→4:canary_1_client({DHCP,DNS,route,net,block})→5:narrow_FW_exceptions→6:move_1_low_risk_grp→7:add_VPN(min_routes+FW)→8:doc({state,exceptions,rollback})
§CHK{review}
∀net:purpose+trust_boundary; ¬mgmt_from({guest,IoT,public}); DNS_fail¬block_recovery; DHCP_Δ_canary_1st; VPN⇒min(routes,DNS); FW≡default_deny+named_exceptions; admin_ok({gw,switch,AP,DNS,VPN}); rollback∈platform(UI∨CLI)
§ANTI
segment_pre_known(port/SSID→VLAN) | move_admin_off_mgmt | all_DHCP→Pi-hole_pre_fallback | expose_mgmt({NAS,DNS,rtr,hypervisor}) | VPN≡full_LAN | stale_allow_all_FW | cross_vendor_copy_paste_no_syntax_check
§REL
[../SKILL.md](../SKILL.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md)
