---
name: skill-authoring
description: "Skill Authoring guides designing, writing, testing, evaluating, and refining Claude skills, including SKILL.md frontmatter, body structure, trigger descriptions, benchmarks, and test cases. Use when creating a new skill, updating an existing skill, improving skill triggering, writing SKILL.md, adding examples, running evals, or refining agent instructions and workflows."
---

# Skill Authoring

**Purpose** – Provide a complete, repeatable process for creating, editing, testing, and improving Claude skills. The workflow combines interview, documentation, test‑driven development, quantitative evaluation, and description optimisation so the skill loads reliably and adds genuine expert knowledge.

---

## When to use
- You need a brand‑new skill to capture a workflow, tool integration, or domain expertise.
- An existing skill is outdated, missing edge‑cases, or triggers poorly.
- You want to add or improve test cases, assertions, or benchmarks.
- You need to audit a skill for token efficiency, knowledge delta, or anti‑patterns.
- You want to optimise the skill description so Claude triggers it in the right contexts.

---

## End‑to‑end workflow
1. **Capture intent** – ask the user what the skill should enable, when it should trigger, and the expected output format.
2. **Interview & research** – clarify edge cases, input/output schemas, dependencies, and gather reference material.
3. **Draft `SKILL.md`** – write front‑matter, a concise description, and the body using the patterns below.
4. **Create test prompts** – store realistic user prompts in `evals/evals.json` (no assertions yet).
5. **Run evaluations** – spawn a *with‑skill* and a *baseline* run for each prompt in the same turn.
6. **Draft assertions** while runs are in progress; add them to the eval files.
7. **Capture timing** (`total_tokens`, `duration_ms`) as soon as each run finishes.
8. **Grade results** – evaluate each assertion, produce `grading.json`.
9. **Aggregate benchmark** – compute pass‑rate, token usage, and latency statistics.
10. **Analyse** – look for non‑discriminating assertions, high variance, or time‑token trade‑offs.
11. **Iterate** – rewrite the skill or add resources, then repeat from step 4.
12. **Optimise description** – apply the *Claude Search Optimisation* rules (see below).
13. **Final audit** – run the Skill Judge scoring checklist to ensure compliance.

---

## 1. Capture intent & interview
| Question | Why it matters |
|----------|----------------|
| What should Claude be able to do? | Defines the core capability. |
| When should the skill trigger? (phrases, file types, contexts) | Drives the description and trigger keywords. |
| What is the exact output format? | Enables deterministic assertions. |
| Are there objective test cases? (file transforms, data extraction) | Determines whether to create `evals.json`. |
| What are common edge cases or failure modes? | Guides the anti‑pattern list and assertions. |

Ask follow‑up questions only as needed; avoid overwhelming the user.

---

## 2. Draft `SKILL.md`
### Front‑matter (YAML)
```yaml
---
name: my-new-skill               # lower‑case, hyphens, ≤64 chars
description: >
  Use when the user asks to generate a PDF report from a CSV file, needs
  column aggregation, or mentions "PDF report" or ".csv". Include keywords
  like "report", "PDF", "CSV", and "aggregation".
---
```
**Description rules**
- Start with **"Use when"**.
- List concrete trigger conditions, symptoms, and keywords.
- Do **not** summarise the workflow; keep it strictly *when* to use.
- Be *pushy*: include all synonyms the model might search for.
- Keep ≤ 1024 characters.

### Body structure (keep < 500 lines)
```markdown
# My New Skill

## Overview
One‑sentence purpose.

## When to Use
Bullet list of symptoms and trigger phrases.

## Core Pattern
Decision tree or pseudo‑code showing expert reasoning.

## Quick Reference
Table or bullets for the most common operations.

## Implementation
- Inline code (< 50 lines) for simple patterns.
- Link to heavy reference files for detailed APIs.

## Anti‑patterns (NEVER list)
Specific things to avoid, with a short why.

## Common Mistakes
Typical pitfalls and fixes.
```
**Writing style** – imperative, concise, avoid jargon unless the skill is technology‑specific.

### Naming & freedom calibration
- Use gerund form (`creating‑skills`, `debugging‑with‑logs`).
- Match freedom to fragility: high freedom for creative tasks, low freedom (scripts) for error‑prone operations.

---

## 3. Resource organisation (Progressive disclosure)
```
skill-name/
├── SKILL.md               # required, < 500 lines
├── scripts/               # deterministic code, reusable
├── references/            # large docs, schemas, APIs (> 100 lines)
└── assets/                # templates, images, fonts
```
- **Reference files** > 100 lines must start with a table of contents.
- Load a reference only when the body explicitly says **MANDATORY – READ**.
- Keep references one level deep from `SKILL.md`.

---

## 4. Test‑Driven Skill Development (RED‑GREEN‑REFACTOR)
1. **RED** – Run the same prompt *without* the skill; capture the baseline output.
2. **GREEN** – Add the skill, run the prompt again, and verify the output matches expectations.
3. **REFRACTOR** – Add missing edge‑case handling, improve description, and repeat.

### `evals/evals.json` schema (minimal example)
```json
{
  "skill_name": "my-new-skill",
  "evals": [
    {
      "id": 1,
      "prompt": "Generate a PDF report from sales.csv with total sales per region.",
      "expected_output": "PDF file containing a table with region totals",
      "files": []
    }
  ]
}
```
Add an empty `assertions` array now; fill it later.

---

