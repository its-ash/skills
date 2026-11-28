@REF:cloudflare-crawl

§CFG:auth{
  product:Cloudflare_Browser_Run(formerly_Browser_Rendering);
  env:{CLOUDFLARE_ACCOUNT_ID,CLOUDFLARE_API_TOKEN("Browser Run - Edit")};
  base:`https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-run/crawl`;#legacy_alias:/browser-rendering/crawl;
  header:`Authorization: Bearer ${CLOUDFLARE_API_TOKEN}`
}

§CMD:flow{
  start:POST $B `{"url":"...","limit":100,"depth":2,"formats":["markdown"],"contentUse":"full","excludePatterns":["**/changelog/**"]}`→.result=$JOB_ID;
  poll(5s):GET `$B/$JOB_ID?limit=1`→.result.status=="completed";
  page:GET `$B/$JOB_ID?status=completed&limit=50[&cursor=$cursor]`→.result.records[](url,markdown|json), .result.cursor(null⇒done)
}

§CFG:params{
  url(str,req);
  formats(arr,def=["html"],∈{html,markdown,json});#markdown_preserves_code_fences;json_uses_Workers_AI_schema_extraction;
  render(bool,def=true:headless_Chromium | false:fast_static_Workers_fetch);
  limit(int,plan_cap);depth(int,max_link_hops);
  contentUse(str,def="full",∈{"reference","full"});#Content_Signals+robots.txt_enforced:exceeding_site_policy⇒400_Bad_Request;
  includePatterns(arr,wildcard|regex);excludePatterns(arr,wildcard|regex);
  modifiedSince(Unix_ts)|maxAge(int):incremental_crawl_skip_unchanged;
  authenticate:`{username,password}`(HTTP_Basic_Auth);
  browser_opts(when_render:true):gotoOptions(`waitUntil`:"networkidle0",timeout),rejectResourceTypes,rejectRequestPattern,cookies,setExtraHTTPHeaders
}

§PAT:save_md_py{
  out=.crawl-output;
  slug=`re.sub(r"[^a-zA-Z0-9]","_",re.sub(r"https?://","",rec["url"]))[:120]`;
  skip !rec.get("markdown");
  write `<!-- Source: {rec['url']} -->\n\n{md}`→`{out}/{slug}.md`
}

§R:limits{
  free_plan:5_crawl_jobs/d ∧ ≤100_pages/crawl ∧ 10m_browser/d;
  paid_plan:billed_active_container_usage ∧ max_runtime=7d/job ∧ REST_rate=10req/s(600/min);
  result_TTL=14d;page>10MB⇒truncated;
  daily_sync:1_full_crawl→incremental(modifiedSince∨maxAge)
}

§ANTI{
  default_contentUse:"full"_when_only_citing⇒set_`contentUse:"reference"`_to_prevent_400_on_restricted_sites;
  render:true_on_static_HTML_docs⇒set_`render:false`(zero_browser_time);
  daily_full_recrawl⇒use_`modifiedSince`|`maxAge`;
  loading_images/fonts_in_render:true⇒block_via_`rejectResourceTypes`
}
