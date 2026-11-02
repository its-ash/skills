---
name: healthcare
description: "Healthcare software guidance for HIPAA, PHI and PII handling, EMR and EHR workflows, clinical decision support, and patient-safety deployment gates. Use when a task mentions HIPAA, PHI, covered entities, business associates, BAAs, breach posture, patient records, EMR, EHR, encounters, prescriptions, drug interactions, dose validation, NEWS2, qSOFA, HL7, FHIR, or US healthcare compliance. Sub-skills: phi-compliance, emr, cdss, eval-harness."
---

# Healthcare
Build software that stores, moves, or acts on patient data without PHI leaks or patient-safety risk.

## Core rules
- Treat HIPAA as an overlay on the PHI rules in [references/phi-compliance.md](references/phi-compliance.md).
- Never put PHI in logs, analytics events, crash reports, prompts, or client-visible error strings.
- Never put PHI in URLs, browser storage, screenshots, or copied example payloads.
- Require authentication, scoped authorization, and an audit trail for each PHI read, write, and export.
- Block third-party SaaS, observability, support tools, and LLM providers by default until BAA status and data boundaries are clear.
- Apply minimum necessary access: each user sees only the smallest PHI slice the task needs.
- Use opaque internal IDs, not names, MRNs, phone numbers, addresses, or other identifiers.
- Assume free text (support transcripts, patient messages) contains PHI.
- For patient-safety, clinical-workflow, or regulated production changes: get a second review from the `healthcare-reviewer` agent and gate release with [references/eval-harness.md](references/eval-harness.md).

## Decisions
HIPAA gates, in order:

| Question | If yes | If no / unknown |
|---|---|---|
| Is this data PHI? | Apply all core rules | Confirm it cannot re-identify a patient |
| Is the actor a covered entity or business associate? | HIPAA duties apply | Check contracts before you assume exemption |
| Does a vendor or model provider touch the data? | Require a signed BAA first | Proceed |
| Is access limited to minimum necessary scope? | Proceed | Narrow roles, fields, or rows |
| Can you audit each read, write, and export? | Proceed | Add audit trail before release |

| Situation | Do | Avoid |
|---|---|---|
| AI visit summaries for clinicians | Confirm BAA with the LLM provider; review prompt boundaries; apply [cdss](references/cdss.md) if summaries affect decisions | Sending PHI to a provider with no BAA |
| Send patient messages to analytics | Use a non-PHI event model or redact; require HIPAA-approved vendor | Raw message text in events |
| General auth, secrets, API hardening | Use [`secure-coding`](../secure-coding/SKILL.md) | Restating those rules here |

## Load on demand
| Need | Read |
|---|---|
| PHI/PII classification, row-level security, tamper-proof audit trails, schema tagging, leak vectors (logs, URLs, browser storage, service role keys); HIPAA, DISHA, GDPR | [references/phi-compliance.md](references/phi-compliance.md) |
| EMR/EHR: encounter workflows, clinical templates, medication safety, locked encounters and addenda, prescription PDFs, labs and vitals, accessible data entry | [references/emr.md](references/emr.md) |
| CDSS: drug interactions, dose validation, NEWS2, qSOFA, alert severity, zero-false-negative tests | [references/cdss.md](references/cdss.md) |
| Deploy gate: CDSS accuracy, PHI exposure, data integrity, clinical workflows, HL7/FHIR integration tests in CI | [references/eval-harness.md](references/eval-harness.md) |

## Related skills
- [`secure-coding`](../secure-coding/SKILL.md) — auth, secrets, hardening; privacy in `references/data-privacy-compliance.md`
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Jest and pytest for CDSS and PHI suites
- [`database-design`](../database-design/SKILL.md) — patient-data schema and row-level security
