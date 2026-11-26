@REF:api-endpoints

§API{firecrawl:
  base:https://api.firecrawl.dev; auth:`Authorization: Bearer $FIRECRAWL_API_KEY`;
  POST /v0/scrape `{url,format:"markdown",screenshot:true}`→HTML|md+b64_screenshot|PDF;
  POST /v0/crawl `{url,limit:100,render:true,formats:["markdown"]}`→`[{url,markdown}]`;
  R:robots.txt(def); large_JS⇒quota_risk; PDF=large_b64⇒stream_file
}

§API{tavily:
  base:https://api.tavily.com; auth:`Authorization: Bearer $TAVILY_API_KEY`;
  GET `/search?query=&max_results=5`→`{url,title,snippet}[]`;
  POST /crawl `{urls:[...],include_html:false}`→text `content`;
  R:rate_limit⇒cache; cost=`max_results`; stale⇒chk_ts; robots.txt
}

§API{xquik:
  base:https://xquik.com/api/v1; auth:`x-api-key: $XQ_API_KEY`;
  GET /x/tweets/{id} | GET `/x/tweets/search?q=&limit=`→`{id,text,authorUsername,metrics}[]` |
  GET /x/users/{username} | GET /x/followers/check | GET /trends(0_quota,rate_limited) | GET /account(quota) |
  POST /extractions/estimate | POST /extractions `{toolType:"follower_explorer",targetUsername}`→.id |
  GET /extractions/{jobId}(poll 5s→status==completed)→GET `/extractions/{jobId}/export?format=csv` |
  POST /draws `{tweetUrl,winnerCount:3,uniqueAuthorsOnly:true,mustRetweet:true,filterMinFollowers:50,requiredHashtags:["#giveaway"]}` |
  POST /monitors(MCP_webhook);
  R:rate=10/s,20_burst; page=`cursor`; 402⇒chk `GET /account` pre_bulk; webhook=HMAC(bad_secret⇒drop)
}
