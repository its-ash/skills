# Firecrawl, Tavily, Xquik endpoints

## Firecrawl (`https://api.firecrawl.dev`)
Header: `Authorization: Bearer $FIRECRAWL_API_KEY`.
| Endpoint | Method | Purpose |
|---|---|---|
| `/v0/scrape` | POST | HTML, markdown, screenshot, or PDF of one URL |
| `/v0/crawl` | POST | Crawl a domain; list of pages |

```bash
curl -X POST https://api.firecrawl.dev/v0/scrape -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" -d '{"url":"https://example.com","format":"markdown","screenshot":true}'
# → markdown + base64 screenshot
curl -X POST https://api.firecrawl.dev/v0/crawl -H "Authorization: Bearer $FIRECRAWL_API_KEY" \
  -H "Content-Type: application/json" -d '{"url":"https://docs.example.com","limit":100,"render":true,"formats":["markdown"]}'
# → [{url, markdown}]
```
- Follows `robots.txt` by default.
- Large JS sites can exceed the free quota; monitor usage.
- PDF output is large base64; stream to a file.

## Tavily (`https://api.tavily.com`)
Header: `Authorization: Bearer $TAVILY_API_KEY`.
| Endpoint | Method | Purpose |
|---|---|---|
| `/search` | GET | Top results: `url`, `title`, `snippet` |
| `/crawl` | POST | Plain text `content` for a list of URLs |

```bash
curl -G https://api.tavily.com/search -H "Authorization: Bearer $TAVILY_API_KEY" \
  --data-urlencode "query=latest AI research" --data "max_results=5"
curl -X POST https://api.tavily.com/crawl -H "Authorization: Bearer $TAVILY_API_KEY" \
  -H "Content-Type: application/json" -d '{"urls":["https://example.com/article"],"include_html":false}'
```
- Rate-limited: cache results. Control cost with `max_results`.
- Results can be stale; check timestamps. Respects `robots.txt`.

## Xquik (`https://xquik.com/api/v1`)
Header: `x-api-key: $XQ_API_KEY`.
| Goal | Endpoint | Method |
|---|---|---|
| Tweet by ID | `/x/tweets/{id}` | GET |
| Search tweets (`q`, `limit`) | `/x/tweets/search` | GET |
| User profile | `/x/users/{username}` | GET |
| Follow check | `/x/followers/check` | GET |
| Trends | `/trends` | GET |
| Estimate extraction cost | `/extractions/estimate` | POST |
| Bulk extraction job | `/extractions` | POST |
| Job status / results | `/extractions/{jobId}` | GET |
| Export (`format=csv`) | `/extractions/{jobId}/export` | GET |
| Giveaway draw | `/draws` | POST |
| Real-time monitor (MCP webhook) | `/monitors` | POST |
| Usage / quota | `/account` | GET |

```bash
X=https://xquik.com/api/v1; H="x-api-key: $XQ_API_KEY"
job=$(curl -s -X POST $X/extractions -H "$H" -H "Content-Type: application/json" \
  -d '{"toolType":"follower_explorer","targetUsername":"<user>"}' | jq -r .id)
until [[ $(curl -s $X/extractions/$job -H "$H" | jq -r .status) == completed ]]; do sleep 5; done
curl -L "$X/extractions/$job/export?format=csv" -H "$H" -o followers.csv

curl -X POST $X/draws -H "$H" -H "Content-Type: application/json" -d '{"tweetUrl":"https://x.com/user/status/1234567890",
  "winnerCount":3,"uniqueAuthorsOnly":true,"mustRetweet":true,"filterMinFollowers":50,"requiredHashtags":["#giveaway"]}'
```
- Search result fields: `id`, `text`, `authorUsername`, `metrics`.
- Rate limit: 10 req/s sustained, 20 burst. Paginate with `cursor`.
- HTTP 402 = quota exhausted; check `GET /account` before large jobs.
- Trends use no quota but count toward rate limits.
- Webhooks are HMAC-signed; a wrong secret drops events.
