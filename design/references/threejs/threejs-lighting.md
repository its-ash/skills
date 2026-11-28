@REF:threejs-lighting
§META{ver:"three.js r187",def_renderer:WebGLRenderer,webgpu_sec:WebGPURenderer}

§PAT{quick_start}
```js
import * as THREE from "three";
const r=new THREE.WebGLRenderer({antialias:true}),s=new THREE.Scene(),c=new THREE.PerspectiveCamera(50,innerWidth/innerHeight,.1,100);
c.position.set(4,3,8);
const dl=new THREE.DirectionalLight(0xffffff,3);dl.position.set(5,10,5);
const fl=new THREE.Mesh(new THREE.PlaneGeometry(20,20),new THREE.MeshStandardMaterial({color:0x808080}));fl.rotation.x=-Math.PI/2;
const m=new THREE.Mesh(new THREE.BoxGeometry(1,1,1),new THREE.MeshStandardMaterial({color:0x3a76c4}));
s.add(dl,fl,m);r.shadowMap.enabled=dl.castShadow=m.castShadow=fl.receiveShadow=true;
r.setAnimationLoop(()=>r.render(s,c));
```

§CFG{light_types}
- `AmbientLight(col,int)`:shadow=∅,unit=mult,flat_fill∀dir
- `HemisphereLight(sky,gnd,int)`:shadow=∅,unit=mult,sky(+Y)∧ground(-Y)
- `DirectionalLight(col,int)`:shadow=✓,unit=mult,parallel(`pos→target`),dist=shadow_cam_only;move(target)⇒`scene.add(l.target)`
- `SunLight(col,int)`[`three/addons/lights/SunLight.js`]:shadow=✓(2_cascades),unit=mult,target=∅(`pos→origin`,down_def),WebGL=auto,WebGPU⇒`renderer.library.addLight(SunLightNode,SunLight)`;cascades_fit=auto_frustum≤`min(sun.shadow.camera.far,cam.far)`,ignores`shadow.camera.{left,right,top,bottom}`,def`mapSize=1024×1024`/cascade
- `PointLight(col,int,dist,decay)`:shadow=✓(6_faces),unit=candela,`decay=2`def(1cd@5u=1/25,typ=80..1000),`distance`=cutoff(`0`=∞),`power`=lumens(sets`intensity`)
- `SpotLight(col,int,dist,angle,penumbra,decay)`:shadow=✓,unit=candela,`decay=2`def,`angle≤Math.PI/2`(half-rad),`penumbra∈[0,1]`,`distance=0`⇒∞,`power`=lumens,move(target)⇒`scene.add(l.target)`
- `RectAreaLight(col,int,w,h)`:shadow=∅,unit=nits(`cd/m²`),lights_ONLY:{`MeshStandardMaterial`,`MeshPhysicalMaterial`},front_face(`lookAt`),WebGL⇒`RectAreaLightUniformsLib.init()`(1×),WebGPU⇒`THREE.RectAreaLightNode.setLTC(RectAreaLightTexturesLib.init())`,`RectAreaLightHelper`⇒`l.add(helper)`(must_be_child)
- `LightProbe`:shadow=∅,unit=mult,SH_ambient(baked)

§PAT{lights_core}
```js
import {SunLight} from "three/addons/lights/SunLight.js";
import {RectAreaLightHelper} from "three/addons/helpers/RectAreaLightHelper.js";
import {RectAreaLightUniformsLib} from "three/addons/lights/RectAreaLightUniformsLib.js";
const sun=new SunLight(0xfff2e3,3);sun.position.set(100,160,60);sun.castShadow=true;
const bulb=new THREE.PointLight(0xffdcb0,100,20,2);bulb.power=800;
const spot=new THREE.SpotLight(0xffffff,250,30,Math.PI/6,.4,2);
RectAreaLightUniformsLib.init();
const rect=new THREE.RectAreaLight(0xffffff,5,4,10);rect.position.set(-5,5,0);rect.lookAt(0,0,0);rect.add(new RectAreaLightHelper(rect));
```

