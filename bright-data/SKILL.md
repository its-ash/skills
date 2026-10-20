---
name: bright-data
description: "Bright Data skill guides using Bright Data services including local unfancy-search server, SERP API, Web Unlocker, Web Scraper API, Browser API, and Bright Data MCP to perform web searches, fetch pages as markdown, extract structured data, and run browser automation. Use when working with Bright Data, SERP API, Web Unlocker, Web Scraper API, Browser API, MCP, scraping, crawling, search results, markdown extraction, proxies, curl, API key, query expansion, RRF reranking, async bulk SERP, or browser automation."
---

# Bright Data Integration

Run web searches, fetch pages, extract structured data, and automate browsers using Bright Data's suite of APIs. Choose the most specific API for the task, configure authentication once, and call the endpoint with curl, Python, or Node.

## When to use
- Need a **search** across Google/Bing/Yandex with query expansion or RRF reranking → use the **local unfancy‑search server** or the **SERP API**.
- Need the **raw HTML or clean markdown** of a single page, bypassing bot detection → use **Web Unlocker**.
- Need **structured JSON** from Amazon, LinkedIn, Instagram, TikTok, etc. → use the **Web Scraper API** (datasets) or **Bright Data MCP**.
- Need **full browser interaction** (click, type, capture screenshots) → use the **Browser API** or the **MCP scraping_browser tools**.
- Want a single, default tool for any internet request → use **Bright Data MCP** (preferred over built‑in WebFetch/WebSearch).

---

## 1. Common Authentication Pattern
All Bright Data HTTP APIs share the same header.
```bash
export BRIGHTDATA_API_KEY="your-api-key"
export BRIGHTDATA_UNLOCKER_ZONE="unlocker-zone"   # for Web Unlocker
export BRIGHTDATA_SERP_ZONE="serp-zone"         # for SERP API
export BROWSER_AUTH="brd-customerID-zone-PASSWORD"  # for Browser API
```
Add the header to every request:
```
Authorization: Bearer $BRIGHTDATA_API_KEY
```

---

## 2. Choosing the Right API
| Use case | Bright Data API | Why |
|---|---|---|
| Simple page fetch (no JS) | **Web Unlocker** | Cheapest, HTTP proxy, returns HTML/markdown |
| Search engine results | **SERP API** or **local unfancy‑search** | Structured JSON, multi‑engine, RRF reranking |
| Structured data from supported platforms | **Web Scraper API** (datasets) or **MCP web_data_* tools** | No parsing needed, consistent JSON |
| Full browser automation | **Browser API** (CDP) or **MCP scraping_browser_* tools** | Handles JS, CAPTCHAs, fingerprinting |
| Any other web data task | **Bright Data MCP** (default) | Unified interface, 60+ tools |

---

## 3. Local Unfancy‑Search Server (query expansion, RRF reranking)
### Setup
```bash
# Clone repository
git clone https://github.com/yaronbeen/unfancy-search.git
cd unfancy-search
cp .env.example .env
```
Edit `.env`:
```env
BRIGHT_DATA_API_TOKEN=your_brightdata_token
BRIGHT_DATA_SERP_ZONE=serp_api1
ANTHROPIC_API_KEY=your_anthropic_key   # optional, enables AI query expansion
```
Start the server (Docker recommended):
```bash
docker compose up -d   # server listens on http://localhost:3000
```
Or with Node:
```bash
pnpm install && pnpm dev   # also http://localhost:3000
```
### API Endpoints
- `POST /api/search` – start a search job
- `GET /api/search-status/{jobId}` – poll for results
- `POST /api/baseline` – collect baseline data (optional)

### Running a Search (curl)
```bash
JOB_ID=$(curl -s -X POST http://localhost:3000/api/search \
  -H "Content-Type: application/json" \
  -d '{"query":"best practices for API rate limiting"}' | jq -r .jobId)

while :; do
  RESULT=$(curl -s http://localhost:3000/api/search-status/$JOB_ID)
  STATUS=$(echo $RESULT | jq -r .status)
  if [ "$STATUS" = "done" ]; then
    echo $RESULT | jq .results
    break
  fi
  sleep 3
done
```
#### Parameters
| Name | Type | Default | Meaning |
|---|---|---|---|
| `query` | string | required | Search term |
| `expand` | boolean | false | Enable Claude‑generated sub‑queries |
| `research` | boolean | false | Generate 12 sub‑queries for maximum coverage |
| `engines` | string[] | all | SERP engines to query |
| `geo` | string | – | Geographic filter (ISO‑2) |
| `count` | number | 10 | Max results (≤10) |
| `includeDomains` / `excludeDomains` | string[] | – | Domain whitelist / blacklist |

---

