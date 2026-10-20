---
name: meeting-insights
description: "Analyzes meeting transcripts (txt, md, vtt, srt, docx) to extract communication patterns, speaking ratios, filler-word frequency, conflict avoidance, active listening, and facilitation style with timestamped evidence and coaching feedback. Use when processing meeting transcript, txt, md, vtt, srt, docx for communication analysis, speaking time, filler words, conflict avoidance, active listening, facilitation, timestamped feedback, team dynamics, retrospective, standup, one-on-one, board meeting, interview, user research, conversation patterns, dialogue analytics, speech analysis, meeting effectiveness, collaboration quality."
---

# Meeting Insights Analyzer

Transform raw meeting transcripts into concrete communication feedback. The skill scans a folder of transcript files, extracts speaker labels and timestamps, and produces pattern reports, statistics, and improvement suggestions.

## When to Use
- Review your own or a team’s communication across multiple meetings.
- Identify conflict‑avoidance, interruptions, filler words, or listening gaps.
- Compare facilitation style between two periods or two groups.
- Build a personal development plan or performance‑review evidence.
- Coach others on speaking habits.

---

## Workflow
1. **Prepare Transcripts**
   - Store all files in a single folder (e.g., `~/meetings/`).
   - Acceptable extensions: `.txt`, `.md`, `.vtt`, `.srt`, `.docx`.
   - Ensure each line contains a speaker label and a timestamp (e.g., `00:12:34 John:`).
2. **Define Goal**
   - Ask a clear question: *"Show me when I avoided conflict"* or *"Calculate my speaking ratio"*.
   - If the request is vague, prompt the user for the specific behavior they want to explore.
3. **Run Analysis**
   - The skill scans the folder, parses timestamps, and builds a speaker map.
   - For each requested metric, apply the rule set described below.
4. **Generate Report**
   - Provide a concise summary, key statistics, and 2‑3 strongest timestamped examples.
   - End with concrete next‑step actions.

---

## Core Patterns & How to Detect Them
| Pattern | Detection Rules |
|---|---|
| **Conflict Avoidance** | Look for hedging words (`maybe`, `kind of`, `I think`), indirect phrasing (`we could consider…`), subject changes after tension, or agreements without commitment (`yeah, but…`). |
| **Speaking Ratio** | Compute total speaking time per participant. Ratio = participant speaking time ÷ meeting duration. Also count number of speaking turns. |
| **Interruptions** | An interruption occurs when a speaker’s timestamp starts less than 2 seconds after another speaker’s turn begins. Count *given* (user interrupts) and *received* (user is interrupted). |
| **Filler Words** | Count occurrences of `um`, `uh`, `like`, `you know`, `actually`, etc. Report frequency per minute and per speaking turn. |
| **Active Listening** | Identify moments where the user paraphrases, summarizes, or asks clarifying questions that reference a prior speaker’s point. |
| **Leadership & Facilitation** | Evaluate decision‑making language (directive vs. collaborative), handling of disagreements, inclusion of low‑participation speakers, agenda adherence, and clarity of action items. |

### Example Prompt
```
Analyze all transcripts in ~/meetings/ and:
1. List times I used hedging language.
2. Show my speaking ratio vs. the team.
3. Count my filler words per minute.
4. Provide two examples of good active listening.
```
---

## Reporting Format
For each pattern, output the following markdown block:

```markdown
### <Pattern Name>
**Finding**: <One‑sentence summary>
**Frequency**: <X occurrences across Y meetings>
**Examples**:
1. **<Meeting File> – <Timestamp>**
   > "<Exact quote>"
   **Why it matters**: <Brief impact statement>
   **Better approach**: <Suggested phrasing or behavior>
2. … (up to three examples)
```

After all patterns, include a summary section:

```markdown
# Meeting Insights Summary
**Period**: <Start – End>
**Meetings Analyzed**: <N>
**Total Duration**: <hours>

## Key Patterns
1. <Primary pattern> – <impact> – <recommendation>
2. <Secondary pattern> – …

## Strengths
- <Strength 1 with example>
- <Strength 2>

## Growth Opportunities
- <Area 1>: <actionable tip>
- <Area 2>: <actionable tip>

## Statistics
- Speaking time: <%>
- Questions per meeting: <avg>
- Filler words per minute: <value>
- Interruptions given/received: <value>

## Next Steps
1. <Action 1>
2. <Action 2>
3. <Action 3>
```
---

## Pitfalls & How to Avoid Them
- **Missing timestamps** – Skip files without timestamps and warn the user.
- **Unlabeled speakers** – Attempt to infer speaker from surrounding lines; if ambiguous, mark as `Unknown`.
- **Over‑counting filler words** – Exclude filler words that appear in quoted material or as part of a proper noun.
- **Bias toward recent meetings** – When analyzing many meetings, sample uniformly across the date range.
- **Privacy leakage** – Remind users to keep transcripts local and not share sensitive content with external services.
---

## Checklist for a Successful Run
- [ ] Transcripts are stored in one folder.
- [ ] Files contain speaker labels and timestamps.
- [ ] User has defined a clear analysis goal.
- [ ] No confidential data will be sent outside the environment.
- [ ] Review the generated examples for accuracy before sharing.
- [ ] Schedule a follow‑up analysis to track improvement.
---

## Quick Start Commands
```
# List all transcript files
ls ~/meetings/*.{txt,md,vtt,srt,docx}

# Basic conflict‑avoidance query
Analyze all meetings in this folder and tell me when I avoided conflict.

# Full communication profile
Analyze all meetings in this folder and provide speaking ratio, filler‑word count, and active‑listening examples.
```
---

## Frequently Asked Queries
- *When do I interrupt others?* – Use the **Interruptions** pattern.
- *What is my filler‑word rate?* – Use the **Filler Words** pattern.
- *How inclusive am I of quiet participants?* – Look at **Leadership & Facilitation** metrics for speaker turn distribution.
- *Has my listening improved over time?* – Run the analysis for two separate date ranges and compare the **Active Listening** counts.

---

**Remember:** Treat the output as a coaching tool. Pick one growth area, apply the recommended behavior in the next meeting, and re‑run the analysis to measure change.

## Related skills

Load these when the task spans more than this skill.

- [`professional-communication`](../professional-communication/SKILL.md) — Provides frameworks, templates, and checklists for writing professional emails, internal updates, chat message…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`learning-to-action`](../learning-to-action/SKILL.md) — Creates a concrete Ship‑Learn‑Next action plan from any learning material (transcript, article, tutorial). Use…
- [`workflow-automation`](../workflow-automation/SKILL.md) — Architect and implement reliable automation using n8n, Zapier, Make, and durable execution platforms. Use for…
- [`speech-audio`](../speech-audio/SKILL.md) — Skill for robust speech‑audio processing: transcribe audio (Whisper or OpenAI API, with optional diarization)…
- [`notion`](../notion/SKILL.md) — Creates structured Notion pages from conversations, decisions, how‑tos, FAQs, or research findings. Use when y…
