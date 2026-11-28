@REF:threejs-react-three-fiber
§META{three:r187;r3f:9.8.2(React19;v10_alpha=WebGPU_def);react:19(Html_bug:19.2);drei:10.7(verified:10.7.9);default_renderer:WebGLRenderer;webgpu_sec:WebGPURenderer}

§CFG{QuickStart
  <Canvas> owns WebGLRenderer+scene+camera;fills parent⇒parent needs explicit height.
  ```jsx
  import { useRef } from "react";
  import { Canvas, useFrame } from "@react-three/fiber";
  import { OrbitControls } from "@react-three/drei";
  function Box() {
    const ref = useRef();
    useFrame((_, delta) => { ref.current.rotation.y += delta; });
    return <mesh ref={ref} position={[0, 0.5, 0]} castShadow><boxGeometry args={[1, 1, 1]} /><meshStandardMaterial color="#d9915b" /></mesh>;
  }
  export default function App() {
    return (
      <Canvas shadows="percentage" camera={{ position: [3, 2, 4], fov: 50 }}>
        <color attach="background" args={["#111827"]} />
        <ambientLight intensity={0.4} />
        <directionalLight position={[3, 4, 2]} intensity={2} castShadow />
        <Box />
        <mesh rotation-x={-Math.PI / 2} receiveShadow><planeGeometry args={[10, 10]} /><meshStandardMaterial color="#20293a" /></mesh>
        <OrbitControls makeDefault />
      </Canvas>
    );
  }
  ```
}

§CFG{CanvasProps
  camera:PerspectiveCamera(fov=75,near=0.1,far=1000,pos=[0,0,5],lookAt=[0,0,0])|instance;auto-updates aspect(or left/right/top/bottom w/ orthographic)+projectionMatrix on resize;manual:{manual:true}.
  dpr:num|[min,max] clamped to window.devicePixelRatio;tracks display changes.
  shadows:true|"basic"|"percentage"|"variance"|shadowMapObj;true|"soft"|false(default)→PCFSoftShadowMap(deprecated r182⇒swaps to PCFShadowMap+console warn:WebGLRenderer on shadow render,WebGPURenderer on every Canvas);use "percentage" for soft w/o warn.
  flat:NoToneMapping(default=ACESFilmicToneMapping,unlike plain three);linear:LinearSRGBColorSpace(default=sRGB);legacy:disables THREE.ColorManagement.
  gl:WebGLRendererProps(defaults:{canvas,antialias:true,alpha:true,powerPreference:"high-performance"})|rendererInstance|(props)=>renderer|Promise<renderer>.
  frameloop:"always"|"demand"(React Δ or invalidate())|"never"(call module-level advance(sec);useFrame delta=Δtimestamps⇒ms causes 1000x delta!).
  events:custom eventMgr;eventSource:DOM_el(default=Canvas wrapper);eventPrefix:"offset"(default)|"page"|"client"|"layer"|"screen"(scroll/CSS transforms);onCreated:(state)=>void;onPointerMissed:()=>void.
}

