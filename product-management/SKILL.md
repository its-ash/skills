---
name: product-management
description: "Guides product managers through feature prioritization, customer discovery, PRD writing, OKR cascading, user story creation, sprint planning, metrics, and opportunity analysis. Use when planning a roadmap or backlog, scoring RICE or MoSCoW, writing PRDs from templates, defining OKRs, creating user stories, running sprint planning, analyzing product metrics, synthesizing interview findings, or evaluating 10x opportunities."
---

# Product Management Toolkit

A single reference for modern product work. Use it to discover customer problems, prioritize features, write clear requirements, align goals, plan sprints, track impact, and find game‑changing opportunities.

## When to use
- You have a list of feature ideas and need a systematic way to rank them.
- You are preparing or updating a Product Requirements Document (PRD).
- You need to run customer interviews and turn raw notes into actionable insights.
- You must cascade company OKRs to product and team levels.
- You write user stories for an agile team and need INVEST compliance.
- You want to evaluate high‑leverage "10x" ideas for strategic impact.

---

## 1. Feature Prioritization
### 1.1 Gather feature requests
- Capture requests from customers, sales, support, technical debt, and strategic initiatives.
- Store each request as a single line in a CSV file with columns: `name,reach,impact,confidence,effort`.

### 1.2 Score with RICE
```
Score = (Reach × Impact × Confidence) / Effort
```
| Field      | Definition                              | Example values |
|------------|------------------------------------------|----------------|
| Reach      | Users affected per quarter               | 1000, 5000     |
| Impact     | Effect on user value (massive=3, high=2, medium=1, low=0.5, minimal=0.25) |
| Confidence | Certainty of impact (high=1.0, medium=0.8, low=0.5) |
| Effort     | Person‑months required (e.g., 2, 5) |

**Calculate** each row’s score and sort descending. The highest scores are your top priorities.

### 1.3 Portfolio view
- Plot each feature on a **Value vs Effort** matrix.
- Label quadrants:
  - **Quick Wins** – High value, low effort.
  - **Strategic Bets** – High value, high effort.
  - **Fill‑ins** – Low value, low effort.
  - **Time Sinks** – Low value, high effort.
- Aim for a balanced mix of quick wins and strategic bets each quarter.

### 1.4 MoSCoW classification (optional)
- **Must Have** – Critical for launch.
- **Should Have** – Important but not essential.
- **Could Have** – Nice to have.
- **Won’t Have** – Out of scope for this cycle.

---

## 2. Customer Discovery
### 2.1 Interview guide
| Phase | Time | Focus |
|-------|------|-------|
| Context | 5 min | Role, responsibilities, tools |
| Problem | 15 min | Pain points, frequency, impact, work‑arounds |
| Solution | 10 min | Reaction to concepts, perceived value, willingness to pay |
| Wrap‑up | 5 min | Additional thoughts, referrals, permission to follow up |

- Record with consent.
- Use open‑ended questions; avoid leading language.
- Ask “why” up to five times to uncover root causes.

### 2.2 Manual analysis template
1. List **pain points** and assign a severity rating (1‑5).
2. Extract **feature requests** and map to pain points.
3. Identify **Jobs‑to‑Be‑Done** statements.
4. Note **sentiment** (positive, neutral, negative).
5. Highlight **key quotes** for stakeholder decks.

### 2.3 Synthesize findings
- Group similar pain points.
- Create an **Opportunity Solution Tree**:
```
Outcome
├─ Opportunity A
│  ├─ Solution A1
│  └─ Solution A2
└─ Opportunity B
   ├─ Solution B1
   └─ Solution B2
```
- Validate hypotheses with low‑fidelity prototypes before building.

---

## 3. PRD Development
### 3.1 Choose a template
| Template | Use case |
|----------|----------|
| Standard PRD | Complex features (6‑8 weeks) |
| One‑Page PRD | Small features (2‑4 weeks) |
| Feature Brief | Exploration phase (≤1 week) |
| Agile Epic | Sprint‑based delivery |

