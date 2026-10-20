---
name: email-marketing
description: "Builds complete email marketing systems covering sequence architecture, deliverability infrastructure, and conversion optimization. Use when designing welcome series, nurture drips, re-engagement campaigns, onboarding flows, or win-back automations; configuring SPF DKIM DMARC DNS records, IP warmup schedules, bounce and complaint processing, inbox placement monitoring, and sender reputation management; writing subject lines, preview text, preheaders, body copy, and calls-to-action for maximum open click and conversion rates; segmenting audiences, setting up A/B tests, tracking opens clicks conversions revenue attribution, and ensuring CAN-SPAM GDPR CASL compliance across ESP platforms."
---

# Email Marketing – Sequence Design & System Foundations

Create email sequences that nurture relationships, drive conversions, and keep your messages out of the spam folder. This skill covers audience assessment, sequence planning, copy guidelines, deliverability setup, tracking, segmentation, testing, and a final checklist.

## When to use
- You need a **welcome/onboarding**, **lead‑nurture**, **re‑engagement**, **post‑purchase**, **trial win‑back**, or **billing** email flow.
- You are configuring **SMTP, SPF/DKIM/DMARC, IP warm‑up, bounce handling**, or other deliverability settings.
- You want to **segment**, **personalize**, and **optimize** subject lines, send times, and calls‑to‑action.

---

## 1. Initial Assessment
| Question | Why it matters |
|---|---|
| **Sequence type** (welcome, nurture, re‑engagement, etc.) | Determines length, tone, and metrics. |
| **Audience context** – who they are, what triggered the email, what they already know | Shapes relevance and personalization. |
| **Primary goal** – conversion, activation, retention, revenue, feedback | Sets the CTA and success criteria. |
| **Success definition** – open rate, click‑through, conversion, churn reduction | Guides measurement and optimization. |

---

## 2. Core Principles for Every Email
1. **One email, one job** – one main purpose, one CTA.
2. **Value before ask** – give useful content first, then request action.
3. **Relevance over volume** – send only to segments that need the message.
4. **Clear path forward** – every link moves the reader toward the next step.

---

## 3. Sequence Strategy
### 3.1 Length & Timing
| Sequence | Typical # emails | Typical delay |
|---|---|---|
| Welcome / onboarding | 3‑7 | Immediate, then 1‑2 days, then every 2‑3 days |
| Lead nurture | 5‑10 | 2‑4 days apart |
| Re‑engagement | 3‑5 | Day 0, +2 days, +5 days, optional final day 10‑14 |
| Post‑purchase | 3‑5 | Immediate, +2 days, +7 days |
| Win‑back (trial) | 3‑4 | Day 1, +7 days, +14 days, +30 days |

Adjust based on sales cycle, product complexity, and user stage.

### 3.2 Subject‑Line & Preview Text
- Keep subject **clear > clever**; 40‑60 characters.
- Use proven patterns: Question, How‑to, Number, Direct name insertion, Story tease.
- Preview text should complement, not repeat, the subject (≈90‑140 chars).
- Test emojis only if your audience responds positively.

### 3.3 Template Overview (example for a welcome series)
| Email | Timing | Goal | Subject pattern |
|---|---|---|---|
| 1. Welcome | Immediate | Confirm signup, set expectation | "Welcome to {{Product}} – your first step" |
| 2. Quick win | Day 1‑2 | Show easy success | "Get {{Result}} in 10 minutes" |
| 3. Story/Why | Day 3‑4 | Build emotional connection | "Why we built {{Product}}" |
| 4. Social proof | Day 5‑6 | Show real results | "How {{Customer}} achieved {{Result}}" |
| 5. Overcome objection | Day 7‑8 | Address common hesitation | "I don’t have time for X – sound familiar?" |
| 6. Core feature | Day 9‑11 | Highlight under‑used benefit | "Have you tried {{Feature}} yet?" |
| 7. Conversion | Day 12‑14 | Ask for purchase/upgrade | "Ready to {{UpgradeAction}}?" |

Replace placeholders with merge fields (first name, product name, feature, etc.).

---

## 4. Email System Foundations
### 4.1 Authentication & DNS
- **SPF** – list all sending IPs/domains.
- **DKIM** – generate a 2048‑bit key, publish the public key in DNS, sign every outbound message.
- **DMARC** – set policy to `p=none` while testing, then move to `p=quarantine` or `p=reject`.
- Verify records with tools like MXToolbox.

### 4.2 IP Management
- Use a **dedicated IP** for transactional email; a separate IP for bulk marketing.
- **Warm‑up schedule**: start at 10 k emails/day, double every 2‑3 days until target volume.
- Monitor reputation (Sender Score, Google Postmaster) daily.

### 4.3 Bounce & Complaint Handling
- Set up **bounce webhook** or inbox parsing.
- Classify bounces: *hard* (permanent) → remove from list; *soft* (temporary) → retry up to 3 times.
- Process **complaint (spam) notifications** immediately; suppress those addresses.

### 4.4 Deliverability Monitoring
- Track **delivery, open, click, bounce, complaint** rates per campaign.
- Alert on open < 15 % or bounce > 2 %.
- Use a dedicated subdomain for links (e.g., `mail.example.com`) to protect brand reputation.

