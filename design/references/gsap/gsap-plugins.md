@REF:gsap-plugins
§REL{gsap-core:tweens;gsap-scrolltrigger:ScrollTrigger;gsap-react:React}
§URL{https://gsap.com/docs/v3/Plugins/|https://gsap.com/blog/webflow-GSAP/}

§LIC{
  ∀plugin:FREE(commercial∈true,post_Webflow_acq);¬membership∧¬license_key∧¬auth_token(incl:SplitText,MorphSVGPlugin);
  CMD:npm install gsap;IMP:gsap/<PluginName>(e.g.gsap/SplitText,gsap/MorphSVGPlugin);
  ¬ANTI:{.npmrc+auth_token,npm.greensock.com,Club_GSAP_signup}
}

§REG{
  gsap.registerPlugin(ScrollToPlugin,Flip,Draggable,...);
  REQ:register_once_before_first_tween_or_API;
  React:top_level∨app_init_before_useGSAP(useGSAP∈plugin⇒must_register);¬inside_rerendering_component
}

§SCROLL{
  ScrollToPlugin(gsap/ScrollToPlugin):animate_scroll(window|scrollable_el)∧¬ScrollTrigger;
    vars:{x|y:num|"max",element:sel|el,offsetX|offsetY:px};
    ```js
    gsap.registerPlugin(ScrollToPlugin);
    gsap.to(window,{duration:1,scrollTo:{y:"#section",offsetY:50}});
    gsap.to(scrollEl,{duration:1,scrollTo:{x:"max"}});
    ```
  ScrollSmoother:smooth_native_scroll;REQ:ScrollTrigger∧register_AFTER(ScrollTrigger);
    DOM:`body>#smooth-wrapper>#smooth-content`(position:fixed_els_outside_wrapper)
}

§DOM_UI{
  Flip(gsap/Flip):https://gsap.com/docs/v3/Plugins/Flip;
    flow:const s=Flip.getState(".item")→mutate_DOM(reorder|add|remove|class)→Flip.from(s,{duration:0.5,ease:"power2.inOut"});
    vars:{absolute:bool(def:false,pos_abs_during_flip),nested:bool(1st_lvl_children_only),scale:bool(def:true,avoid_stretch),simple:bool(pos+scale_only,faster/less_accurate),duration,ease};
  Draggable(gsap/Draggable):Draggable.create(sel,{type:"x,y",bounds:"#container",inertia:true});
    vars:{type:"x"|"y"|"x,y"|"rotation"|"scroll",bounds:el|sel|{minX,maxX,minY,maxY},inertia:bool(true⇒req_InertiaPlugin),edgeResistance:0..1,cursor:css,onDragStart|onDrag|onDragEnd:(ev,target),onThrowUpdate|onThrowComplete:fn(inertia_active)};
  InertiaPlugin:gsap.registerPlugin(Draggable,InertiaPlugin);
    track_glide:InertiaPlugin.track(".box","x")→gsap.to(obj,{inertia:{x:"auto"}});
  Observer(gsap/Observer):normalize_pointer_scroll_touch_without_ScrollTrigger;
    ```js
    Observer.create({target:"#area",onUp,onDown,onLeft,onRight,tolerance:10,type:"touch,pointer"});
    ```
    vars:{target:el|sel,onUp|onDown|onLeft|onRight:fn(pass_tolerance),tolerance:px(def:10),type:"touch"|"pointer"|"wheel"(def:"touch,pointer")}
}

§TEXT{
  SplitText(gsap/SplitText):https://gsap.com/docs/v3/Plugins/SplitText/;
    API:SplitText.create(target:sel|el|arr,vars)→{chars,words,lines,masks,revert()};integrates(gsap.context,matchMedia,useGSAP);
    ```js
    const s=SplitText.create(".heading",{type:"words, chars"});
    gsap.from(s.chars,{opacity:0,y:20,stagger:0.03,duration:0.4});
    SplitText.create(".split",{type:"lines",autoSplit:true,onSplit(self){return gsap.from(self.lines,{y:100,opacity:0,stagger:0.05,duration:0.5});}});
    ```
    vars:{
      type:"chars"|"words"|"lines"(comma_sep,def:"chars,words,lines";split_only_needed;chars_only⇒smartWrap:true);
      charsClass|wordsClass|linesClass:str(append"++"⇒1-based_idx,e.g."line++"→line1,line2);
      aria:"auto"(def:aria-label_on_root+aria-hidden_on_units)|"hidden"(hide_all)|"none"(unchanged;pair_w/_sr-only_dup_for_nested_links);
      autoSplit:bool(v3.13.0+:revert+resplit_on_fonts_ready∨width_Δ_if_lines;MUST_create_anims_inside_onSplit∧return_anim_for_cleanup+sync);
      onSplit(self):v3.13.0+_cb_on_split+resplit(returning_tween|tl⇒auto_revert+time_sync);
      mask:"lines"|"words"|"chars"(single_type_only;overflow:clip_wrapper;access:self.masks∨"<class>-mask");
      tag:str(def:"div";"span"_for_inline,caveat:transforms_may_fail_on_inline);
      deepSlice:bool(def:true,subdivide_nested_multiline_els_like_strong_on_lines);
      ignore:sel|el(e.g."sup");smartWrap:bool(def:false,nowrap_word_wrapper_when_chars_only;ignored_if_words|lines);
      wordDelimiter:str(def:" ")|RegExp|{delimiter:RegExp,replaceWith:str}(hashtags/non-Latin);
      prepareText:(text,parent)=>str(pre-split_break_markers_for_spaceless_langs);
      propIndex:bool(CSS_vars:--word:1,--char:2);
      reduceWhiteSpace:bool(def:true;v3.13.0+:honors_newlines+<br>_for_<pre>);
      onRevert:fn
    };
    tips:{wait:document.fonts.ready.then(...)∨autoSplit:true+onSplit;kerning_fix:"font-kerning:none;text-rendering:optimizeSpeed;";¬"text-wrap:balance";¬SVG_<text>};
  ScrambleTextPlugin:gsap.to(".text",{duration:1,scrambleText:{text:"New message",chars:"01",revealDelay:0.5}})
}

§SVG{
  DrawSVGPlugin:https://gsap.com/docs/v3/Plugins/DrawSVGPlugin;
    targets:<path|line|polyline|polygon|rect|ellipse>;animates:stroke-dashoffset/dasharray(¬fill);
    val:visible_segment_"start end"(%|len);current→target("0% 100%"=full,"20% 80%"=mid,0|"100%"≡"0% 100%");
    REQ:visible_stroke+stroke-width(CSS|attr);
    caveats:{prefer_single_segment_path;¬<use>_internals;utils:DrawSVGPlugin.getLength(el),DrawSVGPlugin.getPosition(el)};
    ```js
    gsap.from("#path",{duration:1,drawSVG:0});
    gsap.fromTo("#path",{drawSVG:"0% 0%"},{drawSVG:"0% 100%",duration:1});
    ```
  MorphSVGPlugin:https://gsap.com/docs/v3/Plugins/MorphSVGPlugin;
    targets:<path|polyline|polygon>(converts_<circle|rect|ellipse|line>_internally_or_via_convertToPath);
    morphSVG:sel|el|raw_d|points_str|obj(req:shape);
    ```js
    MorphSVGPlugin.convertToPath("circle, rect, ellipse, line");
    gsap.to("#diamond",{duration:1,morphSVG:{shape:"#lightning",type:"rotational",shapeIndex:2}});
    ```
    obj_vars:{
      shape:sel|el|path_str(REQ);
      type:"linear"(def)|"rotational"(angle/len_interp,avoids_kinks);
      map:"size"(def)|"position"|"complexity"(else_split_paths);
      shapeIndex:int|int[](multi-seg,e.g.[5,1,-8],neg=reverse)|"log"(closed_paths_only;utility:findShapeIndex(start,end));
      smooth:v3.14+_num(e.g.80)|"auto"|{points:40|"auto",redraw:bool(false=keep_orig_anchors),persist:bool(false=strip_added_pts_on_end)};
      curveMode:bool(v3.14+,interp_handle_angle/len_to_avoid_curve_kinks);
      origin:str(def:"50% 50%",or_"20% 60%, 35% 90%"_for_rotational_start/end);
      precision:int(def:2);
      precompile:path_str[]|"log"(<path>_only,skips_startup_calc,¬fixes_mid_tween_jank);
      render:(rawPath,target)=>void(canvas;rawPath=seg[][x,y_cubic_beziers]);
      updateTarget:bool(false_for_canvas_render;default:MorphSVGPlugin.defaultUpdateTarget)
    };
    utils:{convertToPath(sel|el),rawPathToString(rawPath),stringToRawPath(d),stores_orig_d_on_target(morphSVG:"#origId"|same_el)};
  MotionPathPlugin:gsap.to(".dot",{duration:2,motionPath:{path:"#path",align:"#path",alignOrigin:[0.5,0.5],autoRotate:true,curviness:1}});
    vars:{path:el|sel|d,align:el|sel,alignOrigin:[0..1,0..1](def:[0.5,0.5]),autoRotate:bool|num,curviness:0..2};
  MotionPathHelperPlugin:dev_UI;MotionPathHelper.create(".dot","#path",{end:0.5})→helper.path|helper.getProgress()
}

§EASE_PHYS_DEV{
  CustomEase:CustomEase.create("name",".17,.67,.83,.67");
  EasePack:SlowMo,RoughEase,ExpoScaleEase;CustomWiggle;CustomBounce;
  Physics2DPlugin:gsap.to(".ball",{duration:2,physics2D:{velocity:250,angle:80,gravity:500}});
  PhysicsPropsPlugin:gsap.to(".obj",{duration:2,physicsProps:{x:{velocity:100,end:300},y:{velocity:-50,acceleration:200}}});
  GSDevTools:dev_only(¬ship_prod);GSDevTools.create({animation:tl});
  PixiPlugin:gsap.to(sprite,{pixi:{x:200,y:100,scale:1.5},duration:1})
}

§ANTI{
  ¬unregistered_plugin_in_tween_or_API;¬ship_GSDevTools_or_dev_plugins;
  ¬leak_unreverted_instances(call_split.revert()_on_unmount/removal)
}
