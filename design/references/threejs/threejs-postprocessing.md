@REF:threejs-postprocessing
meta:{target:three@r186;webgl:EffectComposer|renderer.setEffects;webgpu:RenderPipeline+TSL}

§IMP{
  webgl_core:three;
  pp:three/addons/postprocessing/{EffectComposer,RenderPass,UnrealBloomPass,OutputPass,SMAAPass,FXAAPass,ShaderPass,BokehPass,SSAOPass,OutlinePass,FilmPass,GlitchPass,HalftonePass,RenderPixelatedPass}.js;
  sh:three/addons/shaders/{VignetteShader,ColorCorrectionShader}.js;
  webgpu:three/webgpu;
  tsl:three/tsl/{pass,mrt,renderOutput,normalView,screenUV,builtinAOContext,sin,time,vec2,emissive,output};
  tsl_fx:three/addons/tsl/display/{BloomNode:bloom,DepthOfFieldNode:dof,FXAANode:fxaa,GTAONode:ao}.js
}

§ORD{
  buf:linear;
  chain:RenderPass(scene,cam)→linear_fx(UnrealBloomPass,BokehPass,SSAOPass,OutlinePass,FilmPass,GlitchPass,HalftonePass,ShaderPass,SMAAPass)→OutputPass→[FXAAPass];
  OutputPass:applies renderer.toneMapping+exposure+outputColorSpace once;last_unless(FXAAPass);
  FXAAPass:needs sRGB⇒after OutputPass;SMAAPass:linear⇒before OutputPass;
  SSAOPass:darkens prev_pass⇒requires preceding RenderPass;
  RenderPixelatedPass:renders scene⇒replaces RenderPass;
  toggle:pass.enabled=false(skip w/o rebuild)
}

§CMP{
  ctor:new EffectComposer(renderer[,rt]);
  dpr:copies renderer.getPixelRatio() at ctor⇒call renderer.setPixelRatio(devicePixelRatio) before ctor ∨ composer.setPixelRatio() after;
  msaa:composer bufs ¬multisampled(renderer antialias:true ignored)⇒pass rt:new THREE.WebGLRenderTarget(w,h,{type:THREE.HalfFloatType,samples:4}) then composer.setSize(w,h)(scales by dpr);
  resize:camera.aspect=w/h;camera.updateProjectionMatrix();renderer.setSize(w,h);composer.setSize(w,h);¬resize pass manually;
  loop:renderer.setAnimationLoop(fn)→composer.render([deltaSec]);// internal timer drives FilmPass unless delta passed;
  offscreen:composer assigns renderToScreen to last enabled pass every frame⇒set composer.renderToScreen=false(not pass.renderToScreen)
}

§PASS{
  UnrealBloomPass:"new UnrealBloomPass(new THREE.Vector2(w,h),1.5,0.4,0.85)";// .strength,.radius,.threshold(luminance cutoff);addPass resizes to composer size;resolution read only in ctor⇒resize via composer.setSize;
  SMAAPass:"new SMAAPass()";// no size args(removed r175);composer sizes;
  FXAAPass:"new FXAAPass()";// sets resolution from composer size*dpr;
  BokehPass:"new BokehPass(scene,cam,{focus:10.0,aperture:0.025,maxblur:0.01})";// focus=view-space depth(world units);refocus:bokehPass.uniforms.focus.value=cam.position.distanceTo(mesh.position);
  SSAOPass:"new SSAOPass(scene,cam,w,h)";// .kernelRadius=16,.minDistance=0.005,.maxDistance=0.1;debug:.output=SSAOPass.OUTPUT.{SSAO,Blur,Depth,Normal};
  OutlinePass:"new OutlinePass(new THREE.Vector2(w,h),scene,cam)";// .selectedObjects=[mesh],.edgeStrength=3,.visibleEdgeColor.set(0xffffff),.hiddenEdgeColor.set(0x190a05);
  FilmPass:"new FilmPass(0.35,false)";// (intensity,grayscale);no scanline args;
  GlitchPass:"new GlitchPass()";// .goWild=true(every frame)∨false(default random);
  HalftonePass:"new HalftonePass({shape:1,radius:4,scatter:0,greyscale:false})";// width/height removed r175;shape:1=dot,2=ellipse,3=line,4=square,5=diamond;
  Vignette:"new ShaderPass(VignetteShader)";// .uniforms.{offset,darkness}.value=1.0;
  ColorCorrection:"new ShaderPass(ColorCorrectionShader)";// uniforms:powRGB/mulRGB/addRGB;default powRGB=(2,2,2) darkens⇒neutral=(1,1,1);
  RenderPixelatedPass:"new RenderPixelatedPass(6,scene,cam)";// pixelSize=6,.normalEdgeStrength=0.3,.depthEdgeStrength=0.4
}

