---
name: healthcare
description: "Healthcare software guidance for HIPAA, PHI and PII handling, EMR and EHR workflows, clinical decision support, and patient-safety deployment gates. Use when a task mentions HIPAA, PHI, covered entities, business associates, BAAs, breach posture, patient records, EMR, EHR, encounters, prescriptions, drug interactions, dose validation, NEWS2, qSOFA, HL7, FHIR, or US healthcare compliance. Sub-skills: phi-compliance, emr, cdss, eval-harness."
---

# Healthcare

Use this skill for healthcare software that stores, processes, exports, or transmits patient data, or that affects clinical decisions. Treat HIPAA as an overlay on the PHI rules in [references/phi-compliance.md](references/phi-compliance.md). Apply [`secure-coding`](../secure-coding/SKILL.md) for general auth, input handling, secrets, API, and deployment hardening.

## When to use

- The request mentions HIPAA, PHI, covered entities, business associates, or BAAs.
- You build or review US healthcare software that stores, processes, exports, or transmits PHI.
- You must find if logging, analytics, LLM prompts, storage, or support workflows cause HIPAA exposure.
- You design patient-facing or clinician-facing systems where minimum necessary access and audit trails are important.
- You build EMR or EHR features, clinical decision support, or deployment gates for clinical code.

## How it works

1. Start with [references/phi-compliance.md](references/phi-compliance.md) for the implementation rules.
2. Apply the HIPAA decision gates:
   - Is this data PHI?
   - Is this actor a covered entity or a business associate?
   - Does a vendor or model provider need a BAA before it touches the data?
   - Is access limited to the minimum necessary scope?
   - Can you audit each read, write, and export event?
3. If the task affects patient safety, clinical workflows, or regulated production architecture, do a second review with the `healthcare-reviewer` agent, and gate the release with [references/eval-harness.md](references/eval-harness.md).

## HIPAA guardrails

- Never put PHI in logs, analytics events, crash reports, prompts, or error strings that the client can see.
- Never put PHI in URLs, browser storage, screenshots, or copied example payloads.
- Require authenticated access, scoped authorization, and audit trails for PHI reads and writes.
- Block third-party SaaS, observability, support tools, and LLM providers by default until the BAA status and data boundaries are clear.
- Apply minimum necessary access: each user sees only the smallest PHI slice that the task needs.
- Use opaque internal IDs, not names, MRNs, phone numbers, addresses, or other identifiers.

## Examples

### Product request framed as HIPAA

> Add AI-generated visit summaries to our clinician dashboard. We serve US clinics and need to stay HIPAA compliant.

- Use [references/phi-compliance.md](references/phi-compliance.md) to review PHI movement, logging, storage, and prompt boundaries.
- Make sure that a BAA covers the summarization provider before you send PHI.
- If the summaries influence clinical decisions, apply [references/cdss.md](references/cdss.md) and get a review from the `healthcare-reviewer` agent.

### Vendor or tool decision

> Can we send support transcripts and patient messages into our analytics stack?

- Assume that those messages can contain PHI.
- Block the design unless the analytics vendor is approved for HIPAA workloads and the data path is minimized.
- Require redaction or a non-PHI event model when possible.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/phi-compliance.md](references/phi-compliance.md) | Code touches patient or clinician data: PHI and PII classification, row-level security, tamper-proof audit trails, schema tagging, and leak vectors (logs, URLs, browser storage, service role keys) for HIPAA, DISHA, or GDPR. |
| [references/emr.md](references/emr.md) | Build EMR or EHR features: encounter workflows, clinical templates, medication safety, locked encounters and addenda, prescription PDFs, lab and vitals display, and accessible clinical data entry UI. |
| [references/cdss.md](references/cdss.md) | Build clinical decision support: drug interaction checks, dose validation, NEWS2 and qSOFA scoring, alert severity classification, and CDSS tests with zero false negatives. |
| [references/eval-harness.md](references/eval-harness.md) | Gate a healthcare deployment on patient-safety tests for CDSS accuracy, PHI exposure, data integrity, clinical workflows, and HL7 or FHIR integration in CI. |

## Related skills

Load these when the task spans more than this skill.

- [`secure-coding`](../secure-coding/SKILL.md) — General auth, input validation, secrets, API, and deployment hardening; GDPR and HIPAA privacy programs in `references/data-privacy-compliance.md`.
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — Jest and pytest patterns for the CDSS and PHI test suites.
- [`database-design`](../database-design/SKILL.md) — Schema design and row-level security for patient data.
