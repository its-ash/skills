# Home Network Plan

## Device roles

```text
Internet
  |
Modem or ONT
  |
Gateway or router      NAT, firewall, DHCP, DNS, inter-VLAN routing
  |
Managed switch         wired clients, AP uplinks, optional VLAN trunks
  |
Access points          Wi-Fi only; wired backhaul preferred
Servers and NAS        stable addresses, DNS names, monitoring
Clients and IoT        DHCP pools; isolate later with VLANs
```

## Gateway options

| Option | Fit | Notes |
|---|---|---|
| ISP router | Basic internet only | Little control, weak VLAN support |
| UniFi gateway | Managed home network | Good UI, ecosystem lock-in |
| OPNsense / pfSense | Flexible homelab | Strong VLAN, firewall, VPN, DNS |
| MikroTik | Advanced users | Powerful, easy to misconfigure |
| Linux router | Tinkerers | Document rollback before primary use |

## IP plan example

```text
192.168.10.0/24  trusted clients
192.168.20.0/24  IoT and media
192.168.30.0/24  servers and NAS
192.168.40.0/24  guest Wi-Fi
192.168.99.0/24  network management

.1        gateway
.2-.49    infrastructure reservations
.50-.240  DHCP pool
.241-.254 spare
```

Local names under `home.arpa`: `nas.home.arpa`, `pihole.home.arpa`, `gateway.home.arpa`, `switch-01.home.arpa`.

## Physical layer

- Prefer wired AP backhaul to mesh when Ethernet is possible.
- Use a PoE switch for APs and cameras if budget allows.
- Label both cable ends; keep a port map.
- Put gateway, switch, DNS server, and NAS on a UPS if outages are common.

## Worked examples

Beginner upgrade (keep ISP router, stabilize a small lab):
1. DHCP reservations for NAS, Pi, and SSH hosts.
2. Move local names to `home.arpa`.
3. Disable extra DHCP servers on secondary routers or APs.
4. Wire the main AP.

VLAN-ready plan (prepare, do not enable yet):
1. Pick non-overlapping /24s for trusted, IoT, servers, guest, management.
2. Reserve `.1` gateway and `.2-.49` infrastructure on every subnet.
3. Buy a gateway and switch with VLAN and inter-VLAN firewall support.
4. Document which SSIDs and switch ports map to each network.
