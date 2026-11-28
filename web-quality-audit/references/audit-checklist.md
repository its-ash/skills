@REF:audit-checklist
§W{Perf~40%|A11y~30%|SEO~15%|BP~15%}
§PERF{
  CWV(p75):LCP≤2.5s(TTFB+load_delay+load_dur+render_delay),INP≤200ms(LoAF,scheduler.yield,worker),CLS≤0.1(w/h,aspect-ratio,ad_slot);
  nav:bfcache_eligible(¬unload→pagehide|visibilitychange,¬no-store_HTML)∧Speculation_Rules(prefetch|prerender);
  transport:HTTP/2|HTTP/3∧comp∈{zstd(dynamic),Brotli(static),gzip};
  img:AVIF>WebP,srcset+sizes,LCP=`loading="eager" fetchpriority="high"`,below_fold=`loading="lazy" decoding="async"`;
  js:code-split,tree-shake,min,defer,¬legacy_JS(Baseline);
  css:crit<14KB_inline,unused_rm,¬@import,`content-visibility:auto`(offscreen);
  font:variable_font,woff2,preload_crit,`font-display:swap|optional`,subset;
  hints:preconnect(≤4_crit_3p),preload(LCP,crit_font);
  cache:hashed=`public,max-age=31536000,immutable`,unhashed=`stale-while-revalidate`
}
§A11Y{
  std:WCAG_2.2_AA(EAA_Jun2025/EN_301_549;ADA_Title_II_2027-2028);
  P:alt(desc|""_decor),contrast≥4.5:1(lg≥18pt/24px∨≥14pt/18.67px_bold:≥3:1;UI≥3:1),captions,transcripts,reflow@400%;
  O:kbd_all,¬trap,`:focus-visible`,2.4.11_focus_not_obscured(sticky_hdr),2.5.7_drag_single_ptr_alt,2.5.8_target≥24×24px(mobile_rec_44-48px),"Skip to main";
  U:`<html lang>`,3.2.6_consistent_help,3.3.7_no_redundant_entry,3.3.8_accessible_auth(allow_paste+pw_mgr+passkeys,¬cognitive_only),`<label>`/ctrl,err_suggestion;
  R:valid_HTML(¬dup_id),native_first(`<dialog>`,`[popover]`,`inert`)>ARIA
}
§SEO{
  crawl:robots.txt_allow,XML_sitemap(GSC),canonical,¬noindex,clean_status(200/301/404);
  page:uniq`<title>`(50-60c),meta_desc(150-160c),1`<h1>`+order,desc_link(¬"click here");
  tech:responsive,tap≥24×24px(44-48px_mobile),HTTPS,CWV_green,JSON-LD(Article|Product|FAQ|Org),agentic_metadata(LH13_ARD)
}
§BP{
  sec_hdrs:HTTPS,¬mixed,HSTS=`max-age=63072000; includeSubDomains; preload`(all_subdomains_HTTPS_first);
  CSP:Strict(`default-src 'self'; script-src 'nonce-<rand>' 'strict-dynamic'; object-src 'none'; base-uri 'none'; frame-ancestors 'none'; require-trusted-types-for 'script'`),rollout=`Content-Security-Policy-Report-Only`(1-2wk);
  isolation:`X-Content-Type-Options: nosniff`,`Referrer-Policy: strict-origin-when-cross-origin`,`Permissions-Policy`,COOP=`same-origin`,COEP=`require-corp`(test_Report-Only_first),`X-Frame-Options: DENY`(legacy_fallback_only;superseded_by_frame-ancestors);
  cookies:`__Host-`+`Secure; HttpOnly; SameSite=Lax|Strict`(cross-site_embeds:CHIPS_`SameSite=None; Secure; Partitioned`);
  compat:`<!DOCTYPE html>`,`<meta charset="UTF-8">`_1st,viewport,LH13_Baseline_diag(`web-features`),feat_det(¬UA),polyfill:self(¬polyfill.io:2024_hack),¬unload,¬document.write,¬sync_XHR,passive_scroll/touch;
  code:¬prod(console.error,console.log),global_err+ErrorBoundary,DOMPurify+TrustedTypes,dep_audit(npm/pnpm/yarn),srcmap=hidden|off,semantic_HTML5,unmount_clean(`AbortController`)
}
§RPT{Crit(X):[Cat]@path:line(Impact,Fix)→High(X)→Med(X)→Low(X)→Sum(Perf,A11y,SEO,BP+crit)→Prio(1:sec+CWV,2:a11y,3:SEO+perf,4:code)}
§CADENCE{
  deploy:CWV_green∧LH13_insights_clean∧0_crit_axe(wcag22aa)∧0_console_err∧HTTPS_¬mixed∧sec_hdrs∧{title,desc,viewport,charset};
  wk:GSC,CrUX_Vis(40wk_trend),dep_audit,SR_spot(NVDA,VoiceOver);
  mo:LH13_full+CPU/net_trace,Baseline_drift,manual_a11y_kbd_audit,rank_check
}
§TOOLS{Lighthouse_13+|LHCI|chrome-devtools-mcp|axe-core_4.14+(wcag22aa)|CrUX_API/Vis|web-vitals_v5|WebPageTest|npm/pnpm_audit|W3C_Validator|SecurityHeaders|GSC}
