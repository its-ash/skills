---
name: web-scraping-apis
description: "Unified guide for using Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik to scrape pages, search the web, crawl sites into markdown, render JavaScript, and fetch X/Twitter posts. Use when scraping with Firecrawl, Tavily, Cloudflare Browser Rendering, or Xquik; crawling sites; extracting HTML/JSON; converting to .md; searching SERPs; rendering JavaScript; fetching tweets; using curl; handling 403, 429, or CAPTCHA; or building a scheduled scraper agent that monitors jobs, prices, news, or repos with LLM scoring. Sub-skills: bright-data, data-scraper-agent."
---

# Web Scraping APIs

Unified reference for four public APIs that provide web content extraction, site crawling, and X (Twitter) data. Choose the API that matches the task: deep page rendering, fast search, large‑scale crawling, or social‑media analytics.

## When to Use
- Extract full text, screenshots, or PDFs from a single page (Firecrawl).
- Perform a web search and pull the top results or extract content from a URL (Tavily).
- Crawl an entire site, render JavaScript, and save pages as markdown (Cloudflare Browser Rendering).
- Retrieve tweets, user profiles, follower lists, trends, or run giveaways on X (Xquik).

---

## 1. Firecrawl API – Deep Page Extraction

### Authentication
```bash
export FIRECRAWL_API_KEY=your_key_here   # set in environment
```
All requests must include the header `Authorization: Bearer $FIRECRAWL_API_KEY`.

### Core Endpoints
| Endpoint | Method | Purpose |
|---|---|---|
| `/v0/scrape` | POST | Extract full HTML, markdown, screenshots, or PDF from a URL |
| `/v0/crawl` | POST | Crawl a domain and return a list of pages (optional rendering) |

### Example: Scrape a Page with Screenshot
```bash
curl -X POST "https://api.firecrawl.dev/v0/scrape" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://example.com","format":"markdown","screenshot":true}'
```
Response includes `markdown` and a base‑64 `screenshot`.

### Example: Crawl a Site (rendered)
```bash
curl -X POST "https://api.firecrawl.dev/v0/crawl" \
  -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"url":"https://docs.example.com","limit":100,"render":true,"formats":["markdown"]}'
```
The response returns an array of page objects with `url` and `markdown`.

### Best Practices
- Store the API key in environment variables, never hard‑code.
- Use `render:false` for static sites to reduce cost and latency.
- Limit `limit` to the smallest number that satisfies the use case.
- Respect `robots.txt`; Firecrawl follows it by default.

### Pitfalls
- Rendering large JavaScript sites can exceed the free quota; monitor usage.
- PDF parsing may return large base‑64 strings; stream to file instead of keeping in memory.

---

## 2. Tavily API – Fast Web Search & Content Extraction

### Authentication
```bash
export TAVILY_API_KEY=your_key_here
```
Add header `Authorization: Bearer $TAVILY_API_KEY`.

### Core Endpoints
| Endpoint | Method | Purpose |
|---|---|---|
| `/search` | GET | Return top search results for a query |
| `/crawl` | POST | Extract raw text from a list of URLs |

### Example: Search the Web
```bash
curl -G "https://api.tavily.com/search" \
  -H "Authorization: Bearer $TAVILY_API_KEY" \
  --data-urlencode "query=latest AI research" \
  --data "max_results=5"
```
The JSON response contains `url`, `title`, and `snippet` for each result.

### Example: Extract Content from URLs
```bash
curl -X POST "https://api.tavily.com/crawl" \
  -H "Authorization: Bearer $TAVILY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"urls":["https://example.com/article"],"include_html":false}'
```
Each entry returns `url` and `content` (plain text).

### Best Practices
- Cache results locally; search APIs are rate‑limited.
- Use `max_results` to control cost.
- Combine `search` then `crawl` to get full article text.

### Pitfalls
- Results may be outdated; verify timestamps if freshness matters.
- Some sites block automated crawling; Tavily respects `robots.txt`.

---

## 3. Cloudflare Browser Rendering – Site‑wide Crawl to Markdown

### Prerequisites
- Cloudflare account with Browser Rendering enabled.
- Environment variables:
```bash
export CLOUDFLARE_ACCOUNT_ID=your_account_id
export CLOUDFLARE_API_TOKEN=your_api_token   # token must have "Browser Rendering - Edit"
```

