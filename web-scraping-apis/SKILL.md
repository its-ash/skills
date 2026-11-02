---
name: web-scraping-apis
description: "Unified guide for using Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik to scrape pages, search the web, crawl sites into markdown, render JavaScript, and fetch X/Twitter posts. Use when scraping with Firecrawl, Tavily, Cloudflare Browser Rendering, or Xquik; crawling sites; extracting HTML/JSON; converting to .md; searching SERPs; rendering JavaScript; fetching tweets; using curl; handling 403, 429, or CAPTCHA; or building a scheduled scraper agent that monitors jobs, prices, news, or repos with LLM scoring. Sub-skills: bright-data, data-scraper-agent."
---
# Web Scraping APIs
Pick the right hosted API to scrape, search, crawl, or pull X data, and call it safely.

## Core rules
- Read keys from env only: `FIRECRAWL_API_KEY`, `TAVILY_API_KEY`, `CLOUDFLARE_ACCOUNT_ID` + `CLOUDFLARE_API_TOKEN`, `XQ_API_KEY`.
- Send the auth header on every call: `Authorization: Bearer <key>` (Firecrawl, Tavily, Cloudflare), `x-api-key` (Xquik).
- Respect `robots.txt` and site terms.
- Set `render:false` for static sites; it cuts cost and latency.
- Set `limit` / `max_results` to the smallest value that does the job.
- Async jobs: start → poll until `completed` → fetch pages with `cursor` until it is null.
- Retry only 429 and 5xx: back off 1 s, 2 s, 4 s, max 3 tries. Never retry other 4xx.
- Check quota before large jobs; cache search results.
- Save each page with a `<!-- Source: <url> -->` header for traceability.
- Stream large outputs (PDF base64, CSV) to files, not memory.
- Revoke keys and delete temp output when done.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| One page: full text, screenshot, or PDF | Firecrawl `/v0/scrape` | Full-site crawl |
| Web search, then article text | Tavily `/search` → `/crawl` | Scraping SERP HTML |
| Whole docs site to markdown, JS rendered | Cloudflare Browser Rendering crawl | Page-by-page scrape |
| Daily site sync | Full crawl once, then `modifiedSince` | Daily full crawl |
| Noisy sections (changelog, API ref) | `excludePatterns` | Crawl then filter |
| Tweets, profiles, followers, trends, giveaways | Xquik | Raw X scraping |
| Proxies, Web Unlocker, SERP API, 403/CAPTCHA | [bright-data](references/bright-data.md) | Hand-rolled proxy rotation |
| Scheduled monitor with LLM scoring | [data-scraper-agent](references/data-scraper-agent.md) | One-off scripts in cron |
| Browser automation you control | [`playwright`](../unit-testing-patterns/references/playwright.md) | Hosted render for simple clicks |

## Load on demand
| Need | Read |
|---|---|
| Firecrawl, Tavily, Xquik endpoints, curl examples, limits | [references/api-endpoints.md](references/api-endpoints.md) |
| Cloudflare crawl: start/poll/page, Python saver, params, limits | [references/cloudflare-crawl.md](references/cloudflare-crawl.md) |
| Bright Data: SERP API, Web Unlocker, Scraper API, Browser API, MCP, RRF reranking | [references/bright-data.md](references/bright-data.md) |
| Scheduled Python agent: collect, Gemini Flash batch scoring, Notion/Sheets/Supabase, feedback, GitHub Actions cron | [references/data-scraper-agent.md](references/data-scraper-agent.md) |

## Related skills
- [`playwright`](../unit-testing-patterns/references/playwright.md) — browser automation and e2e
- [`screenshot`](../screenshot/SKILL.md) — desktop screen capture
- [`research`](../research/SKILL.md) — cited research, Exa search, OSINT
- [`programmatic-seo`](../seo/references/programmatic-seo.md) — template pages from scraped data
