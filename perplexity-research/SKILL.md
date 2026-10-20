---
name: perplexity-research
description: "Perplexity-Research performs real-time web search and synthesis using Perplexity models through OpenRouter for factual lookups, conversational answers, and deep multi-source research. Use when you need Perplexity search, OpenRouter model calls, current web information, source-backed answers, research summaries, citations, or deep research reports."
---

# Perplexity‑Research

Perform AI‑powered web searches and research with Perplexity models through OpenRouter. The skill chooses the appropriate tool (search, ask, or deep researcher) and selects the optimal Perplexity model based on query complexity.

---

## When to use
- User asks to *search*, *find*, *look up*, *research*, or wants the *latest* information.
- Need current facts, recent scientific papers, or up‑to‑date technical documentation.
- Require a short answer (search) **or** a synthesized explanation (ask).
- Need multi‑source synthesis with citations (deep research).

**Do NOT use** for:
- Library or framework documentation (use Context7).
- Commands that mention the `gt` CLI (use Graphite MCP).
- Questions about the current workspace (use Nx MCP).
- Simple calculations or code execution (use built‑in language tools).

---

## Tool selection chain
| Priority | Tool | When to pick |
|---|---|---|
| 1 | **Context7 MCP** | Library/framework docs |
| 2 | **Graphite MCP** | Any `gt` CLI reference |
| 3 | **Nx MCP** | Workspace‑specific queries |
| 4 | **Perplexity Search** | Generic resource discovery, URLs, recent tutorials |
| 5 | **Perplexity Ask** | Conversational explanation, synthesis of web info |
| 6 | **Researcher agent** (`/research <topic>`) | Deep multi‑source synthesis, citations |
| 7 | **WebSearch** | Last resort when Perplexity fails |

---

## Perplexity Search
### When to use
- Find URLs, tutorials, blog posts, or recent best‑practice guides.
- User says *"search for…"*, *"find…"*, *"look up…"*.

### Default call (TypeScript syntax for internal MCP)
```typescript
mcp__perplexity__perplexity_search({
  query: "your search query",
  max_results: 3,            // limit to avoid context bloat
  max_tokens_per_page: 512    // keep each result concise
})
```
### Increase limits only if required
```typescript
mcp__perplexity__perplexity_search({
  query: "complex topic",
  max_results: 5,
  max_tokens_per_page: 1024
})
```
### CLI example (uses OpenRouter, no external script required)
```bash
perplexity-search "What are the latest CRISPR developments?" \
  --model sonar-pro \
  --max-results 3 \
  --max-tokens-per-page 512
```
---

## Perplexity Ask
### When to use
- User wants an explanation, comparison, or synthesis rather than raw URLs.
- The query is a *question* (e.g., *"Explain how PostgreSQL advisory locks work"*).

### Call (TypeScript)
```typescript
mcp__perplexity__perplexity_ask({
  messages: [{ role: "user", content: "Explain how PostgreSQL advisory locks work" }]
})
```
### CLI example
```bash
perplexity-ask "Explain the mechanism of mRNA vaccines" \
  --model sonar-reasoning-pro
```
---

## Researcher Agent (deep multi‑source synthesis)
### When to use
- Complex comparative analysis, systematic review, or any task that needs citations from multiple sources.
- Token‑intensive queries (30‑50k tokens).

### Invocation
```
/research <topic>
```
The agent automatically selects the best Perplexity model and returns a structured answer with citations.
---

## Model selection guide (OpenRouter)
| Model | Typical use | Cost (approx.) |
|---|---|---|
| **sonar** | Simple fact look‑ups | $0.001‑0.002 per query |
| **sonar‑pro** (default) | General searches, balanced quality | $0.002‑0.005 |
| **sonar‑pro‑search** | Multi‑step agentic search, high depth | $0.020‑0.050 |
| **sonar‑reasoning‑pro** | Step‑by‑step reasoning, comparative analysis | $0.005‑0.010 |

