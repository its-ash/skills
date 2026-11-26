@REF:gsap-scrolltrigger
§REL{gsap-core:tweens/eases;gsap-timeline:sequencing;gsap-react:React_cleanup;gsap-plugins:ScrollSmoother/scrollTo}
§WHEN{scroll-driven_anim∨pin∨scrub∨parallax(default_rec=GSAP+ScrollTrigger)}
§INIT{`gsap.registerPlugin(ScrollTrigger);`//once}
§CFG{
  shorthand:`scrollTrigger:".box"`(sets trigger only)⊕obj;
  trigger:Str|El(req_unless_shorthand);
  endTrigger:Str|El;
  start:Str|Num|Fn(def:"top bottom"|"top top" if pin:true);
  end:Str|Num|Fn(def:"bottom top");
  pos_fmt:"triggerPos viewportPos"(e.g."top center","bottom 80%","top top","center center")|num_px(`500`=scroller_500px_from_0)|rel(`"+=300"`,`"+=100%"`)|`"max"`|`clamp(...)`(v3.12+,e.g.`"clamp(top bottom)"`)|`fn(self)=>Str|Num`(call `ScrollTrigger.refresh()` on Δ);
  scrub:Bool|Num(`true`=direct;Num=catchup_lag_sec,e.g.`0.5`,`1`);
  toggleActions:Str("onEnter onLeave onEnterBack onLeaveBack",ea∈{"play","pause","resume","reset","restart","complete","reverse","none"},def:"play none none none");
  pin:Bool|Str|El(`true`=pin trigger;¬animate pinned el⇒animate children);
  pinSpacing:Bool|Str(def:`true`;`false`|"margin");
  horizontal:Bool(`true`=horizontal);
  scroller:Str|El(def:viewport);
  markers:Bool|Obj(`true`|`{startColor,endColor,fontSize,...}`;dev_only⇒¬prod);
  once:Bool(kills ST after end once;anim continues);
  id:Str(for `ScrollTrigger.getById(id)`);
  refreshPriority:Num(lower=refreshed first;use when non-top-to-bottom);
  toggleClass:Str|Obj(str_on_trigger|`{targets:".x",className:"active"}`);
  snap:Num|Arr|Fn|"labels"|Obj(inc e.g.`0.25`|vals[]|"labels"|`{snapTo:0.25,duration:0.3,delay:0.1,ease:"power1.inOut"}`);
  containerAnimation:Tween|Timeline(fake horizontal scroll;pin∧snap=disabled);
  cb_enter:{onEnter,onLeave,onEnterBack,onLeaveBack}`(self)=>{}`(`self.progress`,`.direction`,`.isActive`,`.getVelocity()`);
  cb_life:{onUpdate(progress Δ),onToggle(active flip),onRefresh(recalc),onScrubComplete(num scrub end)}
}
§PAT{
  tween:`gsap.to(".box",{x:500,duration:1,scrollTrigger:{trigger:".box",start:"top center",end:"bottom center",toggleActions:"play reverse play reverse"}});`
  standalone:`ScrollTrigger.create({trigger:"#id",start:"top top",end:"bottom 50%+=100px",onUpdate:s=>log(s.progress.toFixed(3),s.direction)});`
  timeline:`const tl=gsap.timeline({scrollTrigger:{trigger:".container",start:"top top",end:"+=2000",scrub:1,pin:true}});tl.to(".a",{x:100}).to(".b",{y:50}).to(".c",{opacity:0});`
}
§API_BATCH{
  sig:`ScrollTrigger.batch(triggers,vars)`→`ScrollTrigger[]`(1 ST/target;alt_to_IntersectionObserver);
  triggers:Str|El[];
  vars_excl:¬{trigger,animation,invalidateOnRefresh,onSnapComplete,onScrubComplete,scrub,snap,toggleActions};
  opts:{interval:Num(sec,def≈1_rAF;timer_starts_1st_cb),batchMax:Num|Fn(runs_on_refresh/resize/focus)};
  cb_sig:`(targets,scrollTriggers)=>{}`(2_args);
  ex:`ScrollTrigger.batch(".card",{interval:0.1,batchMax:4,start:"top 80%",end:"bottom 20%",onEnter:(els,trs)=>gsap.to(els,{opacity:1,y:0,stagger:0.1,overwrite:true}),onLeaveBack:els=>gsap.set(els,{opacity:0,y:50,overwrite:true})});`
  doc:https://gsap.com/docs/v3/Plugins/ScrollTrigger/static.batch/
}
§API_PROXY{
  sig:`ScrollTrigger.scrollerProxy(scroller,vars)`(for 3rd-party smooth-scroll;GSAP `ScrollSmoother` ¬needs proxy);
  req_vars:`scrollTop`∨`scrollLeft`(fn:0_args=getter,1_arg=setter;≥1_req);
  opt_vars:{getBoundingClientRect:`()=>({top,left,width,height})`,scrollWidth:fn,scrollHeight:fn,fixedMarkers:Bool(`position:fixed` if scroller translated),pinType:"fixed"|"transform"("fixed"=anti-jitter,"transform"=if pins ¬stick)};
  sync_CRITICAL:register `ScrollTrigger.update` listener on scroller(e.g.`smoothScroller.addListener(ScrollTrigger.update)`);
  lenis1x_native_scroll_no_proxy:`lenis.on("scroll",ScrollTrigger.update);gsap.ticker.add(t=>lenis.raf(t*1000));gsap.ticker.lagSmoothing(0);`
  doc:https://gsap.com/docs/v3/Plugins/ScrollTrigger/static.scrollerProxy/
}
§PAT_HORIZ{
  1:pin wrapper/section(`pin:scrollingEl.parentNode`);2:tween inner `x`|`xPercent` with `ease:"none"`(REQUIRED)+`scrub:true`;3:child ST sets `containerAnimation:scrollTween`,e.g.`start:"left center"`;
  ex:`const scrollTween=gsap.to(el,{xPercent:()=>Math.max(0,innerWidth-el.offsetWidth),ease:"none",scrollTrigger:{trigger:el,pin:el.parentNode,start:"top top",end:"+=1000"}});gsap.to(".nested",{y:100,scrollTrigger:{containerAnimation:scrollTween,trigger:".nested-wrap",start:"left center",toggleActions:"play none none reset"}});`
  caveats:¬pin∧¬snap on `containerAnimation` STs;¬animate trigger el horizontally(animate child);if trigger moved⇒offset `start`/`end`.
}
§LIFE{
  refresh:`ScrollTrigger.refresh()`(after DOM/layout/img/font Δ;auto-called on resize debounced 200ms;order=creation∨`refreshPriority`);
  kill:`ScrollTrigger.getAll().forEach(t=>t.kill());`|`ScrollTrigger.getById("id")?.kill();`
  react:`useGSAP()`(`@gsap/react`)∨`gsap.context()` in `useEffect`/`useLayoutEffect` cleanup.
}
§R{
  1:registerPlugin once before use;
  2:create top→bottom(0→max)∨set `refreshPriority`(lower=earlier on page);
  3:call `ScrollTrigger.refresh()` after dynamic DOM/img/font layout Δ;
  4:scrub⊕toggleActions(never both;if both⇒`scrub` wins);
  5:ST only on top-level tween∨timeline;
  6:`containerAnimation` horizontal tween ⇒ `ease:"none"`
}
§ANTI{
  ¬ST on child tween inside timeline(`tl.to(...,{scrollTrigger})`=BUG)∨nested ST timelines;
  ¬`scrub`+`toggleActions` together;
  ¬ease≠`"none"` with `containerAnimation`;
  ¬animate pinned element itself;
  ¬`markers:true` in prod;
  ¬forget `refresh()` after dynamic layout Δ∨`useGSAP()`/`kill()` cleanup
}
§DOC:https://gsap.com/docs/v3/Plugins/ScrollTrigger/
