---
name: notebooklm
description: "Authenticate with Google NotebookLM to create, manage, and query AI-powered research notebooks, run structured multi-source deep research workflows, and generate studio artifacts including slides, audio, video, infographics, reports, and mind maps. Use when you need to authenticate NotebookLM, manage notebook library, add context sources via Smart Add, define research scope, create notebooks, import discovered sources, query for insights, write research briefs, generate slides, produce audio, create video, build infographics, export reports, or make mind maps from Google's AI research assistant notebook LM."
---

# NotebookLM Research Assistant

Use this skill to interact with Google NotebookLM from Claude Code. Authenticate, add or search notebooks, run source‑grounded Gemini queries, and produce a structured research brief with optional studio artifacts.

## When to Use
- User mentions NotebookLM or provides a NotebookLM URL.
- User wants to query their uploaded documents for citation‑backed answers.
- User needs a market, competitive, trend, or prospect research brief.
- User asks for a slide deck, podcast, video, infographic, report, or mind‑map derived from the research.

---

## Prerequisites
- A NotebookLM MCP server must be configured (`nlm setup add claude-code`).
- Python 3.9+ is installed.
- Internet access for Google authentication.

---

## 1. Authentication
1. **Check status**
   ```bash
   python -m notebooklm.auth_manager status
   ```
2. If not authenticated, run the one‑time setup (browser will open for Google login):
   ```bash
   python -m notebooklm.auth_manager setup
   ```
   *Tell the user that a browser window will appear for manual login.*
3. After login, re‑run the status command to confirm.

---

## 2. Notebook Library Management
| Action | Command | Notes |
|--------|---------|-------|
| List notebooks | `python -m notebooklm.notebook_manager list` | Shows ID, name, topics. |
| Search by keyword | `python -m notebooklm.notebook_manager search --query "keyword"` | Returns matching notebooks. |
| Add a notebook (all metadata required) | `python -m notebooklm.notebook_manager add --url "URL" --name "Name" --description "Full description" --topics "t1,t2"` | If description or topics are unknown, first run a **Smart Add** (see below). |
| Activate a notebook | `python -m notebooklm.notebook_manager activate --id NOTEBOOK_ID` | Sets default for queries without explicit ID. |
| Remove a notebook | `python -m notebooklm.notebook_manager remove --id NOTEBOOK_ID` | |

### Smart Add (when metadata missing)
1. Discover content:
   ```bash
   python -m notebooklm.ask_question --question "What topics does this notebook cover? Summarize briefly." --notebook-url "URL"
   ```
2. Use the returned summary to fill `--name`, `--description`, and `--topics` in the add command.

---

## 3. Structured Research Workflow (Deep Research)
### Step 1 – Define Scope
Ask the user to confirm the research type and key questions. Typical types:
- **Market Research** – trends, sizing, TAM/SAM/SOM.
- **Competitive Intel** – competitor list, positioning gaps.
- **Prospect Research** – company background, decision makers.
- **Trend Analysis** – technology adoption, forecasts.
- **Proposal Research** – sector data, case studies.
- **Academic/Technical** – papers, frameworks.

### Step 2 – Create a Notebook
```bash
python -m notebooklm.notebook_manager create --name "Research: TOPIC - YYYY-MM-DD"
```
Store the returned `NOTEBOOK_ID`.

### Step 3 – Add Context Sources
For each URL, document, or text the user provides, run:
```bash
python -m notebooklm.source_add --notebook-id NOTEBOOK_ID --url "URL"
# or
python -m notebooklm.source_add --notebook-id NOTEBOOK_ID --text "Summary text"
```
Add company sites, LinkedIn pages, press releases, etc.

### Step 4 – Run Research Engine
```bash
python -m notebooklm.research_start \
  --notebook-id NOTEBOOK_ID \
  --query "Your detailed research question" \
  --mode fast   # use "deep" only if user explicitly wants exhaustive results
```
Poll status until `completed`:
```bash
python -m notebooklm.research_status --task-id TASK_ID
```
If needed, run parallel `WebSearch` calls to gather fresh URLs while the engine works.

### Step 5 – Import Discovered Sources
```bash
python -m notebooklm.research_import --task-id TASK_ID --notebook-id NOTEBOOK_ID
```

### Step 6 – Query for Insights
Ask 3‑5 targeted questions with `notebook_query`:
```bash
python -m notebooklm.notebook_query \
  --notebook-id NOTEBOOK_ID \
  --question "What are the key findings about TOPIC?"
```
Typical questions:
1. Overview of findings.
2. Opportunities or gaps.
3. Actionable recommendations.
4. Risks or challenges.
5. Custom question specific to the research type.

