---
name: pricing-strategy
description: "This skill delivers a step-by-step framework for SaaS pricing and monetization covering value-metric selection, tier design, freemium versus trial decisions, price-increase planning, enterprise contract pricing, and pricing-page optimization. Use when setting SaaS prices, choosing value metrics such as seats or usage volume, designing pricing tiers and packages, running Van Westendorp price sensitivity meter or MaxDiff best-worst scaling surveys, calculating willingness-to-pay, planning price hikes and grandfathering, negotiating enterprise deals, writing pricing page copy, A/B testing price points, or modeling revenue impact of packaging changes."
---

# Pricing Strategy

Help design pricing that captures value, drives growth, and aligns with customer willingness to pay.

## When to use
- You need to set or revise prices, tiers, or packaging.
- You are planning a freemium, free trial, or price increase.
- You need to choose a value metric or create an enterprise offering.
- You want to test price sensitivity or improve a pricing page.

---

## 1. Gather Context
Ask the user for the following information if it is not already provided:

### Business Context
- Product type (SaaS, marketplace, e‑commerce, service)
- Current pricing (if any)
- Target market segment (SMB, mid‑market, enterprise)
- Go‑to‑market motion (self‑serve, sales‑led, hybrid)

### Value & Competition
- Primary value delivered to customers
- Main alternatives customers consider
- Competitor pricing models
- Differentiators that justify a premium

### Current Performance
- Conversion rate (visitor → paying)
- Average revenue per user (ARPU)
- Churn rate
- Any direct feedback on pricing

### Goals
- Optimize for growth, revenue, or profitability?
- Move up‑market or expand down‑market?
- Specific pricing changes under consideration?

---

## 2. Pricing Fundamentals
### The Three Pricing Axes
1. **Packaging** – Features, limits, support level per tier.
2. **Pricing Metric** – What you charge for (per user, per usage, flat fee, etc.).
3. **Price Point** – Dollar amount for each tier.

### Value‑Based Pricing Framework
Price should sit between the next‑best alternative and the customer's perceived value.
```
Next‑best alternative   $300
Your cost to serve      $ 50
Your price (target)    $500   ← capture value, leave surplus
Customer perceived value $1000
```
Cost is a floor, not a basis.

---

## 3. Pricing Research Methods
### Van Westendorp Price Sensitivity Meter
Ask respondents four questions:
1. Too expensive (won’t buy)
2. Too cheap (question quality)
3. Expensive but still consider
4. Bargain/good value
Plot cumulative distributions and locate:
- **Point of Marginal Cheapness (PMC)** – “Too cheap” × “Expensive”
- **Point of Marginal Expensiveness (PME)** – “Too expensive” × “Cheap”
- **Optimal Price Point (OPP)** – “Too cheap” × “Too expensive”
- **Indifference Price Point (IDP)** – “Expensive” × “Cheap”
Use 100‑300 respondents, segment by persona, and add purchase‑intent questions.

### MaxDiff (Best‑Worst Scaling)
1. List 8‑15 potential features.
2. Show respondents 4‑5 at a time.
3. Ask which is most important and which is least.
4. Analyze utility scores.
**Interpretation:**
- Top 20 % → include in all tiers (table‑stakes).
- 20‑50 % → use to differentiate tiers.
- 50‑80 % → reserve for higher tiers.
- Bottom 20 % → consider add‑on or removal.

### Willingness‑to‑Pay Surveys
- **Direct**: “How much would you pay?” (biased)
- **Gabor‑Granger**: “Would you buy at $X?” Vary X to build a demand curve.
- **Conjoint**: Show full bundles at different prices; statistical analysis yields price elasticity per feature.

---

## 4. Choose a Value Metric
A value metric should:
- Align price with the value the customer receives.
- Be easy to understand.
- Scale as the customer grows.
- Be hard to game.

### Common Metrics
| Metric | Typical Use |
|---|---|
| Per user/seat | Collaboration tools |
| Per usage (API calls, minutes) | Variable consumption |
| Per record/contact | CRM, email platforms |
| Per transaction | Payments, marketplaces |
| Flat fee | Simple products |
| Revenue share | Outcome‑based platforms |

### Selecting the Right Metric
1. Identify the outcome customers care about.
2. Map usage patterns to that outcome.
3. Test alignment: *When the metric increases, does value increase?* If yes, keep; if no, choose another.
4. Validate with usage data and correlation to retention/expansion.

---

## 5. Tier Structure
### How Many Tiers?
- **2 tiers** – simple choice, risk of leaving money on the table.
- **3 tiers** – industry standard (Good‑Better‑Best).
- **4+ tiers** – more granularity, risk of decision paralysis.

### Good‑Better‑Best Framework
| Tier | Purpose | Typical Content | Pricing Hint |
|---|---|---|---|
| Good (Entry) | Remove barrier | Core features, low limits | Low, accessible |
| Better (Recommended) | Anchor price, most customers land here | Full feature set, reasonable limits | Main price point |
| Best (Premium) | Capture high‑value customers | All features, high limits, dedicated support | 2‑3× Better |

### Differentiation Strategies
- **Feature gating** – advanced features only in higher tiers.
- **Usage limits** – same features, higher caps (users, storage, API calls).
- **Support level** – email → priority → dedicated CSM.
- **Access & customization** – API, SSO, custom branding for enterprise.

---

## 6. Persona‑Based Packaging
1. Define pricing personas (size, use case, willingness to pay).
2. Map each feature to personas (must‑have, differentiator, premium).
3. Set a price that captures value for each persona while keeping the tier hierarchy clear.

