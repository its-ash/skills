@REF:api-endpoints

§PAT:firecrawl_v2{
  base:`https://api.firecrawl.dev/v2`;auth:`Authorization: Bearer $FIRECRAWL_API_KEY`;#v0/v1_legacy⇒use_v2;
  POST /v2/scrape `{url,formats:["markdown",{"type":"json","schema":{...},"prompt":"..."},"screenshot"],onlyMainContent:true,maxAge:86400000,waitFor?,actions?,mobile?,blockAds?}`→md|html|rawHtml|links|json|screenshot;
  POST /v2/scrape/{scrapeId}/interact→exec_NL_or_Playwright_on_active_session;
  POST /v2/batch/scrape `{urls:[...],formats:["markdown"]}`→async_id→GET /v2/batch/scrape/{id} | DELETE /v2/batch/scrape/{id} | GET /v2/batch/scrape/{id}/errors;
  POST /v2/crawl `{url,limit:100,maxDiscoveryDepth:2,includePaths?,excludePaths?,sitemap:"include"|"skip"|"only",ignoreQueryParameters:true,scrapeOptions:{formats:["markdown"]}}`→async_id→GET /v2/crawl/{id} | DELETE /v2/crawl/{id};
  POST /v2/map `{url,search?}`→fast_site_URL_discovery;
  POST /v2/search `{query,limit:5,sources:["web","news","images"],scrapeOptions?}`→search+optional_scrape;
  POST /v2/agent `{prompt,schema?}`→autonomous_search_navigate_extract(supersedes_legacy_extract)→GET /v2/agent/{id} | DELETE /v2/agent/{id};
  POST /v2/parse(multipart_file)→local_or_private_PDF_to_md|json;
  sdks:`from firecrawl import Firecrawl`(Py) | `import { Firecrawl } from 'firecrawl'`(TS) + official_MCP/CLI;
  R:formats_arr_replaces_v0_format_str∧v1_jsonOptions;maxAge_ms_hits_cache_saves_credits;PDF_b64⇒stream_file
}

§PAT:tavily{
  base:`https://api.tavily.com`;auth:`Authorization: Bearer $TAVILY_API_KEY`(prefix_`tvly-`);∀endpoint≡POST+`Content-Type: application/json`;
  POST /search `{query,search_depth:"basic"|"advanced",include_answer:true,max_results:5}`→`{results:[{url,title,content,score}],answer?}`;
  POST /extract `{urls:[...]}`(≤20_URLs/req)→clean_extracted_content;
  POST /crawl `{url,max_depth:2,limit:50}`→graph_based_site_traversal+extraction;
  POST /map `{url}`→structured_site_links;
  POST /research `{input,model:"auto",stream:false,output_length:"standard"}`→autonomous_multi_step_report;
  R:cost∝max_results∧search_depth;cache_responses;respect_robots.txt
}

§PAT:jina_and_crawl4ai{
  llms_txt:GET `<origin>/llms.txt` first_on_docs_sites⇒structured_AI_index_without_crawling;
  jina_reader:GET `https://r.jina.ai/<target_url>`(opt_`Authorization: Bearer $JINA_API_KEY`)→zero_setup_md|json;
  jina_search:`https://s.jina.ai/<query>` | MCP:`mcp.jina.ai`;
  crawl4ai:open_source(Apache-2.0)_self_hosted_async_Playwright+CSS/XPath/LLM_extraction+built_in_MCP⇒zero_SaaS_lock_in
}

§PAT:xquik_v1{
  base:`https://xquik.com/api/v1`;auth:`x-api-key: $XQ_API_KEY`;
  GET /x/tweets/{id} | GET `/x/tweets/search?q=&limit=`→`{id,text,authorUsername,metrics}[]` |
  GET /x/users/{username} | GET /x/followers/check | GET /trends(0_quota,rate_limited) | GET /account(quota);
  POST /extractions/estimate→POST /extractions `{toolType:"follower_explorer",targetUsername,dedupeAcrossTargets?,dedupeMode?}`→202+.id;
  poll:GET /extractions/{jobId}(5s→completed)→paginate(`nextCursor` while `hasMore`) ∨ GET `/extractions/{jobId}/export?format=csv`;
  POST /draws `{tweetUrl,winnerCount:3,uniqueAuthorsOnly:true,mustRetweet:true,filterMinFollowers:50,requiredHashtags:["#giveaway"]}`;
  POST /monitors `{username,eventTypes:["tweet.new","tweet.reply","tweet.quote","tweet.retweet"]}`(hourly_credits⇒PAUSE_via_`PATCH /monitors/{id}` `{isActive:false}`)→GET /events;
  POST /webhooks(HMAC-SHA256_sig_verify+retries;invalid_sig⇒drop);
  R:rate=10/s,20_burst;402⇒chk `GET /account` pre_bulk
}

§ANTI{
  Firecrawl_/v0_endpoints_or_format_str⇒use_/v2_and_formats_array;
  Tavily_GET_/search_or_POST_/crawl_with_urls_arr⇒POST_/search_and_POST_/extract;
  forgetting_active_Xquik_monitor⇒burns_hourly_credits(PATCH_isActive:false);
  unverified_webhook_payload⇒verify_HMAC-SHA256_else_drop
}
