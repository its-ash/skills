---
name: security-compliance
description: "Guides security and compliance programs including risk assessment, control selection, framework mapping, ISMS implementation, incident response, vulnerability management, third-party risk, audits, and continuous monitoring. Use when working on SOC 2, ISO 27001, HIPAA, GDPR, PCI-DSS, security policies, audit readiness, risk registers, control matrices, vendor assessments, or security operations."
---

# Security & Compliance

This skill guides security and compliance work across risk assessment, control selection, framework mapping, ISMS implementation, incident response, vulnerability management, third-party risk, audits, and continuous monitoring. Use it when designing or operating a security program, preparing for SOC 2, ISO 27001, HIPAA, GDPR, PCI-DSS, or similar requirements.

## When to use

- Design defense-in-depth, Zero Trust, or segmented architectures.
- Assess and prioritize security risks.
- Select and implement security controls.
- Choose and map compliance frameworks.
- Implement or audit an ISMS, including ISO 27001 and ISO 27002.
- Manage incidents, vulnerabilities, access reviews, and vendor risk.
- Prepare for internal or external security audits.

## Core principles

- Apply defense in depth. Use multiple independent controls.
- Use Zero Trust. Verify every access request.
- Grant least privilege. Review and revoke unused access.
- Build security into design. Do not add it later.
- Monitor continuously. Detect anomalies in real time.
- Prioritize by risk. Focus on critical assets and likely threats.
- Treat compliance as a baseline. Exceed minimum requirements.
- Prepare for incidents. Test response plans regularly.

## Security lifecycle

1. Assess and plan: assess posture, identify requirements, model threats, define policies, build roadmap.
2. Design and architect: design controls, Zero Trust, IAM, encryption, CI/CD security, threat models.
3. Implement and harden: deploy controls, harden systems, enable MFA, configure logging, start vulnerability management.
4. Monitor and detect: monitor SIEM, hunt threats, scan vulnerabilities, track metrics, review access.
5. Respond and recover: contain, eradicate, recover, review incidents, notify regulators when required.
6. Audit and improve: audit controls, update policies, train staff, run exercises, improve continuously.

## Risk assessment

Use this process to identify and prioritize risks.

1. Identify assets: systems, data, services, owners, business value.
2. Identify threats: threat actors, motivations, current trends.
3. Identify vulnerabilities: weaknesses, missing controls, known CVEs.
4. Calculate risk: Risk = Likelihood x Impact.
5. Prioritize risks.
6. Choose a response: mitigate, accept, transfer, or avoid.

Likelihood scale (1-5):
- 1 = Rare (<5% in one year)
- 2 = Unlikely (5-25%)
- 3 = Possible (25-50%)
- 4 = Likely (50-75%)
- 5 = Almost certain (>75%)

Impact scale (1-5):
- 1 = Minimal (<$10K, no data breach)
- 2 = Minor ($10K-$100K, limited exposure)
- 3 = Moderate ($100K-$1M, significant breach)
- 4 = Major ($1M-$10M, extensive breach or fines)
- 5 = Catastrophic (>$10M or business-threatening)

Risk score = Likelihood x Impact (max 25).

Prioritize:
- Critical: 15-25, act immediately.
- High: 10-14, act within 30 days.
- Medium: 5-9, act within 90 days.
- Low: 1-4, monitor or accept.

Output: risk register with owners, scores, and mitigation plans.

## Security control selection

Use NIST CSF functions to organize controls:
- Identify: asset management, risk assessment, governance.
- Protect: access control, data security, protective technology.
- Detect: anomalies, monitoring, detection processes.
- Respond: planning, communications, analysis, mitigation.
- Recover: recovery planning, improvements, communications.

Control types:
- Preventive: stop incidents before they occur.
- Detective: identify incidents when they occur.
- Corrective: fix issues after detection.
- Deterrent: discourage attackers.
- Compensating: alternative controls when primary controls are not feasible.

Selection criteria:
- Does it address the identified risk?
- Is it cost-effective? Control cost should be less than risk value.
- Is it technically feasible?
- Does it meet compliance requirements?
- Can the team maintain and monitor it?

## Compliance framework selection