## 4. SERP API (direct HTTP request)
### Request example (Google)
```bash
curl -X POST https://api.brightdata.com/request \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "zone": "$BRIGHTDATA_SERP_ZONE",
    "url": "https://www.google.com/search?q=python+web+scraping&brd_json=1&gl=us&hl=en",
    "format": "raw"
}'
```
The response is JSON with an `organic` array:
```json
{
  "organic": [
    {"rank":1,"title":"...","link":"https://...","description":"..."}
  ]
}
```
### Key URL parameters (Google)
- `q` – query string
- `brd_json=1` – always request parsed JSON
- `gl` – country code (e.g., `us`)
- `hl` – language (e.g., `en`)
- `start` – pagination offset (10 = page 2)
- `tbm` – result type (`nws` news, `isch` images, `vid` videos)
- `brd_mobile` – `1` for mobile, `ios` for iOS device
- `brd_browser` – browser emulation (e.g., `chrome`)
> **Note:** The `num` parameter is deprecated; use `start` for pagination.

### Async Bulk SERP
```bash
# Submit
RESP=$(curl -s -X POST "https://api.brightdata.com/request?async=1" \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"zone":"$BRIGHTDATA_SERP_ZONE","url":"https://www.google.com/search?q=test&brd_json=1","format":"raw"}')
RESP_ID=$(echo $RESP | jq -r '.response_id')

# Retrieve (not billed)
curl -s "https://api.brightdata.com/serp/get_result?response_id=$RESP_ID" \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY"
```
---

## 5. Web Unlocker (HTML → Markdown)
### Simple fetch (curl)
```bash
curl -X POST https://api.brightdata.com/request \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "zone": "$BRIGHTDATA_UNLOCKER_ZONE",
    "url": "https://example.com/article",
    "format": "raw",
    "data_format": "markdown"
}'
```
The response body is clean markdown ready for LLM consumption.
### Optional parameters
- `country` – ISO‑2 code for geo‑targeting
- `data_format` – `markdown` (default) or `screenshot`
- `async` – `true` for bulk jobs (poll with `/request_status` endpoint)
- `method` – HTTP verb, default `GET`
> **Critical rule:** Do **not** use Web Unlocker with Playwright, Selenium, or other browser drivers. Use the Browser API instead.
---

## 6. Web Scraper API (pre‑built dataset scrapers)
### Synchronous request (up to 20 URLs)
```python
import requests, json
API_KEY = "${BRIGHTDATA_API_KEY}"
DATASET_ID = "amazon_product"   # example scraper identifier
url = "https://www.amazon.com/dp/B09X7M8TBQ"
resp = requests.post(
    "https://api.brightdata.com/datasets/v3/scrape",
    params={"dataset_id": DATASET_ID, "format": "json"},
    headers={"Authorization": f"Bearer {API_KEY}"},
    json={"input": [{"url": url}]}
)
print(resp.json())
```
### Asynchronous trigger (large batches)
```python
# Trigger
trigger = requests.post(
    "https://api.brightdata.com/datasets/v3/trigger",
    params={"dataset_id": DATASET_ID, "format": "json"},
    headers={"Authorization": f"Bearer {API_KEY}"},
    json={"input": [{"url": u} for u in url_list]}
).json()
SNAPSHOT_ID = trigger["snapshot_id"]

# Poll until ready
import time
while True:
    status = requests.get(
        f"https://api.brightdata.com/datasets/v3/progress/{SNAPSHOT_ID}",
        headers={"Authorization": f"Bearer {API_KEY}"}
    ).json()["status"]
    if status == "ready":
        break
    if status == "failed":
        raise RuntimeError("Job failed")
    time.sleep(10)

# Download results
data = requests.get(
    f"https://api.brightdata.com/datasets/v3/snapshot/{SNAPSHOT_ID}",
    params={"format": "json"},
    headers={"Authorization": f"Bearer {API_KEY}"}
).json()
print(json.dumps(data, indent=2))
```
### Important fields
- `dataset_id` – identifier from Bright Data's Scraper Library (e.g., `amazon_product`, `linkedin_person_profile`).
- `format` – `json` (default), `ndjson`, `csv`.
- `include_errors` – set `true` to receive error details (still billed).
> **Billing:** Pay per delivered record. Failed URLs are still billed.
---

## 7. Browser API (CDP / WebDriver)
### Connect with Playwright (Node)
```javascript
const { chromium } = require('playwright-core');
const AUTH = process.env.BROWSER_AUTH; // e.g., brd-customerID-zone-PASSWORD

(async () => {
  const browser = await chromium.connectOverCDP(`wss://${AUTH}@brd.superproxy.io:9222`);
  const page = await browser.newPage();
  page.setDefaultNavigationTimeout(120000);
  await page.goto('https://example.com', { waitUntil: 'domcontentloaded' });
  const html = await page.content();
  console.log(html);
  await browser.close();
})();
```
### Connect with Playwright (Python)
```python
from playwright.async_api import async_playwright
import os
AUTH = os.getenv('BROWSER_AUTH')

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp(f"wss://{AUTH}@brd.superproxy.io:9222")
        page = await browser.new_page()
        page.set_default_navigation_timeout(120000)
        await page.goto('https://example.com', wait_until='domcontentloaded')
        html = await page.content()
        print(html)
        await browser.close()