§CUSTOM{
  gl_shader:"{uniforms:{tDiffuse:{value:null},time:{value:0},intensity:{value:1.0}},vertexShader:vUv=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);,fragmentShader:vec2 uv=vUv;uv.x+=sin(uv.y*10.0+time)*0.01*intensity;gl_FragColor=texture2D(tDiffuse,uv);}";
  pass:"new ShaderPass(WaveShader)";// tDiffuse receives prev pass;place before OutputPass(linear)∨after(sRGB);
  timer:"const timer=new THREE.Timer();timer.connect(document);";// in loop:timer.update();pass.uniforms.time.value=timer.getElapsed();(Clock deprecated r183)
}

§SEL_BLOOM{
  layers:BLOOM_LAYER=1;bloomLayer=new THREE.Layers();bloomLayer.set(1);mesh.layers.enable(1);// ¬.set()(removes layer 0);
  dark:"darkMat=new THREE.MeshBasicMaterial({color:0x000000});materials=new Map()";
  bloomComposer:renderToScreen=false;passes:[RenderPass,UnrealBloomPass];
  finalComposer:passes:[RenderPass,ShaderPass(ShaderMaterial({uniforms:{baseTexture:{value:null},bloomTexture:{value:bloomComposer.renderTarget2.texture}},frag:"gl_FragColor=texture2D(baseTexture,vUv)+texture2D(bloomTexture,vUv);"}),"baseTexture"),OutputPass];
  frame:"bg=scene.background;scene.background=null;scene.traverse(darkenNonBloomed);bloomComposer.render();scene.traverse(restoreMaterial);scene.background=bg;finalComposer.render()";// darken:if(o.isMesh&&!bloomLayer.test(o.layers)){materials.set(o,o.material);o.material=darkMat;}
  resize:setSize(w,h) on both composers
}

§BUILTIN{
  init:"new THREE.WebGLRenderer({antialias:true,outputBufferType:THREE.HalfFloatType})";// requires HalfFloatType∨FloatType(default logs err+skips fx);
  run:"renderer.setEffects([bloomPass]);/* loop: */renderer.render(scene,cam);";
  rules:{auto_tonemap_srgb:true;¬OutputPass(warns+double-applies);¬FXAAPass(gets linear);aa_via:antialias:true;resize_via:renderer.setSize;no_delta_time:FilmPass time=NaN(grain lost)⇒use EffectComposer}
}