§PAT{SceneGraphJSX
  THREE.*→camelCase JSX(<mesh>→THREE.Mesh);shorthand via .set():pos={[1,2,3]}(fromArray)|pos={vec3}(copy)|pos={5}(setScalar)|color="#d9915b";plain obj {x,y,z} throws read-only err.
  pierce:rotation-x,material-color,geometry-attributes-position;attach="material-0" for array index;geometries/materials auto-attach to parent mesh.
  args:constructor args(Δargs⇒full rebuild);onUpdate={(self)=>void}.
  primitive:<primitive object={obj}/>(1 obj/primitive,clone for copies;fiber never disposes);dispose={null} opts element+children out of unmount disposal.
  extend:import { extend } from "@react-three/fiber";extend({ Water });→<water args={[geometry]}/>(required for non-THREE addons e.g. three/addons/*).
  TS_DOM_collisions:{line,audio,source,path}→<threeLine>,<threeAudio>,<threeSource>,<threePath>.
}

§PAT{Hooks
  useFrame((state,delta)=>void,renderPriority?):runs pre-render;renderPriority>0 disables Canvas auto-render⇒must call state.gl.render(state.scene,state.camera)(calling gl.render at priority 0 double-renders).
  useThree(selector?):reactive state{gl,camera,scene,raycaster,pointer,size,viewport,invalidate,setDpr,setFrameloop,controls,performance};inside useFrame read state arg(avoids re-render).
  clock:r3f 9.8 creates state.clock=THREE.Clock(triggers three deprecation warn per Canvas,ignore);read state.clock.elapsedTime(¬getElapsedTime() which mutates getDelta()).
  useLoader(LoaderOrInst,url,extensions?,onProgress?):suspends(needs <Suspense>);caches by loader+url;extensions runs on shared loader instance per class⇒settings persist across calls;useLoader.preload(L,url);useLoader.clear(L,url).
  useGraph(object)→{nodes,materials,meshes}.
}

§PAT{PointerEvents
  raycast:only objects w/ handlers(pointermove tests only move/over/out/enter/leave);nearest-first,bubbles hit→parents.
  event:{object,eventObject,point,distance,face,instanceId,intersections,ray,camera,unprojectedPoint,delta(px since pointerdown),nativeEvent};stopPropagation() blocks deeper hits;event.target.setPointerCapture(id)/releasePointerCapture(id).
  handlers:onClick,onDoubleClick,onContextMenu,onWheel,onPointerUp,onPointerDown,onPointerMove,onPointerOver,onPointerOut,onPointerEnter,onPointerLeave,onPointerMissed(onPointerCancel/onLostPointerCapture typed,never fired).
  CPU_raycaster:works any renderer via intersectObject(obj,true);tune:<Canvas raycaster={{params:{Line:{threshold:0.1}}}}/>.
}

§PAT{LoadingAssets
  all hooks suspend⇒wrap in <Suspense fallback={...}>.
  useGLTF(url):@react-three/drei(three-stdlib GLTFLoader,Draco+meshopt on);Draco pinned gstatic URL(useGLTF.setDecoderPath(p),useGLTF(url,false) disables);useGLTF.preload(url);returns {scene,animations,cameras,nodes,materials,meshes}.
  skinned_clones:useMemo(()=>SkeletonUtils.clone(scene),[scene])(from "three/addons/utils/SkeletonUtils.js")+own <primitive>(¬scene.clone() which shares skeleton).
  useTexture(url|[urls]|{k:url}):auto-sets sRGB on LDR(RGBA8) color props(map,emissiveMap,envMap);scalar maps keep NoColorSpace.
  <Preload all/>:inside <Suspense> after assets;compiles materials once on mount(incl hidden w/ all)& uploads textures via cube target.
  useProgress()→{active,progress,errors}(DefaultLoadingManager store,usable outside <Canvas>).
}

§PAT{DreiHelpers
  OrbitControls:damping on by default;updates pre-callback;calls invalidate() on change(demand-safe);makeDefault→state.controls;regress drops perf during drag;props:{enableDamping,dampingFactor,target,minDistance,maxDistance,maxPolarAngle,autoRotate,autoRotateSpeed}.
  CameraControls:wraps camera-controls(ref methods e.g. fitToBox;updates w/ delta).
  ContactShadows:depth target from below+blur(no shadow-map setup);frames={1} bakes static;props:{position,opacity,scale,blur,far}.
  Environment+Lightformer:<Environment resolution={256} preset|files|map><Lightformer form="circle|ring|rect|box" intensity position scale/></Environment>.
  Text:troika SDF(suspends on font);props:{fontSize,anchorX,anchorY,color,outlineWidth,maxWidth,textAlign,lineHeight,letterSpacing,characters}.
  Html:DOM projection;transform=3D-rotated;occlude={true|"raycast"}(¬anchor inside mesh)|"blending"(WebGL depth ShaderMaterial).Bug(r3f 9.8+drei 10.7+React 19.2):Html mounting same commit/remounting w/ default WebGLRenderer Canvas renders empty⇒pass portal={overlayRef} to fixed overlay <div ref={overlay} style={{position:"absolute",inset:0,pointerEvents:"none"}}/> after Canvas inside position:relative wrapper.
  Center:bbox recenter(top/bottom/left/right/front/back,precise={false},onCentered);measures vertices⇒misplaces Text(unit quad)⇒position Text w/ anchorX/anchorY/position.
  Bounds:fit/clip/observe;useBounds()→{refresh,reset,moveTo,lookAt,fit,clip}.
}

§PAT{Performance
  demand:<Canvas frameloop="demand"/>;React Δ auto-invalidates;imperative Δ(refs/timers) must call invalidate();¬setState in useFrame(mutate refs;rare DOM sync via store|flushSync).
  instancing:<Instances limit={n} castShadow><geom/><mat/>{items.map(<Instance key position color/>)}</Instances>(1 draw call).
  LOD:<Detailed distances={[0,15,40]} hysteresis={0.1}>...</Detailed>(child i active ≥distances[i],first=0).
  adaptive:OrbitControls regress drops performance.current→min(0.5) on drag,restores after 200ms;<AdaptiveDpr pixelated/> sets dpr=performance.current*initialDpr.<PerformanceMonitor onDecline onIncline flipflops={3} onFallback/> samples real FPS via callbacks(¬sets dpr);drive <Canvas dpr={dpr}/> via React state(Canvas re-applies dpr prop on render,overwriting setDpr)∧omit AdaptiveDpr(else drag restores initialDpr over lowered dpr).
  beyond_r3f:cap dpr,KTX2,merge/instance,unmount disposal⇒threejs-performance.
}

§R{Disposal
  auto_disposed(idle on unmount):JSX-created objects,child geometries/materials/textures,gl-prop/factory renderer.
  never_disposed:prop-passed objects(geometry={g},map={t}),<primitive>,dispose={null} subtree.
  passed_gl_instance:not disposed,but fiber forces context loss on unmount(cannot reuse).
  cached_assets:useLoader/useGLTF/useTexture persist across remounts;.clear() only drops cache entry⇒dispose manually;dispose(obj) disposes obj+own props(geom/mat),NOT children⇒traverse manually.
}

§PAT{WebGPU_TSL
  ```jsx
  import * as THREE from "three/webgpu";
  import { color } from "three/tsl";
  import { Canvas, extend } from "@react-three/fiber";
  extend(THREE); // node materials not in default THREE namespace
  <Canvas gl={async (props) => { const r = new THREE.WebGPURenderer(props); await r.init(); return r; }}>
    <mesh><torusKnotGeometry args={[0.8, 0.3, 128, 24]} /><meshBasicNodeMaterial colorNode={color(0x42699c)} /></mesh>
  </Canvas>
  ```
  async_gl:fiber awaits promise inside Canvas before mounting children(outer <Suspense> fallback does NOT show).
  TSL_compile:node materials compile once⇒build nodes in module scope|useMemo & animate via uniform()(new node prop requires material.needsUpdate=true);use Fn,¬GLSL(⇒threejs-shaders).
  tone_mapping:WebGPURenderer tone-maps entire frame incl <color attach="background">⇒renders darker than WebGLRenderer unless flat.
  compat_ok(WebGPU+forceWebGL:true):scene graph,hooks,events(CPU raycast⇒ignores positionNode displacement),useGLTF(auto-converts→node materials),useTexture,Preload,Center,Bounds,Instances,Detailed,OrbitControls,CameraControls,Html(¬occlude="blending"),Environment(preset|map|.hdr),useProgress/AdaptiveDpr/PerformanceMonitor(no renderer API).
  compat_fail:Text(untextured quad;onBeforeCompile),ContactShadows(onBeforeCompile+ShaderMaterial),Html(occlude="blending"),Environment(ground|.jpg/.webp gainmap files:ShaderMaterial),Environment(children:cube camera works on WebGPU,renders black silently on WebGL2 fallback).
}

§ANTI{CommonMistakes
  requestAnimationFrame→useFrame((state,delta)=>...)
  state.clock.getElapsedTime()→state.clock.elapsedTime(avoids getDelta corruption)
  "three/examples/jsm/..."→"three/addons/..."(import-map compat)
  fixed step in useFrame→scale by delta
  setState in useFrame→mutate ref.current
  useFrame(...,1) w/o gl.render→omit priority∨call state.gl.render(state.scene,state.camera)
  position={{x:1,y:0,z:0}}→position={[1,0,0]}|Vector3|scalar
  useEffect+GLTFLoader→useGLTF(url)
  gltf.scene.clone()→useMemo(()=>SkeletonUtils.clone(scene),[scene])
  scene.add(gltf.scene)→<primitive object={gltf.scene}/>
  <water/> w/o extend→extend({Water})
  <line> in TS→<threeLine>(also threeAudio,threeSource,threePath)
  <Canvas shadows>→<Canvas shadows="percentage">(avoids r182 PCFSoftShadowMap warn)
  <directionalLight> w/o castShadow→add castShadow on light+shadows on Canvas
  ref mutation under frameloop="demand"→call invalidate()
  gl={new THREE.WebGPURenderer()}→async gl factory + await r.init()
  new OrbitControls(...)→<OrbitControls makeDefault/>
  <Environment><Lightformer/></Environment> on WebGPURenderer→<Environment files="env.hdr"/>|preset|map
}

§REL{threejs-fundamentals,threejs-loaders,threejs-interaction,threejs-shaders,threejs-performance,threejs-asset-pipeline}
