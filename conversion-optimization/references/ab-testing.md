# A/B Testing Guide

Help teams create statistically valid experiments that produce clear, actionable outcomes. The guide covers hypothesis creation, test design, sample‑size calculation, implementation options, monitoring, analysis, and documentation.

## When to use
- You want to compare a control version (A) with one or more variants (B, C, …).
- You need to validate a change before rolling it out to all users.
- You have a measurable business metric (e.g., click‑through rate, conversion, revenue).
- You have enough traffic to reach a reliable sample size.

---

## Core Principles
- **Start with a hypothesis** – state a specific, data‑driven prediction.
- **Test one variable** – isolate the cause of any observed effect.
- **Pre‑determine sample size** – avoid peeking and stopping early.
- **Measure what matters** – pick a primary metric tied to business value; add secondary and guardrail metrics.

---

## 1. Define the Hypothesis
Use the structured template:

```
Because [observation],
we believe [change]
will cause [expected outcome]
for [audience].
We'll know this is true when [metric].
```

**Example (strong)**
> Because heat‑maps show users miss the CTA, we believe enlarging the button and using a contrasting color will increase CTA clicks by at least 15 % for new visitors. We'll know this is true when the click‑through rate from page view to signup start rises.

### Checklist for a good hypothesis
- Observation (data or insight)
- Specific change (single variable)
- Expected effect (direction and magnitude)
- Target audience
- Success metric definition

---

## 2. Choose the Test Type
| Type | When to use | Traffic needed |
|------|-------------|----------------|
| **A/B (split) test** | One change, simple analysis | Low to moderate |
| **A/B/n test** | Multiple independent variants | Higher |
| **Multivariate test (MVT)** | Test interactions of several changes | Very high |
| **Split‑URL test** | Major page redesign, different URLs | Moderate |

---

## 3. Calculate Sample Size
**Inputs**
1. Baseline conversion rate (current metric value).
2. Minimum Detectable Effect (MDE) – smallest lift worth acting on.
3. Significance level – usually 95 % (p < 0.05).
4. Power – usually 80 %.

**Quick reference (approx. visitors per variant)**
| Baseline | 10 % lift | 20 % lift | 50 % lift |
|----------|----------|----------|----------|
| 1 % | 150 k | 39 k | 6 k |
| 3 % | 47 k | 12 k | 2 k |
| 5 % | 27 k | 7 k | 1.2 k |
|10 %| 12 k | 3 k | 550 |

**Formula (for two‑variant test)**
```
N = (Zα/2√[2p(1‑p)] + Zβ√[p1(1‑p1) + p2(1‑p2)])² / (p1‑p2)²
```
- *p* = pooled conversion rate, *p1* and *p2* = control & variant rates.
- Use online calculators (e.g., Evan Miller, Optimizely) for convenience.

**Test duration**
```
Duration = (Sample size per variant) / (Daily traffic × Baseline conversion rate)
```
Run at least 1–2 business weeks but no longer than 4–6 weeks to avoid novelty effects.

---

## 4. Select Metrics
- **Primary metric** – single KPI that directly reflects the hypothesis (e.g., CTA click‑through rate).
- **Secondary metrics** – provide context (time on page, scroll depth, funnel steps).
- **Guardrail metrics** – must not degrade (overall revenue, churn, support tickets).

---

## 5. Design Variants
### Control (A)
- Keep the current experience unchanged.

### Variant (B, C…)
- Apply **one** meaningful change.
- Ensure the change is bold enough to generate a measurable effect.
- Typical elements to vary:
  - Headline / copy
  - Button text, size, color, placement
  - Image or visual hierarchy
  - Layout or spacing
  - Social proof format

### Document each variant
```
Variant B:
- Change: Larger CTA button, orange background
- Reason: Improves visibility per hypothesis
- Mockup: (attach screenshot or link)
```

---

## 6. Allocate Traffic
- **Standard split** – 50/50 for A/B; equal split for A/B/n.
- **Conservative rollout** – 90/10 or 80/20 initially if risk is high; shift to equal split after early validation.
- **Ramping** – start with a small percentage, increase gradually.
- Ensure users see the same variant on repeat visits.

---

