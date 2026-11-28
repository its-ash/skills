@REF:web-performance

§WHEN{
  slow_load ∨ Lighthouse_perf_fail ∨ CWV∈{needs_work,poor} ∨ large_blocking_JS ∨ layout_shift_delay(img,font,3p) ∨ perf_budget ∨ caching_plan ∨ CI_CD_audit
}

§WORKFLOW{
  1.baseline: `npx lighthouse <url>`(LH13_insights) ∨ `chrome-devtools-mcp`(performance_start_trace) ∧ RUM(`web-vitals` v5 | CrUX_API/CrUX_Vis);
  2.identify: DevTools(Performance_Insights,Network,Memory) ∧ WebPageTest(waterfall,filmstrip) ∧ bundle_analyzer(`rollup-plugin-visualizer`|`@next/bundle-analyzer`|`webpack-bundle-analyzer`|`esbuild --metafile`) ∧ `PerformanceObserver`(LCP,event,CLS,LoAF);
  3.fix: apply §PAT/§R;
  4.validate: LH13_CLI(`--output json --output-path report.json`)∨LHCI(`@lhci/cli`)→diff_before/after ∧ field_RUM(`web-vitals` v5 attribution | CrUX_Vis_40wk | Search_Console_CWV)
}

§CFG{budget:
  total_page<1.5MB; js_gzip<300KB; css_gzip<100KB; above_fold_img<500KB; img_each<200KB; fonts<100KB; 3p_scripts<200KB; crit_css_inline<14KB; TTFB≤800ms
}

§R{server_crp:
  TTFB≤800ms (CDN, edge HTML cache, fast backend, streaming SSR);
  compression∈{zstd(fast_dynamic),Brotli(precomp_static),gzip(fallback)};
  protocol∈{HTTP/2,HTTP/3};
  crit_CSS<14KB inline; defer non_crit CSS/JS; ¬render_blocking_JS in `<head>`;
  bfcache: ¬`unload` listeners (use `pagehide`|`visibilitychange`) ∧ ¬`Cache-Control: no-store` on regular HTML ∧ release locks/IDB on `pagehide`
}

§PAT{resource_hints_speculation:
```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://cdn.example.com" crossorigin>
<link rel="preload" href="/hero.avif" as="image" fetchpriority="high">
<link rel="preload" href="/fonts/heading.woff2" as="font" type="font/woff2" crossorigin>
<style>/* crit <14KB */</style>
<link rel="preload" href="/styles.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
<noscript><link rel="stylesheet" href="/styles.css"></noscript>
<script defer src="/app.js"></script>
<script async src="https://analytics.example.com/track.js"></script>
<script type="speculationrules">{"prerender":[{"where":{"href_matches":"/*"},"eagerness":"moderate"}]}</script>
```
}

§CWV{
  LCP: goal≤2.5s(p75); phases(LH13_lcp-breakdown-insight):TTFB+ResourceLoadDelay+ResourceLoadDuration+ElementRenderDelay; target∈{hero_img,large_text,bg_img,SVG};
    slow_srv→CDN+HTML_cache+zstd/Brotli; load_delay→LCP∈initial_HTML+`fetchpriority="high"`+`<link rel="preload" as="image">`(¬`loading="lazy"`_on_LCP); load_dur→AVIF/WebP_sized+CDN; render_delay→inline_crit_CSS(<14KB)+defer_JS+SSR/SSG/stream_HTML;
  INP: goal≤200ms(p75;replaces_retired_FID;web-vitals_v5_drops_onFID); phases:InputDelay+ProcessingDuration+PresentationDelay;
    task>50ms→yield(`scheduler.yield()`_with_setTimeout_fallback)∨Web_Worker; diagnose_3p_&_scripts→LoAF_API(`long-animation-frame`); handler≥100ms→immediate_UI_feedback+`requestIdleCallback`(analytics)+debounce; 3p→lazy(`import()` on click|visibility); re_render→React_Compiler|`React.memo`|`computed`+`useTransition`;
  CLS: goal≤0.1(p75); formula=`impact×distance`;
    img/video/iframe→`width`/`height`∨`aspect-ratio`; ads/embeds→fixed `height`|`min-height`|`aspect-ratio`; dynamic_DOM→below_fold∨`transform`; FOUT/FOIT→`font-display:optional`∨`size-adjust`; anim→composited `transform`|`opacity` only(¬layout_CSS_transitions)
}

