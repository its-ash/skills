@REF:gsap-performance
§SCOPE{use:60fps|layout_paint_opt|jank_fix;rel:{gsap-core:transforms+autoAlpha,gsap-timeline:seq,gsap-scrolltrigger:scroll}}
§PROPS{
  compositor:[x,y,scale,scaleX,scaleY,rotation,rotationX,rotationY,skewX,skewY,opacity];// x/y=translate
  avoid_layout:[width,height,top,left,margin,padding];
  layer_hint:`will-change: transform;`_ONLY_on_animating_elems(¬blanket_will-change∨force3D)
}
§BATCH_SCALE{
  dom_io:GSAP_batches_writes;mixed_DOM_IO⇒reads_first_then_writes(¬layout_thrash);
  lists:{prefer_stagger_over_manual_delay_tweens,long_lists⇒virtualize∨visible_only,reuse_timelines(¬new_per_frame),test_100s_tweens_on_low_end};
  quickTo:```js
let xTo=gsap.quickTo("#id","x",{duration:0.4,ease:"power3"}),yTo=gsap.quickTo("#id","y",{duration:0.4,ease:"power3"});
el.addEventListener("mousemove",e=>{xTo(e.pageX);yTo(e.pageY);});// reuses single tween
```
}
§SCROLL_WORK{
  st:{`pin:true`_promotes_layer⇒pin_min_needed,small_`scrub`(e.g.`scrub:1`)_cuts_work(test_low_end),`ScrollTrigger.refresh()`_ONLY_on_layout_Δ(debounced,¬every_resize)};
  work:{pause∨kill_offscreen/inactive(nav_away),¬huge_prop_counts_on_many_elems⇒simplify∨seq}
}
§ANTI{
  ¬animate(width,height,top,left)_when(x,y,scale)_suffice;
  ¬blanket(will-change,force3D);
  ¬100s_overlapping_tweens/ST_without_low-end_test;
  ¬skip_cleanup(stray_tweens/ST_hurt_perf+correctness)
}
