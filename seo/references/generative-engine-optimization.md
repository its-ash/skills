@REF:generative-engine-optimization

§META{def:optimise_pages_for_AI_citation;metric:citation_rate(AI_link/ref_freq);targets:{ChatGPT,Claude,Perplexity,Gemini}}

§D{
  SEO_vs_GEO:{SEO:(rank_#1_Google|Google|rank,CTR|kw_density,backlinks);GEO:(cited_source_AI|ChatGPT,Claude,Perplexity,Gemini|citation_freq|entities,structured_data,clear_defs)};
  engines:{Perplexity:footnotes(`[1]`);ChatGPT_OpenAI:inline|footnote(`"According to *Source* …"`);Claude_Anthropic:contextual(embedded_links);Gemini_Google:Sources_section(end_URLs)};
  retrieval_wt:{semantic_rel:~40%;kw_match:~20%;authority:~15%(author_rep,backlinks,schema);diversity:~15%(domains,formats);freshness:~10%(pub_date,recent_upd)};
  citable_formats:{orig_stats(verifiable+src_links),expert_quotes(name,title,affiliation),clear_defs(1_sent),step_guides(ordered_lists),comparison_tables,FAQ(direct_Q&A)}
}

§CHK{
  content:{Q_title(user_intent);top_TLDR;orig_data+citations;expert_quote(name+credentials);FAQ(≥3,3-5_Q&A);precise_term_defs;visible(`"Last updated"`);author_bio(credentials+affiliation)};
  tech:{schema∈{Article|NewsArticle(datePublished,dateModified),Person(name,jobTitle,affiliation),FAQPage};load<2.5s(Lighthouse∨WebPageTest);semantic_HTML(`<h1>`-`<h3>`,`<section>`,`<article>`);canonical_URL};
  entity:{Google_Knowledge_Panel;Wikipedia_entry+site_link(if_notable);consistent_web_NAP(name,logo,desc);industry_pub_mentions};
  ops:{robots_allows_AI_crawlers;monitor_citations_weekly}
}

§CFG{
  crawlers:{
    GPTBot(ChatGPT/OpenAI):`Mozilla/5.0 (compatible; GPTBot/1.0; +https://openai.com/bot)`;
    Claude-Web(Claude):`Mozilla/5.0 (compatible; Claude-Web/1.0; +https://anthropic.com/bot)`;
    PerplexityBot(Perplexity):`Mozilla/5.0 (compatible; PerplexityBot/1.0; +https://perplexity.ai/bot)`;
    Googlebot(Gemini_shared):standard_Googlebot_UA
  };
  access:{max_citation⇒allow_all;block_training⇒`Disallow: /`(per_bot);ctrl:{`robots.txt`,`X-Robots-Tag`}};
  monitor:{AI_citations:search_brand_weekly;mentions:`"According to [Brand]"`;share:compare_competitor_counts;traffic:`utm_source=ai`}
}

§ANTI{
  ¬missing_pub_date⇒visible(`datePublished`,`dateModified`);
  ¬vague_attribution⇒exact(source_name,URL,date);
  ¬missing_author⇒show(name,title,credentials);
  ¬thin_content⇒comprehensive+data+expert_insight;
  ¬slow_load⇒opt_img+compression+CDN
}