### Initiate a Crawl
```bash
curl -s -X POST "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://docs.example.com",
    "limit": 200,
    "formats": ["markdown"],
    "options": {"excludePatterns": ["**/changelog/**"]}
  }'
```
Response contains a `job` ID.

### Poll for Completion
```bash
while true; do
  status=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl/${JOB_ID}?limit=1" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}" | jq -r '.result.status')
  echo "Status: $status"
  [[ $status == "completed" ]] && break
  sleep 5
done
```

### Retrieve Results (Paginated)
```bash
cursor=""
while :; do
  resp=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl/${JOB_ID}?status=completed&limit=50${cursor:+&cursor=$cursor}" \
    -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN}")
  echo "$resp" | jq -r '.result.records[] | "\(.url)\n\(.markdown)\n---"'
  cursor=$(echo "$resp" | jq -r '.result.cursor')
  [[ $cursor == "null" ]] && break
done
```

### Save Pages Locally (Python helper)
```python
import os, re, json, urllib.request
account = os.getenv('CLOUDFLARE_ACCOUNT_ID')
token = os.getenv('CLOUDFLARE_API_TOKEN')
job_id = '<JOB_ID>'
base = f'https://api.cloudflare.com/client/v4/accounts/{account}/browser-rendering/crawl/{job_id}'
outdir = '.crawl-output'
os.makedirs(outdir, exist_ok=True)
cursor = None
while True:
    url = f'{base}?status=completed&limit=50'
    if cursor:
        url += f'&cursor={cursor}'
    req = urllib.request.Request(url, headers={'Authorization': f'Bearer {token}'})
    with urllib.request.urlopen(req) as r:
        data = json.load(r)
    for rec in data['result']['records']:
        md = rec.get('markdown')
        if not md:
            continue
        name = re.sub(r'https?://', '', rec['url'])
        name = re.sub(r'[^a-zA-Z0-9]', '_', name)[:120]
        path = os.path.join(outdir, f'{name}.md')
        with open(path, 'w') as f:
            f.write(f'<!-- Source: {rec["url"]} -->\n\n')
            f.write(md)
    cursor = data['result'].get('cursor')
    if not cursor:
        break
print('Saved pages to', outdir)
```

### Core Parameters Reference
| Parameter | Type | Default | Description |
|---|---|---|---|
| `url` | string | – | Starting URL |
| `limit` | number | 10 | Max pages (up to 100 000) |
| `formats` | array | `["html"]` | Output format (`html`, `markdown`, `json`) |
| `render` | boolean | true | Use headless browser (JS) |
| `excludePatterns` | array | [] | Wildcard patterns to skip |
| `modifiedSince` | number | – | Unix timestamp; crawl only newer pages |

### Best Practices
- Use `render:false` for static documentation sites to save credits.
- Set `excludePatterns` to avoid large changelog or API reference sections.
- For daily sync, run a full crawl once, then incremental crawls with `modifiedSince`.
- Store results in a version‑controlled folder; include source URL as comment.

### Pitfalls
- Free tier provides only 10 minutes of browser time per day.
- Jobs older than 14 days are deleted; download results promptly.
- Large pages (>10 MB) are truncated.

---

## 4. Xquik API – X (Twitter) Data Extraction

### Authentication
```bash
export XQ_API_KEY=xq_YourKeyHere
```
All requests require header `x-api-key: $XQ_API_KEY`.

### Core Endpoints
| Goal | Endpoint | Method |
|---|---|---|
| Get tweet by ID | `/x/tweets/{id}` | GET |
| Search tweets | `/x/tweets/search` | GET |
| Get user profile | `/x/users/{username}` | GET |
| Check follow relationship | `/x/followers/check` | GET |
| Get trending topics | `/trends` | GET |
| Create bulk extraction job | `/extractions` | POST |
| Retrieve extraction results | `/extractions/{jobId}` | GET |
| Run giveaway draw | `/draws` | POST |

### Example: Search Tweets
```bash
curl -G "https://xquik.com/api/v1/x/tweets/search" \
  -H "x-api-key: $XQ_API_KEY" \
  --data-urlencode "q=AI%20research" \
  --data "limit=10"
```
Response includes `id`, `text`, `authorUsername`, `metrics`.