*Example persona matrix*
| Persona | Size | Core needs | Typical price |
|---|---|---|---|
| Freelancer | 1 | Basic features | $19/mo |
| Small Team | 2‑10 | Collaboration, limited integrations | $49/mo |
| Growing Co | 10‑50 | Unlimited integrations, API | $149/mo |
| Enterprise | 50+ | Security, custom contracts, dedicated support | Custom |

---

## 7. Freemium vs. Free Trial
### Freemium
- Use when product has viral/network effects or free users add value (data, referrals).
- Set clear usage limits that trigger upgrade.
- Monitor conversion; avoid devaluing the product.

### Free Trial
- Use when value requires time to surface or onboarding is heavy.
- Typical length: 7‑14 days (simple) or 14‑30 days (complex).
- Offer full access; show a countdown and reminders.
- Optional credit‑card capture raises conversion but reduces trial volume.

### Hybrid
- Free tier + time‑limited premium trial (e.g., Zoom).
- Reverse trial: full access first, then downgrade to free tier.

---

## 8. Planning a Price Increase
### Signals It May Be Time
- Competitors have raised prices.
- Your conversion > 40 % and churn < 3 %.
- Customers regularly exceed usage limits.
- Significant new value added since last price set.

### Strategies
1. **Grandfather** – keep existing customers at old price.
2. **Delayed increase** – announce 3‑6 months ahead, give lock‑in option.
3. **Value‑tied increase** – add features, then raise price.
4. **Plan restructure** – replace old plans with new ones, map customers to nearest tier.

### Communication Template (existing customers)
```
Subject: Upcoming changes to [Product] pricing

Hi [Name],

We’re adding new features and improving the platform. Starting [date] our pricing will change from [old] to [new].

As a valued customer you can:
- Lock in the current rate by renewing before [date], or
- Continue on your current plan if it’s grandfathered.

Thank you for your continued support.

[Your Name]
```

---

## 9. Pricing Page Best Practices
- **Above the fold:** tier comparison table, monthly/annual toggle, primary CTA per tier.
- **Highlight recommended tier** with visual emphasis.
- **Use checkmarks and limits** instead of paragraphs.\n### Psychological Levers
- **Anchoring:** show a higher‑priced tier first.
- **Decoy:** make the middle tier appear as best value.
- **Charm pricing:** $49 vs. $50 for value‑focused offers.
- **Round pricing:** $50 vs. $49 for premium perception.
- **Annual discount:** display monthly price and a “Save 20 % annually” badge.

---

## 10. Price Testing
### Methods
1. **A/B test pricing page** (use with caution; disclose if required).
2. **Geographic testing** – higher price in a new region.
3. **New‑customer only** – raise price for new sign‑ups, compare cohorts.
4. **Sales‑team discretion** – test higher quotes in negotiations.
5. **Feature‑based testing** – add a premium tier and observe uptake.

### Metrics to Track
- Conversion rate per price point
- ARPU
- Total revenue (conversion × price)
- Customer LTV by price tier
- Churn rate by price tier
- Price sensitivity by segment

---

## 11. Enterprise Pricing
### When to Offer Custom Pricing
- Expected ARR > $10k per account.
- Need for custom contracts, implementation, or compliance.
- Procurement or legal review required.

### Core Enterprise Elements
- SSO/SAML, audit logs, admin controls, SLA, security certifications.
- Dedicated support, custom onboarding, training, bespoke integrations.

### Pricing Models
- **Per‑seat volume discounts** (e.g., $15/user → $10/user for 100+ seats).
- **Base fee + usage** (e.g., $500/mo + $0.01 per API call).
- **Value‑based contracts** (percentage of transaction value or revenue share).

---

## 12. Pricing Checklist
- **Research**: personas, competitor pricing, willingness‑to‑pay surveys.
- **Value metric**: identified, aligned, and tested.
- **Tier design**: number of tiers, Good‑Better‑Best, clear differentiation.
- **Packaging**: features mapped to tiers and personas.
- **Pricing page**: layout, psychology, annual discount.
- **Testing plan**: method, metrics, timeline.
- **Enterprise strategy**: custom tier, contract elements.
- **Price‑increase plan**: signals, strategy, communication.
- **Tracking**: set up dashboards for conversion, ARPU, churn, LTV.

---

## 13. Questions to Ask the User
- What pricing research have you already performed?
- What are your current ARPU, conversion, and churn rates?
- Which value metric do you think best reflects customer value?
- Who are your primary pricing personas?
- Is your GTM model self‑serve, sales‑led, or hybrid?
- Are you considering a freemium, free trial, or a price increase?
- Do you have enterprise customers that need custom contracts?

## Related skills

Load these when the task spans more than this skill.

- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`marketing-strategy`](../marketing-strategy/SKILL.md) — Comprehensive playbook for product marketing, positioning, GTM planning, demand generation, paid media, SEO, p…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`ab-testing`](../ab-testing/SKILL.md) — A step‑by‑step guide for planning, designing, running, and analyzing A/B (split) tests or multivariate experim…
- [`analytics-tracking`](../analytics-tracking/SKILL.md) — Provides a complete workflow for planning, implementing, auditing, and analyzing analytics tracking (GA4, GTM,…
- [`executive-advisor`](../executive-advisor/SKILL.md) — Provides integrated executive and technology leadership guidance for CEOs and CTOs. Use when planning corporat…
- [`marketing-psychology`](../marketing-psychology/SKILL.md) — Provides a curated list of psychological principles, mental models, and behavioral‑science tactics for marketi…
