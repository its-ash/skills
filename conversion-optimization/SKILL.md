---
name: conversion-optimization
description: "Conversion optimization skill audits and improves conversion rates for marketing pages, landing pages, pricing pages, forms, popups, signup flows, onboarding experiences, and in-app paywalls with CRO recommendations, A/B test ideas, and step-by-step audits. Use when you need CRO audit, conversion rate optimization, landing page optimization, form optimization, popup optimization, signup flow optimization, onboarding optimization, paywall optimization, funnel optimization, checkout optimization, or A/B test ideas. Sub-skills: ab-testing."
---
# Conversion Optimization

Audit a conversion asset and give a ranked plan of fixes and tests.

## Core rules
- Before the audit, record: asset type, primary conversion goal, traffic context (source, device mix, new vs. returning), current metrics (rate, drop-off, time, errors), and constraints (required data, compliance, tech limits, brand tone).
- Show value before the ask (CTA, form, upgrade).
- Remove every field or step that is not essential now; collect the rest later (progressive profiling).
- Reduce cognitive load: one question per field, clear labels, logical groups, smart defaults, inline validation.
- Respect the user: easy dismiss, clear escape hatch, frequency caps, no dark patterns, accessible.
- Put headline, value, and one primary CTA above the fold.
- Put trust signals (logos, testimonials, security badges, privacy note) near the CTA.
- Handle objections with FAQ, guarantees, risk reversal, and clear pricing.
- Show progress and next steps (checklists, progress bars, celebration).
- Trigger popups, paywalls, and upgrade prompts after the aha moment or at a friction point, never on arrival.
- Design mobile first: tap targets ≥44 px, correct keyboards, single column, fast load.
- Define the metric for every recommendation before you propose a test.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| Form has ≤3 fields | single step | splitting into steps |
| Form has >3 fields (signup) or >5 (lead) or logical sections | multi-step, progress bar, easy questions first, save progress | one long page |
| Popup timing | scroll 25–50 %, exit intent, 30–60 s delay, or behavior trigger | delay <10 s, on-load modals |
| Popup repeat | once per session, honor dismiss 7–30 days | show on every page view |
| Paywall | after value or at limit; 1–2 per session; "Continue with Free" link | price-first headline, guilt-trip copy |
| Signup auth | social auth first, email/password second | required company/role/phone at signup |
| Validation error | inline, specific, focus first error, keep data | clear the form, generic "invalid input" |

## Output format
1. **Quick wins**: changes you can ship today.
2. **High-impact changes**: larger redesigns or new flows.
3. **Test ideas**: 2–3 A/B hypotheses with expected lift and metric.
4. **Copy alternatives**: 2–3 variants for headline, CTA, value prop, each with a short rationale.

## Load on demand

| Need | Read |
|---|---|
| Per-asset checks, field-cost rule, triggers, metrics for page, form, popup, signup, onboarding, paywall | [references/asset-frameworks.md](references/asset-frameworks.md) |
| A/B and multivariate test design: hypothesis, sample size, power, allocation, significance | [references/ab-testing.md](references/ab-testing.md) |

## Related skills
- [`copywriting`](../content-writing/references/copywriting.md) — headlines, CTAs, and page copy.
- [`ux-research`](../ux-research/SKILL.md) — personas, journeys, usability tests.
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) — accessible forms and modals.