§PAT{cwv_rum_observers:
```js
// Production RUM: web-vitals v5 (Baseline Widely Available, onFID removed)
import {onLCP, onINP, onCLS} from 'web-vitals/attribution';
[onLCP, onINP, onCLS].forEach(fn => fn(m => sendMetric(m)));
// Local diagnostics: LCP, slow events, CLS, and Long Animation Frames (LoAF) script attribution
new PerformanceObserver(l=>{const e=l.getEntries(),x=e[e.length-1];console.log(x.element,x.startTime);}).observe({type:'largest-contentful-paint',buffered:true});
new PerformanceObserver(l=>{for(const e of l.getEntries())if(e.duration>200)console.warn(e);}).observe({type:'event',buffered:true,durationThreshold:16});
new PerformanceObserver(l=>{for(const e of l.getEntries())if(!e.hadRecentInput)e.sources?.forEach(s=>console.log(e.value,s.node,s.previousRect,s.currentRect));}).observe({type:'layout-shift',buffered:true});
new PerformanceObserver(l=>{for(const f of l.getEntries())if(f.duration>50)console.warn(f.duration,f.scripts.map(s=>[s.sourceURL,s.invoker,s.duration]));}).observe({type:'long-animation-frame',buffered:true});
```
}

§PAT{images:
  order: AVIF>WebP>JPEG/PNG; above_fold_LCP:`loading="eager" fetchpriority="high"`(¬lazy); below_fold:`loading="lazy" decoding="async"`; each<200KB;
```html
<!-- Above-the-fold LCP hero: eager + fetchpriority="high" (use loading="lazy" ONLY below the fold) -->
<picture>
  <source type="image/avif" srcset="hero-400.avif 400w, hero-800.avif 800w, hero-1200.avif 1200w" sizes="(max-width:600px) 100vw, 50vw">
  <source type="image/webp" srcset="hero-400.webp 400w, hero-800.webp 800w, hero-1200.webp 1200w" sizes="(max-width:600px) 100vw, 50vw">
  <img src="hero-800.jpg" srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w" sizes="(max-width:600px) 100vw, 50vw" width="1200" height="600" alt="Hero" loading="eager" fetchpriority="high" decoding="async">
</picture>
```
  batch(`npm install sharp`): `sharp(f).avif({quality:70})` | `.webp({quality:80})` | `.jpeg({quality:80,progressive:true})`
}

§PAT{fonts:
  variable_fonts>multi_weight; preload crit `.woff2`(`as="font" type="font/woff2" crossorigin`);
```css
@font-face{font-family:'Custom';src:url('/fonts/custom.woff2') format('woff2');font-display:swap;/*optional if non-crit*/unicode-range:U+0000-00FF;}
```
}

§PAT{js_runtime:
  code_split(`import()`) ∧ tree_shake(`import debounce from 'lodash/debounce'` ¬`import _ from 'lodash'`) ∧ defer/async ∧ task<50ms(yield|Web_Worker) ∧ `requestAnimationFrame`(visual) ∧ `requestIdleCallback`(non_essential) ∧ virtualize(`@tanstack/react-virtual`|`react-window`);
  yield_main: `const yieldToMain=()=>globalThis.scheduler?.yield?scheduler.yield():new Promise(r=>setTimeout(r,0));`
  debounce(scroll/resize,100ms): `const debounce=(fn,d)=>{let t;return(...a)=>{clearTimeout(t);t=setTimeout(()=>fn(...a),d);};};`
  ¬layout_thrash: batch DOM reads(`const h=els.map(e=>e.offsetHeight)`) before writes(`els.forEach((e,i)=>e.style.height=h[i]+10+'px')`);
  CSS: `contain` ∧ `content-visibility:auto`(offscreen) ∧ unused_CSS_removed ∧ minified
}

§PAT{caching_3p:
  HTML: `Cache-Control: no-cache, must-revalidate` (¬`no-store` so bfcache works)
  hashed_static: `Cache-Control: public, max-age=31536000, immutable`
  unhashed_static: `Cache-Control: public, max-age=86400, stale-while-revalidate=604800`
  SW_cache_first(`['image','style','script'].includes(e.request.destination)`): `caches.match(req)||fetch(req)`→`caches.open('static-v1').put(req,resp.clone())`;
  3p_embeds→facade(`.yt-facade` thumb+button→`onclick` `iframe.src='https://www.youtube.com/embed/'+id; iframe.width=560; iframe.height=315; el.replaceWith(iframe)`)
}

§REL{
  ../../frontend-development/SKILL.md | performance.md | ../SKILL.md | ../../frontend-development/references/nextjs.md | ../../frontend-development/references/astro.md | ../../unit-testing-patterns/references/playwright.md
}