Choose frameworks by organization type:
- SaaS or cloud provider: SOC 2 Type II for enterprise sales; ISO 27001 for international customers; HIPAA and HITRUST for health data; PCI-DSS for card data.
- Healthcare provider or payer: HIPAA for U.S. operations; add GDPR for international data; use HITRUST for a comprehensive framework.
- Financial services: GLBA and SOX where applicable; PCI-DSS for payment processing; ISO 27001 and local regulations internationally; NIST CSF as a framework.
- E-commerce or retail: PCI-DSS for card data; GDPR for EU customers; CCPA for California customers; SOC 2 Type II for B2B sales.
- General enterprise: SOC 2 Type II for enterprise sales; ISO 27001 for broad recognition; FedRAMP or NIST 800-53 for government contracts.

Multi-framework strategy:
- Start with SOC 2 or ISO 27001 as the foundation.
- Add privacy regulations as needed.
- Layer industry-specific requirements last.

## Incident severity classification

- P0 Critical: active breach, ransomware in progress, critical outage, unauthorized production database access. Respond immediately with 24/7 effort.
- P1 High: confirmed malware on critical systems, attempted sensitive data access, DDoS, actively exploited critical vulnerability. Respond within one hour.
- P2 Medium: malware on non-critical systems, suspicious account activity, security policy violations, patchable vulnerability. Respond within four hours.
- P3 Low: failed logins below threshold, minor violations, informational events. Respond within 24 hours.

Classify by data confidentiality, availability, integrity, affected scope, and regulatory reporting requirements.

## Vulnerability prioritization

Priority score = Base CVSS score x Business context multiplier.

CVSS severity:
- Critical: 9.0-10.0
- High: 7.0-8.9
- Medium: 4.0-6.9
- Low: 0.1-3.9

Business context multipliers:
- Internet-facing production system: 2.0
- Internal production system: 1.5
- System with sensitive data: 1.5
- Development or test environment: 0.5
- Active exploit in the wild: 2.0
- Compensating controls in place: 0.7

Priority levels:
- P0: score 14 or higher, patch within 24-48 hours.
- P1: score 10-13.9, patch within 7 days.
- P2: score 6-9.9, patch within 30 days.
- P3: score below 6, patch within 90 days or accept risk.

Also consider isolation options, detective controls, patching complexity, and vendor patch availability.

## Third-party risk assessment

Categorize vendors:
- Low risk: no system or data access, limited integration, non-critical service. Use a simple questionnaire.
- Medium risk: limited system access, non-sensitive data, important service. Use a questionnaire plus evidence review.
- High risk: production access, sensitive data, critical dependency. Use full assessment, audit reports, and penetration test results.
- Critical risk: full production access, PHI or PII processing, business-critical dependency. Use on-site audit, continuous monitoring, and SLA terms.

Assessment components for medium, high, and critical vendors:
- Security questionnaire (SIG, CAIQ, or custom).
- Compliance certifications (SOC 2, ISO 27001).
- Cyber liability insurance certificate.
- Security policies and procedures.
- Incident response plan.
- Disaster recovery and business continuity plan.
- Data processing agreement.
- Penetration test results for high and critical vendors.
- Right-to-audit clause in the contract.

Ongoing monitoring:
- Reassess annually.
- Monitor breaches and incidents.
- Review security updates and patches.
- Track certification renewals.
- Audit critical vendors periodically.

Vendor risk score (0-100):
- Security maturity: 40 points.
- Compliance certifications: 20 points.
- Incident history: 15 points.
- Financial stability: 15 points.
- References and reputation: 10 points.

Actions:
- 80-100: approved.
- 60-79: approved with conditions.
- 40-59: requires remediation plan.
- Below 40: do not engage.

## Key frameworks and standards

- NIST CSF: risk-based framework with five functions. Best for general organizations and government contractors.
- CIS Controls: 18 prioritized controls with implementation groups. Best for practical defense.
- ISO/IEC 27001: international ISMS standard. Best for formal certification and international recognition.
- ISO/IEC 27002: control guidance for organizational, people, physical, and technological controls.
- SOC 2 Type II: service organization controls over a 3-12 month observation period. Best for SaaS and cloud providers.
- NIST 800-53: 20 control families for federal systems. Best for government contractors and FedRAMP.
- GDPR: EU data privacy regulation with breach notification and data subject rights. Penalties up to 4% of global revenue or EUR 20M.
- HIPAA: protects PHI through administrative, physical, and technical safeguards.
- PCI-DSS: 12 requirements for cardholder data. Required for storing, processing, or transmitting card data.

## Core security domains

