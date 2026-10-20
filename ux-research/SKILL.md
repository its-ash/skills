---
name: ux-research
description: "Generates data-driven personas, customer journey maps, usability test plans, findings synthesis, and design validation workflows for UX research. Use when conducting user research, interviews, surveys, usability testing, persona creation, journey mapping, heuristic evaluation, prototype testing, Figma prototypes, Maze, UserTesting, Hotjar, UX metrics, SUS, task success, affinity mapping, thematic analysis, or design validation."
---

# UX Research & Design Toolkit

Create research‑backed personas, map journeys, run usability tests, synthesize insights, and validate designs. Use this skill when you need a repeatable, data‑driven process for user research and design validation.

## When to use
- You have interview transcripts, survey results, or analytics data.
- You need to define clear personas for product strategy.
- You must visualize the end‑to‑end user experience.
- You are planning or analyzing usability testing sessions.
- You need to turn raw findings into actionable design recommendations.

## Workflow Overview
1. **Collect raw data** – Gather interview notes, survey CSVs, analytics exports.
2. **Clean & structure data** – Use a spreadsheet or Python `pandas` to normalize fields.
3. **Identify patterns** – Cluster behaviors, goals, and pain points.
4. **Generate personas** – Create archetype profiles with demographics, psychographics, scenarios, and confidence scores.
5. **Map the journey** – Plot steps, touchpoints, emotions, and pain points on a timeline.
6. **Plan usability tests** – Define tasks, success criteria, and participant criteria.
7. **Run tests & capture metrics** – Record success rate, time on task, and qualitative feedback.
8. **Synthesize findings** – Summarize themes, highlight design implications, and prioritize actions.
9. **Validate designs** – Compare prototype results against persona goals and journey pain points.

## Detailed Steps
### 1. Data Collection
- Export interview transcripts to plain‑text or JSON.
- Export survey results to CSV.
- Pull analytics events (e.g., page views, clicks) into a CSV or JSON file.

### 2. Data Cleaning (Python example)
```python
import pandas as pd

# Load survey data
survey = pd.read_csv('survey_responses.csv')
# Load interview tags (pre‑processed JSON with key themes)
interviews = pd.read_json('interview_tags.json')

# Standardize column names
survey.columns = [c.strip().lower().replace(' ', '_') for c in survey.columns]

# Drop rows with missing critical fields
survey = survey.dropna(subset=['age', 'goal', 'pain_point'])
```
- Remove duplicate rows.
- Normalize categorical values (e.g., "Very Satisfied" → "5").

### 3. Pattern Identification
- Use simple frequency counts for goals and pain points.
- For larger data sets, apply K‑means clustering on numeric encodings of responses.
```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans

vectorizer = TfidfVectorizer(stop_words='english')
X = vectorizer.fit_transform(survey['goal'])
km = KMeans(n_clusters=4, random_state=42).fit(X)
survey['persona_cluster'] = km.labels_
```
- Review cluster centroids to label archetypes (e.g., "Power User", "Occasional Shopper").

### 4. Persona Generation
Create a markdown or Google Docs template for each archetype:
```
## Persona: <Name>
- **Demographics**: Age, gender, location, occupation
- **Behaviors**: Frequency of product use, device preference
- **Goals**: Primary objectives when using the product
- **Pain Points**: Frustrations and barriers
- **Psychographics**: Attitudes, motivations, values
- **Scenario**: Short story of a typical interaction
- **Confidence Score**: (Number of participants supporting this archetype / total participants) * 100
```
- Fill the template with aggregated data from the cluster.
- Add a confidence score to indicate reliability.

### 5. Customer Journey Mapping
- List key stages (Awareness, Consideration, Purchase, Use, Support).
- For each stage, note touchpoints, emotions, and pain points.
- Use a table or a visual tool (Miro, FigJam, Lucidchart).
```
| Stage      | Touchpoint          | Emotion   | Pain Point                |
|------------|---------------------|-----------|---------------------------|
| Awareness  | Social ad           | Curious   | Too much jargon           |
| Consideration | Product page    | Interested | Missing pricing details |
| Purchase   | Checkout flow       | Anxious   | Complex form validation   |
| Use        | Mobile app onboarding| Confident| Inconsistent UI patterns |
| Support    | Live chat           | Frustrated| Long wait times           |
```

