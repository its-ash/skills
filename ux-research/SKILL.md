---
name: ux-research
description: "Generates data-driven personas, customer journey maps, usability test plans, findings synthesis, and design validation workflows for UX research. Use when conducting user research, interviews, surveys, usability testing, persona creation, journey mapping, heuristic evaluation, prototype testing, Figma prototypes, Maze, UserTesting, Hotjar, UX metrics, SUS, task success, affinity mapping, thematic analysis, or design validation."
---

# UX Research

Turn raw user data into personas, journeys, tested insights, and validated designs.

## Core rules
- Follow the pipeline: collect → clean → find patterns → personas → journey → test plan → run → synthesize → validate.
- Keep raw data (transcripts, survey CSV, analytics exports) in a version-controlled folder.
- Drop duplicate rows and responses with > 30% missing fields. Normalize categorical answers (Likert → 1-5).
- Use 3-5 persona clusters.
- Require ≥ 5 participants per persona cluster for a reliable confidence score.
- Give every persona a confidence score: supporting participants / total × 100.
- Keep persona scenarios < 150 words.
- Map each journey stage with touchpoint, emotion, and pain point. Include alternative paths.
- Define tasks, success criteria, and participant criteria before a usability test.
- Target ≥ 80% task success and ≤ 2 min mean time on critical tasks.
- Record quantitative (success, time, errors) and qualitative (think-aloud, comments) data in a structured CSV.
- Write each theme as insight statement → design implication. Prioritize by impact/effort.
- Keep negative and outlier feedback; it often shows critical issues.
- Recruit across demographics; one group skews results.
- Validate changes with a second test against the baseline.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Small dataset | frequency counts of goals and pain points | clustering noise |
| Large text dataset | TF-IDF + K-means, label by centroids | hand-sorting hundreds of rows |
| Two distinct user types look similar | keep separate personas | merging into one generic persona |
| Choose test method | moderated remote (depth), unmoderated remote (scale), in-person (physical/context) | one method for every question |
| Many findings | impact/effort matrix; ship high-impact low-effort first | fixing in arrival order |
| Quantify perceived usability | SUS after each session | ad-hoc satisfaction scale |
| Validate a fix | re-test same persona groups, compare to baseline | declaring success from design review |
| Compare two live variants | A/B test | usability test with 5 users |

## Load on demand
| Need | Read |
|---|---|
| Step detail, pandas cleaning and K-means code, persona template, journey map and impact/effort examples, final checklist | [references/research-workflow.md](references/research-workflow.md) |

## Related skills
- [`design`](../design/SKILL.md) — Parent workflow: UI design from brief to production.
- [`figma`](../design/references/figma.md) — Figma MCP context, screenshots, assets.
- [`ab-testing`](../conversion-optimization/references/ab-testing.md) — Split and multivariate experiments.
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Funnel, form, signup, paywall CRO.