### Example: Bulk Follower Extraction
```bash
# 1. Estimate cost (optional)
curl -X POST "https://xquik.com/api/v1/extractions/estimate" \
  -H "x-api-key: $XQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"toolType":"follower_explorer","targetUsername":"elonmusk"}'

# 2. Create job
job=$(curl -s -X POST "https://xquik.com/api/v1/extractions" \
  -H "x-api-key: $XQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"toolType":"follower_explorer","targetUsername":"elonmusk"}' | jq -r '.id')

# 3. Poll for completion (simple loop)
while :; do
  status=$(curl -s -X GET "https://xquik.com/api/v1/extractions/$job" -H "x-api-key: $XQ_API_KEY" | jq -r '.status')
  echo "Status: $status"
  [[ $status == "completed" ]] && break
  sleep 5
done

# 4. Download results as CSV
curl -L "https://xquik.com/api/v1/extractions/$job/export?format=csv" \
  -H "x-api-key: $XQ_API_KEY" -o followers.csv
```

### Giveaway Draw Example
```bash
curl -X POST "https://xquik.com/api/v1/draws" \
  -H "x-api-key: $XQ_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "tweetUrl":"https://x.com/user/status/1234567890",
    "winnerCount":3,
    "uniqueAuthorsOnly":true,
    "mustRetweet":true,
    "filterMinFollowers":50,
    "requiredHashtags":["#giveaway"]
  }' | jq '.'
```
The response lists winners with usernames and tweet IDs.

### Error Handling & Retries
- Retry only on HTTP 429 (rate limit) or 5xx server errors.
- Use exponential back‑off: wait 1 s, 2 s, 4 s up to three attempts.
- Do **not** retry 4xx errors other than 429.

### Best Practices
- Store the API key securely; never commit to source control.
- Respect rate limits: 10 req/s sustained, 20 burst.
- Use pagination (`cursor` parameter) for large result sets.
- For real‑time monitoring, create a monitor via `POST /monitors` and receive events through the MCP webhook endpoint.

### Pitfalls
- Quota exhaustion returns HTTP 402; check usage via `GET /account` before large jobs.
- Some endpoints (e.g., trends) do not consume quota but still count toward rate limits.
- HMAC‑signed webhooks require correct secret; mismatched signatures cause dropped events.

---

## Checklist
- [ ] Choose the correct API for the task (Firecrawl, Tavily, Cloudflare, Xquik).
- [ ] Set required environment variables (`FIRECRAWL_API_KEY`, `TAVILY_API_KEY`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_API_TOKEN`, `XQ_API_KEY`).
- [ ] Verify authentication headers are included in every request.
- [ ] Define request parameters: URL, limit, render flag, output format, include/exclude patterns.
- [ ] For crawling APIs, start a job, poll until `completed`, then fetch paginated results.
- [ ] Save markdown or CSV output with source URL comments for traceability.
- [ ] Respect rate limits and quota; implement retry logic for 429/5xx.
- [ ] Handle errors gracefully; log status codes and error messages.
- [ ] Clean up temporary files and revoke API keys when no longer needed.
- [ ] Document any custom headers, cookies, or authentication details used.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/bright-data.md](references/bright-data.md) | Bright Data skill guides using Bright Data services including local unfancy-search server, SERP API, Web Unlocker, Web Scraper API, Browser API, and Bright Data MCP to perform web searches, fetch pages as markdown, extract structured data, and run browser automation. Use when working with Bright Data, SERP API, Web Unlocker, Web Scraper API, Browser API, MCP, scraping, crawling, search results, markdown extraction, proxies, curl, API key, query expansion, RRF reranking, async bulk SERP, or browser automation. |
| [references/data-scraper-agent.md](references/data-scraper-agent.md) | Build a scheduled Python agent that collects public data (jobs, prices, news, repos, listings), scores it in batches with Gemini Flash, stores it in Notion, Sheets, or Supabase, learns from user feedback, and runs on GitHub Actions cron. |

## Related skills

Load these when the task spans more than this skill.

- [`bright-data`](references/bright-data.md) — Provides step‑by‑step guidance for using Bright Data services – local unfancy‑search server, SERP API, Web Unl…
- [`playwright`](../unit-testing-patterns/references/playwright.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`screenshot`](../screenshot/SKILL.md) — Capture a desktop screenshot (full screen, window, region, or app) on macOS, Linux, or Windows. Use when the u…
- [`research`](../research/SKILL.md) — Multi-source cited research, Exa search, and OSINT on top of scraped data.
- [`programmatic-seo`](../seo/references/programmatic-seo.md) — Programmatic SEO skill guides you to design, build, and launch large numbers of SEO-optimized pages using temp…
