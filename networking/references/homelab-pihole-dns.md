@REF:homelab-pihole-dns
# Pi-hole v6 network-wide DNS blocker (embedded pihole-FTL HTTP/HTTPS+REST API, pihole.toml, ¬lighttpd/PHP). Consistent VLAN30 IP=192.168.30.2, RFC8375=.home.arpa.
§PAT{flow}
no_pihole:dev→ISP_DNS→real_IP; pihole:dev→Pi-hole(192.168.30.2:53)→(blocked⇒0.0.0.0|allowed⇒upstream[Unbound_recursive|cloudflared_DoH|Cloudflare/Quad9])
§CFG{docker_v6}
# Pi-hole v6: FTLCONF_* replaces v5(WEBPASSWORD,PIHOLE_DNS_,DNSMASQ_LISTENING); env-set keys⇒READ-ONLY in UI/CLI (Docker=source_of_truth); HTTPS:443 native (self-signed auto); pin image tag(¬latest); .env(chmod 600,¬git)
```yaml
services:
  pihole:
    image: pihole/pihole:<pinned-v6-tag>
    container_name: pihole
    ports: ["53:53/tcp", "53:53/udp", "80:80/tcp", "443:443/tcp"] # add "67:67/udp" only if DHCP
    environment:
      TZ: "America/New_York"
      FTLCONF_webserver_api_password: "${PIHOLE_WEBPASSWORD}"
      FTLCONF_dns_upstreams: "1.1.1.1;1.0.0.1" # or "127.0.0.1#5335"(Unbound) / "127.0.0.1#5053"(cloudflared)
      FTLCONF_dns_listeningMode: "ALL" # required in Docker bridge mode (else drops non-local)
    volumes: ["./etc-pihole:/etc/pihole"] # pihole.toml lives here; mount etc-dnsmasq.d only if FTLCONF_misc_etc_dnsmasq_d="true"
    cap_add: [NET_ADMIN] # DHCP only; optional: SYS_TIME, SYS_NICE
    restart: unless-stopped
```
§CMD{bare_metal}
# Static IP pre-install on RPi OS Bookworm/Trixie+Debian (NetworkManager nmcli; ¬legacy /etc/dhcpcd.conf):
nmcli connection show
sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.30.2/24 ipv4.gateway 192.168.30.1 ipv4.dns "127.0.0.1,1.1.1.1" ipv4.method manual && sudo nmcli connection up "Wired connection 1"
# Inspect installer pre-run:
curl -sSL https://install.pi-hole.net -o pi-hole-install.sh && less pi-hole-install.sh && sudo bash pi-hole-install.sh
# Manage v6 settings via CLI (single source=/etc/pihole/pihole.toml; ¬edit raw while FTL running):
sudo pihole-FTL --config dns.upstreams '["1.1.1.1","1.0.0.1"]' | sudo pihole setpassword
§PAT{client_dns}
M1_router_DHCP(rec):Primary=192.168.30.2; Secondary=∅(strict)∨2nd_Pi-hole (public fallback e.g. 1.1.1.1 aids uptime but clients bypass blocks); renew:Wi-Fi_reconnect∨`nmcli con up`
M2_per_dev(canary):Win(Adapter→IPv4→DNS) | macOS(Settings→Net→Details→DNS) | Linux(nmcli∨systemd-resolved)
M3_pihole_DHCP:Settings→DHCP→Enable (MUST disable router DHCP 1st; dual_DHCP⇒conflicts)
§CFG{blocklists}
# Lists→Add → Tools→Update Gravity (`pihole -g`); monitor live via Dashboard→Query Log
https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts # unified hosts
https://big.oisd.nl/domainswild2 # low-FP community list (OISD)
https://blocklistproject.github.io/Lists/malware.txt
§D{upstream_privacy}
zero_3rd_party_logs+DNSSEC⇒local_Unbound(127.0.0.1#5335,recursive_root_hints)
encrypted_ISP_transit_simple⇒cloudflared_DoH(127.0.0.1#5053)
native_DoH/DoT/DoQ_no_sidecar⇒AdGuard_Home_alt
§CMD{doh_cloudflared}
# Prefer signed Cloudflare APT pkg repo; else pin CLOUDFLARED_VERSION + verify SHA256:
curl -LO "https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-arm64"
sudo install -m 0755 cloudflared-linux-arm64 /usr/local/bin/cloudflared && sudo mkdir -p /etc/cloudflared
# /etc/cloudflared/config.yml: proxy-dns: true | proxy-dns-port: 5053 | proxy-dns-upstream: [https://1.1.1.1/dns-query, https://1.0.0.1/dns-query]
sudo cloudflared service install && sudo systemctl enable --now cloudflared
# Pi-hole v6: FTLCONF_dns_upstreams="127.0.0.1#5053" (or Settings→DNS→Custom=127.0.0.1#5053, uncheck others)
§CFG{local_dns}
# RFC 8375 std=.home.arpa (¬.local mDNS/Bonjour conflict; avoid ad-hoc .home.lan)
# Settings→Local DNS Records (or pihole.toml dns.hosts): nas.home.arpa→192.168.30.10, pihole.home.arpa→192.168.30.2, grafana.home.arpa→192.168.30.3, proxmox.home.arpa→192.168.30.4
# CNAME (dns.cnameRecords): portainer.home.arpa→pihole.home.arpa
§CMD{debug_v6}
# v6 CLI replaces v5 flags (-w→allow, -b→deny, -a -p→setpassword, restartdns→reloaddns∨systemctl):
pihole -q <domain> | pihole allow <domain> | pihole deny <domain> | pihole deny --regex '<re>' | pihole status | dig @192.168.30.2 example.com | pihole reloaddns | sudo systemctl restart pihole-FTL | pihole -t | pihole -g
§R{best_practices}
static_IP∨DHCP_res pre_install; redundancy=2nd_Pi-hole(keepalived_VIP∨dual_DHCP_DNS,¬public_fallback_for_strict); recursive_Unbound∨DoH; weekly `pihole -g`; HTTPS:443_admin_UI; never_expose_53_WAN
§ANTI
v5_env_vars_on_v6(WEBPASSWORD,PIHOLE_DNS_) | edit_pihole.toml_while_FTL_running | legacy_dhcpcd_on_Bookworm+ | SPOF_single_Pi-hole_no_recovery | dual_DHCP | .local_domain | stale_gravity
§REL
[../SKILL.md](../SKILL.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-wireguard-vpn.md](homelab-wireguard-vpn.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
