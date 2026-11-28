@REF:homelab-vlan-segmentation
# Isolate flat net (¬192.168.1.0/24)→VLANs; rules add isolation (¬remove protections). Apply in maint window with OOB/recovery port; verify per step.
§CFG{template}
10:trusted(192.168.10.0/24,gw=.1,PC/phone/laptop) | 20:iot(192.168.20.0/24,gw=.1,TV/bulb/cam/thermostat) | 30:servers(192.168.30.0/24,gw=.1,NAS=.10,Pi-hole=.2,VMs) | 40:guest(192.168.40.0/24,gw=.1,internet_only) | 99:management(192.168.99.0/24,gw=.1,switch/AP_UIs)
§PAT{example_unifi}
SSID→VLAN:{"Home"→10(WPA3∨WPA2/WPA3),"IoT"→20(WPA2_compat,sep_PSK),"Guest"→40(WPA2/WPA3,client_iso)}; ports:{P1:trunk→rtr(10,20,30,40,99),P2:trunk→AP(native=99_or_mgmt_tagged,allow=10,20,40),P3:access_30(NAS),P4:access_30(Pi-hole),P5-8:access_10(ws)}; FW:{IoT→Trusted:BLOCK,IoT→Servers:ALLOW(192.168.30.2:53)_then_BLOCK,IoT→Ext:ALLOW,Guest→Local/Gw:BLOCK,Guest→Ext:ALLOW,Trusted→*:ALLOW+Return}
§CFG{unifi_zbf}
# UniFi Network 9.0+/11.x Zone-Based Firewall (replaces legacy LAN In/Out & Traffic Rules):
Networks:Settings→Networks→New_Virtual_Network(IoT,VLAN=20,192.168.20.1/24,DHCP=50-240,DNS=192.168.30.2,Isolate_Network=opt)
WiFi:Settings→WiFi→Create(Network=VLAN; Trusted=WPA3/Transition; Guest⇒Client_Device_Isolation=Enable)
ZBF_Zones:assign_VLANs→{Internal(10),Servers(30_or_DMZ),IoT(custom_zone_20),Hotspot/Guest(40),External(WAN),Gateway(rtr),VPN}
ZBF_Matrix:IoT→Internal:Block | IoT→Servers:Allow(UDP/TCP_53→192.168.30.2;opt_TCP_8123→HA),Block_All | Internal→IoT:Allow+Auto_Allow_Return | IoT→Gateway:Allow(DHCP_67/68,DNS_if_gw),Block_Admin(22,80,443) | Guest→Internal/Servers/Gateway:Block
§CFG{opnsense_pfsense}
# OPNsense 25.x/26.x & pfSense 2.8+/Plus: ISC DHCP is EOL ⇒ use Kea DHCP or Dnsmasq DHCP
VLANs:OPNsense(Interfaces→Other_Types→VLAN) | pfSense(Interfaces→Assignments→VLANs)→Add(Parent=igc1/vtnet1,Tag=20,Desc=IoT)→Assign→Enable+192.168.20.1/24
DHCP:Kea(Services→Kea_DHCP→Subnets→192.168.20.0/24,Pool=.50-.240,GW=.1,DNS=192.168.30.2) ∨ Dnsmasq(Services→Dnsmasq_DHCP→enable_on_VLAN20,auto_local_DNS)
FW(IoT_20,top_down_1st_match):1:Allow_UDP_67-68(DHCP_to_gw_if_not_auto) | 2:Allow_UDP/TCP_IoT→192.168.30.2:53(pre_RFC1918) | 2b_opt:Allow_TCP_IoT→192.168.30.x:8123(HA) | 3:Block_any_IoT→Gateway_Admin(22,80,443) | 4:Block_any_IoT→RFC1918_Alias(192.168.0.0/16,10.0.0.0/8,172.16.0.0/12) | 5:Allow_any_IoT→any; Trusted_10:Allow_Trusted→any
§CFG{mikrotik_ros7}
# RouterOS 7: build with vlan-filtering=no FIRST; MUST include `bridge` in tagged= for any VLAN with L3 /interface vlan; enable vlan-filtering=yes LAST (use Safe Mode!)
```routeros
/interface bridge add name=bridge vlan-filtering=no
/interface bridge port
add bridge=bridge interface=ether1 frame-types=admit-only-vlan-tagged ingress-filtering=yes
add bridge=bridge interface=ether2 pvid=10 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
add bridge=bridge interface=ether3 pvid=20 frame-types=admit-only-untagged-and-priority-tagged ingress-filtering=yes
/interface bridge vlan
add bridge=bridge tagged=bridge,ether1 untagged=ether2 vlan-ids=10
add bridge=bridge tagged=bridge,ether1 untagged=ether3 vlan-ids=20
/interface vlan
add interface=bridge name=vlan10 vlan-id=10
add interface=bridge name=vlan20 vlan-id=20
/ip address
add interface=vlan10 address=192.168.10.1/24
add interface=vlan20 address=192.168.20.1/24
/ip pool
add name=pool-trusted ranges=192.168.10.50-192.168.10.240
add name=pool-iot ranges=192.168.20.50-192.168.20.240
/ip dhcp-server
add interface=vlan10 address-pool=pool-trusted name=dhcp-trusted
add interface=vlan20 address-pool=pool-iot name=dhcp-iot
/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1 dns-server=192.168.30.2
add address=192.168.20.0/24 gateway=192.168.20.1 dns-server=192.168.30.2
/ip firewall filter
add chain=forward connection-state=established,related action=accept
add chain=forward src-address=192.168.20.0/24 dst-address=192.168.10.0/24 action=drop comment="Block IoT to Trusted"
# Enable LAST in Safe Mode after verifying mgmt access:
/interface bridge set bridge vlan-filtering=yes
```
§D{ports}
trunk(tagged,multi):switch↔switch/router(10,20,30,40,99), switch↔AP(SSID_VLANs; AP tags per_SSID)
access(untagged,1):end_devs(PC,cam,NAS; ¬VLAN_aware)
cross_VLAN_cast(Chromecast/AirPlay):mDNS_reflector(Avahi/UniFi_mDNS)+narrow_media_ports¬collapse_VLANs
§R{best_practices}
start_4_VLANs:{Trusted,IoT,Servers,Guest}+Mgmt(Trusted_only); Pi-hole∈Servers(192.168.30.2)+Allow_53(all→Pi-hole) pre_RFC1918_block; block_gw_admin_from(IoT,Guest); test(ping IoT→Trusted⇒FAIL, DNS_53⇒OK); doc(ID,name,subnet,zone,purpose)
§ANTI
VLANs_no_FW(inter-VLAN_open) | RouterOS7_missing_tagged=bridge(breaks_L3) | enable_vlan-filtering=yes_before_port_cfg | EOL_ISC_DHCP_new_builds | Pi-hole∈IoT | native_VLAN≡mgmt_VLAN(hopping⇒unused_native_999,mgmt_tagged) | shared_WiFi_PSK(IoT,Trusted)
§REL
[../SKILL.md](../SKILL.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
