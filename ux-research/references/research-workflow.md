# UX Research Workflow: Steps, Code, Templates

Detail for [../SKILL.md](../SKILL.md).

## 1. Collect
- Interview transcripts → plain text or JSON.
- Survey results → CSV.
- Analytics events (page views, clicks) → CSV or JSON.
- Store raw files in a version-controlled folder.

## 2. Clean (pandas)
```python
import pandas as pd

survey = pd.read_csv("survey_responses.csv")
interviews = pd.read_json("interview_tags.json")  # pre-tagged themes

survey.columns = [c.strip().lower().replace(" ", "_") for c in survey.columns]
survey = survey.drop_duplicates()
survey = survey[survey.isna().mean(axis=1) <= 0.30]          # drop rows >30% missing
survey = survey.dropna(subset=["age", "goal", "pain_point"])
if "satisfaction" in survey:  # normalize Likert labels to 1-5
    survey["satisfaction"] = survey["satisfaction"].map({"Very Satisfied": 5, "Satisfied": 4, "Neutral": 3, "Dissatisfied": 2, "Very Dissatisfied": 1})
```

## 3. Find patterns
Small sets: frequency counts of goals and pain points. Large sets: TF-IDF + K-means (3-5 clusters).
```python
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.cluster import KMeans

X = TfidfVectorizer(stop_words="english").fit_transform(survey["goal"])
survey["persona_cluster"] = KMeans(n_clusters=4, random_state=42).fit(X).labels_
```
Read cluster centroids to label archetypes (for example "Power User", "Occasional Shopper").

## 4. Persona template
```markdown
## Persona: <Name>
- **Demographics**: age, gender, location, occupation
- **Behaviors**: use frequency, device preference
- **Goals**: primary objectives
- **Pain Points**: frustrations, barriers
- **Psychographics**: attitudes, motivations, values
- **Scenario**: typical interaction, < 150 words
- **Confidence Score**: supporting participants / total participants * 100
```

## 5. Journey map
Stages: Awareness → Consideration → Purchase → Use → Support. Per stage: touchpoint, emotion, pain point. Tools: table, Miro, FigJam, Lucidchart.

| Stage | Touchpoint | Emotion | Pain Point |
|---|---|---|---|
| Awareness | Social ad | Curious | Too much jargon |
| Consideration | Product page | Interested | Missing pricing details |
| Purchase | Checkout flow | Anxious | Complex form validation |
| Use | Mobile onboarding | Confident | Inconsistent UI patterns |
| Support | Live chat | Frustrated | Long wait times |

Add alternative paths; a journey is not one line.

## 6. Usability test plan
- Tasks that reflect core persona scenarios.
- Success criteria per task (for example: done in ≤ 2 min, ≤ 1 error).
- Participants that match persona demographics; diverse recruit.
- Method: moderated remote, unmoderated remote (Maze, UserTesting), or in-person.

## 7. Run and capture
- Quantitative: success rate, time on task, error count; SUS score after session.
- Qualitative: comments, think-aloud remarks, observed expressions.
- Store results in a structured CSV.

## 8. Synthesize
- Aggregate: mean time, success %.
- Code comments into themes (affinity mapping, thematic analysis).
- Write per theme: insight statement → design implication.
- Prioritize with impact/effort:

| Insight | Impact | Effort | Priority |
|---|---|---|---|
| Navigation labels unclear | High | Low | High |
| Checkout steps too many | Medium | Medium | Medium |

## 9. Validate
- Change wireframes or prototypes (Figma) for top insights.
- Re-test with the same persona groups.
- Compare against baseline metrics.

## Checklist
- [ ] Raw data in version control.
- [ ] Duplicates removed; missing critical fields handled.
- [ ] Clusters found and labeled.
- [ ] Persona per archetype with confidence score.
- [ ] Journey map: stages, touchpoints, emotions, pain points.
- [ ] Test plan: tasks, success criteria, participant criteria.
- [ ] Results in structured CSV.
- [ ] Insights prioritized and linked to design implications.
- [ ] Changes validated with a follow-up test.
- [ ] Artifacts shared with the product team.
