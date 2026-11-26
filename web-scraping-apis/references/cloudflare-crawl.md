@REF:cloudflare-crawl

§AUTH{
  req:Browser_Rendering∧CLOUDFLARE_ACCOUNT_ID∧CLOUDFLARE_API_TOKEN("Browser Rendering - Edit");
  B=https://api.cloudflare.com/client/v4/accounts/${CLOUDFLARE_ACCOUNT_ID}/browser-rendering/crawl;
  H=`Authorization: Bearer ${CLOUDFLARE_API_TOKEN}`
}

§CMD{flow:
  POST $B `{"url":"...","limit":200,"formats":["markdown"],"options":{"excludePatterns":["**/changelog/**"]}}`→.result=$JOB_ID;
  poll(5s): GET `$B/$JOB_ID?limit=1`→.result.status==completed;
  page: GET `$B/$JOB_ID?status=completed&limit=50[&cursor=$cursor]`→.result.records[](url,markdown), .result.cursor(null⇒done)
}

§PAT{save_md_py:
  out=.crawl-output; slug=`re.sub(r"[^a-zA-Z0-9]","_",re.sub(r"https?://","",rec["url"]))[:120]`;
  skip !rec.get("markdown"); write `<!-- Source: {rec['url']} -->\n\n{md}`→{out}/{slug}.md
}

§CFG{params:
  url(str); limit(num,def=10,max=100000); formats(arr,def=["html"],∈{html,markdown,json});
  render(bool,def=true,headless_JS); excludePatterns(arr,def=[],wildcards); modifiedSince(num,Unix_ts,newer_only)
}

§R{limits:
  free=10m_browser/d; job_TTL=14d; page>10MB⇒truncated; daily_sync=1_full→incremental(modifiedSince)
}
