# Product Diagnostics (4 modes)

Every mode outputs an actionable document. Each recommendation has one specific next step.

## Mode 1: Product diagnostic (YC office hours)

Ask one question at a time:

1. Who is this for? A specific person, not "developers".
2. What is the pain? Quantify: how often, how bad, what do they do today?
3. Why now? What changed that makes this possible or necessary?
4. What is the 10-star version (unlimited money and time)?
5. What is the MVP: the smallest thing that proves the thesis?
6. What is the anti-goal: what do you explicitly NOT build?
7. How do you know it works? A metric, not vibes.

Output: `PRODUCT-BRIEF.md` with answers, risks, and go/no-go. Ask the user before you write it into the repo. On "go", continue with [product-capability.md](product-capability.md).

## Mode 2: Founder review

1. Read README, CLAUDE.md, package.json, recent commits.
2. Infer what the project tries to be.
3. Score product-market-fit signals (0-10):
   - Usage growth trajectory.
   - Retention (repeat contributors, return users).
   - Revenue (pricing page, billing code, Stripe integration).
   - Moat (what is hard to copy?).
4. Name the one thing that would 10x it.
5. Flag work that does not matter.

## Mode 3: User journey audit

1. Clone or install as a new user.
2. Record every friction point (confusing steps, errors, missing docs).
3. Time each step.
4. Compare to competitor onboarding.
5. Score time-to-value (time to first win).
6. Recommend the top 3 onboarding fixes.

Verify findings in a real browser: [browser-qa.md](../../unit-testing-patterns/references/browser-qa.md).

## Mode 4: Feature prioritization (ICE)

1. List all candidate features.
2. Score each: impact (1-5) × confidence (1-5) ÷ effort (1-5).
3. Rank by ICE score.
4. Apply constraints: runway, team size, dependencies.
5. Output a prioritized roadmap with rationale.
