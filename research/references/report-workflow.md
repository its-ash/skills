# Research report workflow

## Tools

Need at least one MCP: **firecrawl** (`firecrawl_search`, `firecrawl_scrape`, `firecrawl_crawl`) or **exa** (`web_search_exa`, `web_search_advanced_exa`, `crawling_exa`). Both together give best coverage. Tool names, quotas, and result shapes change: check configured tools and current API docs before you promise coverage. No MCP: use [web-scraping-apis](../../web-scraping-apis/SKILL.md) HTTP APIs or built-in web search/fetch.

## Steps

1. **Goal**: ask 1–2 questions (learn, decide, or write? angle/depth?). "Just research it" → use defaults.
2. **Plan**: split topic into 3–5 sub-questions. Example "AI in healthcare": applications today; measured clinical outcomes; regulatory challenges; leading companies; market size and growth.
3. **Search** each sub-question with 2–3 keyword variants, general + news:
   ```
   firecrawl_search(query: "<keywords>", limit: 8)
   web_search_exa(query: "<keywords>", numResults: 8)
   web_search_advanced_exa(query: "<keywords>", numResults: 5, startPublishedDate: "2025-01-01")
   ```
   Target 15–30 unique sources.
4. **Deep-read** 3–5 key sources in full; do not rely on snippets:
   ```
   firecrawl_scrape(url: "<url>")
   crawling_exa(url: "<url>", tokensNum: 5000)
   ```
5. **Write** the report (template below).
6. **Deliver**: short topic → full report in chat. Long → executive summary + takeaways in chat, full report to a file.

## Parallel subagents (broad topics)

Launch 3 agents: A → sub-questions 1–2; B → 3–4; C → 5 + cross-cutting themes. Each searches, reads, returns findings. Main session synthesizes.

## Report template

```markdown
# [Topic]: Research Report
*Generated: [date] | Sources: [N] | Confidence: [High/Medium/Low]*

## Executive Summary
[3-5 sentences]

## 1. [Theme]
- Key point ([Source](url))
- Supporting data ([Source](url))

## 2. [Theme] ...

## Key Takeaways
- [Actionable insight]

## Sources
1. [Title](url) — [one-line summary]

## Methodology
Searched [N] queries across web and news. Analyzed [M] sources. Sub-questions: [list]
```