### 3.2 Required sections (common to all templates)
1. **Problem Statement** – What user problem are we solving?
2. **Proposed Solution** – High‑level description.
3. **Success Metrics** – Quantitative goals (e.g., adoption ≥ 20 %).
4. **Out‑of‑Scope** – Explicit boundaries.
5. **Acceptance Criteria** – Testable conditions.
6. **Dependencies** – Other teams, APIs, data.
7. **Risks & Mitigations** – Known uncertainties.

### 3.3 Collaboration checklist
- Review feasibility with engineering.
- Validate desirability with design mock‑ups.
- Confirm market fit with sales or support.
- Store the PRD in version‑controlled documentation (e.g., Git, Confluence).

---

## 4. OKR Cascade (Strategic Alignment)
### 4.1 Structure
```
Company Objective → Product Objective → Team OKRs → Individual Key Results
```
### 4.2 Example cascade (Growth strategy)
- **Company Objective**: Increase annual recurring revenue (ARR) by 30 %.
- **Product Objective**: Grow active users by 25 %.
- **Team OKR**: Launch referral program.
  - KR1: Implement referral link generation (by Q1).
  - KR2: Achieve 5 % conversion from referrals.
- **Individual KR**: Write referral API documentation.

### 4.3 Alignment score
- For each lower‑level OKR, assign a **contribution %** to its parent.
- Sum contributions; aim for ≥ 80 % alignment across the hierarchy.

---

## 5. Agile Backlog & User Stories
### 5.1 INVEST checklist for each story
- **I**ndependent
- **N**egotiable
- **V**aluable
- **E**stimable
- **S**mall
- **T**estable

### 5.2 Story template
```
As a <role>, I want <feature> so that <benefit>.
```
**Acceptance Criteria** (example):
- Given <context>, when <action>, then <outcome>.
- All fields are validated and error messages are user‑friendly.

### 5.3 Automatic point estimation (manual method)
- Use **T-shirt sizing** (XS, S, M, L, XL).
- Convert to story points (1, 2, 3, 5, 8).
- Validate with the team during planning poker.

### 5.4 Sprint capacity planning
1. Sum the available person‑days for the sprint.
2. Subtract 20 % buffer for meetings and unexpected work.
3. Divide remaining capacity by average story points to get the **velocity target**.
4. Pull stories until the target is met.

---

## 6. Metrics & Analytics
### 6.1 North Star Metric (NSM)
- Identify the single metric that best reflects core user value.
- Ensure the NSM is **measurable**, **actionable**, and **leading**.

### 6.2 Funnel analysis stages
```
Acquisition → Activation → Retention → Revenue → Referral
```
Track conversion rates, drop‑off points, and time between stages.

### 6.3 Feature success metrics
- **Adoption** – % of active users who use the feature.
- **Frequency** – Avg. uses per user per week.
- **Depth** – % of feature capabilities exercised.
- **Retention** – Cohort survival after feature launch.
- **Satisfaction** – NPS or CSAT specific to the feature.

---

## 7. 10x Opportunity Mode
### 7.1 Goal
Identify ideas that could make the product **ten times** more valuable, not just incremental improvements.

### 7.2 Workflow
1. **Understand current value** – Answer: problem solved, core action, user complaints.
2. **Generate ideas** across three effort levels:
   - **Massive** – Transformative, new markets, platform shift.
   - **Medium** – Strong leverage on existing core.
   - **Small** – Tiny changes with outsized impact.
3. **Score each idea** on Impact, Reach, Frequency, Differentiation, Defensibility, Feasibility.
4. **Prioritize** into four buckets:
   - **Do Now** – Quick wins.
   - **Do Next** – High‑leverage moves.
   - **Explore** – Strategic bets.
   - **Backlog** – Good but not urgent.