§CFG{shadows}
- Req_3:`renderer.shadowMap.enabled=true`∧`light.castShadow=true`∧`mesh.{castShadow,receiveShadow}=true`
- `renderer.shadowMap.type`:`THREE.PCFShadowMap`(def,soft)|`THREE.VSMShadowMap`(blurs,`shadow.blurSamples`def=8,PointLight_unsupported⇒WebGL_warns∧skips,∀receiver⇒casts)|`THREE.BasicShadowMap`(hard,`shadow.radius`∈∅)|`THREE.PCFSoftShadowMap`(deprecated_r182⇒warns∧fallback→`PCFShadowMap`)
- `shadow.radius>1`:widens PCF∧VSM(¬BasicShadowMap)
- `DirectionalLight.shadow.camera`:at`pos→target`,`near..far`=dist_from_light(casters∈`[near,far]`),`{left,right,top,bottom}`=target_frame;post_1st_render_Δ⇒`shadowCam.updateProjectionMatrix()`;`mapSize`∈2ⁿ;`normalBias=0.02`(grazing_acne);`bias=-0.0001`(depth_acne);`shadow.intensity∈[0,1]`(0=none,1=dark)
- Derived(Point∧Spot):rebuilt_every_pass;Spot`fov=2*angle*shadow.focus`(deg,overwritten),`far=light.distance`(Point∧Spot;manual`far`kept⇔`distance===0`);tune Spot:`angle`∧`shadow.focus`(e.g.`0.9`),range:`distance`
- Debug:`scene.add(new THREE.CameraHelper(light.shadow.camera))`,Δcam⇒`helper.update()`

§PAT{contact_shadows}
- ∅`ContactShadows`class;cheap_blob:radial_gradient`CanvasTexture`(`colorSpace=THREE.SRGBColorSpace`),`MeshBasicMaterial({map,transparent:true,depthWrite:false})`,`PlaneGeometry`,`rotation.x=-Math.PI/2`,`position.y=0.001`(¬z-fight)
- Silhouette:render_depth_below→RT+blur(`HorizontalBlurShader`,`VerticalBlurShader`∈`three/addons/shaders/`,ref`webgl_shadow_contact`)

§R{light_helpers}
- `{Directional,Point,Spot,Hemisphere}LightHelper`:`scene.add(h)`
- Color copied ONLY in`h.update()`;`{Directional,Spot,Hemisphere}LightHelper`re-aim ONLY in`h.update()`⇒call`update()`post color/pos/target Δ

§PAT{ibl_env}
```js
import {HDRLoader} from "three/addons/loaders/HDRLoader.js";
import {RoomEnvironment} from "three/addons/environments/RoomEnvironment.js";
const hdr=await new HDRLoader().loadAsync("sunset.hdr");
hdr.mapping=THREE.EquirectangularReflectionMapping;
scene.environment=scene.background=hdr;
scene.environmentIntensity=1;scene.environmentRotation.set(0,Math.PI/4,0);
scene.backgroundBlurriness=0;scene.backgroundIntensity=1;scene.backgroundRotation.set(0,0,0);
// Generated env ONLY -> PMREMGenerator:
const pmrem=new THREE.PMREMGenerator(r),room=new RoomEnvironment();
scene.environment=pmrem.fromScene(room,.04).texture;room.dispose();pmrem.dispose();
// Cube env (no .mapping needed):
await new THREE.CubeTextureLoader().loadAsync(["px.jpg","nx.jpg","py.jpg","ny.jpg","pz.jpg","nz.jpg"]);
```
- Material_support(`scene.environment`):WebGL={Standard,Physical,Lambert,Phong};WebGPU={Standard,Physical}(¬Lambert,¬Phong)
- Renderers auto-prefilter equirect env⇒¬`pmrem.fromEquirectangular`;r187:`CubeUVReflectionMapping`_removed(`PMREMGenerator`_uses_cube_RTs_directly⇒higher_IBL_fidelity)

§PAT{light_probes}
```js
import {LightProbeGenerator} from "three/addons/lights/LightProbeGenerator.js";
import {LightProbeGridWebGL} from "three/addons/lighting/LightProbeGridWebGL.js";
const cc=new THREE.CubeCamera(.1,100,new THREE.WebGLCubeRenderTarget(256)); // WebGPU:CubeRenderTarget
cc.update(r,s);s.add(await LightProbeGenerator.fromCubeRenderTarget(r,cc.renderTarget)); // sync:fromCubeTexture(cubeTex)
const g=new LightProbeGridWebGL(10,4,10);g.position.set(0,2,0);s.add(g);g.bake(r,s); // WebGPU:LightProbeGrid∈three/addons/lighting/
```

§PAT{setups_and_anim}
- 3-point(`DirectionalLight`):key`(5,6,4)`i=2,fill`(-5,3,5)`i=.5,back`(-4,5,-6)`i=1
- Outdoor:`SunLight(0xfff2e3,3)`@`(100,160,60)`+`castShadow=true`∧`HemisphereLight(0x87ceeb,0x8b6f47,.5)`
- Anim:`const timer=new THREE.Timer();timer.connect(document);`→frame:`timer.update();t=timer.getElapsed();`(`Clock`deprecated r183)

