---
name: wireshark-analysis
description: "Analyze packet captures and live network traffic with Wireshark and tshark. Use when inspecting PCAP or PCAPNG files, writing display or capture filters, following TCP, UDP, HTTP, or TLS streams, checking protocol statistics, or investigating scans, ARP spoofing, DNS anomalies, latency, retransmissions, packet loss, and authorized network incidents."
---

# Wireshark Network Traffic Analysis

Use Wireshark to capture, filter, inspect, and analyze network packets. Use it for authorized troubleshooting, protocol analysis, performance diagnosis, and security investigations.

## When to use

- Analyze live traffic or PCAP/PCAPNG files.
- Filter packets by address, port, protocol, TCP flags, content, or analysis fields.
- Reconstruct TCP, UDP, HTTP, or TLS conversations.
- Detect port scans, ARP spoofing, DNS anomalies, retransmissions, and suspicious transfers.
- Export statistics, packet subsets, HTTP objects, or dissections.

## Prerequisites

- Wireshark installed on Windows, macOS, or Linux.
- Administrator or root privileges for live capture.
- Permission to capture the target network traffic.
- Basic knowledge of TCP/IP, ports, and common protocols.

## Capture traffic

1. Launch Wireshark.
2. Select the network interface.
3. Start capture with the shark fin icon or by double-clicking the interface.
4. Stop capture with Ctrl+E.

Capture filters limit data before capture:

```text
host 192.168.1.100
port 80
net 192.168.1.0/24
not arp
host 192.168.1.100 and port 443
```

Capture controls:

| Action | Shortcut |
|---|---|
| Start/Stop capture | Ctrl+E |
| Restart capture | Ctrl+R |
| Open PCAP file | Ctrl+O |
| Save capture | Ctrl+S |

## Display filters

Apply display filters after capture. Red text means invalid syntax.

Basic filters:

```text
ip.addr == 192.168.1.1
ip.src == 192.168.1.1
ip.dst == 192.168.1.1
tcp.port == 80
udp.port == 53
tcp.dstport == 443
tcp.srcport == 22
```

Protocol filters:

```text
http
https or ssl or tls
dns
ftp
ssh
icmp
arp
dhcp
smb or smb2
```

TCP flag filters:

```text
tcp.flags.syn == 1
tcp.flags.ack == 1
tcp.flags.fin == 1
tcp.flags.reset == 1
tcp.flags.syn == 1 && tcp.flags.ack == 0
```

Content filters:

```text
frame contains "password"
http.request.uri contains "login"
tcp contains "GET"
```

Analysis filters:

```text
tcp.analysis.retransmission
tcp.analysis.duplicate_ack
tcp.analysis.zero_window
tcp.analysis.flags
dns.flags.rcode != 0
```

Combine filters with logical operators:

```text
ip.addr == 192.168.1.1 && tcp.port == 80
dns || http
!(arp || icmp)
(ip.src == 192.168.1.1 || ip.src == 192.168.1.2) && tcp.port == 443
```

## Follow streams

Reconstruct a conversation:

1. Right-click a packet.
2. Select Follow > TCP Stream, UDP Stream, HTTP Stream, or TLS Stream.
3. Review the reconstructed data.
4. Switch between ASCII, Hex, and Raw views.
5. Apply the generated stream filter if needed.

Use stream review to inspect request/response pairs, transmitted data, plaintext credentials, and unusual commands. TLS streams require decryption keys.

## Statistical analysis

Use the Statistics menu for traffic overview:

- Protocol Hierarchy: protocol percentages, packet counts, byte counts.
- Conversations: Ethernet, IPv4/IPv6, TCP, and UDP pairs.
- Endpoints: addresses, packet counts, byte counts.
- Flow Graph: packet sequence, timing, and direction.
- I/O Graphs: packets or bytes over time, with custom filters and overlays.

## Security analysis

Port scan detection:

```text
ip.src == SUSPECT_IP && tcp.flags.syn == 1
```

Also review Statistics > Conversations for one source hitting many destination ports.

Suspicious traffic filters:

```text
tcp.dstport > 1024 && tcp.dstport < 49152
!(ip.addr == 192.168.1.0/24)
dns.qry.name contains "suspicious-domain"
frame.len > 1400
```

ARP spoofing detection:

```text
arp.duplicate-address-frame
arp
```

Look for multiple MAC addresses for one IP, gratuitous ARP floods, and unusual ARP patterns.

HTTP download analysis:

```text
http.request.method == "GET" && http contains "Content-Disposition"
```

