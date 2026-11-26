@REF:gsap-timeline
§REL{gsap-core:tweens/eases;gsap-scrolltrigger:scroll_timelines;gsap-react:React}
§WHEN{multi-step_anim|seq/parallel_tweens|keyframe_seq}
§CORE{
  `const tl=gsap.timeline(vars?);tl.to(".a",{x:100,duration:1}).to(".b",{y:50,duration:0.5});`(def:append seq);
  opts:{paused:Bool(`.play()`),repeat:Num,yoyo:Bool,onComplete:Fn,onStart:Fn,onUpdate:Fn,defaults:Obj(inherited by children,e.g.`{duration:0.5,ease:"power2.out"}`)};
  tl_duration:derived from children(¬constructor `duration`)
}
§POS{
  arg3_or_vars.position:abs(`1`=1s)|rel(def):`"+=0.5"`,`"-=0.2"`|label:`"lbl"`,`"lbl+=0.3"`|place:`"<"`(prev start),`">"`(prev end,def),`"<0.2"`(0.2s after prev start);
  ex:`tl.to(".a",{x:100},0).to(".b",{y:50},"+=0.5").to(".c",{opacity:0},"<").to(".d",{scale:2},"<0.2");`
}
§LBL_NEST{
  `tl.addLabel("intro",0);tl.to(".a",{x:100},"intro");tl.addLabel("outro","+=0.5");tl.play("outro");`
  `tl.tweenFromTo("intro","outro")`(pauses tl;returns ease-free Tween animating playhead);
  nest:`master.add(child,0);master.to(".c",{opacity:0},"+=0.2");`
}
§CTRL{`tl.play()|pause()|reverse()|progress(1).reverse()|restart()|time(2)|progress(0.5)|kill()`(kills tl+children by def)}
§R{prefer `gsap.timeline()`+pos_param over `delay` chains;pass `defaults` for shared child props;use `addLabel()`;ST on tl/top-level tween only}
§ANTI{¬chain multi-step w/`delay`;¬omit shared `defaults`;¬expect constructor `duration` to act like tween;¬ST on child tween∨nested ST tl}
