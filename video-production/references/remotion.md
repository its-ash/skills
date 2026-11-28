@REF:remotion
§WHEN{remotion|@remotion/*|overlays|lower_thirds|anim_charts|captions|explainers|dyn_dur_dims; docs:"https://www.remotion.dev/docs"; v4.x(Node16+)}
§R{
  1:anim←`useCurrentFrame()` ∧ sec*`fps`(`useVideoConfig()`);
  2:FORBID:{CSS_transitions,CSS_animations,Tailwind `transition-*`|`animate-*`};
  3:3rd_party_anim=OFF(charts,shaders,Lottie,3D) ∧ `useFrame()`(@react-three/fiber)=FORBID;
  4:media(wait_load):`<Img>`(¬`<img>`|Next`<Image>`|CSS`background-image`), `<Video>`+`<Audio>`(`@remotion/media`,Mediabunny-backed), `<AnimatedImage>`(GIF/APNG/AVIF/WebP);
  5:async_wait←`useDelayRender()`(30s_def_timeout;¬raw`delayRender()`_for_browser/cloud_compat);
  6:`public/`←`staticFile()`; remote_URLs⇒CORS;
  7:∀`<Sequence>`⇒`premountFor`;
  8:install←`npx remotion add <pkg>`(bunx|yarn|pnpm exec) ∧ LOCK_EXACT_VERSION(∀`remotion`+`@remotion/*`,¬version_drift);
  9:media_parse←`mediabunny`(¬deprecated`@remotion/media-parser`|`@remotion/webcodecs`)
}
§COMP{
  `src/Root.tsx`:`Folder`(name∈`[A-Za-z0-9-]+`),`Composition`(id,component,durationInFrames,fps,width,height,schema?,defaultProps `satisfies` T),`Still`(id,component,width,height);
  props:`type`(¬`interface`),strict_JSON_object(v4_rejects_non-object;validate_via_Zod`schema`;`Date`,`Map`,`Set`,`staticFile()` OK);
  render:`npx remotion render src/index.ts Promo out.mp4` # agent_skills:`npx remotion skills add`;
  `CalculateMetadataFunction<Props>`:`async({props,abortSignal})=>({durationInFrames?,width?,height?,props?,defaultOutName?,defaultCodec?})` # overrides `<Composition>`, `abortSignal` cancels stale Studio fetches
}
§ANIM{
  `interpolate(frame,[0,2*fps],[0,1],{extrapolateLeft:"clamp",extrapolateRight:"clamp",easing:Easing.inOut(Easing.quad)})` # no default clamp;
  `spring({frame,fps,config,delay,durationInFrames})`:def`{mass:1,damping:10,stiffness:100}`(bounce); presets:{smooth:`{damping:200}`,snappy:`{damping:20,stiffness:200}`,bouncy:`{damping:8}`,heavy:`{damping:15,stiffness:80,mass:2}`}; `delay`=shift,`durationInFrames`=fixed_len; in_out=`inAnim-outAnim`;
  `Easing`:(`in`|`out`|`inOut`)+(`quad`|`sin`|`exp`|`circle`)∨`Easing.bezier(x1,y1,x2,y2)`; def=linear
}
§SEQ{
  `<Sequence from durationInFrames premountFor/>`; `<Series><Series.Sequence durationInFrames offset?/></Series>`;
  abs_fill_wrapper unless `layout="none"`(req in `<ThreeCanvas>`); `useCurrentFrame()`=0-based inside;
  neg `from` trims start(`from={-0.5*fps}`); `durationInFrames` unmounts at end; nest outer `from` to trim+delay; neg `offset` overlaps `<Series>`
}
§TRANS{
  `@remotion/transitions`:`<TransitionSeries>`+`<TransitionSeries.Sequence durationInFrames>`+`<TransitionSeries.Transition presentation timing/>`;
  pres(`@remotion/transitions/*`):`fade()`,`slide({direction:"from-left"|"from-right"|"from-top"|"from-bottom"})`,`wipe()`,`flip()`,`clockWipe()`;
  timing:`linearTiming({durationInFrames:15})`,`springTiming({config:{damping:200}})`;
  len=Σ(scenes)-Σ(trans); `timing.getDurationInFrames({fps})`; `springTiming` w/o `durationInFrames` depends on `fps`
}
§MEDIA{
  `<Img src={staticFile(...)} style/>`;
  `<AnimatedImage src width height fit="fill"|"contain"|"cover" playbackRate loopBehavior="loop"|"pause-after-finish"|"clear-after-finish"/>`;
  `<Video src trimBefore trimAfter volume={(f)=>...} playbackRate muted loop loopVolumeCurveBehavior="repeat"|"extend"/>` # `@remotion/media`+`<OffthreadVideo>`:mixed_sample_rate_sync,muted_skips_heavy_audio_init;
  `<Audio src volume loop toneFrequency/>`;
  notes:`trimBefore`/`trimAfter` in frames; `<Sequence>` delays; multi `<Audio>` layers; `toneFrequency`∈`0.01..2`(pitch w/o speed Δ); `loopVolumeCurveBehavior`:"repeat"(reset/loop)|"extend"(keep counting);
  lottie(`@remotion/lottie`):`const {delayRender,continueRender,cancelRender}=useDelayRender()`→fetch JSON→state→`<Lottie animationData={data}/>`
}
§FONTS_TEXT{
  gfonts:`@remotion/google-fonts/<Font>`:`loadFont("normal",{weights:["400","700"],subsets:["latin"]})`→`{fontFamily,waitUntilDone}` # minimal weights/subsets;
  local:`@remotion/fonts`:`loadFont({family,url:staticFile("font.woff2")})`∨`FontFace`+`staticFile()`;
  typewriter:slice str by frame(¬per-char opacity);
  `@remotion/layout-utils`:`measureText({text,fontFamily,fontSize,fontWeight})`(cached),`fitText({text,withinWidth,fontFamily,fontWeight})`(cap e.g.`Math.min(fontSize,80)`),`fillTextBox()`;
  DOM:divide `getBoundingClientRect()` by `useCurrentScale()`
}
§CAPTIONS{
  stt:{Studio_WebGPU_local,`@remotion/install-whisper-cpp`(local_free),`@remotion/whisper-web`(WASM),`@remotion/openai-whisper`(paid)};
  parse(`@remotion/captions`):fetch `staticFile("subs.srt"|"subs.vtt")` in `useDelayRender()`→`parseSrt({input})`|`parseVtt({input})`;
  presets:`npx remotion elements use`(Basic,Rounded,Moving_Pill,Popping_Word);
  display:`createTikTokStyleCaptions({captions,combineTokensWithinMilliseconds:1200})`(higher=more words/page)→`<Sequence>`(`page.startMs/1000*fps`..next_page)→highlight active token(`fromMs`..`toMs`)
}
§CHARTS_3D_TW{
  charts:HTML/SVG/D3(lib_anim=OFF); bars=`spring({frame,fps,delay:i*5,config:{damping:200}})`; pie=`strokeDashoffset` segmentLen→0+rotate(`-90deg`,12_oclock);
  3D(`@remotion/three`):`<ThreeCanvas width height>`+`<ambientLight>`+`<directionalLight>`+`<mesh rotation={[0,frame*0.02,0]}>`; `<Sequence>` inside req `layout="none"`;
  tailwind:OK if enabled,¬`transition-*`|`animate-*`
}
§MEDIABUNNY{
  replaces_deprecated:`@remotion/media-parser`,`@remotion/webcodecs`;
  `import {Input,ALL_FORMATS,UrlSource,FileSource} from "mediabunny"`(browser/Node/Bun;WebCodecs-native);
  `open(src)`:`new Input({formats:ALL_FORMATS,source:new UrlSource(src,{getRetryDelay:()=>null})})` # `UrlSource`=URLs/`staticFile()`,`FileSource`=`File`;
  `getMediaMetadata`:`input.computeDuration()`(video&audio)+`track=await input.getPrimaryVideoTrack()`→`{displayWidth,displayHeight}`;
  `canDecode`:`await input.getFormat()`(try/catch→false)∧`v.canDecode()`∧`a.canDecode()`;
  thumbs:`VideoSampleSink(primaryVideoTrack)`→iterate timestamps→close each `VideoSample`
}
§ANTI{¬CSS_transitions|Tailwind`animate-*`; ¬`useFrame()`; ¬raw`delayRender()`(use`useDelayRender()`); ¬`@remotion/media-parser`|`@remotion/webcodecs`; ¬pkg_version_mismatch; ¬unclamped`interpolate`; ¬non-object`inputProps`; ¬legacy_Lambda_x86}