Follow the HTTP stream or use File > Export Objects > HTTP to extract files.

DNS analysis:

```text
dns
dns.flags.response == 0
dns.flags.response == 1
dns.flags.rcode != 0
dns.qry.name contains "domain.com"
```

## Expert information

Open Analyze > Expert Information. Categories:

- Errors: critical issues.
- Warnings: potential problems.
- Notes: informational items.
- Chats: normal conversation events.

Common findings:

| Finding | Meaning | Action |
|---|---|---|
| TCP Retransmission | Packet resent | Check packet loss |
| Duplicate ACK | Possible loss | Investigate network path |
| Zero Window | Receiver buffer full | Check receiver performance |
| RST | Connection reset | Check blocks or errors |
| Out-of-Order | Packets reordered | Investigate if excessive |

## Quick reference

Shortcuts:

| Action | Shortcut |
|---|---|
| Open file | Ctrl+O |
| Save file | Ctrl+S |
| Start/Stop capture | Ctrl+E |
| Find packet | Ctrl+F |
| Go to packet | Ctrl+G |
| Next packet | Down arrow |
| Previous packet | Up arrow |
| First packet | Ctrl+Home |
| Last packet | Ctrl+End |
| Apply filter | Enter |
| Clear filter | Ctrl+Shift+X |

Common protocol filters:

```text
http || https
smtp || pop || imap
smb || smb2 || ftp
ldap || kerberos
snmp || icmp
tls || ssl
```

Export options:

- File > Export Specified Packets: save filtered subset.
- File > Export Objects > HTTP: extract HTTP files.
- File > Export Packet Dissections: export as text or CSV.

## Constraints and guardrails

- Capture only authorized traffic.
- Protect PCAP files that contain sensitive data.
- Avoid unnecessary capture of credentials.
- Follow privacy and retention policies.
- Large captures consume memory.
- Encrypted payload content is not visible without keys.
- High-speed capture may drop packets.
- Some protocols need plugins for full decoding.

Best practices:

- Use capture filters to reduce data.
- Save captures regularly during long sessions.
- Use display filters instead of deleting packets.
- Document findings and methodology.

## Examples

Example 1: HTTP credential analysis

1. Filter: `http.request.method == "POST"`.
2. Look for login forms.
3. Follow HTTP Stream.
4. Search for username and password parameters.

Example 2: Malware C2 detection

1. Filter: `dns`.
2. Look for unusual query patterns.
3. Check for high-frequency beaconing.
4. Identify domains with random-looking names.
5. Filter: `ip.dst == SUSPICIOUS_IP`.
6. Analyze traffic patterns.

Indicators: regular timing intervals, encoded or encrypted payloads, unusual ports or protocols.

Example 3: Network troubleshooting

1. Filter: `ip.addr == WEB_SERVER`.
2. Check Statistics > Service Response Time.
3. Filter: `tcp.analysis.retransmission`.
4. Review I/O Graph for patterns.
5. Check for high latency or packet loss.

## Troubleshooting

No packets captured:

- Verify the correct interface.
- Check admin or root permissions.
- Confirm the adapter is active.
- Disable promiscuous mode if needed.

Filter not working:

- Check syntax; red text indicates an error.
- Check field name spelling.
- Use the Expression button.
- Clear and rebuild the filter incrementally.

Performance issues:

- Use capture filters.
- Split large captures.
- Disable name resolution during capture.
- Close unnecessary protocol dissectors.

Cannot decrypt TLS/SSL:

- Obtain the server private key.
- Configure it at Edit > Preferences > Protocols > TLS.
- Capture the pre-master secret from the browser for ephemeral keys.
- Some modern ciphers cannot be decrypted passively.

## Related skills

Load these when the task spans more than this skill.

- [`network-service-pentesting`](../network-service-pentesting/SKILL.md) — Assess SSH and SMTP services for weak configurations, credential exposure, vulnerabilities, open relays, tunne…
- [`web-vulnerability-testing`](../web-vulnerability-testing/SKILL.md) — Test web applications for OWASP-aligned vulnerabilities across injection, authentication, access control, API,…
- [`cloud-pentesting`](../cloud-pentesting/SKILL.md) — Assess authorized AWS, Azure, and GCP environments: reconnaissance, IAM and resource enumeration, metadata and…
- [`active-directory-attacks`](../active-directory-attacks/SKILL.md) — Authorized Active Directory penetration-testing techniques: reconnaissance, credential attacks, Kerberos ticke…
- [`observability`](../observability/SKILL.md) — Observability skill provides practical guidance for building, querying, and visualizing production‑grade monit…
