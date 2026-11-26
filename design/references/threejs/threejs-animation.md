@REF:threejs-animation
§META{target:three.js@r186;renderers:{WebGLRenderer(default),WebGPURenderer(WebGPU/TSL)}}
§ARCH{
  AnimationClip:"stateless keyframe tracks(times,values)";
  AnimationMixer:"1/root→drives root+descendants;CPU_only(identical WebGL|WebGPU)";
  AnimationAction:"playback ctrl for(1_clip,1_mixer);mixer.clipAction(clip) cached/(clip,root)"
}
§PAT{loop_timer:
  ```js
  import * as THREE from "three";
  const timer=new THREE.Timer();timer.connect(document);//caps delta after tab hidden
  function animate(){
    timer.update();//MUST be 1st call/frame
    const dt=timer.getDelta(),t=timer.getElapsed();
    mesh.rotation.y+=dt;mesh.position.y=Math.sin(t*2)*0.25;
    renderer.render(scene,camera);
  }
  renderer.setAnimationLoop(animate);
  ```
}
§API{tracks_clips:
  name_fmt:"[nodeName.][objectName[objectIdx].]propertyName[propIdx]";objectName∈{material,materials,bones,map};
  ex:{".position",".material.opacity",".position[y]",".morphTargetInfluences[smile]","Hips.position"};
  inv:values.length===times.length*valueSize;//fractional⇒play() hangs;other mismatch⇒wrong samples
  AnimationClip:"new THREE.AnimationClip(name,dur_s,tracks) (dur=-1⇒derive from tracks)";
  tracks:{
    NumberKeyframeTrack(1):".material.opacity(req material.transparent=true)|.morphTargetInfluences[k]";
    VectorKeyframeTrack(3):".position([x,y,z,...])";
    QuaternionKeyframeTrack(4):".quaternion([x,y,z,w,...]);¬Euler;id=[0,0,0,1];new THREE.Quaternion().setFromAxisAngle(axis,rad)";
    ColorKeyframeTrack(3):".material.color([r,g,b,...])";
    BooleanKeyframeTrack(1):".visible([true,false]);always discrete"
  };
  interp:"track.setInterpolation(m)":THREE.InterpolateLinear(def)|InterpolateSmooth(cubic)|InterpolateDiscrete(step)|InterpolateBezier(abs(t,v),2/keyframe/comp;stride1_2k⇒4/arr;track.settings={inTangents:[0,0,1,1],outTangents:[0,1,1,0]})
}
§API{mixer_action:
  mixer:"m=new THREE.AnimationMixer(root); m.update(dt); events:{finished:'(e)=>e.action.getClip().name(req LoopOnce|finite reps)',loop}";
  action:{
    ctrl:"play()|reset()(t=0,cancel fades,re-enable after one-shot)|stop()(unschedule,un-animated props revert)|halt(dur_s)";
    props:"time=s|timeScale=n(<0 backward)|paused=bool|clampWhenFinished=true(hold final pose)";
    loop:"setLoop(THREE.LoopOnce,1)|LoopRepeat,Infinity(def)|LoopPingPong,4(alt dir)";
    fade:"crossFadeTo(to,0.4,warpBool)(warp=true matches cycle timeScales) ⊕ (to.reset().fadeIn(0.4).play();from.fadeOut(0.4))(¬both)"
  }
}
§PAT{gltf_skeleton_morph:
  ```js
  import{GLTFLoader}from"three/addons/loaders/GLTFLoader.js";
  import*as SkeletonUtils from"three/addons/utils/SkeletonUtils.js";
  const gltf=await new GLTFLoader().loadAsync("model.glb");//2nd arg=onProgress
  //MeshStandardMaterial is lit⇒add DirectionalLight+HemisphereLight or renders black
  const mixer=new THREE.AnimationMixer(gltf.scene),clip=THREE.AnimationClip.findByName(gltf.animations,"Walk");
  if(clip)mixer.clipAction(clip).play();
  const clone2=SkeletonUtils.clone(gltf.scene),mixer2=new THREE.AnimationMixer(clone2);//own skeleton+mixer,shared clip
  ```
  skeleton:{
    find:"sm=mesh.getObjectByProperty('type','SkinnedMesh'); sm.skeleton.bones.find(b=>b.name==='RightHand')";
    viz:"new THREE.SkeletonHelper(mesh)";
    override:"set bone pose AFTER mixer.update(dt)(update overwrites clip props)";
    attach:"handBone.add(weapon); weapon.position.set(...); //bones are Object3Ds"
  };
  morph:{
    inspect:"Object.keys(mesh.morphTargetDictionary)(name→idx); mesh.morphTargetInfluences[idx]∈[0,1]";
    manual:"arr=geo.attributes.position.array.slice();a=new THREE.Float32BufferAttribute(arr,3);a.name='raised';geo.morphAttributes.position=[a];mesh.updateMorphTargets()";
    drive:"mesh.morphTargetInfluences[0]=w | NumberKeyframeTrack('.morphTargetInfluences[raised]',times,vals)"
  }
}
§PAT{blend_utils_proc:
  weight:"action.setEffectiveWeight(w)∈[0,1]";
  additive:"THREE.AnimationUtils.makeClipAdditive(clip)(rebases frame 0+marks additive)";
  utils:{
    find:"THREE.AnimationClip.findByName(clips,name)";
    subclip:"THREE.AnimationUtils.subclip(clip,name,startF,endF,fps)//[startF,endF) at fps;¬resample";
    clone:"clip.clone()";
    optimize:"clip.optimize()//drops dup-time&neighbor-equal keys on non-smooth tracks;Bezier ¬compacted";
    resetDuration:"clip.resetDuration()//recomputes dur from longest track;¬seek";
    validate:"clip.validate()//false iff fractional values/times,empty track,unsorted times,∨NaN"
  };
  damp:"THREE.MathUtils.damp(cur,target,lambda,dt)//higher lambda=faster;frame-rate indep"
}
§PERF{
  share:"1 AnimationClip set→N mixers";
  cull:"skip mixer.update() for offscreen/inactive(keeps last pose)";
  bounds:"SkinnedMesh.boundingSphere computed once on 1st cull/raycast⇒large disp culls at edge;fix:after mixer.update() run mixer.getRoot().updateMatrixWorld()+sm.computeBoundingSphere()(CPU pass) ∨ sm.frustumCulled=false";
  free:"mixer.stopAllAction(); mixer.uncacheRoot(mesh);"
}
§PAT{webgpu_tsl:
  ```js
  import*as THREE from"three/webgpu";
  import{positionLocal,time,deltaTime,vec3,color,mix,oscSine,oscSquare,oscTriangle,oscSawtooth}from"three/tsl";
  const renderer=new THREE.WebGPURenderer({antialias:true});await renderer.init();//req before any use
  scene.background=new THREE.Color(0x111418);//WebGPU canvas transparent by default
  const mat=new THREE.MeshBasicNodeMaterial();
  mat.positionNode=positionLocal.add(vec3(0,oscSine().mul(0.05),0));//preserves skin/morph/batch/instance;NEVER positionGeometry
  mat.colorNode=mix(color(0x202030),color(0xffd24a),oscSine());//osc* default t=time(1s period);oscSine(time.mul(0.5))⇒2s
  ```
  note:"CPU mixer/bones/morphs unchanged; time(elapsed s)&deltaTime(prev delta s) auto-updated; vertex disp req NodeMaterial+subdivided mesh"
}
§ANTI{mistakes:
  "new THREE.Clock()"⇒"new THREE.Timer()+timer.connect(document) (Clock deprecated r183)";
  "clock.getElapsedTime();clock.getDelta()"⇒"timer.update();timer.getDelta();timer.getElapsed() (getElapsedTime calls getDelta⇒delta≈0,stalls mixer)";
  "requestAnimationFrame(animate)"⇒"renderer.setAnimationLoop(animate) (WebXR handoff+docs)";
  "three/examples/jsm/..."⇒"three/addons/... (examples/jsm fails import map)";
  "values.length≠times.length*valueSize"⇒"exact multiple";
  "StringKeyframeTrack('.morphTargetInfluences[...]')"⇒"NumberKeyframeTrack(...)";
  "bone.rot=...;mixer.update(dt)"⇒"mixer.update(dt);bone.rot=...";
  "clip.resetDuration()"⇒"action.reset()";
  "positionGeometry.add(off)"⇒"positionLocal.add(off)";
  "uniform(0)=timer.getElapsed()"⇒"TSL time node";
  "model.clone()"⇒"SkeletonUtils.clone(model) (shares skeleton)";
  "import{clone}from'.../SkeletonUtils.js'"⇒"import*as SkeletonUtils from'...'";
  "new Promise(loader.load(...))"⇒"await loader.loadAsync(url,onProgress)"
}
§REL{threejs-fundamentals:render loop/Timer/renderer/scene;threejs-loaders:glTF+clips;threejs-shaders:GPU displacement(TSL|ShaderMaterial)}
