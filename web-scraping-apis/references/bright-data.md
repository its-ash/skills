@REF:bright-data

§CFG:auth{
  env:{BRIGHTDATA_API_KEY,BRIGHTDATA_UNLOCKER_ZONE,BRIGHTDATA_SERP_ZONE,BROWSER_AUTH="brd-customerID-zone-PASSWORD"};
  header:`Authorization: Bearer $BRIGHTDATA_API_KEY`
}

§D:route{
  simple_fetch(¬JS,HTML/md,anti_bot)⇒Web_Unlocker(cheapest_HTTP_proxy);
  search(Google|Bing|Yandex,expand|RRF)⇒SERP_API ∨ local_unfancy-search;
  structured_JSON(Amazon|LinkedIn|IG|TikTok|1200+_domains)⇒Web_Scraper_API_v3(datasets) ∨ MCP_scrapers;
  full_browser(click|type|screenshot|JS|CAPTCHA|FP)⇒Browser_API(CDP) ∨ MCP_browser;
  agent_tool_calling⇒Bright_Data_MCP(hosted_Streamable_HTTP_or_local_npx)¬raw_unproxied_fetch_on_blocked_targets
}

§PAT:mcp{
  hosted_remote:`https://mcp.brightdata.com/mcp?token=$BRIGHTDATA_API_KEY`(Streamable_HTTP/SSE_MCP_client_config;¬raw_REST_endpoints);
  local_stdio:`npx -y @brightdata/mcp`(env:`API_TOKEN`,`PRO_MODE`,`GROUPS`);
  modes:Rapid(default,free_5000req/mo_auto_renew:search+markdown_scrape) | Pro(`&pro=1` URL ∨ `PRO_MODE=true` env,usage_billed:browser+scrapers+advanced);
  scope_tokens:`&groups=scrapers,browser,advanced_scraping,geo`(or `all`) ∨ `&tools=search_engine,scrape_as_markdown`(cuts_LLM_context_overhead);
  core_tools:`search_engine` | `search_engine_batch`(≤10) | `scrape_as_markdown` | `scrape_batch` | `search_scrapers` | `search_dataset` | `run_scraper` | `web_data_<platform>_*`(Pro) | `extract`(Pro) | `scraping_browser_*`(Pro);
  err_chk:verify_MCP_connected∧req_params(`url`|`query`);empty⇒fallback_less_specific_BD_tool(¬raw_unproxied_fetch_on_403/CAPTCHA)
}

§PAT:serp_api{
  sync:POST `https://api.brightdata.com/request` `{"zone":"$BRIGHTDATA_SERP_ZONE","url":"https://www.google.com/search?q=...&brd_json=1&gl=us&hl=en","format":"raw"}`→`{"organic":[{"rank":1,"title":"...","link":"...","description":"..."}]}`;
  google_params:`q`,`brd_json=1`(parsed_JSON),`gl`(ISO-2),`hl`(lang),`start`(offset,10=p2;¬`num`_deprecated),`tbm`∈{`nws`,`isch`,`vid`},`brd_mobile`∈{`1`,`ios`},`brd_browser`(e.g.`chrome`);
  async_bulk:POST `https://api.brightdata.com/request?async=1`→`.response_id`→GET `https://api.brightdata.com/serp/get_result?response_id=$RESP_ID`(retrieve=free)
}

§PAT:web_unlocker{
  POST `https://api.brightdata.com/request` `{"zone":"$BRIGHTDATA_UNLOCKER_ZONE","url":"...","format":"raw","data_format":"markdown"}`→md_body;
  params:`country`(ISO-2),`data_format`∈{`markdown`(def),`screenshot`},`async`(true→poll `/request_status`),`method`(GET_def);
  ¬mix(Web_Unlocker,Playwright|Selenium|drivers)⇒use_Browser_API
}

§PAT:web_scraper_api{
  sync(≤20_URLs):POST `https://api.brightdata.com/datasets/v3/scrape?dataset_id=<id>&format=json` `{"input":[{"url":"..."}]}`;
  async(bulk):POST `https://api.brightdata.com/datasets/v3/trigger?dataset_id=<id>&format=json`→`snapshot_id`→poll(10s)_GET `/datasets/v3/progress/{snapshot_id}`_until `status=="ready"`(`"failed"`⇒err)→GET `/datasets/v3/snapshot/{snapshot_id}?format=json`;
  params:`dataset_id`(1200+_pre_built,e.g.`amazon_product`,`linkedin_person_profile`),`format`∈{`json`(def),`ndjson`,`csv`},`include_errors`(true=err_details,billed);
  billing:per_delivered_record ∧ failed_URLs_billed
}

§PAT:browser_api{
  cdp:`wss://${BROWSER_AUTH}@brd.superproxy.io:9222`;
  node:`playwright-core` `chromium.connectOverCDP(cdp)`;py:`playwright.async_api` `connect_over_cdp(cdp)`;
  timeout:`setDefaultNavigationTimeout(120000)` ∧ `waitUntil:'domcontentloaded'`;
  cdp_cmds:`Captcha.solve`(manual,opt_timeout) | `Captcha.setAutoSolve`(auto) | `Proxy.setLocation`(lat/lng_pre_nav) | `Emulation.setDevice`(`iPhone 14`) | `Network.setBlockedURLs`(block_ads/analytics) | `Page.inspect`(DevTools_URL);
  limits:1_init_nav/session(new_URL⇒new_session) ∧ reuse_session_same_site(IP_sticky) ∧ idle=5m ∧ max=30m ∧ traffic_billed
}

§PAT:unfancy_search{
  repo:`https://github.com/yaronbeen/unfancy-search.git`;
  `.env`:`BRIGHT_DATA_API_TOKEN`,`BRIGHT_DATA_SERP_ZONE=serp_api1`,`ANTHROPIC_API_KEY`(opt,AI_expand);
  run:`docker compose up -d` | `pnpm install && pnpm dev`→`http://localhost:3000`;
  api:POST `/api/search`→`jobId`;GET `/api/search-status/{jobId}`(poll 3s→`status=="done"`→`.results`);POST `/api/baseline`(opt);
  params:`query`(str,req),`expand`(bool,false),`research`(bool,false,12_subqueries),`engines`(str[],all),`geo`(str,ISO-2),`count`(num,10,≤10),`includeDomains`/`excludeDomains`(str[])
}

§ANTI{
  calling_`mcp.brightdata.com/<tool>`_via_raw_curl⇒use_MCP_client_at_`/mcp?token=...`_or_REST_`api.brightdata.com/request`;
  loading_full_MCP_catalog_unscoped⇒append_`&groups=`_or_`&tools=`_to_save_context_tokens;
  using_deprecated_Google_`num`_param⇒use_`start`_pagination_offset;
  mixing_Web_Unlocker_with_Playwright⇒use_Browser_API_CDP
}

§CHK{
  env_vars_set ∧ Bearer_auth ∧ MCP_scoped(`&groups=`|`&tools=`) ∧ ¬`num`→`start` ∧ `brd_json=1` ∧ `data_format:markdown` ∧ `dataset_id`∧zone_valid ∧ bulk→async+exp_backoff ∧ geo∈{`country`,`Proxy.setLocation`} ∧ async_retrieve=free(except_Scraper_failed_URLs) ∧ browser_timeout≥120s+block_unused_res
}

§REL{
  ../SKILL.md | ../../unit-testing-patterns/references/playwright.md
}