### Automatic model choice (research‑lookup logic)
1. Scan the query for **reasoning keywords** such as `compare`, `analyze`, `explain`, `mechanism`, `trade‑off`, `meta‑analysis`, etc.
2. Assign points (3 per keyword, 2 per question mark, 1.5 per conjunction, 1 for >150 chars).
3. If total ≥ 3 → select **sonar‑reasoning‑pro**.
4. Otherwise → select **sonar‑pro‑search**.

**Manual override** – add `--force-model sonar-pro` or `--force-model reasoning` to the CLI.
---

## Crafting effective queries
- **Be specific**: include domain, time frame, and desired output.
- **Add time constraints** for recent info (e.g., *"2024"*, *"past 6 months"*).
- **State source preference** when needed (e.g., *"peer‑reviewed journals"*).
- **Structure complex queries**:
  1. Topic
  2. Specific aspect
  3. Context / time frame
  4. Desired format

**Good example**: `"What improvements does AlphaFold3 offer over AlphaFold2 for protein structure prediction, according to papers published 2023‑2024? Include accuracy metrics."`

**Bad example**: `"vaccines"` (too vague).
---

## Cost‑management tips
1. Use **sonar** for trivial fact checks.
2. Keep default **sonar‑pro** for most queries.
3. Reserve **sonar‑pro‑search** and **sonar‑reasoning‑pro** for queries that trigger the reasoning score.
4. Set `--max-tokens` to limit response length.
5. Monitor usage at the OpenRouter dashboard.
6. Cache results locally when the same query is repeated.
---

## Pitfalls & safeguards
- **Avoid excessive `max_results`** – large result sets increase token usage and may dilute relevance.
- **Do not use** the prohibited `mcp__perplexity__perplexity_research` tool; use the researcher agent instead.
- **Validate citations** – always cross‑check AI‑generated references with the original source.
- **Respect rate limits** – add a short delay (e.g., 2 s) between batch queries.
- **Protect API keys** – store `OPENROUTER_API_KEY` in environment variables, never commit to version control.
---

## Checklist
- [ ] Identify the user intent: search, ask, or deep research.
- [ ] Choose the correct tool according to the selection chain.
- [ ] Apply default parameters (`max_results: 3`, `max_tokens_per_page: 512`).
- [ ] Craft a specific, time‑bounded query.
- [ ] Verify if reasoning keywords push the query to **sonar‑reasoning‑pro**.
- [ ] Run the query using the appropriate CLI or MCP call.
- [ ] Review the answer for relevance and citation accuracy.
- [ ] Cache or store results if they will be reused.
- [ ] Monitor token usage and cost.
---

## Quick reference table
| Trigger phrase | Tool | Model (default) |
|---|---|---|
| "search for…", "find…", "look up…" | Perplexity Search | sonar‑pro |
| "explain…", "what are the trade‑offs…" | Perplexity Ask | sonar‑reasoning‑pro (if reasoning keywords) else sonar‑pro |
| "/research <topic>" or complex comparative request | Researcher agent | sonar‑pro‑search / sonar‑reasoning‑pro (auto) |

## Related skills

Load these when the task spans more than this skill.

- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
- [`market-research-reports`](../market-research-reports/SKILL.md) — Generate comprehensive 50+ page market research reports with consulting-style analysis, strategic frameworks (…
- [`lead-research`](../lead-research/SKILL.md) — Lead Research skill finds and qualifies high‑quality prospects for a product or service. Provide product detai…
- [`research-critique`](../research-critique/SKILL.md) — Systematically evaluate scientific research rigor, methodology, and claims. Use for peer review of manuscripts…
- [`citation-management`](../citation-management/SKILL.md) — Manage academic citations: search Google Scholar and PubMed, extract metadata from DOI, PMID, arXiv ID, or URL…
- [`hypothesis-generation`](../hypothesis-generation/SKILL.md) — Generate testable scientific hypotheses through structured ideation and evidence synthesis. Combines conversat…
- [`notebooklm`](../notebooklm/SKILL.md) — NotebookLM skill lets you authenticate, manage, and query Google NotebookLM notebooks from Claude Code, run st…
