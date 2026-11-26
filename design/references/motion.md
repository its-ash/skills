@REF:motion
§MAP{src:[design](../SKILL.md)(§5-9,12-13,15-19,22);react:[motion-react.md](motion-react.md);css_a:[css/animation-motion.md](css/animation-motion.md);css_c:[css/components-ui.md](css/components-ui.md)}

§R{5_DECIDE
  freq:100+/d(kbd)=0;10s/d(hover)=subtle∨0;occasional(modal,toast)=std;rare(onboard,ok)=delight;¬anim(kbd);
  why∈{feedback,spatial,state,bridge,explain,delight};¬name⇒¬build;¬move(read_data);
  ease:in/out=ease-out;move=ease-in-out;hover=ease;const=linear;¬ease-in;
  dur(<300ms):press=100-160ms;tip=125-200ms;drop=150-250ms;modal/drawer=200-400ms;
  tool:CSS_trans>@starting-style>CSS_anim>scroll/ViewTrans>WAAPI>Motion(spring,layout,gesture)
}
```css
--ease-out:cubic-bezier(0.23,1,0.32,1);--ease-in-out:cubic-bezier(0.77,0,0.175,1);--ease-drawer:cubic-bezier(0.32,0.72,0,1);
```

§PAT{6_MECH
  core:anim∈{transform,opacity,clip-path};¬scale(0)⇒scale(0.95)+opacity:0;spring(gesture/interrupt)@live;sym_in/out,orig=trig(¬modal),exit<enter;stag=30-80ms,¬block_in;hover@@media(hover:hover)and(pointer:fine);!:1-sent_why,≤1_marquee/pg;
  spring:damp=1.0_def;~0.8_post-momentum(flick,drag);move=1.0/0.4,rot=0.8/0.4,drawer=0.8/0.3;`animate(el,{y:0},{type:'spring',bounce:0,duration:0.4})`;
  gest:v_handoff→spring(v/(tgt-cur)_norm);proj:end=pos+(v/1000)*d/(1-d)(d=0.998)→snap_near;always_interrupt(¬lock,split_XY,blend_v_rev);rubber:(o*dim*0.55)/(dim+0.55*|o|),¬hard_stop;drag:ptr_cap,1_touch,dismiss_v>~0.11;
  mat:backdrop-filter_over_scroll;¬light-glass/light-glass;boost_txt_ctr;anim(blur+scale)_sync;solid_if_prefers-reduced-transparency
}

§R{7_UI_!
  press:scale(0.98)150ms--ease-out;trans>kf(retarget);blur(2px)_hides_crossfade;
  in/out:@starting-style+transition-behavior:allow-discrete;
  hdr(!):w-full,rounded-none(¬float/pill_def);app/dash/scroll⇒sticky top-0 z-50+(solid∨backdrop-blur)+1px_bot_hairline;edit/landing⇒static;nav_item⇒filled_pill/round_hover+active@page_r;
  tabs(!):filled_round_seg_in_track(padding:4px,outer_r=inner_r+pad);active=solid_elev+hairline/shadow∨accent+hi-ctr_lbl;¬(underline,bot-border,bare-txt);
  card/callout/alert(!):tonal_elev+1px_hairline(border-subtle);¬1-side_border(border-[lt]-[24])@(card,tile,callout,alert,li);¬nested_card⇒inset_muted∨div;pad≥p-4_uniform,concentric_r;
  sel(!):{sidebar,dropdown,card,tr,opt}⇒tonal_bg∨filled_pill∨full_ring(1.5-2px+tint);¬1-side_border(border-[ltb]);
  cb/radio/sw(!):checked=solid_accent(accent-color∨custom)+hi-ctr_mark;sw=pill_track+solid_accent+thumb(role="switch");
  badge:color-mix(in oklch,var(--status) 12%,transparent)+hi-ctr_tint+opt_1px_hairline;¬loud_sat_routine;¬pulsing_dots;
  overlay/tip:modal=<dialog>(showModal(),closedby="any");pop=[popover]+anchor+position-try-fallbacks;tip=popover="hint"+anchor(delay_1st,instant_next);hold=clip-path_2s_lin_in,200ms_out
}

