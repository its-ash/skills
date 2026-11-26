@REF:technical-seo
§REL{../SKILL.md:parent;../../web-quality-audit/references/web-performance.md:CWV}
§CRWL{
  robots.txt:`User-agent: * | Allow: / | Disallow: /admin/, /api/ | Sitemap: https://example.com/sitemap.xml`;
  sitemap:reachable∧canonical_indexable∧GSC_sub∧(≤50000_URLs∧≤50MB;else⇒sitemap_index)∧intended_surface;
  arch:key≤3_clicks_home∧¬orphan_pages;
  crawl_budget:ctrl_params∧paginate_inf_scroll∧strip_session_IDs
}
§IDX{
  cmp(`site:example.com`,GSC_Page_Indexing)∧¬`noindex`∈rank_pages;
  canonical:self_ref∧consistent∧loop_free∧¬uncontrolled_dupes;
  redirects:fix(chains,loops,soft_404)∧hops≤2;
  `<meta name="robots" content="noindex, follow">`∈{pagination,tag,internal_search}
}
§CWV{
  LCP<2.5s⇒WebP+`width`/`height`+preload_crit_CSS+CDN;
  INP<200ms⇒split_JS_tasks+web_workers;
  CLS<0.1⇒explicit_media_dims∧¬insert_above_existing
}
§MOB_SEC_URL{
  mob:responsive(¬m_sub_unless_req)∧mob=desk∧`<meta name="viewport" content="width=device-width, initial-scale=1">`∧tap≥48x48px;
  https:site_wide∧¬mixed_content∧`Strict-Transport-Security: max-age=31536000; includeSubDomains`;
  url:lower∧hyphen_sep∧<75c∧primary_kw∧¬needless_params
}
§I18N{`<link rel="alternate" hreflang="en|es|x-default" href="https://example.com/[es/]page">`}
§TOOLS{GSC(idx,cov,CWV);PSI|WebPageTest(CWV,waterfall);GA4(traffic,conv);Screaming_Frog|Sitebulb(crawl,links,redir);Ahrefs|Semrush(kw,links,comp);Rich_Results_Test(JSON-LD)}
