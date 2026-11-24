---
name: web-scraping-apis
description: "AUTO_INVOKE(silent)⇔prompt∈{scrape,crawl,Firecrawl,Tavily,Cloudflare_Browser_Rendering,Xquik,Bright_Data,SERP,tweets,X_Twitter,HTML,JSON,markdown,.md,render_JS,curl,403,429,CAPTCHA,Web_Unlocker,proxies,robots.txt,modifiedSince,excludePatterns,scraper_agent,monitor_jobs_prices_news_repos,LLM_scoring}|SUB:{bright-data,data-scraper-agent}"
---
@SKL:web-scraping-apis
§R{
  keys∈env_only:{FIRECRAWL_API_KEY,TAVILY_API_KEY,CLOUDFLARE_ACCOUNT_ID+CLOUDFLARE_API_TOKEN,XQ_API_KEY};
  ∀call:auth_header←(Firecrawl∨Tavily∨Cloudflare⇒"Authorization: Bearer <key>")⊕(Xquik⇒"x-api-key");
  respect(robots.txt∧site_terms);
  static_site⇒render:false(cuts_cost∧latency);
  limit∨max_results←min_sufficient_val;
  async_job:start→poll(completed)→fetch_pages(cursor)_until(cursor≡null);
  retry∈{429,5xx}_only:backoff(1s,2s,4s),max_tries=3;¬retry(other_4xx);
  large_job⇒check_quota_first;cache(search_results);
  ∀saved_page:prepend("<!-- Source: <url> -->");
  large_out(PDF_base64,CSV)⇒stream_to_file¬memory;
  done⇒revoke(keys)∧delete(temp_output)
}
§D{
  1_page(full_text∨screenshot∨PDF)⇒Firecrawl(/v0/scrape)¬full_site_crawl;
  web_search→article_text⇒Tavily(/search→/crawl)¬scrape_SERP_HTML;
  whole_docs_site→md(JS_rendered)⇒Cloudflare_Browser_Rendering_crawl¬page_by_page_scrape;
  daily_site_sync⇒full_crawl_once→modifiedSince¬daily_full_crawl;
  noisy_sections(changelog,API_ref)⇒excludePatterns¬crawl_then_filter;
  tweets∨profiles∨followers∨trends∨giveaways⇒Xquik¬raw_X_scraping;
  proxies∨Web_Unlocker∨SERP_API∨403/CAPTCHA⇒references/bright-data.md¬hand_rolled_proxy_rotation;
  scheduled_monitor+LLM_scoring⇒references/data-scraper-agent.md¬one_off_cron_scripts;
  browser_automation_you_control⇒../unit-testing-patterns/references/playwright.md¬hosted_render_for_simple_clicks
}
§REF{
  Firecrawl,Tavily,Xquik_endpoints,curl_ex,limits→references/api-endpoints.md;
  Cloudflare_crawl:start/poll/page,Python_saver,params,limits→references/cloudflare-crawl.md;
  Bright_Data:SERP_API,Web_Unlocker,Scraper_API,Browser_API,MCP,RRF_rerank→references/bright-data.md;
  scheduled_Py_agent:collect,Gemini_Flash_batch_score,Notion/Sheets/Supabase,feedback,GH_Actions_cron→references/data-scraper-agent.md
}
§REL{
  ../unit-testing-patterns/references/playwright.md:browser_automation,e2e;
  ../screenshot/SKILL.md:desktop_screen_capture;
  ../research/SKILL.md:cited_research,Exa_search,OSINT;
  ../seo/references/programmatic-seo.md:template_pages_from_scraped_data
}
