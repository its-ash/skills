---
name: notion
description: "Creates structured Notion pages from conversations, decisions, how‑tos, FAQs, or research findings with proper linking and citations. Use when you need to capture knowledge, synthesize multiple Notion sources into briefs, comparisons, or reports, export meeting notes, organize project documentation, build a wiki, write product specs, draft RFCs, compile research summaries, or migrate notes from Obsidian, markdown files, Google Docs, or Confluence into Notion databases and pages using the Notion API or MCP integration."
---

# Notion Knowledge Capture & Research Documentation

Convert chats, notes, or research into well‑structured, linkable Notion pages. The skill guides you from goal definition to final publishing, handling both single‑item capture (decision, how‑to, FAQ) and multi‑source research (brief, summary, comparison, report).

## When to use
- You have a decision, how‑to, FAQ, learning note, or documentation draft that must be stored in Notion.
- You need to gather information from several Notion pages and produce a brief, summary, comparison, or comprehensive report.
- You want consistent formatting, proper citations, and automatic linking to related records.

## Workflow
### 0️⃣ Connect the Notion MCP (if required)
```bash
codex mcp add notion --url https://mcp.notion.com/mcp
# Enable remote client
# Option 1: edit config.toml
#   set [features].rmcp_client = true
# Option 2: command line
codex --enable rmcp_client
# Log in via OAuth
codex mcp login notion
```
After login, restart **codex** and continue with step 1.

### 1️⃣ Define the goal
- Ask for purpose, audience, and freshness.
- Choose content type: decision, how‑to, FAQ, learning note, documentation page, brief, summary, comparison, or report.

### 2️⃣ Locate the destination
- Select the appropriate Notion database (team wiki, how‑to, FAQ, decision log, research, etc.).
- Verify required properties: title, tags, owner, status, date, and any relation fields.
- If more than one database fits, ask the user to confirm.

### 3️⃣ Gather sources (research only)
- Search with `Notion:notion-search` using focused queries.
- Refine the query until the result set matches the scope.
- Fetch each page with `Notion:notion-fetch`.
- Record the page URL or ID for later citation.

### 4️⃣ Extract and structure content
- Pull facts, decisions, actions, and rationale.
- For decisions, list alternatives, reasoning, and outcome.
- For how‑tos, list prerequisites, step‑by‑step actions, and edge cases.
- For FAQs, write a clear question and a concise answer.
- For research, group findings by theme, note evidence, and flag gaps.

### 5️⃣ Create or update the Notion page
```bash
Notion:notion-create-pages \
  --database-id <ID> \
  --title "<Title>" \
  --properties "{\"tags\": [\"example\"], \"owner\": \"@user\", \"status\": \"Draft\"}" \
  --content "<Markdown or rich text>"
```
- Use the matching template (decision log, how‑to guide, FAQ, brief, summary, comparison, report).
- If the page already exists, fetch it first and edit with `Notion:notion-update-page`.

### 6️⃣ Link, cite, and surface
- Add backlinks to hub pages, related specs, or team databases.
- Insert inline citations using the recorded source IDs.
- Add a short changelog or summary for future readers.
- Create follow‑up tasks in the appropriate task database and link them.

### 7️⃣ Finalize and handoff
- Review for clarity, completeness, and correct owners.
- Publish the page and share the link.
- Update the page status (e.g., `Published`) with `Notion:notion-update-page`.

## Rules
- Always clarify purpose, audience, and whether the entry is new or an update.
- Use the correct database; mismatched properties break automation.
- Record a citation for every external fact or metric.
- Keep titles under 80 characters and descriptive.
- Fill required properties (tags, owner, status, dates) before saving.
- Link to related pages to improve discoverability.

## Common Patterns
| Pattern | Key Elements |
|---|---|
| **Decision Log** | Alternatives, rationale, chosen option, outcome, next steps |
| **How‑to Guide** | Prerequisites, step list, screenshots/code snippets, edge cases |
| **FAQ** | Question line, concise answer, link to deeper documentation |
| **Research Brief** | Executive summary, key findings, recommendations, citations |
| **Comparison Report** | Table of criteria, side‑by‑side scores, pros/cons, source links |
| **Comprehensive Report** | Detailed sections, methodology, data tables, risk analysis, full bibliography |

## Pitfalls to avoid
- Skipping citations – readers cannot verify facts.
- Selecting the wrong database – required fields will be missing.
- Overloading a page with unrelated topics – reduces readability.
- Forgetting to set the owner or status – tasks may be orphaned.
- Not linking related records – knowledge stays siloed.

## Checklist
- [ ] Define purpose, audience, and freshness.
- [ ] Choose the correct Notion database/template.
- [ ] Search and fetch all relevant source pages (research only).
- [ ] Record source IDs for citations.
- [ ] Extract facts, decisions, steps, or findings.
- [ ] Draft the page using the appropriate template.
- [ ] Fill required properties (title, tags, owner, status, dates).
- [ ] Add backlinks and relation fields.
- [ ] Insert inline citations and a references section.
- [ ] Review for clarity and completeness.
- [ ] Publish and share the page link.
- [ ] Update status/owner and add any follow‑up tasks.

## Related skills

Load these when the task spans more than this skill.

- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`meeting-insights`](../meeting-insights/SKILL.md) — Analyzes meeting transcripts (txt, md, vtt, srt, docx) to reveal communication patterns, speaking ratios, fill…
- [`research-engineer`](../research-engineer/SKILL.md) — Research Engineer skill for rigorous, correctness-first engineering. Use when implementing algorithms, optimiz…
- [`file-organization`](../file-organization/SKILL.md) — Organizes files and folders intelligently: analyzes directory structure, finds duplicates, proposes logical fo…
- [`clear-writing`](../clear-writing/SKILL.md) — The clear‑writing skill helps you edit any human‑focused prose—documentation, commit messages, UI copy, report…
- [`obsidian`](../obsidian/SKILL.md) — Create, edit, and validate Obsidian Flavored Markdown, .base files, .canvas JSON files, and Web Clipper templa…
