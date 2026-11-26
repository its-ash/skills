@REF:performance
§R{
CWV_p75⇒LCP≤2.5s∧CLS≤0.1∧INP≤200ms;measure(CrUX,web-vitals,lab);
critical_path⇒1 main CSS in <head>,¬@import chains,inline critical CSS⇔measurably faster;
LCP_img⇒fetchpriority="high"∧¬loading="lazy"∧¬CSS_bg(unless preloaded);below-fold⇒loading="lazy";
CLS_reserve⇒width/height|aspect-ratio(img,video,iframe,ad_slots);
offscreen⇒content-visibility:auto+contain-intrinsic-size:auto <est>;
compositor⇒transform,opacity,(mostly filter);will-change briefly,¬globally;
fonts⇒self-host subset WOFF2,preload≤1-2,font-display:swap|optional+metric fallback;
purge⇒Tailwind/PurgeCSS/Lightning_CSS∧safelist runtime classes(¬string-concat);
INP⇒CSS>JS(popover,dialog,:has(),scroll-anim)
}
§PAT:Delivery_Priority{
<link rel="stylesheet" href="/app.css">;media="print"(non-blocking);
async_CSS:<link rel="preload" href="/b.css" as="style" onload="this.rel='stylesheet'">+<noscript><link rel="stylesheet" href="/b.css"></noscript>;
@import=serial→bundle_build;HTTP/2⇒split route/component;
cache⇒content-hashed+Cache-Control:max-age=31536000,immutable;<link rel="preconnect" href="…" crossorigin>;
fetchpriority="high|low|auto" on img/preload/script/fetch()(Baseline 2024;replaces importance);
hidden_slides/below-fold⇒fetchpriority="low";preload only late_discovered(CSS fonts,LCP bg);
JS⇒modulepreload(critical ESM),defer(app),async(3p)
}
§PAT:Rendering_Anim{
content-visibility:auto(Baseline 2024) skips offscreen layout/paint∧keeps a11y+find-in-page(hidden hides both)+contain-intrinsic-size:auto 800px(no scrollbar jump);
contain:layout paint|content(strict collapses sans dims);
JS⇒batch getBoundingClientRect() reads before writes+rAF;
paint_heavy⇒large box-shadow,filter:blur(),backdrop-filter(¬animate,limit area);
bottleneck⇒large_DOM(>~1500 nodes)∧broad_invalidation(<body> class,global_var_Δ)>broad_selectors;
will-change:transform on parent :hover/pointerenter or pre-JS_anim,remove after;
CSS scroll-driven>scroll listener({passive:true});pause offscreen⇒animation-play-state(IntersectionObserver|content-visibility)
}
§PAT:Images_Fonts{
AVIF>WebP>JPEG;SVG(vector);PNG(lossless);srcset+sizes;non-critical⇒decoding="async";
GIF⇒<video autoplay muted loop playsinline>;heavy_embeds(YT,maps)⇒facade→iframe on click;
WOFF2_only,subset(unicode-range,glyphhanger|fonttools),1 variable≈4-6 static;
font-display:optional+preload⇒0_CLS;swap+size-adjust⇒min_CLS;system_stack=0_cost
}
§CHK:CLS_INP_Cache{
CLS⇒reserve_space,overlay late UI(banners¬push),transform_anim(¬top/height),scrollbar-gutter:stable,¬insert above post-load(sans user action);
INP⇒split tasks(>50ms) via await scheduler.yield()(fallback:setTimeout)|WebWorkers,instant feedback(:active,optimistic),debounce,¬sync_layout;
SW⇒cache-first(hashed),network-first|SWR(HTML,API),prune on activate;bfcache⇒¬unload∧¬Cache-Control:no-store on HTML;
measure⇒DevTools Performance(CWV,LCP,LS)+Coverage+Lighthouse+WebPageTest;PerformanceObserver(largest-contentful-paint,layout-shift,event)|web-vitals
}
