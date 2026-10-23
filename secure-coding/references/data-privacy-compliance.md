# Data Privacy Compliance

Implement and audit privacy controls across GDPR/DSGVO, CCPA/CPRA, HIPAA, and related data protection laws. Apply privacy by design, document lawful processing, manage consent and data subject rights, assess risks, and respond to incidents.

## When to use

- Implementing GDPR, DSGVO, CCPA/CPRA, or HIPAA controls
- Conducting DPIAs or privacy risk assessments
- Managing data subject rights requests
- Building consent and cookie preference systems
- Drafting privacy notices and policies
- Responding to data breaches
- Designing privacy-by-design systems
- Auditing compliance or preparing for supervisory authority review

## Regulations and scope

### GDPR and DSGVO

- Scope: processing of EU residents' personal data, regardless of company location.
- Key requirements: lawful basis, data subject rights, DPIA for high-risk processing, 72-hour breach notification, records of processing, privacy by design and by default.
- Penalties: up to EUR 20M or 4% of global annual revenue.
- German DSGVO: coordinate GDPR with BDSG, state data protection laws, sectoral rules, and federal/state supervisory authorities.

### CCPA/CPRA

- Scope: California residents' personal information.
- Key requirements: right to know, delete, correct, opt out of sale/sharing, limit use of sensitive personal information.
- Penalties: up to $7,500 per intentional violation.

### HIPAA

- Scope: protected health information (PHI) in the US.
- Key requirements: Privacy Rule, Security Rule for ePHI, 60-day breach notification, business associate agreements.
- Penalties: up to $1.5M per violation category per year.

## Lawful basis and records

- Identify and document a lawful basis for each processing purpose: consent, contract, legal obligation, vital interests, public task, or legitimate interests.
- For special category data, identify an additional Article 9 basis and document it.
- Keep records of processing activities with purpose, data categories, data subjects, recipients, retention, security measures, and transfer details.
- Reassess purpose and legal basis when processing changes.

## Data subject rights

Implement request intake, identity verification, classification, fulfillment, documentation, and appeal handling.

Rights to support:
- Information and transparency (privacy notices)
- Access
- Rectification
- Erasure
- Restriction of processing
- Data portability
- Objection
- Withdrawal of consent

Timelines:
- GDPR: one month, extendable to three months.
- CCPA/CPRA: 45 days, extendable to 90 days.

Handle complex cases carefully: conflicting rights, third-party rights, legal retention obligations, and legitimate interest balancing.

### Access request handler

```javascript
async function handleAccessRequest(userId, email) {
  const verified = await verifyIdentity(email);
  if (!verified) throw new Error('Identity verification failed');

  const userData = await collectUserData(userId);
  const report = {
    personalInfo: userData.profile,
    activityLogs: userData.activities,
    preferences: userData.settings,
    thirdPartySharing: userData.dataSharing,
    retentionPeriod: '2 years from last activity',
    dataProtectionOfficer: 'dpo@company.com'
  };

  const pdf = await generatePDFReport(report);
  await logAccessRequest(userId, 'completed');
  return pdf;
}
```

### Deletion request handler

```javascript
async function handleDeletionRequest(userId, email) {
  const verified = await verifyIdentity(email);
  if (!verified) throw new Error('Identity verification failed');

  const mustRetain = await checkRetentionRequirements(userId);
  if (mustRetain.required) {
    return {
      status: 'partial_deletion',
      retained: mustRetain.data,
      reason: mustRetain.legalBasis,
      retentionPeriod: mustRetain.period
    };
  }

  await Promise.all([
    deleteFromDatabase(userId),
    deleteFromBackups(userId),
    deleteFromAnalytics(userId),
    deleteFromThirdPartyServices(userId),
    revokeAPIKeys(userId),
    anonymizeHistoricalRecords(userId)
  ]);

  await sendDeletionConfirmation(email);
  await logDeletionRequest(userId, 'completed');
  return { status: 'deleted', timestamp: new Date() };
}
```

Refuse or limit deletion only for documented legal obligations, public interest or research, defense of legal claims, or freedom of expression.

### Portability request handler

```javascript
async function handlePortabilityRequest(userId, format = 'json') {
  const userData = await collectUserData(userId);
  const portableData = {
    exportDate: new Date().toISOString(),
    userId,
    data: {
      profile: userData.profile,
      content: userData.userGeneratedContent,
      settings: userData.preferences,
      history: userData.activityHistory
    }
  };

  if (format === 'csv') return convertToCSV(portableData);
  if (format === 'xml') return convertToXML(portableData);
  return portableData;
}
```

Portability applies to data provided by the data subject, for automated processing based on consent or contract, in a structured, commonly used, machine-readable format.