§R{perf}
- Add/rm light(WebGPU:`AmbientLight`only)∨toggle`castShadow`⇒shader_recompile;toggle runtime via`light.intensity`
- WebGPU:`DynamicLighting`(¬recompile for ambient/hemi/dir/point/spot when`castShadow=false`∧¬spot.`map`);`ClusteredLighting`(Forward+ many point lights)
- Shadows add depth passes(6/PointLight);static⇒`l.shadow.autoUpdate=false;l.shadow.needsUpdate=true;`(WebGL also`renderer.shadowMap.autoUpdate`)
- Layers:test light vs camera ONLY(¬per-mesh);per-mesh⇒`material.lightsNode`

§CFG{webgpu_tsl}
```js
import * as THREE from "three/webgpu";import {lights} from "three/tsl";
import {RectAreaLightTexturesLib} from "three/addons/lights/RectAreaLightTexturesLib.js";
import {SunLight} from "three/addons/lights/SunLight.js";import {SunLightNode} from "three/addons/lights/SunLightNode.js";
import {ClusteredLighting} from "three/addons/lighting/ClusteredLighting.js";
const r=new THREE.WebGPURenderer({antialias:true});await r.init(); // MUST precede all renderer calls
scene.background=new THREE.Color(0x101010); // WebGPU canvas transparent def
THREE.RectAreaLightNode.setLTC(RectAreaLightTexturesLib.init());
r.library.addLight(SunLightNode,SunLight);
r.lighting=new ClusteredLighting();
const mat=new THREE.MeshStandardNodeMaterial();mat.lightsNode=lights([keyLight]);
```
- Replacements:`RectAreaLightUniformsLib`→`RectAreaLightTexturesLib`+`RectAreaLightNode.setLTC`,`WebGLCubeRenderTarget`→`CubeRenderTarget`,`LightProbeGridWebGL`→`LightProbeGrid`,`renderer.shadowMap.autoUpdate`→`light.shadow.autoUpdate`,`SunLight`→`addLight(SunLightNode,SunLight)`,`scene.environment`¬Lambert/Phong
- Colored_shadows:`r.shadowMap.transmitted=true`→`mat.castShadowNode`(vec4)∨alpha(`map`∧`colorNode`);`mat.receivedShadowNode`(Fn(shadow))works w/o flag

§ANTI{common_mistakes}
- `light.layers.set(1)`(hides from whole scene if cam≠1)⇒`mat.lightsNode=lights([keyLight,fillLight])`(WebGPU∨WebGLNodesHandler)
- `PointLight(0xffffff,1,100)`(too dim at range,decay=2)⇒`PointLight(0xffffff,100,20)`
- `renderer.useLegacyLights=true`/`physicallyCorrectLights`(removed no-op)⇒retune Point/Spot in candela
- `shadowMap.type=PCFSoftShadowMap`(deprecated r182)⇒`THREE.PCFShadowMap`
- `lightProbe.copy(LightProbeGenerator.fromCubeRenderTarget(...))`(returns Promise)⇒`await LightProbeGenerator.fromCubeRenderTarget(...)`
- `new ContactShadows(...)`(drei-only)⇒radial-gradient`CanvasTexture`on`PlaneGeometry`
- `scene.environment=pmremGenerator.fromEquirectangular(tex).texture`(redundant)⇒`tex.mapping=EquirectangularReflectionMapping;scene.environment=tex`
- `scene.background=hdr`(flat UV quad)⇒`hdr.mapping=EquirectangularReflectionMapping;scene.background=hdr`
- `three/examples/jsm/loaders/RGBELoader.js`(renamed r180,import-map fail)⇒`three/addons/loaders/HDRLoader.js`
- `spotLight.shadow.camera.fov=30`(overwritten every pass)⇒`spotLight.shadow.focus=0.9`+`angle`
- `PointLight(0xffffff,100,20);lamp.shadow.camera.far=50`(overwritten by`distance≠0`)⇒`PointLight(0xffffff,100,50)`(manual`far`kept iff`distance===0`)
- `material.envMapIntensity=0.5`(scales`material.envMap`only)⇒`scene.environmentIntensity=0.5`
- `new THREE.Clock()`(deprecated r183)⇒`new THREE.Timer();timer.connect(document);`+`timer.update()`
- `RectAreaLightUniformsLib.init()`under WebGPU(ignored→null LTC)⇒`THREE.RectAreaLightNode.setLTC(RectAreaLightTexturesLib.init())`

§REL{threejs-materials,threejs-textures,threejs-shaders,threejs-postprocessing,threejs-fundamentals}
