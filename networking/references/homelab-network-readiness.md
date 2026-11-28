@REF:homelab-network-readiness
# Pre-change plan/review gate for homelab Δ(VLANs,ZBF,DNS,DHCP,VPN). ¬emit copy-paste cfg unless {platform,topology,rollback,console_access,maint_window} known.
§D{use}
split_flat→{trusted,iot,guest,server,mgmt}_VLANs | UniFi_ZBF_migration | DHCP→{Kea,dnsmasq,Pi-hole_v6,AdGuard_Home,Unbound} | add_VPN∈{WireGuard,Tailscale,Headscale,NetBird} | lockout_audit∈{gw,switch,AP,DNS,VPN} | staged_migration+evidence
§R{safety}
1st_reply≡READ_ONLY(inventory,risks,plan,validation,rollback)
¬expose(public,{gw_admin,DNS_53,SSH,NAS_UI,VPN_UI,hypervisor})
¬emit({FW,NAT,VLAN,DHCP,VPN}_cmds) unless platform∧rollback_known
require(OOB⊕local_console⊕mgmt_recovery_port) pre_Δ({mgmt_VLAN,trunks,ZBF_matrix,FW_default,DHCP,DNS})
keep(internet_path) pre_cutover(DNS∨VPN)
zones:{IoT,guest,camera,lab_server}≠Trusted unless explicit_named_rule
§CHK{inventory}
edge:modem/ONT,ISP_rtr(bridged/routing),CGNAT(WAN_IP∈100.64.0.0/10∨WAN_IP≠public_IP)?
gw:platform(UniFi_Net9+/ZBF,OPNsense_25+,pfSense_2.8+,RouterOS7),routes,FW,DHCP_engine(Kea/dnsmasq/¬ISC_EOL),VPN?
switch:uplink/access/trunk/unmanaged,PoE_budget?
wifi:SSID→VLAN,WPA3_compat(IoT),AP(wired/mesh)?
addr:subnets(¬192.168.1.0/24),IPv6_PD,VPN_conflicts?
dns_dhcp:lease_srv+resolver(Pi-hole_v6/Unbound/AdGuard)?
mgmt:post_Δ_reach(gw,switch,AP,ctrl)?
recovery:local_revert(DNS,DHCP,VLAN,ZBF,VPN)?
§CFG{zones}
Trusted:{laptops,phones,admin}⇒svcs+mgmt(explicit)
Servers:{NAS,Home_Assistant,lab,DNS}⇒narrow_in(Trusted)
IoT:{TV,plugs,cams,speakers}⇒internet+named_exceptions_only(DNS_53,HA_8123)
Guest:{visitors}⇒internet_only∧¬RFC1918∧¬Gateway_UI
Management:{gw,switch,AP,ctrl}⇒in(Trusted_admin_only)
VPN:{remote}⇒access≤Trusted(scoped_routes+ACL)
pre_VLAN:{gw_route+FW/ZBF,switch_tag/untag,AP_SSID→VLAN,operator_port_known,mgmt_ok_post(trunk_Δ,ZBF_Δ,SSID_Δ)}
§R{dns_readiness}
1:reserve_IP(resolver) pre_DHCP_cutover
2:verify(public_DNS∧home.arpa_RFC8375)
3:fallback(2nd_local_resolver∨documented_gw_rollback)
4:canary(1_client∨1_VLAN) pre_all_scopes
5:doc(bypass_nets+reason)
6:verify_¬break({captive_portals,work_VPNs,fw_updates,medical_security_devs})
evidence:{DHCP_lease,DNS_IP,public_ok,home.arpa_ok,block_scoped,admin_blocked(guest,IoT)}
§CFG{vpn_readiness}
split_1_subnet(Servers/NAS)⇒narrow_routes; split_trusted(IP/DNS)⇒precise_FW; full_tunnel(untrusted/travel)⇒↑upload_BW+DNS
ISP_CGNAT⇒Tailscale/Headscale(overlay+ACLs+subnet_rtr)∨WG_outbound→VPS¬inbound_port_fwd
pre_port_fwd:{public_IP_verified,patched,fwd→UDP_51820_only(¬admin_UI),PresharedKey_per_peer,DDNS_ok,per_peer_revoke,logs_who_when}
§PAT{change_seq}
1:snapshot({topology,IP_plan,DHCP,DNS,FW/ZBF,cfg_backup})→2:reserve_IPs({gw,DNS,ctrl,AP,NAS,VPN})→3:create_VLAN(¬move_crit)→4:canary_1_client({DHCP,DNS,route,net,block})→5:narrow_FW/ZBF_exceptions→6:move_1_low_risk_grp→7:add_VPN(min_routes+FW/ACL)→8:doc({state,exceptions,rollback})
§CHK{review}
∀net:purpose+trust_boundary | ¬mgmt_from({guest,IoT,public}) | DNS_fail¬block_recovery | DHCP_Δ_canary_1st | ¬EOL_ISC_DHCP | VPN⇒min(routes,DNS)+CGNAT_checked | FW/ZBF≡default_deny+named_exceptions | admin_ok({gw,switch,AP,DNS,VPN}) | rollback∈platform(UI∨CLI)
§ANTI
segment_pre_known(port/SSID→VLAN) | move_admin_off_mgmt | all_DHCP→single_Pi-hole_pre_fallback | expose_mgmt({NAS,DNS,rtr,hypervisor}) | inbound_WG_behind_CGNAT | VPN≡full_LAN | stale_allow_all_FW | blind_ZBF_auto_migrate_unreviewed | cross_vendor_copy_paste_no_syntax_check
§REL
[../SKILL.md](../SKILL.md) | [home-network-plan.md](home-network-plan.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [network-config-validation.md](network-config-validation.md) | [network-interface-health.md](network-interface-health.md)