### Objection handler

```javascript
async function handleObjectionRequest(userId, processingType) {
  switch (processingType) {
    case 'direct_marketing':
      await disableMarketing(userId);
      await updateConsent(userId, 'marketing', false);
      break;
    case 'legitimate_interest':
      const assessment = await assessLegitimateInterest(userId);
      if (!assessment.compelling) {
        await stopProcessing(userId, processingType);
      }
      return assessment;
    case 'profiling':
      await disableProfiling(userId);
      await updateConsent(userId, 'profiling', false);
      break;
    default:
      throw new Error('Invalid processing type');
  }

  await logObjectionRequest(userId, processingType, 'granted');
}
```

## Consent management

Valid consent must be freely given, specific, informed, unambiguous, and as easy to withdraw as to give.

Implementation rules:
- Use granular controls for each purpose.
- Do not preselect non-essential options.
- Do not load non-essential cookies or trackers before consent.
- Store consent records with user, timestamp, version, purposes, method, and context.
- Provide withdrawal at any time.

Consent record example:

```javascript
const consentRecord = {
  userId: 'user123',
  timestamp: new Date().toISOString(),
  consentVersion: '2.0',
  purposes: {
    essential: { granted: true, required: true },
    analytics: { granted: true, purpose: 'Website improvement' },
    marketing: { granted: false, purpose: 'Personalized advertising' }
  },
  ipAddress: '192.168.1.1',
  userAgent: 'Mozilla/5.0...',
  method: 'explicit_opt_in'
};
await saveConsentRecord(consentRecord);
```

Cookie banner example:

```html
<div id='cookie-banner' role='dialog' aria-labelledby='cookie-title'>
  <h2 id='cookie-title'>Cookie Preferences</h2>
  <p>We use cookies to enhance your experience. Choose which cookies you allow.</p>
  <button onclick='acceptAll()'>Accept All</button>
  <button onclick='rejectNonEssential()'>Reject Non-Essential</button>
  <button onclick='showPreferences()'>Manage Preferences</button>
</div>
```

```javascript
function acceptAll() {
  setConsent({ analytics: true, marketing: true });
  loadAnalyticsCookies();
  loadMarketingCookies();
  hideBanner();
}

function rejectNonEssential() {
  setConsent({ analytics: false, marketing: false });
  hideBanner();
}
```

## Privacy by design

### Data minimization

Collect only data necessary for the stated purpose.

```javascript
const userRegistration = {
  email: req.body.email,
  password: hashPassword(req.body.password),
  displayName: req.body.displayName
};
```

### Purpose limitation

Document allowed purposes for each data type and reject unauthorized use.

```javascript
const dataProcessingPurpose = {
  email: ['account_authentication', 'order_confirmations', 'password_reset'],
  phoneNumber: ['order_delivery_notifications'],
  purchaseHistory: ['order_fulfillment', 'customer_support']
};

async function processData(data, purpose) {
  if (!isAllowedPurpose(data.type, purpose)) {
    throw new Error('Purpose not authorized for this data');
  }
}
```

### Storage limitation

Retain data only as long as necessary and automate deletion or anonymization.

```javascript
const retentionPolicy = {
  userAccounts: { active: 'indefinite', inactive: '2 years', deleted: '30 days grace period' },
  orderRecords: '7 years',
  supportTickets: '3 years',
  analytics: '26 months',
  marketingData: '1 year or until consent withdrawn'
};
```

Schedule automated enforcement, such as deleting inactive accounts and anonymizing old analytics.

## Data Protection Impact Assessment

Conduct a DPIA for systematic large-scale processing, special category data, systematic monitoring, or new high-risk technologies.

DPIA steps:
1. Decide whether a DPIA is required.
2. Describe processing, data, subjects, recipients, and transfers.
3. Assess necessity and proportionality.
4. Identify and evaluate privacy risks.
5. Define mitigation measures and residual risk.
6. Document the report, consult the DPO, and consult the supervisory authority when required.
7. Monitor and review the DPIA.

DPIA template:

```markdown
# Data Protection Impact Assessment

## Processing overview
- Purpose:
- Data types:
- Data subjects:
- Recipients:

## Necessity assessment
- Is processing necessary for the stated purpose?
- Could the purpose be achieved with less data?
- Is the retention period justified?

## Risk assessment
| Risk | Likelihood | Severity | Mitigation |
|------|------------|----------|------------|
| Data breach | Medium | High | Encryption, access controls |
| Unauthorized access | Low | High | MFA, audit logs |
| Purpose creep | Medium | Medium | Purpose documentation, training |

## Safeguards
- Encryption at rest and in transit
- Access controls and authentication
- Regular security audits
- Data minimization
- Retention policies
- DPO consulted
- Data subject rights mechanism

## Conclusion
Processing is acceptable with the proposed safeguards.

Signed: Data Protection Officer
Date:
```