### Step 7 – Write Research Brief
Create a markdown file under `research/` (create the folder if missing):
```bash
mkdir -p research
cat <<'EOF' > research/topic-slug-$(date +%F).md
# Research Brief – TOPIC

## Overview
...
## Opportunities
...
## Risks
...
## Recommendations
...
EOF
```
Use a consistent template: title, overview, opportunities, risks, actions, and source list.

### Step 8 – Present Takeaways
Return to the user:
- 3‑5 headline bullet findings.
- 1‑2 recommended actions aligned with user goals.
- Any surprising or contrarian insight.
- File path of the full brief.
- Notebook URL for direct exploration.

---

## 4. Generating Studio Artifacts (Optional)
If the user wants an artifact, run:
```bash
python -m notebooklm.studio_create \
  --notebook-id NOTEBOOK_ID \
  --type slide_deck \
  --slide_format detailed_deck \
  --slide_length short \
  --language en \
  --focus_prompt "Emphasize market opportunities" \
  --confirm true
```
Supported types and key parameters:
| Type | Key Params | Best For |
|------|------------|----------|
| `slide_deck` | `slide_format` (`detailed_deck`/`presenter_slides`), `slide_length` (`short`/`default`) | Executive decks |
| `audio` | `audio_format` (`deep_dive`/`brief`), `audio_length` (`short`/`default`/`long`) | Podcast‑style reviews |
| `video` | `video_format` (`explainer`/`brief`/`cinematic`), `visual_style` (`auto_select`/`classic`/`whiteboard`) | Visual explainers |
| `infographic` | `orientation` (`landscape`/`portrait`/`square`), `infographic_style` (`professional`/`bento_grid`) | One‑page summaries |
| `report` | `report_format` (`Briefing Doc`/`Study Guide`/`Blog Post`) | Written deliverables |
| `mind_map` | `title` | Knowledge maps |

After creation, poll `studio_status` until `completed`, then download:
```bash
python -m notebooklm.download_artifact --artifact-id ARTIFACT_ID --output ./artifacts/
```
Provide the artifact file path and the notebook URL to the user.

---

## 5. Follow‑Up Mechanism (Critical)
Every answer from `ask_question` ends with the prompt **"Is that ALL you need to know?"**. Implement the following loop:
1. **Stop** after receiving the answer.
2. **Compare** the answer to the original request.
3. If gaps exist, **ask a follow‑up** using `ask_question` with additional context.
4. Repeat until the user’s need is satisfied.
5. **Synthesize** all collected answers into a single coherent response before replying.

---

## Checklist
- [ ] Verify authentication (`auth_manager status`).
- [ ] Confirm research scope and key questions with the user.
- [ ] Create and activate a dedicated notebook.
- [ ] Add all provided URLs, documents, or text summaries.
- [ ] Choose `fast` mode unless exhaustive depth is requested.
- [ ] Poll research status and import discovered sources.
- [ ] Run 3‑5 targeted `notebook_query` prompts.
- [ ] Save a markdown brief in `research/` folder.
- [ ] Summarize headline findings and actions for the user.
- [ ] Offer artifact generation; create and download if accepted.
- [ ] Apply the follow‑up loop until the user confirms completeness.

---

## Troubleshooting
| Issue | Fix |
|-------|-----|
| `ModuleNotFoundError` | Always run commands via the `python -m notebooklm.*` wrapper; it creates the virtual environment automatically. |
| Authentication fails | Re‑run `auth_manager setup` with `--show-browser` to see the login window. |
| Rate limit reached (≈50 queries/day) | Wait 24 h or switch to another Google account. |
| Browser crashes | Run `python -m notebooklm.cleanup_manager --preserve-library` to reset the browser state. |
| Notebook not found | List notebooks (`notebook_manager list`) and verify the ID. |

---

## Best Practices
- Always check authentication before any operation.
- Use **Smart Add** to discover notebook metadata when the user does not provide it.
- Keep each `ask_question` independent; include necessary context each time.
- Prefer `fast` mode for typical research; reserve `deep` for explicit exhaustive requests.
- Run the follow‑up loop to eliminate gaps before delivering the final answer.
- Store briefs in a versioned `research/` folder for future reference.

## Related skills

Load these when the task spans more than this skill.

- [`perplexity-research`](../perplexity-research/SKILL.md) — Perplexity‑Research runs real‑time web searches with Perplexity models via OpenRouter. Use for generic look‑up…
- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`scientific-writing`](../scientific-writing/SKILL.md) — Write and revise scientific manuscripts in full paragraphs using IMRAD or conference structure, verified citat…
- [`market-research-reports`](../market-research-reports/SKILL.md) — Generate comprehensive 50+ page market research reports with consulting-style analysis, strategic frameworks (…
- [`obsidian`](../obsidian/SKILL.md) — Create, edit, and validate Obsidian Flavored Markdown, .base files, .canvas JSON files, and Web Clipper templa…
