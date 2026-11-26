@REF:bright-data

§AUTH{
  env:{BRIGHTDATA_API_KEY,BRIGHTDATA_UNLOCKER_ZONE,BRIGHTDATA_SERP_ZONE,BROWSER_AUTH="brd-customerID-zone-PASSWORD"};
  header:`Authorization: Bearer $BRIGHTDATA_API_KEY`
}

§D{route:
  simple_fetch(¬JS,HTML/md,anti_bot)⇒Web_Unlocker(cheapest_HTTP_proxy);
  search(Google|Bing|Yandex,expand|RRF)⇒SERP_API ∨ local_unfancy-search;
  structured_JSON(Amazon|LinkedIn|IG|TikTok)⇒Web_Scraper_API(datasets) ∨ MCP `web_data_*`;
  full_browser(click|type|screenshot|JS|CAPTCHA|FP)⇒Browser_API(CDP) ∨ MCP `scraping_browser_*`;
  default_any_web⇒Bright_Data_MCP(60+_tools,¬WebFetch/WebSearch)
}

§PAT{unfancy_search:
  repo:`https://github.com/yaronbeen/unfancy-search.git`;
  `.env`:`BRIGHT_DATA_API_TOKEN`,`BRIGHT_DATA_SERP_ZONE=serp_api1`,`ANTHROPIC_API_KEY`(opt,AI_expand);
  run:`docker compose up -d` | `pnpm install && pnpm dev` → `http://localhost:3000`;
  api: POST `/api/search`→`jobId`; GET `/api/search-status/{jobId}`(poll 3s→`status=="done"`→`.results`); POST `/api/baseline`(opt);
  params: `query`(str,req), `expand`(bool,false,Claude_subqueries), `research`(bool,false,12_subqueries), `engines`(str[],all), `geo`(str,ISO-2), `count`(num,10,≤10), `includeDomains`/`excludeDomains`(str[])
}

§PAT{serp_api:
  sync: POST `https://api.brightdata.com/request` `{"zone":"$BRIGHTDATA_SERP_ZONE","url":"https://www.google.com/search?q=...&brd_json=1&gl=us&hl=en","format":"raw"}` → `{"organic":[{"rank":1,"title":"...","link":"...","description":"..."}]}`;
  google_params: `q`, `brd_json=1`(parsed_JSON), `gl`(ISO-2), `hl`(lang), `start`(offset,10=p2; ¬`num` deprecated), `tbm`∈{`nws`,`isch`,`vid`}, `brd_mobile`∈{`1`,`ios`}, `brd_browser`(e.g.`chrome`);
  async_bulk: POST `https://api.brightdata.com/request?async=1` → `.response_id` → GET `https://api.brightdata.com/serp/get_result?response_id=$RESP_ID` (retrieve=free)
}

§PAT{web_unlocker:
  POST `https://api.brightdata.com/request` `{"zone":"$BRIGHTDATA_UNLOCKER_ZONE","url":"...","format":"raw","data_format":"markdown"}` → md_body;
  params: `country`(ISO-2), `data_format`∈{`markdown`(def),`screenshot`}, `async`(true→poll `/request_status`), `method`(GET_def);
  ¬mix(Web_Unlocker,Playwright|Selenium|drivers)⇒use Browser_API
}

§PAT{web_scraper_api:
  sync(≤20_URLs): POST `https://api.brightdata.com/datasets/v3/scrape?dataset_id=<id>&format=json` `{"input":[{"url":"..."}]}`;
  async(bulk): POST `https://api.brightdata.com/datasets/v3/trigger?dataset_id=<id>&format=json` → `snapshot_id` → poll(10s) GET `/datasets/v3/progress/{snapshot_id}` until `status=="ready"`(`"failed"`⇒err) → GET `/datasets/v3/snapshot/{snapshot_id}?format=json`;
  params: `dataset_id`(e.g.`amazon_product`,`linkedin_person_profile`), `format`∈{`json`(def),`ndjson`,`csv`}, `include_errors`(true=err_details,billed);
  billing: per_delivered_record ∧ failed_URLs_billed
}

§PAT{browser_api:
  cdp:`wss://${BROWSER_AUTH}@brd.superproxy.io:9222`;
  node:`playwright-core` `chromium.connectOverCDP(cdp)`; py:`playwright.async_api` `connect_over_cdp(cdp)`;
  timeout:`setDefaultNavigationTimeout(120000)` ∧ `waitUntil:'domcontentloaded'`;
  cdp_cmds: `Captcha.solve`(manual,opt_timeout) | `Captcha.setAutoSolve`(auto) | `Proxy.setLocation`(lat/lng_pre_nav) | `Emulation.setDevice`(`iPhone 14`) | `Network.setBlockedURLs`(block_ads/analytics) | `Page.inspect`(DevTools_URL);
  limits: 1_init_nav/session(new_URL⇒new_session) ∧ reuse_session_same_site(IP_sticky) ∧ idle=5m ∧ max=30m ∧ traffic_billed
}

§PAT{mcp:
  modes: Rapid(free) | Pro(`pro=1` param ∨ `PRO_MODE=true` env);
  tools: `search_engine` | `search_engine_batch`(≤10) | `scrape_as_markdown` | `scrape_as_html`(Pro) | `web_data_<platform>_...`(Pro) | `extract`(Pro) | `scraping_browser_{navigate,click_ref,type_ref,snapshot}`(Pro);
```bash
SEARCH_ID=$(curl -s -X POST https://mcp.brightdata.com/search_engine -H "Authorization: Bearer $BRIGHTDATA_API_KEY" -H "Content-Type: application/json" -d '{"query":"kubernetes scaling strategies","cursor":0}' | jq -r .search_id)
TOP_URL=$(curl -s https://mcp.brightdata.com/search_engine_status/$SEARCH_ID -H "Authorization: Bearer $BRIGHTDATA_API_KEY" | jq -r '.results[0].link')
curl -s -X POST https://mcp.brightdata.com/scrape_as_markdown -H "Authorization: Bearer $BRIGHTDATA_API_KEY" -H "Content-Type: application/json" -d "{\"url\":\"$TOP_URL\"}" | jq .
```
  err_chk: Settings→Extensions→Bright_Data=Connected ∧ req_params(`url`|`query`) ∧ empty⇒fallback_less_specific_BD_tool(NEVER WebFetch/WebSearch)
}

§CHK{
  env_vars_set ∧ Bearer_auth ∧ ¬`num`→`start` ∧ `brd_json=1` ∧ `data_format:markdown` ∧ `dataset_id`∧zone_valid ∧ bulk→async+exp_backoff ∧ geo∈{`country`,`Proxy.setLocation`} ∧ async_retrieve=free(except_Scraper_failed_URLs) ∧ browser_timeout≥120s+block_unused_res
}

§REL{
  ../SKILL.md | ../../unit-testing-patterns/references/playwright.md
}
