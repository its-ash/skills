@REF:report-workflow
§CFG{tools}
req≥1_MCP:{
  firecrawl(firecrawl_search,firecrawl_scrape,firecrawl_map,firecrawl_crawl,firecrawl_agent,firecrawl_parse,firecrawl_interact),
  exa(https://mcp.exa.ai/mcp?dynamicHighlights=true:web_search_exa,web_fetch_exa,web_search_advanced_exa,get_code_context_exa,agent_run)
};both⇒best
pre_promise⇒chk(tools,live_docs)(names/quotas/shapes_drift);¬MCP⇒../../web-scraping-apis/SKILL.md∨builtin(search/fetch)

§PAT{steps}
1_Goal:1-2_Q(learn|decide|write?angle/depth?);"Just research it"⇒defaults
2_Plan:3-5_subQ(ex_AI_hc:apps,outcomes,reg,leaders,mkt_size)
3_Search:2-3_kw/subQ(gen+news);tgt=15-30_uniq:firecrawl_search(query,limit:8)|web_search_exa(query,numResults:8)|web_search_advanced_exa(query,numResults:5,startPublishedDate:"2025-11-01",maxAgeHours:720)
4_DeepRead:3-5_full(¬snippets):firecrawl_scrape(url)|firecrawl_parse(pdf_url)|web_fetch_exa(url);multi_step_gap⇒firecrawl_agent∨agent_run
5_Verify:chk(URL|DOI|PMID)_exists∧¬retracted∧corroborate(1src_claims)∧sep(facts,estimates,preprints)
6_Write:tpl;7_Deliver:short⇒chat;long⇒exec_sum+takeaways_chat∧full→file

§PAT{par}
broad⇒3_agents:{A:subQ_1-2,B:subQ_3-4,C:subQ_5+cross_chk};each(srch,deep_read,ret_cited);main⇒dedup+synth

§FMT{tpl}
`# [Topic]: Research Report`
`*Generated:[date]|Sources:[N]|Confidence:[High/Medium/Low]*`
`## Executive Summary`:[3-5 sent]
`## [N]. [Theme]`:- Key point([Source](url)) | Supporting data([Source](url))
`## Key Takeaways`:- [Actionable insight]
`## Sources`:1.[Title](url)—[1-line sum]
`## Methodology`:Searched [N] queries(web+news). Analyzed [M] sources. Sub-questions:[list]
