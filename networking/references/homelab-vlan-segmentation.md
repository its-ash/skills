@REF:homelab-vlan-segmentation
# Isolate flat net (192.168.1.0/24)→VLANs; rules add isolation (¬remove protections). Apply in maint window; verify per step.
§CFG{template}
10:trusted(192.168.10.0/24,gw=.1,PC/phone/laptop) | 20:iot(192.168.20.0/24,gw=.1,TV/bulb/cam/thermostat) | 30:servers(192.168.30.0/24,gw=.1,NAS=.10,Pi-hole=.2,VMs) | 40:guest(192.168.40.0/24,gw=.1,internet_only) | 99:management(192.168.99.0/24,gw=.1,switch/AP_UIs)
§PAT{example_unifi}
SSID→VLAN:{"Home"→10(WPA2,strong),"IoT"→20(WPA2,sep_pw),"Guest"→40(WPA2,shareable)}; ports:{P1:trunk→rtr(10,20,30,40,99),P2:trunk→AP(10,20,40),P3:access_30(NAS),P4:access_30(Pi-hole),P5-8:access_10(ws)}; FW:{IoT→Trusted:BLOCK,IoT→Servers:BLOCK_except(192.168.30.2:53),IoT→Net:ALLOW,Guest→Local:BLOCK,Guest→Net:ALLOW,Trusted→*:ALLOW}
§CFG{unifi}
Networks:Settings→Networks→Create(IoT,Corporate[DHCP+route],VLAN=20,192.168.20.0/24,GW=.1,DHCP=100-254)
WiFi:Settings→WiFi→Create(Network=VLAN; Guest⇒Guest_Policy=Enable)
Traffic_Rules:Settings→Traffic&Security→Traffic_Rules:{Block Local_Net IoT→Trusted, Allow IoT→Internet, Block Guest→Local_Networks}
§CFG{pfsense_opnsense}
VLANs:Interfaces→Assignments→VLANs→Add(Parent=em1,Tag=20,Desc=IoT)→Assign→Enable+192.168.20.1/24
DHCP:Services→DHCP_Server→<VLAN>→Enable,Range=192.168.20.100-254,DNS=192.168.30.2
FW(IoT_20,top_down_1st_match): 1:Allow UDP/TCP IoT→192.168.30.2:53 (pre_RFC1918) | 1b_opt:Allow TCP IoT→192.168.30.x:8123(Home_Assistant) | 2:Block any IoT→RFC1918(192.168.0.0/16,10.0.0.0/8,172.16.0.0/12) | 3:Allow any IoT→any; Trusted_10:Allow Trusted→any
§CFG{mikrotik}
```routeros
/interface bridge add name=bridge vlan-filtering=yes
/interface bridge port
add bridge=bridge interface=ether1 frame-types=admit-only-vlan-tagged
add bridge=bridge interface=ether2 pvid=10 frame-types=admit-only-untagged-and-priority-tagged
add bridge=bridge interface=ether3 pvid=20 frame-types=admit-only-untagged-and-priority-tagged
/interface bridge vlan
add bridge=bridge tagged=ether1 untagged=ether2 vlan-ids=10
add bridge=bridge tagged=ether1 untagged=ether3 vlan-ids=20
/interface vlan
add interface=bridge name=vlan10 vlan-id=10
add interface=bridge name=vlan20 vlan-id=20
/ip address
add interface=vlan10 address=192.168.10.1/24
add interface=vlan20 address=192.168.20.1/24
/ip pool
add name=pool-trusted ranges=192.168.10.100-192.168.10.254
add name=pool-iot ranges=192.168.20.100-192.168.20.254
/ip dhcp-server
add interface=vlan10 address-pool=pool-trusted name=dhcp-trusted
add interface=vlan20 address-pool=pool-iot name=dhcp-iot
/ip dhcp-server network
add address=192.168.10.0/24 gateway=192.168.10.1
add address=192.168.20.0/24 gateway=192.168.20.1
/ip firewall filter add chain=forward src-address=192.168.20.0/24 dst-address=192.168.10.0/24 action=drop comment="Block IoT to Trusted"
```
§D{ports}
trunk(tagged,multi):switch↔switch/router(10,20,30,40,99), switch↔AP(SSID_VLANs; AP tags per_SSID); access(untagged,1):end_devs(PC,cam,NAS; ¬VLAN_aware)
§R{best_practices}
start_4_VLANs:{Trusted,IoT,Servers,Guest}+Mgmt(Trusted_only); Pi-hole∈Servers(192.168.30.x)+Allow_53(all→Pi-hole) pre_RFC1918_block; test(ping IoT→Trusted⇒FAIL); doc_table(ID,name,subnet,purpose)
§ANTI
VLANs_no_FW(inter-VLAN open) | Pi-hole∈IoT | native_VLAN≡mgmt_VLAN(hopping⇒unused native e.g. 999, keep mgmt tagged) | shared_WiFi_pw(IoT,Trusted)
§REL
[../SKILL.md](../SKILL.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