§WEBGPU{
  init:"const r=new THREE.WebGPURenderer({antialias:true});await r.init();scene.background=new THREE.Color(0x111111);";// canvas transparent by default;renderAsync deprecated r181⇒sync renderPipeline.render();
  pipe:"const rp=new THREE.RenderPipeline(r);const sp=pass(scene,cam);const col=sp.getTextureNode('output');";// renamed from PostProcessing r183(old name warns);
  sizing:pass() inherits renderer MSAA∧follows renderer.setSize()(no rp resize);
  node_types:{
    additive_or_mask:{
      bloom:"rp.outputNode=col.add(bloom(col,1.5,0.4,0.85))",// returns glow only;
      sel_bloom:"sp.setMRT(mrt({output,emissive}));rp.outputNode=col.add(bloom(sp.getTextureNode('emissive')))",// no layer trick;
      outline:"outline(scene,cam,{selectedObjects})",// returns .visibleEdge,.hiddenEdge masks→color+add to col;
      ssao:"ssao(depthNode,normalNode,cam)"// returns occlusion in .r→multiply col
    };
    filters_replace_output:{
      list:[dof(col,sp.getViewZNode(),4.5,1.2,2.5),film,rgbShift,chromaticAberration,afterImage,dotScreen,lut3D,smaa(linear),pixelationPass(scene,cam,6),traa],
      traa_req:velocity MRT∧renderer w/o antialias
    };
    srgb_fx:"rp.outputColorTransform=false;rp.outputNode=fxaa(renderOutput(dofNode));";
    live_update:"rp.needsUpdate=true;"// required after frame 1 if outputNode∨outputColorTransform changes
  };
  ao_gtao:"const pre=pass(scene,cam,{samples:0});pre.setMRT(mrt({output:normalView}));const aoP=ao(pre.getTextureNode('depth'),pre.getTextureNode(),cam);sp.contextNode=builtinAOContext(aoP.getTextureNode().sample(screenUV).r);rp.outputNode=sp;";// ao() requires samples:0;distanceExponent∧distanceFallOff deprecated r186(no-op)⇒tune aoP.radius.value∧scale;
  custom_tsl:"const off=vec2(sin(screenUV.y.mul(10).add(time)).mul(0.01),0);rp.outputNode=col.sample(screenUV.add(off));"
}

§ANTI{
  examples/jsm/postprocessing/*→addons/postprocessing/*;
  ShaderPass(GammaCorrectionShader)→OutputPass(GammaCorrection only applies sRGB,skips toneMapping+exposure);
  omit OutputPass after bloom→linear/un-tonemapped output;
  FXAAPass→OutputPass→OutputPass→FXAAPass(FXAA needs sRGB);
  ShaderPass(FXAAShader)→FXAAPass(handles dpr*size);
  FilmPass(0.35,0.5,648,false)→FilmPass(0.35,false);
  HalftonePass(w,h,params)→HalftonePass(params)(r175);
  SMAAPass(w,h)→SMAAPass()(r175);
  UnrealBloomPass(vec2(w/2,h/2),...)→vec2(w,h)(addPass overwrites half-res);
  bloomPass.resolution.set(w,h)→composer.setSize(w,h);
  bloomPass.renderToScreen=false→bloomComposer.renderToScreen=false;
  requestAnimationFrame(animate)→renderer.setAnimationLoop(animate)(WebXR);
  clock.getElapsedTime()→THREE.Timer().getElapsed()(Clock deprecated r183);
  composer.render();renderer.render()→2nd clears canvas⇒2 composers for selective bloom;
  setEffects w/o outputBufferType:HalfFloatType|FloatType→error+no fx;
  setEffects([bloom,OutputPass,FXAAPass])→setEffects([bloom]);
  import{bloom}from"three/tsl"→three/addons/tsl/display/BloomNode.js;
  new THREE.PostProcessing(r)→new THREE.RenderPipeline(r)(r183);
  rp.outputNode=bloom(col)→col.add(bloom(col));
  rp.outputNode=fxaa(col)→rp.outputColorTransform=false;rp.outputNode=fxaa(renderOutput(sp));
  rp.outputNode=col.add(dof(...))→rp.outputNode=dof(...)(draws twice);
  await rp.renderAsync()→await renderer.init() then rp.render()(r181);
  aoPass.distanceFallOff.value=2→aoPass.radius.value=0.2(r186);
  new EffectComposer(webgpuRenderer)→new THREE.RenderPipeline(webgpuRenderer)
}

§REL{
  threejs-fundamentals:renderer,sizing,color_spaces,animation_loop;
  threejs-shaders:GLSL_ShaderMaterial,TSL_nodes;
  threejs-textures:render_targets,postprocessed_tex
}
