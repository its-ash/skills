@REF:audit-checklist
§REL{../SKILL.md:parent;on-page-content.md:onpage;technical-seo.md:tech;schema-markup.md:schema;generative-engine-optimization.md:GEO}
§CHK{
  CRIT:HTTPS;robots_ok∧¬noindex(key)∧¬disallow_noindex_URL;HTML≤2MB_uncompressed∧SSR_core_content;title(uniq,kw,50-60c)∧1_h1;canonical(self_ref,incl_pagination);mobile≡desktop;CWV_p75(LCP≤2.5s,INP≤200ms,CLS≤0.1);¬Manual_Actions;
  HIGH:desc(uniq,150-160c);sitemap(accurate_<lastmod>,¬<priority>)→GSC+Bing+IndexNow;active_schema{Article,Product/ProductGroup,BreadcrumbList,ProfilePage,LocalBusiness}(`<`→`\u003c`,¬HowTo,¬SearchAction);AI_crawlers(robots.txt+WAF_split_training_vs_search);links→hub+cluster;img(alt,AVIF/WebP,w,h,LCP_`fetchpriority="high"`,¬lazy_above_fold);
  MED:intent_complete+info_gain(¬scaled_content_abuse);EEAT(author_bio,creds,ProfilePage,sameAs);GEO_blocks(TLDR,40-60w_direct_answers,semantic_tables,visible_dates);`max-image-preview:large`(Discover);schema{Organization,WebSite_Site_Name};bidirectional_hreflang+x-default(i18n);preload(LCP,fonts)+Speculation_Rules;
  ONGOING:GSC(Page_Indexing,Query_Groups,GenAI_reports,Manual_Actions);Bing_Webmaster+IndexNow;AI_referrals(GA4:`utm_source=chatgpt.com`,perplexity.ai,claude.ai);rank+citation_share;refresh_qtr;backlinks(disavow_ONLY_if_manual_action_or_link_scheme)
}
§FLOW{1:crawl(Lighthouse|Screaming_Frog|Sitebulb)+GSC_URL_Inspection→2:log(Issue,Impact,Evidence,Fix,Prio)→3:fix(technical-seo.md,schema-markup.md,on-page-content.md,generative-engine-optimization.md)→4:re_audit(Rich_Results_Test+PSI+crawl)→5:track(GSC+GA4+AI_citations)}
§PAT{[SEV] title|Loc|Issue|Fix;ex:[HIGH] Dup titles|src/routes/products/[slug].tsx|collapse→weak+dup|uniq(name+cat)}
