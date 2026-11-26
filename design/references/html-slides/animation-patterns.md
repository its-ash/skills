@REF:animation-patterns
§FEEL{
  dramatic_cinematic:fade_in(1-1.5s)+scale(.9→1)+parallax|dark_bg,spotlight,full_bleed_img;
  techy_futuristic:neon_glow(box-shadow)+glitch/scramble_txt+grid_reveal|canvas_particles,grid_pat,monospace,cyan|magenta|electric_blue;
  playful_friendly:spring_ease+float/bob|rounded,pastel|bright,hand_drawn;
  professional_corporate:subtle_fast(200-300ms)+clean_slide|navy|slate|charcoal,precise_spacing,dataviz;
  calm_minimal:slow_subtle+gentle_fade|high_whitespace,muted,serif,generous_pad;
  editorial_magazine:stagger_txt_reveal+img_txt_interplay|strong_type_hierarchy,pull_quote,grid_break,serif_h+sans_body
}
§PAT{
  entrance:hidden→`.visible .<cls>`(opacity:1,reset);
    .reveal:{opacity:0;transform:translateY(30px);transition:opacity .6s var(--ease-out-expo),transform .6s var(--ease-out-expo)}→translateY(0);
    .reveal-scale:{opacity:0;transform:scale(.9);transition:opacity .6s,transform .6s var(--ease-out-expo)}→scale(1);
    .reveal-left:{opacity:0;transform:translateX(-50px);transition:opacity .6s,transform .6s var(--ease-out-expo)}→translateX(0);
    .reveal-blur:{opacity:0;filter:blur(10px);transition:opacity .8s,filter .8s var(--ease-out-expo)}→blur(0);
  bg:
    .gradient-bg:radial-gradient(ellipse at 20% 80%,color-mix(in oklch,var(--accent) 30%,transparent) 0%,transparent 50%),radial-gradient(ellipse at 80% 20%,color-mix(in oklch,var(--accent) 15%,transparent) 0%,transparent 50%),var(--bg-primary);
    .noise-bg:background-image:url("data:image/svg+xml,...");
    .grid-bg:background-image:linear-gradient(rgba(255,255,255,.03) 1px,transparent 1px),linear-gradient(90deg,rgba(255,255,255,.03) 1px,transparent 1px);background-size:50px 50px;
  tilt_3d:`TiltEffect(el)`:set `el.style.transformStyle='preserve-3d';perspective='1000px'`;`mousemove(e)`:`r=el.getBoundingClientRect()`, `x=(e.clientX-r.left)/r.width-.5`, `y=(e.clientY-r.top)/r.height-.5`→`el.style.transform=\`rotateY(${x*10}deg) rotateX(${-y*10}deg)\``;`mouseleave`→`rotateY(0) rotateX(0)`
}
§FIX{
  fonts_fail⇒chk(@font-face.src∨font_url)∧match(CSS_font_family);
  anim_fail⇒chk(IntersectionObserver_active)∧chk(.visible_toggled);
  scroll_snap_fail⇒html{scroll-snap-type:y mandatory}∧.slide{scroll-snap-align:start};
  mobile⇒disable_heavy@≤768px∧test_touch∧reduce_particles;
  perf⇒sparing(will-change)∧prefer(transform,opacity)∧throttle(scroll)
}