### 6. Usability Test Planning
- Define **tasks** that reflect core scenarios.
- Set **success criteria** (e.g., complete task within 2 min, ≤ 1 error).
- Recruit participants matching persona demographics.
- Choose a testing method: moderated remote, unmoderated remote, or in‑person.

### 7. Test Execution & Metric Capture
- Record **quantitative** metrics: success rate, time on task, error count.
- Capture **qualitative** notes: user comments, facial expressions, think‑aloud remarks.
- Store results in a CSV for later analysis.

### 8. Synthesis & Insight Generation
- Aggregate quantitative data (average time, success %).
- Code qualitative comments into themes (e.g., "navigation confusion").
- Prioritize insights using an impact‑effort matrix.
```
| Insight                     | Impact | Effort | Priority |
|----------------------------|--------|--------|----------|
| Navigation labels unclear | High   | Low    | High     |
| Checkout steps too many    | Medium | Medium | Medium   |
```
- Write a short **insight statement** for each theme, followed by **design implications**.

### 9. Design Validation
- Update wireframes or prototypes to address top‑priority insights.
- Run a second round of usability testing with the same personas.
- Compare new metrics against baseline to confirm improvement.

## Rules & Decision Criteria
- **Sample Size**: Minimum 5 participants per persona cluster for a reliable confidence score.
- **Data Quality**: Exclude responses with > 30 % missing fields.
- **Cluster Count**: Choose 3‑5 clusters; too many dilute insight, too few hide nuance.
- **Scenario Length**: Keep persona scenarios under 150 words for readability.
- **Success Threshold**: Aim for ≥ 80 % task success and ≤ 2 min average time on critical tasks.

## Common Pitfalls
- **Over‑generalizing**: Merging distinct user types into one persona reduces usefulness.
- **Ignoring Negative Feedback**: Dismissing outlier comments can hide critical issues.
- **Skipping Confidence Scoring**: Without a score, stakeholders cannot gauge reliability.
- **Static Journeys**: Treating the journey as a single path ignores alternative flows.
- **Insufficient Test Diversity**: Recruiting only from one demographic skews results.

## Checklist
- [ ] Raw data files collected and stored in a version‑controlled folder.
- [ ] Data cleaned: duplicates removed, missing critical fields handled.
- [ ] Patterns identified and clusters labeled.
- [ ] Persona template filled for each archetype with confidence score.
- [ ] Journey map created with stages, touchpoints, emotions, and pain points.
- [ ] Usability test plan documented: tasks, success criteria, participant criteria.
- [ ] Test results recorded in a structured CSV.
- [ ] Insights synthesized, prioritized, and linked to design implications.
- [ ] Design changes implemented and validated with a follow‑up test.
- [ ] All artifacts (personas, journey map, test plan, insights) shared with the product team.

## Related skills

Load these when the task spans more than this skill.

- [`design`](../design/SKILL.md) — Unified frontend design skill covering the full lifecycle from brief inference to production. Combines anti-sl…
- [`design-systems`](../design-systems/SKILL.md) — Creates a complete design system with design tokens, atomic component architecture, theming (including dark mo…
- [`figma`](../figma/SKILL.md) — Provides a step‑by‑step workflow to fetch design context, screenshots, and assets from a Figma MCP server and…
- [`product-management`](../product-management/SKILL.md) — A comprehensive product‑management skill that guides product managers, strategists, and agile owners through d…
- [`ab-testing`](../ab-testing/SKILL.md) — A step‑by‑step guide for planning, designing, running, and analyzing A/B (split) tests or multivariate experim…
- [`conversion-optimization`](../conversion-optimization/SKILL.md) — Conversion Optimization skill guides you through improving conversions for marketing pages, forms, popups, sig…
- [`marketing-psychology`](../marketing-psychology/SKILL.md) — Provides a curated list of psychological principles, mental models, and behavioral‑science tactics for marketi…
