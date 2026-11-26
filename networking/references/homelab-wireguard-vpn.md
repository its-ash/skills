@REF:homelab-wireguard-vpn
# WireGuard VPN (UDP 51820); E2E encrypted, keypair/dev, ¬CA. Review iptables & key perms; apply in maint window.
§CMD{linux_server}
sudo apt update && sudo apt install wireguard -y && sudo mkdir -p /etc/wireguard
sudo sh -c 'umask 077; wg genkey > /etc/wireguard/server_private.key'
sudo sh -c 'wg pubkey < /etc/wireguard/server_private.key > /etc/wireguard/server_public.key'
# /etc/wireguard/wg0.conf (chmod 600, ¬git); replace eth0 via `ip route show default`
```ini
[Interface]
Address = 10.8.0.1/24
ListenPort = 51820
PrivateKey = <server_private_key>
PostUp   = iptables -A FORWARD -i wg0 -o eth0 -j ACCEPT; iptables -A FORWARD -i eth0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -o eth0 -j ACCEPT; iptables -D FORWARD -i eth0 -o wg0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
[Peer]
PublicKey = <phone_public_key>
AllowedIPs = 10.8.0.2/32
```
sudo chmod 600 /etc/wireguard/wg0.conf
echo "net.ipv4.ip_forward=1" | sudo tee /etc/sysctl.d/99-wireguard.conf && sudo sysctl --system
sudo wg-quick up wg0 && sudo systemctl enable wg-quick@wg0
§CFG{client}
# Unique keypair/dev (on client⊕secure transfer, ¬plaintext): umask 077; wg genkey | tee priv | wg pubkey > pub
# [Interface]: PrivateKey, Address=10.8.0.2/32, DNS=192.168.1.2(opt Pi-hole)
# [Peer]: PublicKey=<srv_pub>, Endpoint=your-home-ip.ddns.net:51820, AllowedIPs, PersistentKeepalive=25(req mobile/NAT)
§D{tunnel_modes}
split_1(192.168.1.0/24):home_only,internet_direct⇒best_mobile; split_multi(192.168.10.0/24,192.168.20.0/24,192.168.30.0/24,10.8.0.0/24):all_VLANs,internet_direct; full(0.0.0.0/0,::/0):all_via_home(Pi-hole_everywhere; bottleneck=home_upload)
§PAT{python_keygen}
# Write keys mode 600, ¬git, ¬log/print
```python
import subprocess
def generate_keypair() -> tuple[str, str]:
    priv = subprocess.check_output(["wg", "genkey"]).decode().strip()
    pub = subprocess.run(["wg", "pubkey"], input=priv.encode(), capture_output=True, check=True).stdout.decode().strip()
    return priv, pub
def generate_preshared_key() -> str: return subprocess.check_output(["wg", "genpsk"]).decode().strip()
def build_client_config(client_private_key: str, client_vpn_ip: str, server_public_key: str, server_endpoint: str, allowed_ips: str = "192.168.1.0/24", dns: str = "") -> str:
    d = f"DNS = {dns}\n" if dns else ""
    return f"[Interface]\nPrivateKey = {client_private_key}\nAddress = {client_vpn_ip}/32\n{d}\n[Peer]\nPublicKey = {server_public_key}\nEndpoint = {server_endpoint}\nAllowedIPs = {allowed_ips}\nPersistentKeepalive = 25\n"
def build_server_peer_block(client_public_key: str, client_vpn_ip: str, comment: str = "") -> str:
    return f"\n{f'# {comment}\n' if comment else ''}[Peer]\nPublicKey = {client_public_key}\nAllowedIPs = {client_vpn_ip}/32\n"
```
§CFG{pfsense_opnsense}
VPN→WireGuard→Add_Tunnel(GenKeys,Port=51820,Addr=10.8.0.1/24)→Add_Peer(PubKey,AllowedIPs=10.8.0.2/32)→Interfaces→Assignments→Add(wg0,Enable,¬IP)→FW:{WAN:Allow UDP 51820 in, wg_iface:Allow→LANs}
§CFG{ddns}
cloudflare:qmcgaw/ddns-updater, env_file=./ddns.env(600,¬git; SETTINGS_CLOUDFLARE_ZONE_ID,SETTINGS_CLOUDFLARE_TOKEN,¬inline)
duckdns:/etc/ddns.env(600), cron `*/5 * * * * /usr/local/bin/update-duckdns >/dev/null 2>&1`: `curl --fail --silent --show-error --max-time 10 --get "https://www.duckdns.org/update" --data-urlencode "domains=myhome" --data-urlencode "token=${DUCKDNS_TOKEN}" --data-urlencode "ip="`
§CMD{debug}
sudo wg show | sudo ufw status | sudo wg show wg0 public-key | cat /proc/sys/net/ipv4/ip_forward | dmesg | grep wireguard | sudo wg-quick down wg0 && sudo wg-quick up wg0
# Verify: latest handshake ≠ never; UDP 51820 open; srv pubkey matches; ip_forward==1; client AllowedIPs covers target IP
§R{best_practices}
unique_keypair/dev; split_tunnel+PersistentKeepalive=25(mobile); DDNS_creds∈env(600); scoped_iptables(wg0); DNS=Pi-hole_IP; rotate server_keypair periodically
§ANTI
privkeys∈git/shared | 0.0.0.0/0 on mobile_no_upload_check | no_PersistentKeepalive(mobile/NAT) | open_51820_no_ip_forward=1 | shared_keypair | blanket_FORWARD_ACCEPT
§REL
[../SKILL.md](../SKILL.md) | [homelab-vlan-segmentation.md](homelab-vlan-segmentation.md) | [homelab-pihole-dns.md](homelab-pihole-dns.md) | [homelab-network-readiness.md](homelab-network-readiness.md)
