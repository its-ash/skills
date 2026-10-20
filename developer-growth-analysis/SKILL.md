---
name: developer-growth-analysis
description: "Analyzes recent Claude Code conversation history to identify development patterns, skill gaps, and personalized learning priorities, then generates a growth report with curated Hacker News articles and sends it to a Slack direct message. Use when reviewing Claude Code sessions, chat logs, coding habits, developer productivity, skill assessment, learning roadmap, HackerNews recommendations, Slack report, or growth feedback."
---

# Developer Growth Analysis

Provides data‑driven feedback on your recent coding work. It reads your Claude Code chat logs, extracts patterns, highlights improvement areas, curates relevant HackerNews articles, and sends a formatted report to your Slack direct messages.

## When to Use
- You want a quick review of your recent development habits.
- You need concrete, evidence‑based suggestions for skill improvement.
- You prefer a ready‑to‑read report in Slack for easy reference.

## Workflow
1. **Read Chat History**
   - Open `~/.claude/history.jsonl` (JSONL, one entry per line).
   - Keep entries whose `timestamp` (ms) is within the last 24‑48 hours.
   - Each entry contains `display`, `project`, `timestamp`, `pastedContents`.
2. **Extract Work Patterns**
   - **Projects & Domains** – categorize each entry (backend, frontend, DevOps, data, etc.).
   - **Technologies** – list languages, frameworks, tools mentioned.
   - **Problem Types** – label as debugging, performance, feature implementation, refactoring, setup, etc.
   - **Challenges** – detect repeated questions, multi‑step fixes, or explicit knowledge gaps.
   - **Approach** – note whether the user is methodical, exploratory, or experimental.
3. **Identify Improvement Areas**
   - Choose 3‑5 areas that are **specific**, **evidence‑based**, **actionable**, and **prioritized**.
   - Example format: "Advanced TypeScript generics – struggled with type safety in the auth module."
4. **Generate Report**
   - Use the markdown template below (replace placeholders with actual data).
   - Include sections: Work Summary, Improvement Areas (with Why, Observation, Recommendation, Time Estimate), Strengths, Action Items, Learning Resources.
5. **Curate Learning Resources**
   - For each improvement area, search HackerNews via the Rube MCP `RUBE_SEARCH_TOOLS`.
   - Query examples: `"Learn <technology> best practices"`, `"<technology> advanced patterns"`, `"Debugging <problem> in <language>"`.
   - Select 2‑3 posts with high engagement (upvotes/comments).
   - Record title, date, short relevance note, and URL.
6. **Send Report to Slack**
   - Verify Slack connection with `RUBE_SEARCH_TOOLS`.
   - If missing, establish auth using `RUBE_MANAGE_CONNECTIONS`.
   - Send the report using `RUBE_MULTI_EXECUTE_TOOL`, breaking it into logical Slack messages (title, summary, each improvement area, strengths, actions, resources).
   - Confirm delivery in the CLI output.

## Report Template
```markdown
# Your Developer Growth Report

**Report Period**: <Date Range>
**Last Updated**: <Current Date & Time>

## Work Summary
<2‑3 paragraphs summarizing projects, technologies, and focus areas.>

## Improvement Areas (Prioritized)
### 1. <Area Name>
**Why This Matters**: <Brief importance.>
**What I Observed**: <Specific chat evidence.>
**Recommendation**: <Concrete step(s).>
**Time to Skill Up**: <Effort estimate.>
---
<Repeat for 2‑4 more areas>

## Strengths Observed
- <Bullet 1>
- <Bullet 2>
- <Bullet 3>

## Action Items
1. <Top priority action>
2. <Next action>
3. <Next action>

## Curated Learning Resources
### For: <Improvement Area>
1. **<Article Title>** – <Date>
   <One‑sentence relevance description>
   <Link>
2. **<Article Title>** – <Date>
   <Description>
   <Link>

<Repeat for each area>
```

## Checklist
- [ ] Load `history.jsonl` and filter last 24‑48 h.
- [ ] Classify projects, technologies, problem types, challenges, and approach.
- [ ] Draft 3‑5 specific improvement areas with evidence.
- [ ] Fill the report template with summary, areas, strengths, actions.
- [ ] Search HackerNews for each area; pick top 2‑3 high‑engagement posts.
- [ ] Verify Slack connection; authenticate if needed.
- [ ] Send the report to your Slack DM in separate, readable messages.
- [ ] Confirm successful delivery.

## Tips for Ongoing Use
- Run the analysis weekly to monitor progress.
- Focus on one improvement area at a time before moving to the next.
- After a week of focused work, re‑run the skill to see pattern changes.
- Share the report with a mentor for additional feedback.

## Related skills

Load these when the task spans more than this skill.

- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`career-profile`](../career-profile/SKILL.md) — Step‑by‑step guidance to optimize a LinkedIn profile for recruiter searchability and to create a creative port…
- [`learning-to-action`](../learning-to-action/SKILL.md) — Creates a concrete Ship‑Learn‑Next action plan from any learning material (transcript, article, tutorial). Use…
- [`perplexity-research`](../perplexity-research/SKILL.md) — Perplexity‑Research runs real‑time web searches with Perplexity models via OpenRouter. Use for generic look‑up…
