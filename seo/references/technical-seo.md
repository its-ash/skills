@REF:technical-seo
§REL{../SKILL.md:parent;../../web-quality-audit/references/web-performance.md:CWV;../../i18n-localization/SKILL.md:i18n_hreflang;generative-engine-optimization.md:AI_crawlers}
§CRWL{
  robots.txt(RFC9309_voluntary):`User-agent: * | Allow: / | Disallow: /admin/, /api/ | Sitemap: https://example.com/sitemap.xml`;¬block(CSS,JS,imgs_needed_for_render);
  AI_bots+WAF:separate(training_bots,AI_search_bots)@generative-engine-optimization.md;audit(Cloudflare/WAF_"Block AI Scrapers"_blocks_before_robots.txt);
  googlebot_size_limits:{HTML≤2MB_uncompressed(incl_headers;silently_truncated_past_2MB⇒text,links,JSON-LD_lost);PDF≤64MB;general_fetcher_default:15MB;subresources(CSS/JS):separate_requests_same_limits;gzip/Brotli≠bypass};
  sitemap:reachable∧canonical_indexable_URLs∧GSC+Bing_sub∧(≤50000_URLs∧≤50MB_uncompressed;gzip_ok)∧sitemap_index(≤500/property)∧accurate_<lastmod>_ONLY(Google_ignores_<priority>∧<changefreq>);
  IndexNow:push_notify(Bing,Yandex,Seznam,Naver)_on_create/update/delete(feeds_Copilot/AI_search_ecosystems);Google⇒crawl+sitemap;
  SSR_JS:SSR/SSG/RSC_for_critical_content,`<a href>`,metadata,JSON-LD;¬client_only_useEffect_waterfalls;¬hydrate_>2MB_HTML_blobs;
  arch:key≤3_clicks_home∧¬orphan_pages;crawl_budget:ctrl_params∧clean_paginated_links(¬JS_only_inf_scroll)∧strip_session_IDs
}
§IDX{
  inspect:GSC_Page_Indexing+URL_Inspection(`site:example.com`=approx_only)∧¬`noindex`∈rank_pages;
  canonical:self_ref∧consistent∧loop_free∧¬uncontrolled_dupes;
  pagination:self_ref_canonical(page_N→page_N)∧¬canonical_to_page_1∧¬`noindex`(preserves_item_discovery);sort/filter_params→canonical_to_clean_paginated_URL;
  noindex_scope:`<meta name="robots" content="noindex, follow">`∈{internal_search,thin_facets,low_val_tags};¬pair(`noindex`+canonical_elsewhere);¬disallow_noindex_URL_in_robots.txt(Googlebot_must_crawl_to_see_noindex);
  snippet_discover_ctrl:{`max-image-preview:large`(Discover_thumbs≥1200px);`data-nosnippet`(DOM_span/div_exclude_SERP+AI_Overviews);`nosnippet|max-snippet:N`(page_level);`X-Robots-Tag`(HTTP_header_for_PDFs/non-HTML)};
  redirects:301/308(perm),302/307(temp);fix(chains,loops,soft_404)∧hops≤2
}
§CWV{
  LCP≤2.5s(p75)⇒`fetchpriority="high"`(LCP_hero)∧¬`loading="lazy"`(above_fold)∧AVIF/WebP∧SSR_HTML∧preload(LCP,fonts)∧CDN∧Speculation_Rules_API(Chromium_prefetch/prerender);
  INP≤200ms(p75,replaced_FID)⇒break_long_tasks(`scheduler.yield()`)∧reduce_hydration_JS∧web_workers∧`content-visibility:auto`(offscreen);
  CLS≤0.1(p75)⇒explicit(`width`/`height`∨`aspect-ratio`)∧`font-display:swap`+metric_overrides∧¬insert_DOM_above_existing
}
§MOB_SEC_URL{
  mob:responsive(¬m_sub_unless_req)∧DOM_content_links_schema(mob≡desk)∧`<meta name="viewport" content="width=device-width, initial-scale=1">`∧tap≥48x48px;
  https:site_wide∧¬mixed_content∧`Strict-Transport-Security: max-age=31536000; includeSubDomains`;
  url:lower∧hyphen_sep∧<75c∧primary_kw∧¬needless_params
}
§I18N{
  bidirectional_hreflang(ISO639-1+opt_ISO3166-1)+self_ref+`x-default`(HTML_`<link>`∨HTTP_header∨XML_sitemap);
  `<link rel="alternate" hreflang="en|es|x-default" href="https://example.com/[es/]page">`;
  ¬auto_redirect_by_IP_only(allow_user_locale_switch)
}
§TOOLS{
  GSC(Page_Indexing,URL_Inspection,Performance+Query_Groups+GenAI_reports,CWV,Manual_Actions);
  Bing_Webmaster+IndexNow(Copilot/Bing_idx);
  PSI|CrUX|Lighthouse|WebPageTest(field+lab_CWV,waterfall);
  GA4(organic+AI_referrals);
  Screaming_Frog|Sitebulb(crawl,HTML_size,links,redir,hreflang);
  Ahrefs|Semrush(kw,links,comp);
  Rich_Results_Test+Schema_Validator(JSON-LD)
}
