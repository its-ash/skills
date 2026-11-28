@REF:motion-react
@PARENT:[design](../SKILL.md)§5-§9(parent_wins)
§USE{
  React|Next:tokens+springs|reduced_motion|SSR|UI(presence,stagger,modal,toast,page,scroll,layout)|adv(drag,gestures,text,SVG,useAnimate,loaders);
  ¬covered:{CSS:../SKILL.md§5.E+references/css/animation-motion.md,GSAP_Three:immersive-web.md,video:motion-canvas.md}
}
§R{
  1:import_only("motion/react",v14+)∧¬"framer-motion"∧¬mix;
  2:"use client"@top(∀importer("motion/react"))∧client_leaves(../SKILL.md§3);
  3:SSR_match(initial≡server_output);
  4:useReducedMotion()⇒strip_transforms∧opacity_crossfade(≤0.2s)∧¬zero_motion(../SKILL.md§9);
  5:anim_only(transform,opacity,clip-path,pathLength)∧¬(width|height|top|left|margin|padding);
  6:tokens_only(duration,easing,spring)∧¬inline_nums;
  7:guard(window,navigator)w/typeof!=="undefined";
  8:∀AnimatePresence_child⇒key∧exit;
  9:infinite_anim⇒pause(document.visibilityState==="hidden");
  10:∀listener|anim_ctrl⇒cleanup(useEffect_return);
  11:¬useState(continuous_input)⇒useMotionValue|useTransform|useScroll|useSpring(../SKILL.md§3,§12)
}
§CFG{
  // lib/motion-tokens.ts (../SKILL.md §5.C,§5.D,§6.B,§7)
  ```ts
  export const motionTokens={
    duration:{instant:0.1,fast:0.16,normal:0.25,slow:0.4,story:0.8},
    easing:{out:[0.23,1,0.32,1],inOut:[0.77,0,0.175,1],drawer:[0.32,0.72,0,1],linear:[0,0,1,1]},
    distance:{xs:4,sm:8,md:16,lg:24,xl:48},
    scale:{enter:0.95,press:0.97,subtle:0.98,lift:1.02},// enter≠0;lift=drag_only
    stagger:{tight:0.03,normal:0.05,loose:0.08},// 30-80ms
  }as const
  export const springs={
    ui:{type:"spring",bounce:0,duration:0.25},
    move:{type:"spring",bounce:0,duration:0.4},
    instant:{type:"spring",bounce:0,duration:0.15},
    drawer:{type:"spring",bounce:0,duration:0.3},
    release:{type:"spring",bounce:0.2,duration:0.4},// momentum_only(flick|drag_release)
  }as const
  ```
  dur:{instant:tooltip|focus|badge,fast:press|icon|chip,normal:dropdown|expand|enter,slow:modal|drawer|page,story:hero_rare(../SKILL.md§5.A)};
  spring:{ui:btns|chips|nav,move:cards|modals|panels,instant:tooltips|popovers|dropdowns,drawer:sheets|drawers,release:drag_release|flick(¬state_Δ)};v14_springs:{mass:"auto"(size-relative),visualDuration+bounce,preserved_layer_velocity};
  // lib/motion-config.ts
  ```ts
  export const motionConfig={
    isLowEnd:()=>typeof navigator!=="undefined"&&navigator.hardwareConcurrency<=4,
    prefersReduced:()=>typeof window!=="undefined"&&window.matchMedia("(prefers-reduced-motion: reduce)").matches,
    shouldAnimate({essential=false}={}){return !this.prefersReduced()&&(essential||!this.isLowEnd())},
  }
  ```
  skip_when:prefersReduced(crossfade)∨(lowEnd∧¬essential)∨¬enters_viewport∨¬named_purpose(../SKILL.md§5.B);
  priority:reduced>lowEnd>designPref∧no_CLS
}
§PAT{
  useSafeMotion(hooks/use-safe-motion.ts):
  ```tsx
  "use client";import{useReducedMotion}from"motion/react"
  export function useSafeMotion(d=16){const r=useReducedMotion();return{initial:{opacity:0,y:r?0:d},animate:{opacity:1,y:0},exit:{opacity:0,y:r?0:-d}}}
  ```
  css_reduced:`@media(prefers-reduced-motion:reduce){.motion-safe-transition{transition:opacity 200ms}.motion-reduce-transform{transform:none}}`;
  ssr:useMotionValue|useSpring=SSR_safe;else_mount_guard(`const[m,setM]=useState(false);useEffect(()=>setM(true),[]);initial={{opacity:m?0:1}}`);
  btn:hover_fine_pointer(../SKILL.md§6.A);`motion.button(whileTap:{scale:scale.press},transition:springs.ui)`;
  stagger(¬block_input):container(`visible:{transition:{staggerChildren:stagger.normal}}`)→item(`hidden:{opacity:0,y:distance.md}`,`visible:{opacity:1,y:0,transition:springs.move}`),`motion.ul(variants=c,initial="hidden",animate="visible")>motion.li(key=i.id,variants=it)`;
  modal(Radix|<dialog>|focus-trap handles trap,Esc,scroll_lock,role="dialog",aria-modal="true";exit_faster ../SKILL.md§6.A):
    `AnimatePresence>{open&&<Modal key="modal"/>}`;
    backdrop:`opacity:0→1→0(duration.fast),onClick=onClose`;
    panel(`role="dialog" aria-modal="true"`):`initial:{opacity:0,scale:scale.enter,y:distance.sm}→animate:{opacity:1,scale:1,y:0}→exit:{opacity:0,scale:scale.enter,duration:duration.fast},transition:springs.move`;
  toast(prod→`sonner` ../SKILL.md§13):`AnimatePresence(mode="sync")>motion.div(key=t.id,layout,initial/exit:{opacity:0,x:distance.xl,scale:scale.subtle},animate:{opacity:1,x:0,scale:1},transition:springs.ui)`;
  page_transition(Next,usePathname):
    `AnimatePresence(mode="wait")>motion.div(key=usePathname(),initial:{opacity:0,y:distance.sm},animate:{opacity:1,y:0},exit:{opacity:0,y:-distance.sm},transition:{duration:duration.normal,ease:easing.out})`;
  scroll_reveal_progress(always `viewport={{once:true}}`):
    reveal:`motion.div(initial:{opacity:0,y:distance.lg},whileInView:{opacity:1,y:0},viewport:{once:true,margin:"-80px"},transition:{duration:duration.slow,ease:easing.out})`;
    bar:`const{scrollYProgress}=useScroll();motion.div(className="fixed top-0 left-0 h-1 w-full origin-left",style:{scaleX:scrollYProgress})`;
  expanding_card+shared:
    `motion.button(layout,onClick,aria-expanded)>motion.h2(layout="position")+AnimatePresence>motion.p(key="body",opacity:0→1→0,duration.fast)`;
    shared_el:same `layoutId="hero-image"` across contexts;
  accordion(¬height,¬scaleY:0;grid `0fr->1fr` ../SKILL.md§25.C ∨ `<details name>`):
    `div(className="grid transition-[grid-template-rows] duration-300 ease-[cubic-bezier(0.23,1,0.32,1)]",style:{gridTemplateRows:open?"1fr":"0fr"})>div.overflow-hidden`
}
§D{
  UI:{show_hide⇒AnimatePresence;seq_list⇒stagger;route_Δ⇒PageTransition|ViewTransitions(../SKILL.md§15);in_place_resize⇒layout;cross_ctx⇒layoutId;scroll_enter⇒whileInView+viewport({once:true});scroll_linked⇒useScroll+useTransform};
  AnimatePresence_mode:{wait⇒page|swap(1_at_a_time);sync⇒stacked_notifs;popLayout⇒list_removal_reflow};
  layout_rules:layout("position")_text_in_expanding_box;¬layout_subtree(>5_children|deep_DOM)⇒x/y;¬layout_static(../SKILL.md§12);
  adv:{drag_physics⇒drag+dragTransition|springs.release;reorder⇒Reorder.Group/Item(complex→dnd_kit)+up/down_kbd_alt;dismiss⇒drag="y"+onDragEnd(offset∧velocity);swipe⇒drag="x"+onDragEnd(offset∧velocity);press_v14(count,hold,repeat)⇒dbl/multi-press|long_press(fallback:useLongPress);multitouch_v14⇒pinch|rotate+vel_snap;smooth⇒useSpring;derived⇒useTransform;seq⇒useAnimate(async/await);one_shot⇒animate()("motion");word⇒stagger_inline_block;svg_draw⇒pathLength(0→1);svg_morph⇒d_tween(equal_cmd_counts);ring⇒strokeDashoffset};
  useSpring_vs_springs:{useSpring:pointer_continuous,per_frame,preserves_velocity;springs.*:discrete_state_Δ,on_change,from_curr_val}
}
§ADV{
  motion_val:`x=useMotionValue(0);opacity=useTransform(x,[-200,0,200],[0,1,0])`;
  useAnimate(scope_on_mounted,call_post_mount,new_call_stops_prev,¬new_MotionValue_in_render):
    `[scope,animate]=useAnimate();await animate(".step-1",{opacity:1},{duration:normal});await animate(".step-2",{x:0},{duration:slow});animate(".step-3",{scale:1},{duration:normal})`;
  drag:`motion.div(drag,dragConstraints:{left:-100,right:100,top:-100,bottom:100},dragElastic:0.1,whileDrag:{scale:scale.lift},dragTransition:{bounceStiffness:300,bounceDamping:30})`;
  bottom_sheet(DISMISS_OFFSET=120,DISMISS_VELOCITY=500;real_touch_test;math→../SKILL.md§6.C-G):
    `y=useMotionValue(0);opacity=useTransform(y,[0,200],[1,0]);motion.div(drag="y",dragConstraints:{top:0},dragElastic:{top:0.1,bottom:0.5},style:{y,opacity},onDragEnd:(_,i)=>(i.offset.y>120||i.velocity.y>500)&&onClose())`;
  swipe(OFFSET=50,VELOCITY=300):`motion.div(drag="x",dragConstraints:{left:0,right:0},onDragEnd:(_,i)=>offset.x>50||vel.x>300?onSwipeRight():offset.x<-50||vel.x<-300?onSwipeLeft():0)`;
  reorder:`Reorder.Group(axis="y",values=items,onReorder=setItems)>Reorder.Item(key=i.id,value=i)`;
  long_press(ms=600):`useLongPress(cb,ms=600):useRef(setTimeout),clear=()=>clearTimeout(t.current),useEffect(()=>clear,[]),{onPointerDown:t=setTimeout(cb,ms),onPointerUp:clear,onPointerLeave:clear,onPointerCancel:clear}`;
  word_reveal:`motion.p(aria-label=text,staggerChildren:stagger.normal)>text.split(" ").map(w=>motion.span(key=i,aria-hidden,className="mr-1 inline-block",y:12→0,opacity:0→1,springs.move))`;
  counter(direct_DOM+tabular-nums,¬setState;prod→NumberFlow ../SKILL.md§13):
  ```tsx
  import{animate}from"motion"
  useEffect(()=>{const c=animate(0,to,{duration:motionTokens.duration.story,ease:motionTokens.easing.out,onUpdate:v=>{if(node.current)node.current.textContent=Math.round(v).toString()}});return()=>c.stop()},[to])
  ```
  svg(R=40,C=2*Math.PI*R):
    path:`motion.path(d,initial:{pathLength:0,opacity:0},animate:{pathLength:1,opacity:1},duration:slow,ease:out)`;
    ring:`svg(100x100,role="img",aria-label="${v}%")>circle(r=40,strokeWidth=8)+motion.circle(r=40,strokeLinecap="round",strokeDasharray:C,animate:{strokeDashoffset:C-(v/100)*C},duration:normal,ease:out,style:{rotate:-90,transformOrigin:"center"})`;
  scroll_reveal_hook:`ref=useRef(null);{scrollYProgress}=useScroll({target:ref,offset:["start end","end start"]});return{ref,style:{opacity:useTransform(scrollYProgress,[0,0.3],[0,1]),y:useTransform(scrollYProgress,[0,0.3],[distance.lg,0])}}`;
  shimmer(match_layout ../SKILL.md§4.5):
  ```tsx
  const controls=useAnimationControls()
  useEffect(()=>{const play=()=>controls.start({x:["-100%","100%"],transition:{repeat:Infinity,duration:1.2,ease:motionTokens.easing.linear}});const onVis=()=>document.visibilityState==="hidden"?controls.stop():void play();void play();document.addEventListener("visibilitychange",onVis);return()=>{controls.stop();document.removeEventListener("visibilitychange",onVis)}},[controls])
  ```
  loading_btn(set `min-width`):`motion.button(onClick,disabled:loading,aria-busy:loading,animate:{opacity:loading?0.7:1},whileTap:loading?undefined:{scale:scale.press},transition:springs.ui)>AnimatePresence(mode="wait",initial=false)>motion.span(key=loading?"loading":"label",opacity:0→1→0,duration.fast)`
}
§NOT{custom_cursors|followers(../SKILL.md§10);pulse_dots(../SKILL.md§10);bouncy_springs(state_Δ,../SKILL.md§6.B);default_btn_hover_scale_up}
§ANTI{
  "framer-motion"⇒"motion/react";SSR_initial_0⇒mount_guard;no_useReducedMotion⇒useSafeMotion;width:"100%"⇒scaleX;inline_dur_stiff_damp⇒tokens;no_"use client"⇒add_top;module_navigator⇒typeof_guard;AnimatePresence_no_key⇒key;initial+animate_no_exit⇒exit;page_no_mode_wait⇒mode="wait";layout_50_items⇒popLayout|transforms;stagger_0.2⇒0.03-0.08;whileInView_no_once⇒once:true;repeat_Infinity_no_pause⇒visibilitychange;onDragEnd_single_check⇒offset∧velocity;useEffect_no_cleanup⇒cleanup;svg_morph_diff_cmds⇒normalize_cmds
}
§REL{../SKILL.md§5-§9;immersive-web.md;make-interfaces-feel-better.md;../../frontend-development/SKILL.md}
