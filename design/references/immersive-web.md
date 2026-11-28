@REF:immersive-web
§REL{
  parent:[`design`](../SKILL.md);
  refs:[`threejs.md`](threejs.md)[Three.js+R3F],[`gsap.md`](gsap.md)[GSAP+ScrollTrigger];
  siblings:[`frontend-development`](../../frontend-development/SKILL.md),[`web-performance`](../../web-quality-audit/references/web-performance.md),[`web-accessibility`](../../web-quality-audit/references/web-accessibility.md);
  topics:[3d-web-experience,scroll-experience,interactive-portfolio,frontend,landing-page-design]
}
§USE{long_form_storytelling;cinematic_landing;portfolios(scroll_reveal|3D_configurator);scroll_primary_nav}
§STACK{
  scroll_anim:CSS_scroll-timeline(Base2026:Cr/Sf/FF159+,native)⊕GSAP_ScrollTrigger(3.15+,complex/pinned)⊕Motion(motion/react_v14+,React);
  parallax:CSS_view()_timeline⊕GSAP_layer_tweens;
  sticky:CSS_position_sticky⊕GSAP_pin;
  snap_horiz:CSS_scroll-snap-type⊕GSAP_horiz_panels;
  smooth_scroll:Lenis(lightweight)⊕GSAP_ScrollSmoother[iff_native_insufficient;¬scroll_hijack];
  3d:React_Three_Fiber_9+drei_10(React)⊕Three.js_r187+(WebGPU/TSL+WebGL2_fb)⊕Spline(rapid_proto);
  opt:`@gltf-transform/cli`(Draco+WebP/KTX2);loader:`@react-three/drei`(`useProgress`+`Html`)
}
§PAT{
  1_gsap_scroll:`gsap.registerPlugin(ScrollTrigger); gsap.to('.element',{scrollTrigger:{trigger:'.element',start:'top center',end:'bottom center',scrub:true},y:-100,opacity:1})`;
  2_motion:`const{scrollYProgress}=useScroll(); const y=useTransform(scrollYProgress,[0,1],[0,-200]);`→`<motion.div style={{y}}>`(`motion/react`);
  3_css_reveal_base2026:`@keyframes reveal{from{opacity:0;transform:translateY(50px)}to{opacity:1;transform:translateY(0)}} .animate-on-scroll{animation:reveal linear;animation-timeline:view();animation-range:entry 0% cover 40%}`;
  4_parallax_speeds:`gsap.to('.background',{scrollTrigger:{scrub:true},y:'-20%'}); gsap.to('.foreground',{scrollTrigger:{scrub:true},y:'-50%'});`;
  5_sticky_css:`.sticky-container{height:300dvh} .sticky-element{position:sticky;top:0;height:100dvh}`;
  6_sticky_gsap:`gsap.to('.content',{scrollTrigger:{trigger:'.section',pin:true,start:'top top',end:'+=1000',scrub:true},x:'-100vw'})`;
  7_horiz_gsap:`const panels=gsap.utils.toArray('.panel'); gsap.to(panels,{xPercent:-100*(panels.length-1),ease:'none',scrollTrigger:{trigger:'.horizontal-container',pin:true,scrub:1,end:()=>'+='+document.querySelector('.horizontal-container').offsetWidth}});`;
  8_r3f_scroll:```tsx
// @react-three/fiber + @react-three/drei
function RotatingModel(){
  const scroll=useScroll(),ref=useRef();
  useFrame(()=>{if(ref.current)ref.current.rotation.y=scroll.offset*Math.PI*2});
  return <mesh ref={ref}>{/* geometry */}</mesh>;
}
// <Canvas><ScrollControls pages={3}><RotatingModel/></ScrollControls></Canvas>
```;
  9_gsap_three_cam:`gsap.to(camera.position,{scrollTrigger:{trigger:'.section',scrub:true},z:5,y:2})` (`gsap`,`gsap/ScrollTrigger`,`three`);
  10_3d_pipeline:Blender→poly<100k→bake_single_atlas→export_GLB/GLTF→`npm i -g @gltf-transform/cli && gltf-transform optimize input.glb output.glb --compress draco --texture-compress webp`→final<5MB+`useProgress`_loader
}
§PERF_A11Y{
  prefer(native_CSS)[compositor,¬JS_jank];`scrub:true`[¬fixed_duration];≤2-3_major_anims/vp;total_anim<2s/view;target≥55fps;
  low_end_mobile⇒reduce_parallax∨disable_3D∨low_poly/static_img_fallback;
  `prefers-reduced-motion`⇒appear_without_anim;kbd_focus∧sticky¬trap_focus∧ARIA_live(3D_progress);¬scroll_hijack(never_block_wheel/touch)
}
§ANTI{
  scroll_hijack⇒breaks_back_btn+a11y→native_scroll+`scrub`;
  anim_overload⇒jank→key_moments+<2s/view;
  desktop_only_3D⇒mobile_loss+battery→detect_capability+low_poly/static_img;
  missing_loader⇒broken_UX→progress_bar/spinner;
  hidden_critical_content⇒missed_info→reachable_without_anim_scroll;
  heavy_assets⇒slow_load+SEO→compress+lazy_load_offscreen+`rel=preload`_critical
}
§CHK{story_beats(hook,context,journey,climax,resolution);stack_lib;parallax_ratios;sticky/pin;3D(R3F|Three|Spline);3D_opt(poly<100k,Draco,WebP,<5MB);loading_UI;reduced_motion;low_end_mobile;kbd+SR;fps≥55}