## International data transfers

For transfers outside the adequate protection area:
- Check for an adequacy decision.
- Use standard contractual clauses, binding corporate rules, certifications, or codes of conduct where appropriate.
- Assess third-country risks, including government access and enforceability of data subject rights.
- Add supplementary measures: encryption, pseudonymization, access controls, data minimization, purpose limitation, retention limits, audit rights, transparency, and redress mechanisms.
- Document the transfer mechanism and risk assessment.

## Healthcare and PHI

For health data:
- Classify health data as special category data.
- Identify an appropriate legal basis, including explicit consent or another Article 9 basis.
- Document processing and coordinate with healthcare providers, device manufacturers, research organizations, and processors.
- Apply heightened safeguards, access controls, audit trails, and encryption.
- Manage cross-border health data transfers with the same transfer controls as other personal data.

## Incident response

GDPR requires notification to the supervisory authority within 72 hours when a breach risks rights and freedoms. Notify affected individuals without undue delay when risk is high.

Response plan:
1. Detect and contain within 0-4 hours: identify scope, isolate systems, stop further loss.
2. Assess within 4-24 hours: data types, number of individuals, risk, and documentation.
3. Notify authority within 24-72 hours: nature, categories, approximate numbers, likely consequences, measures taken.
4. Notify data subjects as soon as possible for high-risk breaches.

Breach notification template:

```text
Subject: Important Security Notice

Dear [Name],

We are writing to inform you of a data security incident that may have affected your personal information.

WHAT HAPPENED:
On [date], we discovered that [brief description].

WHAT INFORMATION WAS INVOLVED:
[List specific data types]
[List what was not involved]

WHAT WE ARE DOING:
- [Immediate actions taken]
- [Ongoing security enhancements]
- [Resources provided]

WHAT YOU CAN DO:
- Change your password immediately
- Monitor your accounts for suspicious activity
- [Specific recommendations]

FOR MORE INFORMATION:
Contact our dedicated hotline: [phone]
Email: security@company.com

Sincerely,
[Name, Title]
```

## DPO and governance

- Appoint a DPO when required and ensure independence, resources, and access.
- Support the DPO with advisory input, cross-functional coordination, training, and conflict-of-interest management.
- Establish governance: data protection committee, privacy steering group, departmental privacy champions, and compliance network.
- Maintain policies, procedures, training, and evidence of implementation.

## Audit and continuous improvement

Audit methodology:
1. Plan scope, inventory processing, identify stakeholders, and define criteria.
2. Execute legal compliance review, technical measures review, organizational measures review, and documentation review.
3. Report non-compliance, risk, recommendations, remediation plans, and timelines.
4. Prepare for external audits and supervisory authority investigations with organized documentation and trained personnel.

Track metrics:
- Compliance rate by requirement
- Data subject request timeliness and accuracy
- Privacy risk identification and mitigation effectiveness
- Breach response and notification compliance
- Training completion and effectiveness

Continuously monitor regulatory guidance, case law, enforcement trends, and privacy-enhancing technologies.

## Privacy policy requirements

Include:
- Controller identity and DPO contact
- Data collected
- Legal basis for each purpose
- How data is used
- Data sharing and sale statements
- Data subject rights and contact method
- Retention periods
- Security measures
- International transfer safeguards
- Policy change notice
- Contact information

## Compliance checklist

### GDPR/DSGVO
- Lawful basis documented for all processing
- Privacy policy published and accessible
- Consent mechanism uses granular controls
- Data subject rights process established
- Records of processing activities maintained
- DPO appointed when required
- DPIA conducted for high-risk processing
- Breach notification procedure in place
- Vendor contracts include data processing agreements
- International transfer safeguards implemented
- Staff training completed

### CCPA/CPRA
- 'Do Not Sell or Share My Personal Information' link on homepage
- Privacy policy discloses collection, use, and sale/sharing
- Verifiable consumer request process established
- Opt-out requests handled within required timelines
- Annual reporting on requests and compliance
- Service provider agreements updated
- Notice at collection provided

### HIPAA
- Risk assessment completed
- Security policies and procedures documented
- Workforce trained on HIPAA requirements
- Business associate agreements signed
- Access controls and audit trails implemented
- ePHI encrypted
- Breach notification procedures established
- Contingency and disaster recovery plan in place

Privacy compliance is an ongoing process. Review practices as regulations, guidance, and processing activities change.

## Related skills

Load these when the task spans more than this skill.

- [`secure-coding`](../SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