§R{8_9_12
  8:var_cascade⇒el.style.transform;Motion_x/y_main⇒full_transform_str;blur/grain⇒fixed_pointer-events-none;animation-timeline:scroll()/view()∨IntersectionObserver(¬scroll_listener);will-change_sparse;¬z-[9999]⇒top_layer(dialog,popover);lazy_WebGL/WASM,pause_offscreen;CWV:LCP<2.5s,INP<200ms,CLS<0.1;
  9:WCAG2.2_AA;target≥24px(touch≥44px);focus¬obscured;drag⇒ptr_alt;rem_space;reduced:@media(prefers-reduced-motion:reduce){transition:opacity 200ms;transform:none}(crossfade,¬0);prefers-reduced-transparency⇒solid;prefers-contrast:more⇒solid+strong_border;forced-colors:active⇒keep_border/outline;¬fullscr_move_bg;soft_theme_sw;
  12:glass=prem/media+inner_border+red-trans_fallback;mag/loops⇒MOTION>5,fits_brief,motion_vals_only;MOTION>4⇒vis_move;¬{scroll_listeners,scrollY_state,rAF→React_state,layout_on_static}
}

§CFG{13_15
  13:BaseUI_1.0/Radix,ArkUI,cmdk,sonner,input-otp,Leva,motion,NumberFlow,torph,Cobe,Satori,shiki,Liveline/recharts,dnd_kit,Virtuoso,zustand,clsx/cva;theme=color-scheme+light-dark()(next-themes_only_manual_persist);rm:{custom_toasts,div_dialogs,rerender_tickers,1k+_unvirt_rows,nested_cn_ternaries};
  15:gate=@supports/feat(WebGPU→WebGL2);BL={ViewTrans(same/cross-doc;React19.3<ViewTransition>@Next16.4),@starting-style,scroll-anim,anchor,@property,WAAPI,Workers,OffscreenCanvas,WASM};prog(Chrome137+/139+,¬BL)={CSS_if(),@function,sibling-index(),corner-shape};polish_20%
}

§CHK{16_17_18
  16:{slowmo_2-5x,DevTools_Anim,Chrome_DevTools_MCP_INP,real_touch,next-day_eyes};
  17:{0-cfg_DX(<Toaster/>+toast()),defs>opts,memorable_names,invisible_edge(pause_hidden),trans>kf,personality(slow_decide,fast_sys)};
  18:{Purpose,Agency(undo>confirm),Responsibility,Familiarity,Flexibility,Simplicity(¬minimal),Craft,Delight;inline_val;screen∈{where,next,out};ctrl_mirrors_tgt;specific_lbl}
}

§MAP{19_22
  hero:{AsymSplit,EditManifesto,VideoMask,KineticType,CurtainReveal,ScrollPinned};nav:{StickyHdr,StaticHdr,DockMag,MagneticBtn,GooeyMenu,DynamicIsland,RadialMenu,MegaMenu};layout:{Bento,Masonry,SplitScroll,StickyStack};cards:{TonalSurf,ParallaxTilt,SpotlightBorder,GlassPanel,SwipeStack,MorphModal};scroll:{HorizHijack,ZoomParallax,ProgressPath};media:{Coverflow,DragPan,HoverTrail};txt:{Marquee,MaskReveal,Scramble,CircularPath};micro:{SkeletonShimmer,Ripple,SVGLineDraw,MeshGrad};
  libs:{Motion_def;GSAP_3.13(free,all_plugins)+ScrollTrigger+Lenis;Three_r186+/R3F_9(isolated+cleanup);¬mix(GSAP/Three,Motion)_1_tree};
  22_fix:¬transition:all⇒prop_list;+§5-9{¬scale(0),¬ease-in,orig=trig,¬kbd_anim,UI≤250ms,hover_media,trans>kf,exit<enter,stag30-80ms,transform/opacity,red_mot_fade,filled_tab,full_hairline,¬nested_card}
}
