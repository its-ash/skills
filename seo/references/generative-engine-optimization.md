@REF:generative-engine-optimization
§REL{../SKILL.md:parent;technical-seo.md:robots_crawl;schema-markup.md:entity_graph}
§META{def:GEO/AEO(optimize_pages_for_RAG_retrieval,query_fan-out,AI_citations);metric:citation_rate+share_of_voice+AI_referral_conv;targets:{Google_AI_Overviews,Google_AI_Mode,ChatGPT_Search,Claude_Search,Perplexity,Microsoft_Copilot}}
§D{
  SEO_vs_GEO:{SEO:(SERP_rank,CTR,crawl,CWV,links);GEO:(RAG_chunk_selection,query_fan-out_coverage,cited_grounding_source,entity_authority,verifiable_facts)};
  engines:{
    Google_AI_Overviews_AI_Mode:Googlebot+Search_idx+Gemini_query_fan-out(blended_in_GSC_Performance+GenAI_impressions);
    ChatGPT_Search:OAI-SearchBot+Bing/web+inline_links(`utm_source=chatgpt.com`);
    Claude_Search:Claude-SearchBot+contextual_embedded_links;
    Perplexity:PerplexityBot+numbered_footnotes(`[1]`);
    Copilot:Bingbot+IndexNow+inline_citations
  };
  retrieval_drivers:{direct_answer_passages(40-60w_under_H2/H3);query_fan-out_subquestion_depth;high_info_density(primary_stats,benchmarks,tables);entity_clarity(@graph+@id,consistent_web_mentions);SSR_HTML_accessibility(AI_fetchers_often_skip_heavy_JS);freshness(visible_date+dateModified)};
  citable_formats:{orig_stats(verifiable+src_links),expert_quotes(name,title,affiliation),crisp_defs(1-2_sent_post_heading),ordered_step_guides,semantic_HTML_comparison_tables,structured_Q&A(visible_FAQ)}
}
§CHK{
  content:{intent_Q_headings;top_TLDR_verdict;40-60w_direct_answers_below_H2/H3;orig_data+exact_citations;expert_quote(name+creds);semantic_HTML_tables;visible_Q&A(3-5);visible(`"Last updated"`);author_bio(creds+affiliation+sameAs)};
  tech:{SSR/SSG_HTML_visible(¬JS_gated_copy);HTML≤2MB;schema:@graph(Article|NewsArticle(datePublished,dateModified),Person/ProfilePage(name,jobTitle,url,sameAs),Organization,opt_FAQPage);CWV_good(LCP≤2.5s);semantic_HTML(`<h1>`-`<h3>`,`<article>`,`<table>`);self_canonical;IndexNow_enabled};
  entity:{Knowledge_Graph/Wikidata(if_notable);consistent_web_NAP(name,logo,desc,sameAs);3rd_party_industry_mentions+reviews};
  ops:{robots.txt_splits_training_vs_search_bots;WAF/CDN_allows_search_bots;monitor_AI_referrals+brand_citations_weekly}
}
§CFG{
  crawlers:{
    training:{GPTBot(OpenAI);ClaudeBot(Anthropic);Google-Extended(Gemini_training/grounding,≠Google_Search);Applebot-Extended(Apple_Intel);Meta-ExternalAgent;CCBot;Bytespider};
    AI_search_index:{OAI-SearchBot(ChatGPT_Search);Claude-SearchBot(Claude_Search);PerplexityBot(Perplexity);Googlebot(Search+AI_Overviews+AI_Mode);Bingbot(Bing+Copilot)};
    user_live_fetch:{ChatGPT-User;Claude-User;Perplexity-User(user_initiated;may_bypass_robots.txt)}
  };
  robots_split_opt_out_training_keep_citations:
  ```text
  User-agent: GPTBot
  Disallow: /
  User-agent: ClaudeBot
  Disallow: /
  User-agent: Google-Extended
  Disallow: /
  User-agent: Meta-ExternalAgent
  Disallow: /
  User-agent: OAI-SearchBot
  Allow: /
  User-agent: Claude-SearchBot
  Allow: /
  User-agent: PerplexityBot
  Allow: /
  User-agent: Googlebot
  Allow: /
  User-agent: Bingbot
  Allow: /
  ```
  emerging_controls:{
    shared_signal:`__usage_ai-training`(IETF_aipref_cross_vendor_std,rollout_2026-2027);
    llms_txt:`/llms.txt`(optional_root_markdown_index_of_core_docs/pages_for_AI_agents;complementary,¬replace_SSR_HTML);
    AI_Overviews_snippet_ctrl:`data-nosnippet`|`nosnippet`|`max-snippet:N`|`X-Robots-Tag`(note:Google-Extended_does_NOT_opt_out_Search_AI_Overviews);
    WAF_gotcha:audit_Cloudflare/CDN_"Block AI Scrapers"_toggles(intercept_before_robots.txt)
  };
  monitor:{
    GA4_referrals:`utm_source=chatgpt.com`∨referrer∈{perplexity.ai,claude.ai,chatgpt.com,copilot.microsoft.com,gemini.google.com};
    GSC:Performance(blended_AI_Overviews/AI_Mode)+Query_Groups(Insights)+GenAI_Performance_Reports(macro_impressions);
    share_of_voice:weekly_prompt_eval(brand_vs_competitors_across_engines)
  }
}
§ANTI{
  ¬blanket_block_AI_bots⇒separates_training(GPTBot,ClaudeBot,Google-Extended)_from_search(OAI-SearchBot,Claude-SearchBot,PerplexityBot);
  ¬legacy_bot_names⇒replace_`Claude-Web`_with_`ClaudeBot`/`Claude-SearchBot`/`Claude-User`;
  ¬JS_only_content⇒SSR_render_facts,tables,answers(many_AI_crawlers_do_not_execute_JS);
  ¬missing_dates_or_author⇒visible(`datePublished`,`dateModified`,author_creds+ProfilePage);
  ¬vague_attribution⇒exact(source_name,URL,date,methodology);
  ¬fluff_or_unverified_AI_copy⇒high_info_density+primary_data+fact_checked
}
