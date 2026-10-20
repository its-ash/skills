---
name: application-security
description: "Application security guidance covering threat modeling, secure design, code review, dependency and supply-chain risk, vulnerability prioritization, penetration testing, cryptography, cloud security, and compliance. Use when threat modeling a repository, auditing npm PyPI crates.io dependencies, hardening GitHub Actions CI/CD pipelines, reviewing code for OWASP Top 10 2025 flaws, designing authentication authorization API security, implementing cryptography, assessing cloud infrastructure risk, prioritizing CVEs, checking malicious package IOCs, mapping attack surfaces, or meeting compliance requirements."
---

# Application Security

Application security covers the design, implementation, and operation of software so that it resists unauthorized access, data exposure, and abuse. Use this skill to assess and improve security across code, dependencies, infrastructure, and processes.

## When to use

- Design or review application security architecture.
- Perform threat modeling for a feature, service, or system.
- Review code for injection, access control, secrets, and unsafe patterns.
- Assess dependencies, lockfiles, CI/CD, and build integrity.
- Plan or review authorized penetration testing.
- Implement or review cryptography and key management.
- Prepare for security audits or compliance reviews.
- Triage and remediate vulnerability findings.

## Core mindset

| Principle | Application |
| --- | --- |
| Assume breach | Design as if an attacker is already inside. |
| Zero trust | Never trust; always verify identity and authorization. |
| Defense in depth | Use multiple independent controls. |
| Least privilege | Grant only the access required for the task. |
| Fail secure | Deny access when an operation errors or is ambiguous. |
| Secure defaults | Choose safe settings unless an explicit, reviewed exception exists. |

Before assessing a system, answer four questions:

- What are we protecting? Identify data, functions, secrets, and availability requirements.
- Who might attack? Consider anonymous users, authenticated users, administrators, insiders, and third parties.
- How might they attack? Map entry points, trust boundaries, and data flows.
- What is the business impact? Estimate data loss, service disruption, fraud, and recovery cost.

## Threat modeling

1. Identify assets and security objectives.
2. Map entry points, data flows, and trust boundaries.
3. Enumerate threats using STRIDE: spoofing, tampering, repudiation, information disclosure, denial of service, and elevation of privilege.
4. Rate each threat by likelihood and impact.
5. Define mitigations, owners, and verification steps.
6. Re-run the model after architecture or dependency changes.

## OWASP Top 10:2025

| Rank | Category | Focus |
| --- | --- | --- |
| A01 | Broken access control | IDOR, SSRF, missing authorization, privilege escalation |
| A02 | Security misconfiguration | Defaults, headers, exposed services, cloud settings |
| A03 | Software supply chain | Dependencies, lockfiles, CI/CD, build integrity |
| A04 | Cryptographic failures | Weak algorithms, exposed secrets, poor key handling |
| A05 | Injection | Untrusted input reaching commands, queries, or templates |
| A06 | Insecure design | Flawed architecture and missing security requirements |
| A07 | Authentication failures | Sessions, credentials, MFA, account recovery |
| A08 | Integrity failures | Unsigned updates, tampered artifacts, unsafe deserialization |
| A09 | Logging and alerting failures | Blind spots, missing audit trails, weak monitoring |
| A10 | Exceptional conditions | Error handling, fail-open states, resource exhaustion |

Key 2025 shifts: SSRF is part of access control; supply chain is a major focus; exceptional conditions is new; root causes matter more than symptoms.

## Secure design rules

- Validate input at every trust boundary.
- Encode output for its execution context.
- Use parameterized queries or safe query builders.
- Enforce authorization on every request, including object-level checks.
- Keep secrets out of source code, logs, and client bundles.
- Apply least privilege to users, services, tokens, and database accounts.
- Fail closed when validation, parsing, or authorization is uncertain.
- Log security events without recording secrets or sensitive payloads.
- Design updates, rollback, and incident response before deployment.

## Authentication and authorization

- Require MFA for privileged, remote, and high-risk actions.
- Store passwords with Argon2id, bcrypt, or scrypt.
- Use short-lived access tokens and rotate refresh tokens.
- Revoke sessions after password changes, privilege changes, and logout.
- Do not rely on client-side authorization decisions.
- Test for IDOR by changing object identifiers across user roles.

## API security