## 5. Running evaluations (no external scripts)
### Workspace layout
```
my-new-skill-workspace/
├── iteration-1/
│   ├── eval-1/
│   │   ├── with_skill/outputs/
│   │   ├── without_skill/outputs/
│   │   ├── eval_metadata.json
│   │   └── timing.json
│   └── ...
└── iteration-2/ …
```
### Step 1 – Spawn runs (same turn)
```text
Execute task:
- Skill path: <path-to-skill>
- Task: <prompt>
- Input files: none
- Save outputs to: <workspace>/iteration-1/eval-1/with_skill/outputs/

Execute baseline task (no skill path) and save to …/without_skill/outputs/.
```
### Step 2 – Draft assertions while runs execute
Create `assertions` objects such as:
```json
{"name":"pdf‑generated","type":"contains","value":".pdf"}
```
Explain each assertion to the user.
### Step 3 – Capture timing
When a run finishes, immediately write:
```json
{"total_tokens": 84231, "duration_ms": 21540, "total_duration_seconds": 21.5}
```
### Step 4 – Grade & aggregate
`grading.json` must contain an array of objects with **text**, **passed**, **evidence** fields.
Run aggregation (Python standard library):
```bash
python -m scripts.aggregate_benchmark my-new-skill-workspace/iteration-1 --skill-name my-new-skill
```
Produces `benchmark.json` and `benchmark.md` with mean ± stddev and delta vs baseline.
### Step 5 – Viewer
```bash
nohup python eval-viewer/generate_review.py \
  my-new-skill-workspace/iteration-1 \
  --skill-name "my-new-skill" \
  --benchmark my-new-skill-workspace/iteration-1/benchmark.json \
  > /dev/null 2>&1 &
```
Add `--previous-workspace` for later iterations.

---

## 6. Description optimisation (Claude Search Optimisation)
1. **Rich description** – only trigger info, no workflow.
2. **Keyword coverage** – include error messages, file extensions, library names, and synonyms.
3. **Avoid summarising** – a description that says *"this skill creates a PDF report"* will cause Claude to skip the body.
4. **Example good vs bad**
   - ❌ Bad: `description: "Creates PDF reports from CSV files and formats them."`
   - ✅ Good: `description: "Use when the user asks for a PDF report from a CSV, mentions ‘report’, ‘PDF’, or ‘.csv’."
5. **Pushy phrasing** – list all plausible trigger phrases.

---

## 7. Quality scoring – the Skill Judge checklist
| Dimension | What to check |
|-----------|---------------|
| **Knowledge Delta** (20) | Does every paragraph teach Claude something it does not already know? Remove basics. |
| **Mindset + Procedures** (15) | Include expert thinking patterns *and* domain‑specific workflows that Claude cannot infer. |
| **Anti‑patterns** (15) | Provide a specific **NEVER** list with reasons. |
| **Description compliance** (15) | Front‑matter present, description includes WHAT, WHEN, and keywords. |
| **Progressive disclosure** (15) | Body < 500 lines, references loaded only when explicitly required. |
| **Freedom calibration** (15) | Freedom level matches task fragility (high for creative, low for error‑prone). |
| **Total** | 120 points max. |

### Scoring guide (excerpt)
- **0‑5** knowledge delta → skill is mostly redundant.
- **16‑20** → pure expert knowledge, token‑efficient.
- **Description** must answer three questions (WHAT, WHEN, KEYWORDS). Missing any reduces the score dramatically.

---

## 8. Common pitfalls & how to avoid them
- **Over‑loading SKILL.md** – split large docs into `references/` and add explicit load triggers.
- **Redundant basics** – audit each paragraph; if Claude already knows it, delete.
- **Vague description** – add concrete trigger phrases and symptoms.
- **Missing anti‑patterns** – always include a **NEVER** list.
- **Incorrect enforcement level** – guardrails that should block must use `block`; advisory skills use `suggest`.
- **Skipping baseline runs** – without a RED baseline you cannot measure improvement.
- **Forgetting timing data** – token and latency metrics are essential for benchmark analysis.

---

## Checklist
- [ ] Capture intent and confirm trigger conditions with the user.
- [ ] Write front‑matter with a *pushy* description (Use when …).
- [ ] Keep `SKILL.md` under 500 lines; move heavy content to `references/`.
- [ ] Name the skill in gerund, hyphenated form.
- [ ] Create 2‑3 realistic test prompts in `evals/evals.json`.
- [ ] Spawn with‑skill and baseline runs in the same turn.
- [ ] Draft assertions while runs are in progress.
- [ ] Save `timing.json` immediately after each run.
- [ ] Produce `grading.json` with `text`, `passed`, `evidence` fields.
- [ ] Run aggregation script to generate `benchmark.json`/`benchmark.md`.
- [ ] Review benchmark for non‑discriminating assertions or high variance.
- [ ] Refine description, body, or resources based on analysis.
- [ ] Run the Skill Judge checklist and address any low scores.
- [ ] Iterate until the skill passes all tests and scores ≥ 90 points.

---

**Result** – A well‑structured, token‑efficient skill that adds genuine expert knowledge, triggers reliably, and is validated by quantitative benchmarks.

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`agent-instructions-refactor`](../agent-instructions-refactor/SKILL.md) — Refactor a bloated AGENTS.md, CLAUDE.md, or similar file into a minimal root file and a set of linked topic fi…
- [`slash-command-development`](../slash-command-development/SKILL.md) — Defines how to create, configure, and organize Claude Code slash commands. Covers file locations, YAML frontma…
- [`hook-development`](../hook-development/SKILL.md) — Guide for creating, configuring, and debugging Claude Code plugin hooks and Hookify rules. Use when you need t…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
