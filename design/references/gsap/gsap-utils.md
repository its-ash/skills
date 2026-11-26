@REF:gsap-utils
§REL{gsap-core;gsap-timeline;gsap-scrolltrigger;gsap-plugins:CustomEase/eases}
§WHEN{math|array/DOM_collections|unit_parsing|value_mapping/random/snap in anims∨callbacks}
§CORE{
  pure_helpers on `gsap.utils`(no registerPlugin needed);
  currying:omit last `value` arg⇒returns reusable `(v)=>res` fn(for scroll/mousemove/tween cb);
  EXCEPTION:`random()` requires `true` as last `returnFunction` arg(¬omit)
}
§RANGE{
  `clamp(min,max,val?)`→[min,max];
  `mapRange(inMin,inMax,outMin,outMax,val?)`→mapped Num(e.g.progress 0..1→0..360);
  `normalize(min,max,val?)`→0..1;
  `interpolate(start,end,progress?)`→Num|Color|Obj(matching keys;progress 0..1)
}
§RAND_SNAP{
  `random(min,max[,snapInc,returnFn])`|`random(arr[,returnFn])`:
  immediate:`random(-100,100)`,`random(0,500,5)`,`random(["red","blue","green"])`;
  fn_form:`random(-200,500,10,true)`→`fn()`;`random([0,100,200],true)`→`fn()`;
  tween_str:`{x:"random(-100, 100, 5)"}`,`{backgroundColor:"random([red, blue, green])"}`(evaluated per target);
  doc:https://gsap.com/docs/v3/GSAP/UtilityMethods/random()
  `snap(snapTo,val?)`:nearest multiple of Num `snapTo`∨nearest item in `Arr`(e.g.`snap([0,100,200],150)`);tween var `snap:{x:20}`;
  `shuffle(arr)`→new shuffled copy;
  `distribute(cfg)`→`(idx,target,targets)=>val`(pass directly to tween prop∨call manually):
  cfg(all_opt):{base:Num(def 0),amount:Num(total across all),each:Num(step/target),from:Num|Str|Arr(idx|"start"|"center"|"edges"|"random"|"end"|[xRatio,yRatio],def 0),grid:[rows,cols]|"auto",axis:"x"|"y",ease:Ease(def "none")};
  ex:`gsap.to(".class",{scale:gsap.utils.distribute({base:0.5,amount:2.5,from:"center"})});`
  doc:https://gsap.com/docs/v3/GSAP/UtilityMethods/distribute/
}
§UNIT_COLOR{
  `getUnit(val)`→`"px"|"%"|"deg"|""`(unitless→`""`);
  `unitize(val,unit)`→appends `unit` if unitless else unchanged(`unitize("2rem","px")==="2rem"`);
  `splitColor(color,returnHSL?)`:
  supports `rgb()`,`rgba()`,`hsl()`,`hsla()`,hex,named;
  def→`[r,g,b]`|`[r,g,b,a]`(0..255);`returnHSL=true`→`[h,s,l]`|`[h,s,l,a]`;
  doc:https://gsap.com/docs/v3/GSAP/UtilityMethods/splitColor/
}
§ARR_PIPE{
  `selector(scope)`→scoped query fn accepting Element∨React ref(`.current`),returns `El[]`;
  `toArray(val,scope?)`→`El[]` from selector(scoped)|NodeList|HTMLCollection|Element|Array;
  `pipe(...fns)`→left→right compose `pipe(f1,f2,f3)(v)`=`f3(f2(f1(v)))`;
  `wrap(min,max,val?)`→wraps into `[min,max)`(incl min,excl max);
  `wrapYoyo(min,max,val?)`→bounces back-and-forth within `[min,max]`
}
§R{
  1:omit `value` arg(or pass `true` for `random`) when reusing config in hot callbacks;
  2:use `selector(scope)` in components;use `toArray` for mixed DOM targets;
  3:use `snap` for grid/step values
}
§ANTI{
  ¬assume `mapRange`/`normalize` preserve CSS units(numeric only⇒pair with `getUnit`/`unitize`);
  ¬rely on undocumented API behavior
}
§DOC:https://gsap.com/docs/v3/HelperFunctions
