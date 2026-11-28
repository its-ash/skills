@REF:homelab-wireguard-vpn
# WireGuard VPN (UDP 51820); E2E encrypted, per-dev keypair + PresharedKey (post-quantum defense), native nftables (¬legacy iptables). Apply in maint window.
§D{cgnat_strategy}
public_IPv4∨IPv6⇒direct_WireGuard@gw(UDP_51820)+DDNS
ISP_CGNAT∧self_hosted_ctrl⇒WG_outbound→VPS_relay(PersistentKeepalive=25+nft_DNAT)∨Headscale(self-hosted_Tailscale_ctrl,NAT_traversal/DERP)
ISP_CGNAT∧zero_ops⇒Tailscale(ACLs_least_priv+MagicDNS+dedicated_subnet_rtr,¬default_allow_all)
§CMD{linux_server_nft}
# Debian 12+/Ubuntu 24.04+/RHEL 9+: native nftables + PresharedKey
sudo apt update && sudo apt install -y wireguard nftables && sudo mkdir -p /etc/wireguard
sudo sh -c 'umask 077; wg genkey > /etc/wireguard/server_private.key && wg pubkey < /etc/wireguard/server_private.key > /etc/wireguard/server_public.key && wg genpsk > /etc/wireguard/phone.psk'
# /etc/wireguard/wg0.conf (chmod 600, ¬git); replace eth0 via `ip route show default`
```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <server_private_key>
PostUp   = nft add table inet wireguard; nft add chain inet wireguard forward { type filter hook forward priority 0\; policy accept\; }; nft add rule inet wireguard forward iifname "wg0" oifname "eth0" accept; nft add rule inet wireguard forward iifname "eth0" oifname "wg0" ct state established,related accept; nft add chain inet wireguard postrouting { type nat hook postrouting priority srcnat\; policy accept\; }; nft add rule inet wireguard postrouting oifname "eth0" ip saddr 10.8.0.0/24 masquerade
PostDown = nft delete table inet wireguard

[Peer]
# Phone (unique keypair + unique PresharedKey)
PublicKey = <phone_public_key>
PresharedKey = <phone_psk>
AllowedIPs = 10.8.0.2/32
```
sudo chmod 600 /etc/wireguard/wg0.conf
printf "net.ipv4.ip_forward=1\nnet.ipv6.conf.all.forwarding=1\n" | sudo tee /etc/sysctl.d/99-wireguard.conf && sudo sysctl --system
sudo wg-quick up wg0 && sudo systemctl enable wg-quick@wg0
§CFG{client}
# Unique keypair/dev (gen on client⊕secure xfer, ¬plaintext); match PresharedKey on both sides
# [Interface]: PrivateKey, Address=10.8.0.2/32, DNS=192.168.30.2(Pi-hole)
# [Peer]: PublicKey=<srv_pub>, PresharedKey=<peer_psk>, Endpoint=vpn.example.org:51820, AllowedIPs, PersistentKeepalive=25(req mobile/NAT/CGNAT)
§D{tunnel_modes}
split_servers(192.168.30.0/24,10.8.0.0/24):NAS/DNS_only,internet_direct⇒best_mobile_battery
split_homelab(192.168.10.0/24,192.168.30.0/24,10.8.0.0/24):trusted+servers,internet_direct(¬192.168.1.0/24_collision)
full_tunnel(0.0.0.0/0,::/0):all_via_home(untrusted_WiFi+Pi-hole_everywhere; bottleneck=home_upload)
§PAT{python_keygen}
# Write keys mode 600, ¬git, ¬log/print; always generate per-peer PresharedKey
```python
import subprocess
def generate_keypair() -> tuple[str, str]:
    priv = subprocess.check_output(["wg", "genkey"]).decode().strip()
    pub = subprocess.run(["wg", "pubkey"], input=priv.encode(), capture_output=True, check=True).stdout.decode().strip()
    return priv, pub
def generate_preshared_key() -> str: return subprocess.check_output(["wg", "genpsk"]).decode().strip()
def build_client_config(priv: str, vpn_ip: str, srv_pub: str, psk: str, endpoint: str, allowed_ips: str = "192.168.30.0/24, 10.8.0.0/24", dns: str = "192.168.30.2") -> str:
    d = f"DNS = {dns}\n" if dns else ""
    return f"[Interface]\nPrivateKey = {priv}\nAddress = {vpn_ip}/32\n{d}\n[Peer]\nPublicKey = {srv_pub}\nPresharedKey = {psk}\nEndpoint = {endpoint}\nAllowedIPs = {allowed_ips}\nPersistentKeepalive = 25\n"
def build_server_peer_block(pub: str, psk: str, vpn_ip: str, comment: str = "") -> str:
    return f"\n{f'# {comment}\n' if comment else ''}[Peer]\nPublicKey = {pub}\nPresharedKey = {psk}\nAllowedIPs = {vpn_ip}/32\n"
```
§CFG{opnsense_pfsense}
VPN→WireGuard→Instances/Tunnels→Add(GenKeys,Port=51820,Addr=10.8.0.1/24)→Peers→Add(PubKey,PresharedKey,AllowedIPs=10.8.0.2/32)→Interfaces→Assignments→Add(wg0,Enable)→FW:{WAN:Allow_UDP_51820_in, wg0:Allow→specific_VLANs(¬blanket_all_if_restricted)}
§CFG{ddns}
cloudflare:qmcgaw/ddns-updater, env_file=./ddns.env(600,¬git; scoped_API_token,¬inline)
duckdns:/etc/ddns.env(600), cron `*/5 * * * * /usr/local/bin/update-duckdns >/dev/null 2>&1`: `curl --fail --silent --show-error --max-time 10 --get "https://www.duckdns.org/update" --data-urlencode "domains=myhome" --data-urlencode "token=${DUCKDNS_TOKEN}" --data-urlencode "ip="`
§CMD{debug}
sudo wg show | sudo nft list table inet wireguard | sudo wg show wg0 public-key | sysctl net.ipv4.ip_forward net.ipv6.conf.all.forwarding | journalctl -k -g wireguard | sudo wg-quick down wg0 && sudo wg-quick up wg0
§CHK{handshake}
latest_handshake≠never | WAN_IP≡public_IP(¬CGNAT) | UDP_51820_forwarded | srv_pubkey+PSK_match | ip_forward==1 | nft_or_ufw_allows_wg0_forward | client_AllowedIPs_covers_target
§R{best_practices}
unique_keypair+PresharedKey/dev; native_nftables(clean_table_teardown); split_tunnel+PersistentKeepalive=25(mobile); DDNS_creds∈env(600); DNS=192.168.30.2(Pi-hole); Tailscale/Headscale_if_CGNAT(lock_ACLs); rotate_keys_periodically
§ANTI
privkeys_or_PSK∈git/shared | legacy_iptables_on_nft_host | omit_PresharedKey | 192.168.1.0/24_AllowedIPs | port_fwd_behind_CGNAT | 0.0.0.0/0_mobile_no_upload_check | no_PersistentKeepalive | shared_keypair | blanket_FORWARD_ACCEPT
§REL
[../SKILL.md](../SKILL.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
