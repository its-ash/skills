# Cloudflare Browser Rendering crawl

Needs Browser Rendering enabled, `CLOUDFLARE_ACCOUNT_ID`, and `CLOUDFLARE_API_TOKEN` with "Browser Rendering - Edit".
Base: `https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl`

## Start, poll, page
```bash
B="https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl"
H="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"
JOB_ID=$(curl -s -X POST "$B" -H "$H" -H "Content-Type: application/json" \
  -d '{"url":"https://docs.example.com","limit":200,"formats":["markdown"],"options":{"excludePatterns":["**/changelog/**"]}}' \
  | jq -r '.result')   # response holds the job ID

until [[ $(curl -s "$B/$JOB_ID?limit=1" -H "$H" | jq -r '.result.status') == completed ]]; do sleep 5; done

cursor=""
while :; do
  resp=$(curl -s "$B/$JOB_ID?status=completed&limit=50${cursor:+&cursor=$cursor}" -H "$H")
  echo "$resp" | jq -r '.result.records[] | "\(.url)\n\(.markdown)\n---"'
  cursor=$(echo "$resp" | jq -r '.result.cursor')
  [[ $cursor == null ]] && break
done
```

## Save pages as .md (Python)
```python
import os, re, json, urllib.request
acct, tok, job = os.environ["CLOUDFLARE_ACCOUNT_ID"], os.environ["CLOUDFLARE_API_TOKEN"], "<JOB_ID>"
base = f"https://api.cloudflare.com/client/v4/accounts/{acct}/browser-rendering/crawl/{job}"
out = ".crawl-output"; os.makedirs(out, exist_ok=True)
cursor = None
while True:
    url = f"{base}?status=completed&limit=50" + (f"&cursor={cursor}" if cursor else "")
    with urllib.request.urlopen(urllib.request.Request(url, headers={"Authorization": f"Bearer {tok}"})) as r:
        data = json.load(r)
    for rec in data["result"]["records"]:
        if not (md := rec.get("markdown")):
            continue
        name = re.sub(r"[^a-zA-Z0-9]", "_", re.sub(r"https?://", "", rec["url"]))[:120]
        with open(os.path.join(out, f"{name}.md"), "w") as f:
            f.write(f"<!-- Source: {rec['url']} -->\n\n{md}")
    if not (cursor := data["result"].get("cursor")):
        break
```

## Parameters
| Param | Type | Default | Notes |
|---|---|---|---|
| `url` | string | – | Start URL |
| `limit` | number | 10 | Max pages, up to 100 000 |
| `formats` | array | `["html"]` | `html`, `markdown`, `json` |
| `render` | bool | true | Headless browser for JS |
| `excludePatterns` | array | [] | Wildcards to skip |
| `modifiedSince` | number | – | Unix timestamp; only newer pages |

## Limits
- Free tier: 10 min browser time per day.
- Jobs are deleted after 14 days; download results promptly.
- Pages > 10 MB are truncated.
- Daily sync: one full crawl, then incremental crawls with `modifiedSince`.