### 4.5 Template Versioning & Testing
- Store HTML and plain‑text versions in a version‑controlled repository.
- Tag each version (`v1.0`, `v1.1‑subject‑test`).
- Run **A/B tests** on subject, preheader, CTA text, and layout.

---

## 5. Copy & Formatting Guidelines
1. **Hook** – first line grabs attention.
2. **Context** – why it matters now.
3. **Value** – concise benefit or tip.
4. **CTA** – single button with action + outcome.
5. **Sign‑off** – warm, human.

### Formatting
- Paragraphs: 1‑3 sentences.
- White space between sections.
- Bullet points for scannability.
- Bold sparingly for emphasis.
- Mobile‑first: single‑column layout, 600 px max width.

### Length
- Transactional: 50‑125 words.
- Educational: 150‑300 words.
- Story‑driven: 300‑500 words.

### CTA Buttons vs. Links
- **Button** for primary action (e.g., "Start your trial").
- **Link** for secondary actions (e.g., "Learn more").
- Use **action‑oriented text**: "Download guide", not "Click here".

---

## 6. Personalization & Dynamic Content
- **Merge fields**: `{{first_name}}`, `{{company}}`, `{{plan}}`, `{{last_login}}`.
- **Fallback**: if first name missing, use "there".
- **Dynamic blocks** based on behavior (e.g., show feature X only if user has used feature Y).
- Triggered emails (action‑based) outrank time‑based sends for relevance.

---

## 7. Segmentation Strategies
| Basis | Example Segments |
|---|---|
| Behavior | Openers vs. non‑openers, clickers vs. non‑clickers, active vs. inactive users |
| Lifecycle stage | Trial, paid, churn risk, long‑term loyal |
| Profile | Industry, role, company size, use case |
| Engagement score | High, medium, low (based on recent activity) |

Apply the most relevant segment to each email to improve relevance and reduce unsubscribes.

---

## 8. Testing & Optimization
1. **What to test** – subject line, send time, email length, CTA copy, personalization depth.
2. **How to test** – A/B test one variable at a time, use at least 1 % of the list for each variant, run for a minimum of 24 hours.
3. **Statistical significance** – aim for 95 % confidence before declaring a winner.
4. **Document learnings** – keep a log of test hypothesis, results, and next steps.

### Key Metrics
- **Open rate** – 20‑40 % is typical.
- **Click‑through rate** – 2‑5 %.
- **Conversion rate** – depends on goal; track per sequence.
- **Unsubscribe rate** – keep under 0.5 %.
- **Revenue per email** – for revenue‑focused campaigns.

---

## 9. Checklist
- [ ] Define sequence type, audience, and primary goal.
- [ ] Draft email copy using the Hook‑Context‑Value‑CTA structure.
- [ ] Create subject line and preview text following the proven patterns.
- [ ] Insert merge fields and set fallback values.
- [ ] Build HTML and plain‑text versions; validate with Litmus or Email on Acid.
- [ ] Version templates and store in source control.
- [ ] Set up SPF, DKIM, DMARC records; verify with DNS tools.
- [ ] Use dedicated IPs and follow warm‑up schedule.
- [ ] Configure bounce and complaint webhooks; suppress hard bounces.
- [ ] Enable open, click, bounce, and complaint tracking.
- [ ] Segment list according to behavior, stage, and profile.
- [ ] Schedule send times (immediate, 1‑2 days, 3‑4 days, weekly, etc.).
- [ ] Run A/B test on subject line before full launch.
- [ ] Monitor deliverability metrics daily; act on spikes.
- [ ] Review sequence performance after 2‑4 weeks; iterate based on metrics.

---

## 10. Quick Reference Table
| Item | Recommended Setting |
|---|---|
| SPF record | `v=spf1 include:mailservice.com -all` |
| DKIM key length | 2048 bits |
| DMARC policy (post‑test) | `p=reject; rua=mailto:postmaster@example.com` |
| IP warm‑up start | 10 k emails/day |
| Plain‑text fallback | multipart/alternative with 30‑40 % of HTML length |
| Unsubscribe link | Visible, single‑click, functional for every marketing email |
| Bounce handling | Remove hard bounces immediately; retry soft bounces up to 3 times |
| Send window (B2B) | 9 am–12 pm local time, weekdays only |
| Send window (B2C) | Test weekdays vs. weekends; avoid late night |

---

**Use this guide to design, implement, and continuously improve email marketing programs that both convert and stay out of the spam folder.**

## Related skills

Load these when the task spans more than this skill.

- [`copywriting`](../copywriting/SKILL.md) — Creates clear, compelling marketing copy for webpages (home, landing, pricing, feature, about, product) and pr…
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`analytics-tracking`](../analytics-tracking/SKILL.md) — Provides a complete workflow for planning, implementing, auditing, and analyzing analytics tracking (GA4, GTM,…
- [`marketing-strategy`](../marketing-strategy/SKILL.md) — Comprehensive playbook for product marketing, positioning, GTM planning, demand generation, paid media, SEO, p…
- [`ab-testing`](../ab-testing/SKILL.md) — A step‑by‑step guide for planning, designing, running, and analyzing A/B (split) tests or multivariate experim…
- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`lead-research`](../lead-research/SKILL.md) — Lead Research skill finds and qualifies high‑quality prospects for a product or service. Provide product detai…
