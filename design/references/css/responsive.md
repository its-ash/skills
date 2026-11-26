@REF:responsive
§R{
intrinsic_first(auto-fill+minmax(),flex_wrap,clamp())→breakpoints iff breaks;
component⇒CQ;page/device/prefs⇒MQ;mobile_first⇒base→@media(width>=48rem);
range⇒(width>=40rem),(30rem<=width<60rem)(Baseline 2023,Safari 16.4);units⇒rem/em;
full_h_mobile⇒100dvh|100svh(¬100vh);full_w⇒100%|full-bleed_grid(¬100vw,scrollbar→h-scroll);
inputs⇒font-size≥16px(stops iOS Safari auto-zoom);
prefs⇒prefers-reduced-motion,prefers-color-scheme,prefers-contrast,forced-colors
}
§PAT:MQ{
@media(width>=48rem){…};@media(hover:hover)and(pointer:fine){:hover{translate:0 -2px}}(blocks sticky tap :hover);
@media(pointer:coarse){.btn{min-block-size:44px}};@media(orientation:landscape)and(height<30rem){.hero{min-block-size:auto}};
@custom-media --md (width>=48rem)⇒¬native,PostCSS/Lightning_CSS_only
}
§PAT:CQ{
.wrap{container:card/inline-size}@container card (width>=30rem){…};
¬query self⇒container-type on wrapper,style children;
inline-size⇒¬shrink-to-fit(inline-block,flex:none,abs sans width)⇒0-collapse;
size⇒height query∧explicit height;unnamed @container⇒nearest ancestor;
units:cqi,cqb,cqw,cqh,cqmin,cqmax(clamp(1rem,4cqi,2rem));
name-only(@container card{…})⇒Chrome 148,FF 149,Safari 26.4;size_CQ⇒Baseline 2023(Chrome 105,Safari 16,FF 110);
style_CQ:@container style(--variant:compact)|style(--columns>3)(all_els=style_container;Chromium+Safari 18+,check FF;ranges+if() Chrome 142+);
scroll-state:container-type:scroll-state;position:sticky;top:0→@container scroll-state(stuck:top|snapped:x|scrollable:top)(Chrome 133+,enhancement)
}
§PAT:Fluid_VP_Images{
clamp(1rem,.9rem+.5vi,1.25rem);h1:clamp(2rem,1.5rem+2.5vi,3.5rem);padding-block:clamp(2rem,6vi,6rem);
mix rem+vi(pure vw fails zoom/WCAG 1.4.4;vi>vw vertical);
VP(Baseline 2022):svh/svw(UI shown),lvh(UI hidden),dvh(dynamic,scroll shifts→svh for heroes);
OSK:<meta name="viewport" content="width=device-width,initial-scale=1,interactive-widget=resizes-content">(Chromium);
img:srcset="400w,800w,1600w" sizes="(width>=60rem) 33vw,100vw" width height loading="lazy" decoding="async";img{max-inline-size:100%;block-size:auto};
<picture>:<source type="image/avif" srcset="…">+webp+<img fetchpriority="high">;
sizes="auto"⇔loading="lazy"(Chromium);art_dir⇒<source media="(width<40rem)">(VP,¬container);
CSS_bg:url(a.jpg) before image-set(url(a.avif) type("image/avif"),url(a.jpg) type("image/jpeg"))
}
§PAT:UserPrefs{
@media(prefers-reduced-motion:reduce){*,*::before,*::after{animation-duration:.01ms!important;animation-iteration-count:1!important;transition-duration:.01ms!important;scroll-behavior:auto!important}}
@media(prefers-contrast:more){:root{--border:CanvasText}}
@media(forced-colors:active){.btn{border:1px solid ButtonText}}(HC strips bg/shadow→borders+ButtonText,Highlight,CanvasText)
}
§ANTI{@media(width>=…) includes scrollbar;hover-only UI unreachable on touch→tap/focus path}