- Identity and access management: MFA, SSO, RBAC, ABAC, PAM, IGA, directory services.
- Network security: segmentation, firewalls, IDS/IPS, VPN, ZTNA, DDoS protection.
- Data security: encryption, key management, classification, DLP, database security, secrets management.
- Application security: secure SDLC, SAST, DAST, SCA, code review, OWASP Top 10 mitigation.
- Cloud security: CSPM, CASB, container security, serverless security, IaC scanning, multi-cloud architecture.
- Endpoint security: EDR, antivirus, host firewalls, device encryption, MDM, patch management.
- Security operations: SIEM, SOAR, threat intelligence, threat hunting, vulnerability management, penetration testing.
- Incident response: plans, playbooks, forensics, malware analysis, containment, recovery, notification.
- Governance, risk, and compliance: policies, risk management, audits, training, vendor risk, business continuity.

## ISO 27001 ISMS implementation

Use this when building or certifying an ISMS.

ISMS lifecycle:
- Planning and design: security policy, scope, risk methodology, security objectives.
- Risk management: asset identification, threat and vulnerability assessment, risk analysis, treatment planning.
- Control implementation: select ISO 27002 controls, deploy technical, administrative, and physical controls.
- Operation and monitoring: incident management, performance monitoring, management review, continuous improvement.

Risk assessment methodology:
- Identify and classify assets by criticality and protection requirements.
- Analyze threats and vulnerabilities for the relevant environment.
- Assess likelihood and impact, then determine and prioritize risk.
- Select risk treatment options and document residual risk.

ISO 27002 control domains:
- Organizational controls: policies, organization of security, HR security, supplier relationships.
- People controls: screening, awareness, disciplinary processes, remote working.
- Physical controls: perimeters, equipment protection, secure disposal, clear desk and screen.
- Technological controls: access control, cryptography, systems security, network security, application security, secure development, supplier security.

Healthcare-specific requirements:
- Implement HIPAA technical safeguards: access control, audit controls, integrity, transmission security.
- Assess medical device cybersecurity using architecture review, vulnerability testing, threat modeling, and update management.
- Protect clinical trial data and patient privacy.
- Secure interoperability, including HL7 FHIR.

Cloud security:
- Assess cloud providers and shared responsibilities.
- Address data residency and sovereignty.
- Manage cloud identity and access.
- Document customer and provider security responsibilities.

Privacy and data protection integration:
- Apply privacy by design.
- Enforce data minimization and retention limits.
- Support data subject rights with technical measures.
- Secure cross-border data transfers.

Governance and operations:
- Maintain an information security policy, acceptable use policy, access control policy, incident response policy, and business continuity policy.
- Run security awareness training for all staff, role-based training, incident response training, and regular updates.
- Manage incidents through detection, classification, investigation, containment, recovery, and lessons learned.

Performance and compliance:
- Track control effectiveness, incident performance, compliance status, risk treatment success, and awareness metrics.
- Conduct risk-based internal audits, technical testing, compliance audits, and process audits.
- Run management reviews covering performance, risk, compliance, investment, and strategy.
- Manage ISO 27001 certification through readiness, Stage 1 and Stage 2 audits, surveillance audits, and renewal.

Regulatory compliance:
- Map controls to HIPAA, GDPR, FDA cybersecurity guidance, and NIST CSF as applicable.

## Common workflows

### Incident response

1. Detect and alert.
2. Triage and classify by severity.
3. Investigate scope and evidence.
4. Contain affected systems and accounts.
5. Eradicate malware and close vulnerabilities.
6. Recover and verify integrity.
7. Review root cause and update playbooks.
8. Report to stakeholders and regulators when required.

### Vulnerability management

1. Discover and inventory assets.
2. Scan with authenticated, unauthenticated, and agent-based methods.
3. Validate findings and remove false positives.
4. Prioritize using CVSS plus business context.
5. Remediate, apply compensating controls, or update configuration.
6. Rescan to verify fixes.
7. Report metrics, trends, and executive status.

### Access review

1. Schedule quarterly reviews.
2. Generate reports for users, privileged accounts, service accounts, and orphaned accounts.
3. Distribute reports to managers.
4. Certify appropriate access and flag exceptions.
5. Revoke unapproved access and disable orphaned accounts.
6. Document completion rates and changes.

### SOC 2 audit preparation

1. Scope systems and select Trust Service Criteria 3-4 months before audit.
2. Assess gaps and create remediation plans 2-3 months before.
3. Implement controls and document procedures 1-2 months before.
4. Collect evidence continuously.
5. Support auditor fieldwork for 4-6 weeks.
6. Review draft report and address exceptions.
7. Monitor controls continuously after issuance.

### ISO 27001 certification management

1. Perform gap analysis and remediation.
2. Coordinate Stage 1 and Stage 2 audits.
3. Prepare surveillance audit evidence.
4. Manage certificate renewal and scope changes.