## 7. Choose Implementation Method
| Method | Tools | Pros | Cons |
|--------|-------|------|------|
| **Client‑side** | Optimizely, VWO, PostHog, custom JS | Fast to deploy, no backend changes | Possible flicker, dependent on JS execution |
| **Server‑side** | LaunchDarkly, Split, custom middleware | No flicker, works for backend features | Requires development effort |
| **Feature flag** | LaunchDarkly, Split | Simple on/off rollout, can become A/B with percentage split | Not true A/B unless split percentages are used |

---

## 8. Pre‑Launch Checklist
- [ ] Hypothesis documented with framework
- [ ] Primary metric defined
- [ ] Sample size calculated and target set
- [ ] Test duration estimated
- [ ] Variants built and reviewed
- [ ] Tracking code verified for all metrics
- [ ] QA performed on each variant
- [ ] Stakeholders notified of start date

---

## 9. Run the Test
### During the test
- Monitor technical health (errors, load times).
- Verify traffic split remains balanced.
- Log any external events (campaigns, holidays) that could affect results.

### What NOT to do
- Peek at results before reaching the planned sample size.
- Change the variant code or traffic allocation mid‑test.
- Add new traffic sources that differ from the original audience.
- End the test early because you “feel” the outcome.

**If you must peek**, use a sequential testing method (e.g., Bayesian monitoring) and pre‑define stopping rules.

---

## 10. Analyze Results
1. **Check sample size** – Was the target reached?
2. **Statistical significance** – p‑value < 0.05 (95 % confidence) or Bayesian credible interval not crossing zero.
3. **Effect size** – Compare observed lift to MDE; assess business impact.
4. **Secondary metrics** – Ensure they support the primary outcome.
5. **Guardrails** – Verify no negative movement on critical metrics.
6. **Segment analysis** – Look for differences by device, geography, new vs. returning users.

### Interpretation matrix
| Outcome | Action |
|---------|--------|
| Significant winner (primary metric) | Deploy variant, update documentation |
| Significant loser | Keep control, record learnings |
| No significance | Consider larger change or more traffic; may be inconclusive |
| Mixed signals (primary up, guardrail down) | Pause rollout, investigate cause |

---

## 11. Document and Share Learnings
Create a test record:
```
Test Name: [Descriptive name]
ID: [Tool ID]
Dates: [Start] – [End]
Owner: [Name]

Hypothesis:
[Full hypothesis]

Variants:
- Control (A): [description]
- Variant (B): [description]

Metrics:
- Primary: [metric] – result: [% change, confidence]
- Secondary: [summary]
- Guardrails: [summary]

Decision: [Winner / Loser / Inconclusive]
Action: [Deploy / Keep control / Re‑test]

Learnings:
- What worked, what didn’t
- Next test ideas
```
Store records in a searchable repository to avoid repeating failed ideas and to build institutional knowledge.

---

## 12. Common Pitfalls & How to Avoid Them
- **Testing too small a change** – leads to huge sample sizes; increase the magnitude of the variation.
- **Testing multiple changes at once** – obscures cause; stick to one variable per test.
- **Stopping early** – inflates false‑positive rate; commit to the pre‑calculated sample size.
- **Changing variants mid‑test** – invalidates data; freeze code until the test ends.
- **Ignoring guardrails** – can damage revenue or user experience; monitor them continuously.
- **Mis‑interpreting statistical significance** – a win must also be practically meaningful.

---

## 13. Quick Reference Checklist
- **Hypothesis**: documented, single variable, measurable metric.
- **Metrics**: primary, secondary, guardrails defined.
- **Sample size**: calculated, target reached.
- **Variants**: built, QA‑ed, documented.
- **Implementation**: method chosen, tracking verified.
- **Pre‑launch**: checklist completed, stakeholders informed.
- **During test**: monitor health, no changes, no early peeking.
- **Analysis**: significance, effect size, guardrails, segments.
- **Decision**: implement winner or iterate, record learnings.

---

## 14. Tools & Resources
- **Sample‑size calculators**: https://www.evanmiller.org/ab-testing/sample-size.html, https://www.optimizely.com/sample-size-calculator/
- **A/B testing platforms**: Optimizely, VWO, Google Optimize (legacy), PostHog, LaunchDarkly, Split.io
- **Statistical references**: “Statistical Power Analysis for the Behavioral Sciences” (Cohen), Bayesian A/B testing guides.

---

*Use this guide to run disciplined experiments that drive data‑backed product and marketing decisions.*

## Related skills

Load these when the task spans more than this skill.

- [`conversion-optimization`](../SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`ux-research`](../../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