### 7.3 Scoring rubric (simple)
| Rating | Meaning |
|--------|---------|
| 🔥 Must do | High impact, high reach, feasible. |
| 👍 Strong | Good impact, worth prioritizing. |
| 🤔 Maybe | Needs more data. |
| ❌ Pass | Low impact or high risk. |

### 7.4 Idea categories to probe
- **Speed** – Reduce latency or steps.
- **Automation** – Eliminate repetitive tasks.
- **Intelligence** – Add recommendation or anomaly detection.
- **Integration** – Connect with complementary tools.
- **Collaboration** – Enable sharing or real‑time work.
- **Personalization** – Tailor views or defaults.
- **Visibility** – Surface hidden data.
- **Confidence** – Reduce user anxiety (undo, preview).
- **Delight** – Add moments of joy (animations, celebrations).
- **Access** – Reach new platforms or improve accessibility.

### 7.5 Output template
```
## Recommended Priority
### Do Now (Quick wins)
1. <Feature> – Reason, Impact.
### Do Next (High leverage)
1. <Feature> – Reason, Unlocks.
### Explore (Strategic bets)
1. <Feature> – Reason, Risk, Upside.
```

---

## 8. Common Pitfalls
- **Solution‑first thinking** – Jump to features before understanding the problem.
- **Analysis paralysis** – Over‑research without shipping.
- **Feature factory** – Build without measuring impact.
- **Ignoring technical debt** – Neglect platform health.
- **Stakeholder surprise** – Fail to communicate decisions early.
- **Metric theater** – Optimize vanity metrics instead of real value.

---

## 9. Checklist (run before each major product decision)
- [ ] Have I captured the problem in a clear statement?
- [ ] Did I interview at least three representative users?
- [ ] Are the pain points ranked by severity?
- [ ] Have I scored each feature with RICE?
- [ ] Does the PRD include success metrics and out‑of‑scope?
- [ ] Are OKRs aligned from company to team level?
- [ ] Does each user story meet the INVEST criteria?
- [ ] Have I estimated sprint capacity with a 20 % buffer?
- [ ] Is the North Star Metric defined and tracked?
- [ ] Did I evaluate 10x ideas and place them in the priority buckets?
- [ ] Have I communicated the plan to all stakeholders?

---

## 10. Quick Reference Commands (generic examples)
```bash
# Create a CSV for RICE scoring
cat > features.csv <<EOF
name,reach,impact,confidence,effort
"Search autocomplete",5000,2,0.9,1
"Export to PDF",2000,1,0.8,2
EOF

# Calculate RICE score (replace with your own script or spreadsheet)
python -c "import csv,sys;\nreader=csv.DictReader(open('features.csv'));\nfor r in reader:\n  score=(float(r['reach'])*float(r['impact'])*float(r['confidence']))/float(r['effort']);\n  print(r['name'], round(score,2))"

# Example user‑story generation (manual template)
cat > story.txt <<EOF
As a project manager, I want to export a project report as PDF so that I can share it with stakeholders.
EOF
```
These snippets illustrate the data formats and simple scripts you can adapt to your environment.

## Related skills

Load these when the task spans more than this skill.

- [`feature-brainstorming`](../feature-brainstorming/SKILL.md) — Feature‑brainstorming skill turns a vague feature idea into a clear design, requirements, and implementation p…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`jira`](../jira/SKILL.md) — Interact with Jira issues using the jira CLI or Atlassian MCP tools. Use when the user mentions an issue key (…
- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`analytics-tracking`](../analytics-tracking/SKILL.md) — Provides a complete workflow for planning, implementing, auditing, and analyzing analytics tracking (GA4, GTM,…
- [`executive-advisor`](../executive-advisor/SKILL.md) — Provides integrated executive and technology leadership guidance for CEOs and CTOs. Use when planning corporat…
- [`pricing-strategy`](../pricing-strategy/SKILL.md) — A step‑by‑step framework for SaaS pricing and monetization, covering research methods, value‑metric selection,…