## Security metrics and KPIs

Risk and compliance:
- Open critical and high risks.
- Mean time to remediate risk.
- Open audit findings.
- Control effectiveness rate.
- Policy acknowledgment rate.
- Training completion rate.

Vulnerability management:
- Mean time to detect vulnerabilities.
- Mean time to patch.
- Open vulnerability backlog by severity.
- Patch compliance rate.
- Vulnerability recurrence rate.

Incident response:
- Mean time to detect incidents.
- Mean time to respond.
- Mean time to contain.
- Mean time to recover.
- Incidents by severity.
- Incident recurrence rate.
- False positive rate.

Security operations:
- SIEM alert volume and severity.
- Alert triage time.
- Alert false positive rate.
- Asset monitoring coverage.
- Threat hunting coverage.
- Penetration test findings.

Access management:
- MFA adoption rate.
- Privileged account review completion.
- Access certification completion.
- Orphaned account count.
- Password policy compliance.
- Failed login rate.

Awareness and culture:
- Phishing simulation click rate.
- Training completion rate.
- Awareness quiz scores.
- Policy violations.
- Security helpdesk tickets.

## Security tools ecosystem

- SIEM: Splunk Enterprise Security, IBM QRadar, Microsoft Sentinel, Elastic Security, Sumo Logic.
- EDR/XDR: CrowdStrike Falcon, SentinelOne, Microsoft Defender for Endpoint, Palo Alto Cortex XDR, Carbon Black.
- Vulnerability management: Tenable Nessus/Tenable.io, Qualys VMDR, Rapid7 InsightVM, Greenbone OpenVAS.
- Cloud security: Wiz, Prisma Cloud, Lacework, Orca Security, AWS Security Hub, Azure Security Center, GCP Security Command Center.
- SAST/DAST: Snyk, Veracode, Checkmarx, SonarQube, OWASP ZAP.
- Container security: Aqua Security, Sysdig Secure, Prisma Cloud Compute, Trivy.
- Secrets management: HashiCorp Vault, AWS Secrets Manager, Azure Key Vault, CyberArk.
- Identity and access: Okta, Auth0, Azure AD/Entra ID, Ping Identity, CyberArk.

## Best practices

- Shift security left into design and CI/CD.
- Use secure defaults and fail securely.
- Enforce MFA everywhere.
- Use just-in-time privileged access.
- Disable accounts promptly on termination.
- Avoid shared accounts and service account abuse.
- Centralize logging in a SIEM.
- Automate detection and response where possible.
- Test incident response through tabletop exercises.
- Keep vulnerability remediation SLAs aggressive.
- Review and certify access regularly.
- Encrypt data at rest and in transit.

## Checklist

- [ ] Risk register exists and is prioritized.
- [ ] Compliance scope and frameworks are documented.
- [ ] Security architecture uses defense in depth and Zero Trust.
- [ ] IAM enforces MFA and least privilege.
- [ ] Data is classified and encrypted.
- [ ] Logging and monitoring cover critical assets.
- [ ] Incident response plan is tested.
- [ ] Vulnerability scanning and remediation SLAs are active.
- [ ] Access reviews occur on schedule.
- [ ] Third-party risk assessments are current.
- [ ] Policies and training are maintained.
- [ ] Audit evidence is collected continuously.
- [ ] Metrics and KPIs are reviewed regularly.

## Related skills

Load these when the task spans more than this skill.

- [`application-security`](../application-security/SKILL.md) — Application security guidance for threat modeling, secure design, code review, dependency and supply-chain ris…
- [`data-privacy-compliance`](../data-privacy-compliance/SKILL.md) — Implement and audit privacy compliance for GDPR/DSGVO, CCPA/CPRA, and HIPAA. Use for lawful basis, consent, da…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`secrets-management`](../secrets-management/SKILL.md) — Manage secrets for CI/CD and runtime systems with Vault, AWS Secrets Manager, GitHub/GitLab variables, Kuberne…
- [`it-operations`](../it-operations/SKILL.md) — Manages IT infrastructure, monitoring, incident response, and service reliability. Use this skill for ITIL ser…
- [`cloud-architecture`](../cloud-architecture/SKILL.md) — Provides step‑by‑step guidance, best‑practice rules, and checklists for designing, building, and optimizing se…
- [`network-service-pentesting`](../network-service-pentesting/SKILL.md) — Assess SSH and SMTP services for weak configurations, credential exposure, vulnerabilities, open relays, tunne…