import asyncio; asyncio.run(main())
```
### Useful CDP commands
| Command | Purpose |
|---|---|
| `Captcha.solve` | Manually trigger CAPTCHA solving (timeout optional) |
| `Proxy.setLocation` | Set precise latitude/longitude before navigation |
| `Emulation.setDevice` | Emulate a device profile (e.g., `iPhone 14`) |
| `Network.setBlockedURLs` | Block ads, analytics, or other resources to save bandwidth |
| `Page.inspect` | Get DevTools URL for live debugging |

### Session limits
- One initial navigation per session; new URL starts a new session.
- Idle timeout: 5 min. Max session duration: 30 min.
- Traffic‑based billing; block unnecessary resources to reduce cost.
---

## 8. Bright Data MCP (Unified Default Tool)
Bright Data MCP supersedes built‑in WebFetch/WebSearch. It offers **Rapid** (free) and **Pro** modes.
### Tool selection quick‑tree
1. **Search** → `search_engine` (single) or `search_engine_batch` (≤10 queries).
2. **Single page markdown** → `scrape_as_markdown`.
3. **Raw HTML** → `scrape_as_html` (Pro).
4. **Structured platform data** → `web_data_<platform>_...` (Pro).
5. **AI‑extracted JSON** → `extract` (Pro).
6. **Browser interaction** → `scraping_browser_navigate`, `scraping_browser_click_ref`, `scraping_browser_type_ref`, `scraping_browser_snapshot`, etc. (Pro).
### Example: Search + Scrape workflow
```bash
# 1. Search Google
SEARCH_ID=$(curl -s -X POST https://mcp.brightdata.com/search_engine \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":"kubernetes scaling strategies","cursor":0}' | jq -r .search_id)

# 2. Get top result URL (example assumes JSON response with .results[0].link)
TOP_URL=$(curl -s https://mcp.brightdata.com/search_engine_status/$SEARCH_ID \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" | jq -r '.results[0].link')

# 3. Scrape as markdown
curl -s -X POST https://mcp.brightdata.com/scrape_as_markdown \
  -H "Authorization: Bearer $BRIGHTDATA_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"url\": \"$TOP_URL\"}" | jq .
```
### Error handling checklist
- Verify MCP connection (Settings → Extensions → Bright Data shows *Connected*).
- Ensure required parameters (e.g., `url` for scrape, `query` for search) are present.
- For Pro tools, add `pro=1` to the request URL or set `PRO_MODE=true` in environment.
- If a tool returns empty data, fall back to a less‑specific tool **but never** to the built‑in WebFetch/WebSearch.
---

## 9. Common Pitfalls & Best Practices
- **Never mix Web Unlocker with Playwright/Selenium.** Use Browser API for any JS‑heavy page.
- **Do not use the deprecated `num` parameter** for SERP pagination; use `start`.
- **Rate limits:** Respect Bright Data's per‑zone limits. For bulk jobs, prefer async endpoints and poll with exponential back‑off.
- **Geo‑targeting:** Use `country` field for simple region, or `Proxy.setLocation` (Browser API) for precise coordinates.
- **Billing awareness:** Async retrieve calls are free; only successful data deliveries are billed.
- **Session reuse:** Re‑use the same Browser API session when navigating multiple pages of the same site to keep the IP consistent.
- **CAPTCHA handling:** Enable auto‑solve (`Captcha.setAutoSolve`) unless you need manual control.
---

## Checklist
- [ ] Set `BRIGHTDATA_API_KEY` and zone variables.
- [ ] Choose the most specific Bright Data API for the task.
- [ ] For local unfancy‑search, verify Docker container is running on port 3000.
- [ ] Include `Authorization: Bearer $BRIGHTDATA_API_KEY` in every request.
- [ ] Use `brd_json=1` for SERP URLs to get parsed JSON.
- [ ] For Web Unlocker, request `data_format: markdown` unless raw HTML is required.
- [ ] When using Web Scraper API, confirm `dataset_id` matches the target platform.
- [ ] For Browser API, set navigation timeout to at least 120 s and block unnecessary resources.
- [ ] Validate MCP connection before any operation.
- [ ] Handle empty or error responses: check URL format, zone activation, and fallback to a less‑specific tool (never to built‑in WebFetch/WebSearch).

## Related skills

Load these when the task spans more than this skill.

- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`playwright`](../playwright/SKILL.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`mcp-development`](../mcp-development/SKILL.md) — Guide for building, testing, and integrating Model Context Protocol (MCP) servers. Use when creating a new MCP…