- Authenticate every endpoint unless it is intentionally public.
- Validate request schema, content type, and size limits.
- Rate limit by user, IP address, and endpoint.
- Use explicit allowlists for CORS origins.
- Return generic errors to clients and detailed diagnostics to server logs.
- Prevent SSRF with URL allowlists, DNS validation, and network segmentation.

## Cryptography

- Use vetted libraries; do not implement custom cryptography.
- Use TLS 1.2 or newer; prefer TLS 1.3.
- Use AES-256-GCM or ChaCha20-Poly1305 for symmetric encryption.
- Use RSA 2048 bits or larger, or ECDSA P-256 or stronger, for asymmetric operations.
- Hash passwords with Argon2id, bcrypt, or scrypt.
- Use SHA-256 or stronger for integrity checks.
- Generate keys, IVs, and nonces with a cryptographically secure random source.
- Rotate keys and support decryption of data encrypted with older keys.
- Never reuse an IV or nonce with the same key.
- Avoid MD5, SHA-1, DES, 3DES, ECB mode, static IVs, and custom crypto.

Example password hashing:

```python
from argon2 import PasswordHasher

ph = PasswordHasher()
stored = ph.hash(password)
ph.verify(stored, password)
```

## Supply chain security

- Commit lockfiles and review dependency changes.
- Pin direct and transitive dependencies where practical.
- Audit new dependencies before adoption.
- Use private registries for internal packages.
- Verify checksums and signatures.
- Generate a software bill of materials (SBOM).
- Restrict CI/CD token permissions and protect the default branch.
- Scan dependencies continuously.
- Review install scripts and postinstall hooks.

## Attack surface mapping

| Category | Elements |
| --- | --- |
| Entry points | APIs, forms, file uploads, webhooks, admin panels |
| Data flows | Input, processing, storage, output, third-party calls |
| Trust boundaries | Authentication, authorization, validation, network edges |
| Assets | Secrets, PII, business data, availability, integrity |

## Risk prioritization

Use both vulnerability severity and business context.

```
Risk = Likelihood x Impact

High impact + high likelihood -> Critical
High impact + low likelihood -> High
Low impact + high likelihood -> Medium
Low impact + low likelihood -> Low
```

Prioritization decision tree:

```
Is it actively exploited (EPSS > 0.5)?
├── Yes -> Critical: immediate action
└── No -> Check CVSS
    ├── CVSS >= 9.0 -> High
    ├── CVSS 7.0-8.9 -> Consider asset value and exposure
    └── CVSS < 7.0 -> Schedule for later
```

Weight findings by CVSS score, exploit likelihood, asset value, and internet exposure.

## Code review patterns

| Pattern | Risk | Look for |
| --- | --- | --- |
| String concatenation in queries | Injection | `"SELECT * FROM users WHERE id = " + input` |
| Dynamic code execution | RCE | `eval()`, `exec()`, `Function()` |
| Unsafe deserialization | RCE | `pickle.loads()`, `unserialize()` |
| Path manipulation | Traversal | User input in file paths |
| Disabled security | Various | `verify=False`, `--insecure` |

Secret indicators:

| Type | Indicators |
| --- | --- |
| API keys | `api_key`, `apikey`, high entropy |
| Tokens | `token`, `bearer`, JWT values |
| Credentials | `password`, `secret`, private keys |
| Cloud | `AWS_`, `AZURE_`, `GCP_` prefixes |

Safe patterns:

- Use parameterized queries.
- Validate against allowlists.
- Encode output for HTML, JavaScript, URLs, and SQL contexts.
- Deserialize only trusted, schema-validated data.
- Normalize and validate file paths.
- Set secure cookie flags and a content security policy.

Example parameterized query:

```sql
SELECT id, email FROM users WHERE id = ?;
```

## Exceptional conditions

| Scenario | Fail-open (bad) | Fail-closed (good) |
| --- | --- | --- |
| Authentication error | Allow access | Deny access |
| Parsing failure | Accept input | Reject input |
| Timeout | Retry forever | Limit retries and abort |

Check for:

- Catch-all exception handlers that ignore errors.
- Missing error handling around security operations.
- Race conditions in authentication or authorization.
- Resource exhaustion and unbounded retries.

## Cloud security

| Layer | You own | Provider owns |
| --- | --- | --- |
| Data | Yes | No |
| Application | Yes | No |
| OS and runtime | Depends | Depends |
| Infrastructure | No | Yes |

Cloud checks:

- Apply least privilege in IAM.
- Prevent public storage buckets unless explicitly required.
- Tighten security groups and network access.
- Store secrets in a secrets manager.
- Enable audit logging and alerting.

## Scanning methodology

1. Reconnaissance: identify technology stack, entry points, and data flows.
2. Discovery: review configuration, dependencies, and code patterns.
3. Analysis: eliminate false positives, score risk, and map attack chains.
4. Reporting: provide reproduction steps, business impact, and remediation.

Run SAST, DAST, software composition analysis, secret scanning, and infrastructure-as-code scanning. Re-scan after changes and on a schedule.

## Vulnerability management

- Maintain an asset inventory.
- Triage findings by exploitability and asset value.
- Reproduce findings when feasible before remediation.
- Fix root causes, not symptoms.
- Track remediation to completion and verify the fix.
- Retest after code or configuration changes.
- Maintain a documented exception process with expiry dates.

## Penetration testing

- Obtain written authorization and a defined scope.
- Agree on rules of engagement and stop conditions.
- Test in approved environments and windows.
- Report reproducible steps, impact, and remediation guidance.
- Avoid destructive actions unless explicitly approved.
- Remediate findings and retest.

## Compliance

- Map controls to applicable requirements such as OWASP ASVS, NIST SSDF, ISO 27001, SOC 2, or PCI DSS.
- Keep evidence: configurations, logs, scan reports, and access reviews.
- Review access rights on a regular schedule.
- Document exceptions with owners and expiry dates.
- Train developers on secure coding practices.

## Anti-patterns

| Avoid | Do instead |
| --- | --- |
| Scan without understanding the system | Map the attack surface first |
| Alert on every CVE | Prioritize by exploitability and asset value |
| Ignore false positives | Maintain a verified baseline |
| Fix symptoms only | Address root causes |
| Scan once before deploy | Scan continuously |
| Trust third-party dependencies blindly | Verify integrity and audit code |

## Reporting principles

Each finding should answer:

- What is the vulnerability?
- Where is it located?
- Why does it occur?
- What is the business impact?
- How should it be fixed?

Severity classification:

| Severity | Criteria |
| --- | --- |
| Critical | Remote code execution, authentication bypass, mass data exposure |
| High | Data exposure, privilege escalation |
| Medium | Limited scope or requires specific conditions |
| Low | Informational or best-practice issue |

## Checklist

- Threat model is current and reviewed.
- Access control is enforced server-side for every request.
- Inputs are validated and outputs are encoded.
- Queries use parameters or safe builders.
- Secrets are stored outside code and logs.
- Dependencies and lockfiles are audited.
- CI/CD permissions are least privilege.
- Cryptography uses current, vetted algorithms.
- Security logging and alerting are enabled.
- Error handling fails closed.
- Cloud IAM, storage, and network settings are reviewed.
- Findings are triaged, remediated, and retested.

Remember: vulnerability scanning finds issues; expert judgment prioritizes what matters. Always ask what an attacker could do with a finding.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/supply-chain-security.md](references/supply-chain-security.md) | Detect and remediate software supply chain attacks across npm, PyPI, crates.io, GitHub Actions, and CI/CD pipelines. Use when auditing dependencies, investigating compromises, hardening pipelines, or checking exposure to known malicious packages and IOCs. |
| [references/threat-modeling.md](references/threat-modeling.md) | Repository-grounded threat modeling for an explicitly requested codebase or path. Enumerates trust boundaries, assets, attacker capabilities, abuse paths, mitigations, and writes a concise Markdown threat model. |

## Related skills

Load these when the task spans more than this skill.

- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`security-compliance`](../security-compliance/SKILL.md) — Guides security and compliance work: risk assessment, control selection, framework mapping, ISMS implementatio…
- [`web-vulnerability-testing`](../web-vulnerability-testing/SKILL.md) — Test web applications for OWASP-aligned vulnerabilities across injection, authentication, access control, API,…
- [`pentest-methodology`](../pentest-methodology/SKILL.md) — Plan and run authorized penetration tests: scope, reconnaissance, scanning, exploitation, post-exploitation, r…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`file-uploads`](../file-uploads/SKILL.md) — Handles file uploads and cloud storage with S3, Cloudflare R2, presigned URLs, multipart uploads, and image op…
- [`electron`](../electron/SKILL.md) — Master Electron desktop app development with secure IPC, contextIsolation, preload scripts, multi-process arch…
