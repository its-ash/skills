@REF:browser-support
§LEG{Cr:Chrome,Chrm:Chromium,FF:Firefox,Sf:Safari,Ed:Edge}
§R{
Base:Newly=latest{Cr,Ed,FF,Sf};Widely=30mo;
layer:base(∀)→enh(@supports|forgiveness);order:fb→modern(height:100vh;height:100dvh);
detect:@supports¬UA;degrade:missing_enh¬hide/block(scroll-reveal_visible);
cleanup:rm_fb_post-target∧doc;evergreen≠latest(Sf=OS,ent_Cr=pin)
}
§SUP{
@supports:{(container-type:inline-size),not (anchor-name:--a),selector(::scroll-marker),font-tech(color-COLRv1),font-format(woff2)};
MQ:nest @media (prefers-reduced-motion:no-preference)∈@supports (animation-timeline:view());
¬depend:@supports at-rule(@starting-style);¬use:@when/@else;
scope:props,vals,selectors,font_tech(¬MQ);
exact:(display:grid-lanes),(width:stretch);
fn:(color:contrast-color(red)),(width:calc-size(auto,size)),(animation-delay:calc(sibling-index()*1ms));
val_fb:2_decls(last_wins);sel_list:1_bad_drops_rule⇒split∨:is()/:where();
JS:CSS.supports('anchor-name','--a'),CSS.supports('selector(:popover-open)')
}
§STAT{
2026-11;chk:caniuse.com|MDN_BCD|webstatus.dev;
Base:{Grid,subgrid,flex_gap,aspect-ratio,CQ_size+units,:has(),:is()/:where(),@layer,nesting,:focus-visible,:user-valid/:user-invalid,logical,dvh/svh/lvh,MQ_range,clamp/min/max(),trig,round/mod(),oklch/oklab/color(),color-mix(),rel_color,light-dark(),@property,linear(),indiv_tx,@starting-style,transition-behavior:allow-discrete,text-wrap:balance,<dialog>,popover,excl_<details name>,inert,content-visibility,fetchpriority,@scope,same-VT,contrast-color(),shape(),text-box_trim,sibling-index/count(FF154),anchor_pos(Cr125+,Sf26+,FF147+),field-sizing:content(Cr123+,FF152+,Sf26.2+),scroll_anim(Chrm115+,Sf26+,FF159+)};
Partial(feat⇒sup|fb):{x-VT⇒Cr126+,Sf18.2+,FF_flag|nav;CQ_style⇒Chrm,Sf18+|cls/attr;scroll-state_Q⇒Chrm133+|IntersectionObserver;text-wrap:pretty⇒Cr117+,Sf26+|norm;interpolate-size/calc-size()⇒Chrm129+|inst/grid_0fr→1fr;base-select⇒Cr135+,Sf_rec,FF_flag|native;::scroll-button/marker⇒Cr135+|JS;if()/@function⇒Chrm|static/build;typed_attr()⇒Chrm|vars;corner-shape⇒Cr139+|radius;background-clip:border-area⇒Sf,Cr150|2-bg;row/column-rule⇒Cr/Ed149|border/∅;column-wrap/height⇒Cr145|cols;light-dark()_img⇒Cr148,FF150|<picture>+prefers-color-scheme;name-only_CQ⇒Cr148,FF149,Sf26.4|cls;random()⇒Sf26.2|const;display:grid-lanes⇒Sf26.4+/TP,others_dev|grid/multi-col};
Exp(¬depend):{flex-wrap:balance,border-shape,text-fit/grow,interestfor,reading-flow,ident(),@when}
}
§POLY{defer_native(CSS.supports)+rm;legacy_only(pre-Base2026):anchor(@oddbird/css-anchor-positioning),scroll(scroll-timeline);inert∧<dialog>=Widely(¬poly);JS_parse⇒FOUC+INP⇒lazy_only;¬poly(:has(),CQ,sibling-index())⇒alt_layout}
§QUIRK{
iOS_Sf:100vh_bar(dvh/svh);input<16px_zooms;background-attachment:fixed✗;
Sf:list-style:none⇒¬VO_list;<details>→::-webkit-details-marker;is=_unsup;
Cr:float_text-decoration-thickness_floors;scrollbar-color/width⇒¬::-webkit-scrollbar;
FF::host-context()_unsup;replaced_overflow:Cr108+;sticky:anc_overflow∉{visible,clip}✗;
Cr_Android_AutoDark:¬color-scheme⇒recolors→color-scheme+dark
}
§TST{real:{Sf(macOS/iOS_WebInspector),FF,Chrm};fb:bad_@supports|DevTools(Cr_flags,FF_about:config);Interop2026:{shape(),VT,sibling-index(),anchor_pos,scroll_anim}}
§ANTI{bad_@supports⇒false⇒test_exact;old⇒base_out;-webkit-line-clamp(display:-webkit-box),-webkit-text-stroke,-webkit-text-size-adjust;rest⇒LightningCSS(browserslist);¬-moz-/-ms-}
