@REF:home-network-plan
§ROLES{Internet→Modem|ONT→Gw|Rtr(NAT,FW,DHCP,DNS,interVLAN)→MgmtSw(wired,AP_uplk,VLAN_trk)→{AP(WiFi,wired_bh),Srv|NAS(static,DNS,mon),Cli|IoT(DHCP,VLAN_lat)}}
§GW{ISP:basic(¬ctrl,weak_VLAN)|UniFi:home(UI,lockin)|OPNsense|pfSense:lab(VLAN,FW,VPN,DNS)|MikroTik:adv(pwr,miscfg)|Linux:tinker(rb≺use)}
§IP{192.168.{10:trust,20:IoT/media,30:srv/NAS,40:guest,99:mgmt}.0/24;host:{.1:gw,.2-.49:infra,.50-.240:DHCP,.241-.254:spare};DNS:{nas,pihole,gateway,switch-01}.home.arpa}
§PHYS{wired_AP>mesh(Eth);PoE_sw(AP,cam)⇔budget;lbl_ends+port_map;UPS(gw,sw,DNS,NAS)⇔outages}
§EX{beg(ISP,lab):1:DHCP_res(NAS,Pi,SSH)→2:DNS→home.arpa→3:off_extra_DHCP(sec/AP)→4:wire_AP;vlan_rdy(prep,¬on):1:disjoint_/24(trust,IoT,srv,guest,mgmt)→2:res(.1:gw,.2-.49:infra)∀net→3:gw+sw(VLAN+FW)→4:map({SSID,port}→net)}
