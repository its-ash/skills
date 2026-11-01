---
name: product-strategy
description: "Validates the why before building with four product diagnostics (YC-style product brief with go/no-go, founder review of product-market-fit signals, user journey audit for time-to-value, ICE feature prioritization), then turns the result into capability plans, market research, competitive benchmarks, and brand positioning. Use when pressure-testing product direction, choosing between features, sanity-checking a launch, writing a PRODUCT-BRIEF.md, PRD-to-SRS capability plans, TAM/SAM/SOM sizing, investor or fund diligence, competitor scoping, benchmarking, competitive landscape reports, white-space analysis, or brand discovery interviews. Sub-skills: product-capability, market-research, competitive-platform-analysis, benchmark-methodology, competitive-report-structure, brand-discovery."
---

# Product Strategy: Think Before You Build

This skill owns product diagnosis: is this the right thing to build, for whom, and why now. It does not write the implementation spec itself. When the diagnosis says "build this", hand off to [references/product-capability.md](references/product-capability.md).

## When to Use

- Before you start a feature: validate the "why".
- Weekly product review: are we building the right thing?
- You are stuck choosing between features.
- Before a launch: sanity-check the user journey.
- You must turn a vague idea into a product brief before engineering planning starts.

## How It Works

### Mode 1: Product Diagnostic

Like YC office hours. Ask the hard questions, one at a time:

```
1. Who is this for? (specific person, not "developers")
2. What's the pain? (quantify: how often, how bad, what do they do today?)
3. Why now? (what changed that makes this possible/necessary?)
4. What's the 10-star version? (if money/time were unlimited)
5. What's the MVP? (smallest thing that proves the thesis)
6. What's the anti-goal? (what are you explicitly NOT building?)
7. How do you know it's working? (metric, not vibes)
```

Output: a `PRODUCT-BRIEF.md` with the answers, risks, and a go/no-go recommendation. Ask the user before you write the file into the repo.

If the result is "yes, build this", the next step is [references/product-capability.md](references/product-capability.md), not more discussion.

### Mode 2: Founder Review

Review the current project through a founder lens:

```
1. Read README, CLAUDE.md, package.json, recent commits
2. Infer: what is this trying to be?
3. Score: product-market fit signals (0-10)
   - Usage growth trajectory
   - Retention indicators (repeat contributors, return users)
   - Revenue signals (pricing page, billing code, Stripe integration)
   - Competitive moat (what's hard to copy?)
4. Identify: the one thing that would 10x this
5. Flag: things you're building that don't matter
```

### Mode 3: User Journey Audit

Map the real user experience:

```
1. Clone/install the product as a new user
2. Document every friction point (confusing steps, errors, missing docs)
3. Time each step
4. Compare to competitor onboarding
5. Score: time-to-value (how long until the user gets their first win?)
6. Recommend: top 3 fixes for onboarding
```

### Mode 4: Feature Prioritization

When you have 10 ideas and must pick 2:

```
1. List all candidate features
2. Score each on: impact (1-5) × confidence (1-5) ÷ effort (1-5)
3. Rank by ICE score
4. Apply constraints: runway, team size, dependencies
5. Output: prioritized roadmap with rationale
```

## Output

All modes produce actionable documents, not essays. Each recommendation has a specific next step.

## Integration

- Verify user journey findings in a real browser with [unit-testing-patterns/references/browser-qa.md](../unit-testing-patterns/references/browser-qa.md).
- Assess visual polish with [design](../design/SKILL.md).
- Watch a launch after release with [web-quality-audit](../web-quality-audit/SKILL.md) (canary watch).
- Validate personas and journeys with real users through [ux-research](../ux-research/SKILL.md).

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/product-capability.md](references/product-capability.md) | Turn a PRD, roadmap item, or founder note into an implementation-ready capability plan: constraints, invariants, states, interfaces, non-goals, open questions, and handoff. |
| [references/market-research.md](references/market-research.md) | Market sizing (TAM/SAM/SOM), competitor comparison, investor or fund diligence, and technology or vendor scans, with sources, untrusted-source rules, and a decision. |
| [references/competitive-platform-analysis.md](references/competitive-platform-analysis.md) | Step 1 of a competitive analysis: scope, tier (Direct, Adjacent, Aspirational), and pre-filter the competitor set, and choose data sources. |
| [references/benchmark-methodology.md](references/benchmark-methodology.md) | Step 2: score each competitor on nine weighted dimensions with 1 to 5 evidence-based rubrics, bias controls, a tension 2x2 plot, and profile cards. |
| [references/competitive-report-structure.md](references/competitive-report-structure.md) | Step 3: assemble the profile cards into a decision-grade report with landscape map, heatmap matrix, deep dives, white-space, recommendations, and alignment questions. |
| [references/brand-discovery.md](references/brand-discovery.md) | Run a multi-session brand identity interview (purpose, positioning, audience, archetype, voice, narrative, founder tension) that ends in a master brandbook and positioning brief. |

## Related skills

Load these when the task spans more than this skill.

- [`software-architecture`](../software-architecture/SKILL.md) — Architecture decisions, ADRs, and acceptance criteria after the capability plan.
- [`ux-research`](../ux-research/SKILL.md) — Personas, journey maps, and usability tests.
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — CRO audits for landing, pricing, signup, and onboarding flows.
- [`content-writing`](../content-writing/SKILL.md) — Launch campaigns, brand voice profiles, and investor materials.
- [`research`](../research/SKILL.md) — Cited multi-source research for market and competitor data.
