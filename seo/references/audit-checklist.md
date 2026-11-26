@REF:audit-checklist
§REL{../SKILL.md:parent;on-page-content.md:onpage;technical-seo.md:tech}
§CHK{
  CRIT:HTTPS;robots_ok∧¬noindex(key);title(uniq,kw,50-60c)∧1_h1;canonical;mobile;CWV(LCP<2.5s,INP<200ms,CLS<0.1);
  HIGH:desc(uniq,150-160c);sitemap→GSC;schema{Article,Product,FAQ,BreadcrumbList};links→pillar+cluster;img(alt,w,h);
  MED:guides≥1500w;EEAT(bio,creds);schema{Organization,LocalBusiness};hreflang(i18n);preload(fonts,assets);
  ONGOING:GSC_err;upd_sitemap;rank+traffic;refresh_qtr;backlinks+disavow
}
§FLOW{1:crawl(Lighthouse|Screaming_Frog)→2:log(Issue,Impact,Evidence,Fix,Prio)→3:fix(on-page-content.md,technical-seo.md)→4:re_audit→5:kw+mo}
§PAT{[SEV] title|Loc|Issue|Fix;ex:[HIGH] Dup titles|src/routes/products/[slug].tsx|collapse→weak+dup|uniq(name+cat)}
