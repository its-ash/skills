@REF:homelab-pihole-dns
# Network-wide DNS ad/malware blocker (RPi/Linux); install, routing, blocklists, DoH, local DNS, debug.
§PAT{flow}
no_pihole:dev→ISP_DNS→real_IP; pihole:dev→Pi-hole→(blocked⇒0.0.0.0|allowed⇒upstream[Cloudflare/Google/DoH])
§CFG{docker}
# Recommended; web_admin=http://<pi-ip>/admin; pin tag (¬latest); .env(PIHOLE_WEBPASSWORD,chmod 600,¬git,¬inline)
```yaml
services:
  pihole:
    image: pihole/pihole:<pinned-release-tag>
    container_name: pihole
    ports: ["53:53/tcp", "53:53/udp", "80:80/tcp"]
    environment: {TZ: "America/New_York", WEBPASSWORD: "${PIHOLE_WEBPASSWORD}", PIHOLE_DNS_: "1.1.1.1;1.0.0.1", DNSMASQ_LISTENING: "all"}
    volumes: ["./etc-pihole:/etc/pihole", "./etc-dnsmasq.d:/etc/dnsmasq.d"]
    restart: unless-stopped
    cap_add: [NET_ADMIN] # only if Pi-hole serves DHCP
```
§CMD{bare_metal}
# RPi OS/Debian/Ubuntu: static IP pre-install (/etc/dhcpcd.conf: interface eth0, static ip_address=192.168.3.2/24, static routers=192.168.3.1, static domain_name_servers=192.168.3.1)
# Prefer OS/pkg installer; else inspect script pre-run:
curl -sSL https://install.pi-hole.net -o pi-hole-install.sh && less pi-hole-install.sh && bash pi-hole-install.sh
# Interactive: eth0 → upstream DNS → confirm static IP → web admin → save pw
§PAT{client_dns}
M1_router_DHCP(rec):Primary=192.168.3.2; Secondary=∅(strict)∨2nd_Pi-hole (public e.g. 1.1.1.1 aids availability but clients may bypass blocks); renew:Wi-Fi_reconnect ∨ `sudo dhclient -r && sudo dhclient`
M2_per_dev(test):Win(Adapter→IPv4→DNS) | macOS(Settings→Net→Details→DNS) | Linux(/etc/resolv.conf∨NetworkManager)
M3_pihole_DHCP:Settings→DHCP→Enable (MUST disable router DHCP 1st; dual_DHCP⇒conflicts); auto hostname reg
§CFG{blocklists}
# Adlists→Add → Tools→Update Gravity (`pihole -g`); Whitelist: e.g. api.my-legitimate-service.com; live: Dashboard→Query Log
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts # 200k+
https://blocklistproject.github.io/Lists/malware.txt
https://blocklistproject.github.io/Lists/tracking.txt
§CMD{doh}
# cloudflared DoH proxy on 127.0.0.1#5053; prefer signed pkg repo, else pin CLOUDFLARED_VERSION + verify checksum/sig:
curl -LO "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-arm64"
sudo mv cloudflared-linux-arm64 /usr/local/bin/cloudflared && sudo chmod +x /usr/local/bin/cloudflared && sudo mkdir -p /etc/cloudflared
# /etc/cloudflared/config.yml: proxy-dns: true | proxy-dns-port: 5053 | proxy-dns-upstream: [https://1.1.1.1/dns-query, https://1.0.0.1/dns-query]
sudo cloudflared service install && sudo systemctl start cloudflared && sudo systemctl enable cloudflared
# Pi-hole Settings→DNS→Custom=127.0.0.1#5053; uncheck all other upstreams
§CFG{local_dns}
# .home.lan common; RFC 8375 std=.home.arpa; ¬.local (mDNS/Bonjour conflict)
# Local DNS→DNS Records: nas.home.lan→192.168.30.10, pi.home.lan→192.168.30.2, grafana.home.lan→192.168.30.3, proxmox.home.lan→192.168.30.4
# CNAME: portainer.home.lan→pi.home.lan
§CMD{debug}
pihole -q <domain> | pihole -w <domain> | pihole status | dig @192.168.3.2 google.com | pihole restartdns | pihole -t | pihole -g
§R{best_practices}
static_IP∨DHCP_res pre_install; redundancy=2nd_Pi-hole (keep router rollback during setup, ¬public_fallback for strict); DoH(cloudflared); weekly `pihole -g` (or Settings→API); review Query_Log
§ANTI
SPOF_single_Pi-hole_no_recovery | install_no_static_IP | enable_Pi-hole_DHCP_before_router_DHCP_off | stale_gravity
§REL
[../SKILL.md](../SKILL.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
