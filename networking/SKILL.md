---
name: networking
description: "Home, homelab, and enterprise networks: gateways, switches, APs, IP plans, DHCP, DNS, VLANs, Pi-hole, WireGuard, Cisco IOS, Netmiko, BGP, config validation, interface health. Use when planning or fixing a home network, segmenting VLANs, setting up Pi-hole or WireGuard, reviewing Cisco config, automating device SSH, or diagnosing BGP, CRC errors, or duplex mismatch. Sub-skills: homelab-network-readiness, homelab-vlan-segmentation, homelab-pihole-dns, homelab-wireguard-vpn, cisco-ios-patterns, netmiko-ssh-automation, network-bgp-diagnostics, network-config-validation, network-interface-health."
---
# Networking

Plan, change, and troubleshoot home, homelab, and enterprise networks so they grow without a rebuild.

## Core rules
- Separate roles: modem/ONT → gateway (NAT, firewall, DHCP, DNS, inter-VLAN) → switch → APs, servers, clients.
- Do not use `192.168.1.0/24` when VPN access is planned; it collides with hotels, offices, and ISP routers.
- Use non-overlapping /24s per zone. Convention: `.1` gateway, `.2-.49` infrastructure, `.50-.240` DHCP, `.241-.254` spare.
- Use `home.arpa` for local names, not ad hoc names like `home.lan`.
- Give a DHCP reservation to every host you SSH into, bookmark, monitor, or expose (NAS, Pi-hole, Home Assistant).
- Run exactly one DHCP server per subnet. Disable DHCP on routers reused as APs.
- Hand out the gateway as DNS until you deploy a local resolver on purpose. For Pi-hole: reserve its address first, then point DHCP DNS at it.
- Avoid double NAT unless it has a documented reason.
- Do not keep cameras, IoT, laptops, and servers in one flat trust zone.
- Collect read-only evidence (`show`, logs, counters) before any config change.
- Stage every change with a written rollback path and an out-of-band way back in.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Basic internet only | ISP router | Extra gear with no need |
| Managed home network, wants a UI | UniFi gateway | Hand-built Linux router |
| Flexible homelab (VLAN, VPN, DNS) | OPNsense / pfSense | ISP router with weak VLAN support |
| Advanced user, wants power | MikroTik, reviewed config | Untested changes on the primary gateway |
| Can run Ethernet to APs | Wired backhaul, PoE switch | Wireless mesh backhaul |
| Frequent power cuts | UPS on gateway, switch, DNS, NAS | Unprotected core devices |
| Need isolation now | VLANs + inter-VLAN firewall rules | Flat network |
| Isolation later | VLAN-ready IP plan and hardware now | Re-addressing everything later |
| Remote access | WireGuard on the gateway + DDNS | Port-forwarding admin UIs |

| Symptom | Read first |
|---|---|
| CRC errors, drops, runts, giants, flaps, duplex mismatch | `network-interface-health` |
| BGP neighbor down, missing routes | `network-bgp-diagnostics` |
| DNS fails or ads not blocked | `homelab-pihole-dns` |
| VPN handshake fails | `homelab-wireguard-vpn` |
| Config about to be pushed | `network-config-validation` |

## Load on demand

| Need | Read |
|---|---|
| Device-role diagram, gateway table, IP plan example, cabling, worked upgrade examples | [references/home-network-plan.md](references/home-network-plan.md) |
| Pre-change plan: inventory, trust zones, staged sequence, rollback | [references/homelab-network-readiness.md](references/homelab-network-readiness.md) |
| VLANs on UniFi, pfSense, OPNsense, MikroTik: trunks, SSIDs, firewall rules | [references/homelab-vlan-segmentation.md](references/homelab-vlan-segmentation.md) |
| Pi-hole install, blocklists, DoH with cloudflared, DHCP, local DNS | [references/homelab-pihole-dns.md](references/homelab-pihole-dns.md) |
| WireGuard server and peers, keys, split/full tunnel, DDNS, handshake fixes | [references/homelab-wireguard-vpn.md](references/homelab-wireguard-vpn.md) |
| Cisco IOS/IOS-XE: modes, show commands, wildcard masks, ACLs, change windows | [references/cisco-ios-patterns.md](references/cisco-ios-patterns.md) |
| Python Netmiko SSH: read-only collection, batches, TextFSM, guarded pushes | [references/netmiko-ssh-automation.md](references/netmiko-ssh-automation.md) |
| BGP states, prefix-lists, route-maps, AS path regex | [references/network-bgp-diagnostics.md](references/network-bgp-diagnostics.md) |
| Pre-deploy config check: dangerous commands, duplicate IPs, overlaps, VTY risk | [references/network-config-validation.md](references/network-config-validation.md) |
| Interface errors on routers, switches, Linux hosts | [references/network-interface-health.md](references/network-interface-health.md) |

## Related skills
- [`devops-iac`](../devops-iac/SKILL.md) — cloud networks, Kubernetes networking, IaC
- [`secure-coding`](../secure-coding/SKILL.md) — cloud network isolation and firewall checklists
- [`python`](../python/SKILL.md) — tooling for Netmiko and parser scripts
