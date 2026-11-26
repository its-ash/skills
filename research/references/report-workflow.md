@REF:report-workflow
§CFG{tools}
req≥1_MCP:{firecrawl(firecrawl_search,firecrawl_scrape,firecrawl_crawl),exa(web_search_exa,web_search_advanced_exa,crawling_exa)};both⇒best
pre_promise⇒chk(tools,live_docs)(names/quotas/shapes_drift);¬MCP⇒../../web-scraping-apis/SKILL.md∨builtin(search/fetch)

§PAT{steps}
1_Goal:1-2_Q(learn|decide|write?angle/depth?);"Just research it"⇒defaults
2_Plan:3-5_subQ(ex_AI_hc:apps,outcomes,reg,leaders,mkt_size)
3_Search:2-3_kw/subQ(gen+news);tgt=15-30_uniq:firecrawl_search(query,limit:8)|web_search_exa(query,numResults:8)|web_search_advanced_exa(query,numResults:5,startPublishedDate:"2025-01-01")
4_DeepRead:3-5_full(¬snippets):firecrawl_scrape(url)|crawling_exa(url,tokensNum:5000)
5_Write:tpl;6_Deliver:short⇒chat;long⇒exec_sum+takeaways_chat∧full→file

§PAT{par}
broad⇒3_agents:{A:1-2,B:3-4,C:5+cross};each(srch,read,ret);main⇒synth

§FMT{tpl}
`# [Topic]: Research Report`
`*Generated:[date]|Sources:[N]|Confidence:[High/Medium/Low]*`
`## Executive Summary`:[3-5 sent]
`## [N]. [Theme]`:- Key point([Source](url)) | Supporting data([Source](url))
`## Key Takeaways`:- [Actionable insight]
`## Sources`:1.[Title](url)—[1-line sum]
`## Methodology`:Searched [N] queries(web+news). Analyzed [M] sources. Sub-questions:[list]
