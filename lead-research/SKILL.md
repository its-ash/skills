---
name: lead-research
description: "Lead Research identifies and qualifies high‑quality prospects for a product or service by analyzing product details and ideal‑customer criteria to produce a ranked list of companies with decision‑maker contacts and outreach suggestions. Use when you need prospecting, lead generation, b2b sales intelligence, company enrichment, contact discovery, decision‑maker lookup, fit scoring, outreach templates, icp definition, target account list building, or sales pipeline filling for SaaS, enterprise, or agency offerings."
---

# Lead Research
Identify and qualify prospects for your product or service. The skill analyzes your offering, matches it to an Ideal Customer Profile (ICP), scores companies, and returns actionable outreach details.

## When to Use
- Building a prospect list for sales or partnership outreach.
- Targeting accounts that fit a defined ICP.
- Preparing data for CRM import or outreach campaigns.
- Researching companies that show recent need signals (funding, hiring, tech stack).

## Workflow
1. **Gather Product Context**
   - Provide a concise description of your product/service.
   - If you run the skill inside your code repository, the assistant will scan the code to infer features.
2. **Define Ideal Customer Profile**
   - Industry / sector
   - Company size (employees or revenue range)
   - Geographic location(s)
   - Pain points your solution addresses
   - Required technology stack or tools
3. **Research Companies**
   - Search public sources (company websites, LinkedIn, Crunchbase, job boards, news).
   - Look for need signals: recent funding, hiring, tech‑stack mentions, relevant job postings, news articles.
4. **Score & Prioritize**
   - Assign a **Fit Score** 1‑10 based on:
     - Alignment with ICP
     - Immediate need indicators
     - Budget likelihood
     - Competitive landscape
     - Timing cues (e.g., recent expansion)
5. **Enrich Lead Data**
   - Identify a primary decision‑maker (role/title).
   - Capture LinkedIn profile URL if available.
   - Note any recent news or events to reference.
6. **Generate Outreach Blueprint**
   - Craft a brief value‑prop statement tailored to the company.
   - Suggest a personalized outreach strategy.
   - Provide 2‑3 conversation starter bullet points.
7. **Deliver Results**
   - Output a markdown report (see template below).
   - Offer next steps: CSV export, draft email, deeper research on top leads.

## Scoring Criteria (Fit Score 1‑10)
| Factor | Weight | How to Evaluate |
|--------|--------|-----------------|
| ICP Alignment | 30% | Match on industry, size, location, tech stack |
| Need Signals | 25% | Recent funding, hiring, job posts, news about problem |
| Budget Indicator | 20% | Revenue range, funding stage, public statements |
| Timing | 15% | Recent product launches, expansion plans |
| Competitive Landscape | 10% | Lack of existing solution or competitor presence |

## Output Template
```markdown
# Lead Research Results

## Summary
- Total leads: X
- High priority (8‑10): Y
- Medium priority (5‑7): Z
- Average fit score: N.N

---

## Lead 1: Company Name
**Website**: https://example.com
**Industry**: Industry name
**Size**: 200‑500 employees
**Priority Score**: 9/10
**Why a Good Fit**:
- Reason 1 (e.g., recent funding for AI initiatives)
- Reason 2 (e.g., uses tech stack compatible with your product)
**Target Decision Maker**: VP of Engineering
**LinkedIn**: https://linkedin.com/in/username
**Value Proposition**: How your product solves their specific problem.
**Outreach Strategy**:
- Personalized email referencing recent news or hiring.
- Connect on LinkedIn with a brief note about the pain point.
**Conversation Starters**:
- "I saw your recent announcement about expanding the data‑science team…"
- "Your engineers are using X technology, which aligns with our solution…"
---

[Repeat for each lead]
```

## Checklist
- [ ] Provide clear product/service description.
- [ ] List all ICP attributes (industry, size, location, pain points, tech).
- [ ] Specify number of leads required.
- [ ] Request fit scores and reasoning.
- [ ] Ask for decision‑maker role and LinkedIn URL.
- [ ] Request outreach strategy and conversation starters.
- [ ] Confirm need for CSV export or draft email follow‑up.

## Tips for Best Results
- Be specific about unique value and differentiators.
- Include any known competitors you want to avoid.
- Mention recent signals you already know (e.g., a funding round).
- If possible, run the skill inside the product’s repository for automatic context extraction.
- Request deeper research on top‑scoring leads for richer insights.

## Related skills

Load these when the task spans more than this skill.

- [`market-research-reports`](../market-research-reports/SKILL.md) — Generate comprehensive 50+ page market research reports with consulting-style analysis, strategic frameworks (…
- [`email-marketing`](../email-marketing/SKILL.md) — Provides a complete guide for building effective email marketing sequences and the supporting email infrastruc…
- [`salesforce`](../salesforce/SKILL.md) — Salesforce Development skill provides concrete patterns for Lightning Web Components, bulkified Apex triggers…
- [`marketing-strategy`](../marketing-strategy/SKILL.md) — Comprehensive playbook for product marketing, positioning, GTM planning, demand generation, paid media, SEO, p…
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`free-tool-marketing`](../free-tool-marketing/SKILL.md) — Provides a step‑by‑step framework for planning, building, and promoting a free marketing tool (calculator, gen…
- [`perplexity-research`](../perplexity-research/SKILL.md) — Perplexity‑Research runs real‑time web searches with Perplexity models via OpenRouter. Use for generic look‑up…
