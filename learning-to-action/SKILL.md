---
name: learning-to-action
description: "Creates a concrete Ship-Learn-Next action plan from learning material such as a transcript, article, tutorial, notes, blog post, course, podcast, documentation, markdown, or pdf. Use when you want to turn advice into a short, shippable iteration, learning quest, practice reps, study plan, action steps, implementation plan, next experiment, hands-on project, or skill-building roadmap from educational content."
---

# Learning-to-Action (Ship‑Learn‑Next Planner)

Transform passive learning material into a short, repeatable implementation cycle. The output is a markdown plan that defines a concrete first rep, success criteria, reflection questions, and a brief roadmap for the next few reps.

## When to Use
- User provides a transcript, article, or tutorial and asks for an implementation plan.
- User wants to turn a lesson into a concrete, shippable task.
- User needs to break a big idea into small, actionable steps.

## Core Framework: Ship‑Learn‑Next
1. **SHIP** – Build a real artifact (code, content, product, demo).
2. **LEARN** – Reflect on what happened.
3. **NEXT** – Plan the next iteration based on the reflection.

Repeat the cycle. Aim for many small reps rather than a single large effort.

## Workflow
### 1. Read the Content
```bash
FILE_PATH="/path/to/content.txt"
```
Use the read tool to load the file. Do not summarize the whole text; focus on actionable parts.

### 2. Extract Core Lessons
Identify and list only:
- **Key advice** – concrete recommendations.
- **Actionable principles** – practices the user can try.
- **Skills to practice** – abilities demonstrated in the source.
- **Examples / case studies** – minimal implementations that can be replicated.

### 3. Define the Quest
Ask the user three questions and record the answers:
1. What do you want to achieve in the next 4‑8 weeks?
2. What does success look like? (Be specific)
3. What concrete thing can you ship to prove progress?

### 4. Design Rep 1 (First Iteration)
Guide the user to the smallest shippable version they can complete in 1‑7 days.
- State the exact deliverable.
- Identify the single new skill needed.
- Define “done” with clear, observable criteria.

### 5. Create the Rep Plan
Use the template below. Fill in the brackets with the user’s answers.
```markdown
## Rep 1: [Specific Goal]

**Ship Goal**: [What you will create]
**Success Criteria**: [How you will know it is done]
**What You’ll Learn**: [Skill or insight]
**Resources Needed**: [Only what is required for this rep]
**Timeline**: [Exact deadline]

**Action Steps**:
1. [Concrete step]
2. [Concrete step]
3. [Concrete step]
4. Ship it (publish, deploy, share, demonstrate)

**Reflection Questions**:
- What actually happened?
- What worked? What didn’t?
- What surprised you?
- Rate this rep 1‑10:
- What will you change for the next rep?
```

### 6. Map Future Reps (2‑5)
For each subsequent rep, add only one new element.
```markdown
## Rep 2: [Next Goal]
**Builds on**: Rep 1
**New Challenge**: [One new skill or improvement]
**Ship Goal**: [Concrete deliverable]
**Success Criteria**: [Brief list]

## Rep 3: …
```
Follow the same structure. Keep each rep shippable and tied to a specific lesson from the source.

### 7. Connect to Source Material
For every rep, add a short note linking the action to the original content, e.g.,
- "Implements the cold‑email script from minute 3:45."
- "Practices the A/B testing method described in the article."
Only reference resources that are required for the current rep.

## Conversation Style
- Ask concise, outcome‑focused questions.
- Encourage the smallest possible version.
- End each exchange with a concrete next step.
- Use supportive language: "Ship it, then we’ll improve."

## What NOT to Do
- Do not create a study‑only plan.
- Do not list every possible resource; keep only what is needed now.
- Do not allow vague goals like “learn X”.
- Do not let the user plan indefinitely without a first ship.
- Do not overwhelm with a full multi‑month roadmap; focus on Rep 1.

## Checklist
- [ ] Loaded the content file.
- [ ] Extracted 3‑5 actionable lessons.
- [ ] Defined a 4‑8 week quest with a specific success metric.
- [ ] Designed a Rep 1 that can be completed in ≤7 days.
- [ ] Filled the Rep 1 template with ship goal, success criteria, learning focus, resources, timeline, steps, and reflection questions.
- [ ] Drafted brief Rep 2‑5 outlines, each adding one new element.
- [ ] Linked each rep to a concrete point in the source material.
- [ ] Saved the plan as `Ship-Learn-Next Plan - [Quest Title].md`.
- [ ] Confirmed the user’s deadline for Rep 1 and asked about potential blockers.

## Related skills

Load these when the task spans more than this skill.

- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`kaizen`](../kaizen/SKILL.md) — Kaizen skill guides developers to improve code quality incrementally, prevent errors by design, follow establi…
- [`developer-growth-analysis`](../developer-growth-analysis/SKILL.md) — Analyzes recent Claude Code chat history (24‑48 h) to surface development patterns, pinpoint skill gaps, and g…
- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`meeting-insights`](../meeting-insights/SKILL.md) — Analyzes meeting transcripts (txt, md, vtt, srt, docx) to reveal communication patterns, speaking ratios, fill…
