@REF:threejs-fundamentals
§META{r186;def:WebGLRenderer;webgpu_tsl:WebGPURenderer}

§PAT{quickstart_webgl
```js
import * as THREE from "three";
const r=new THREE.WebGLRenderer({antialias:true});
r.setPixelRatio(devicePixelRatio);r.setSize(innerWidth,innerHeight);
document.body.appendChild(r.domElement);
const s=new THREE.Scene();s.background=new THREE.Color(0x111318);
const c=new THREE.PerspectiveCamera(75,innerWidth/innerHeight,0.1,1000);c.position.set(0,1.5,5);
const cube=new THREE.Mesh(new THREE.BoxGeometry(1,1,1),new THREE.MeshStandardMaterial({color:0x3a86ff}));
const l=new THREE.DirectionalLight(0xffffff,2);l.position.set(3,4,5);
s.add(cube,l,new THREE.AmbientLight(0xffffff,0.4));
const t=new THREE.Timer();t.connect(document);
r.setAnimationLoop(()=>{t.update();cube.rotation.y+=t.getDelta();r.render(s,c);});
addEventListener("resize",()=>{c.aspect=innerWidth/innerHeight;c.updateProjectionMatrix();r.setSize(innerWidth,innerHeight);});
```}

§CFG{importmaps
  `<script type="importmap">`:
  webgl:`{"imports":{"three":"https://cdn.jsdelivr.net/npm/three@0.186.0/build/three.module.js","three/addons/":"https://cdn.jsdelivr.net/npm/three@0.186.0/examples/jsm/"}}`
  webgpu(∀4_keys_req;`three.tsl.js` imports `three/webgpu`):`{"imports":{"three":"https://cdn.jsdelivr.net/npm/three@0.186.0/build/three.webgpu.js","three/webgpu":"https://cdn.jsdelivr.net/npm/three@0.186.0/build/three.webgpu.js","three/tsl":"https://cdn.jsdelivr.net/npm/three@0.186.0/build/three.tsl.js","three/addons/":"https://cdn.jsdelivr.net/npm/three@0.186.0/examples/jsm/"}}`
}

§API{scene
  `background`∈{`Color`,`CubeTexture`,`Texture(mapping=THREE.EquirectangularReflectionMapping)`};unmapped_`Texture`⇒flat_quad(¬skybox)
  `fog`∈{`Fog(0x111318,1,100)`(linear:near,far),`FogExp2(0x111318,0.02)`(exp:density)}
  `environment`→lights{`MeshStandardMaterial`,`MeshPhysicalMaterial`}@both∧{`MeshLambertMaterial`,`MeshPhongMaterial`}@WebGL_only;HDR⇒`threejs-loaders`
  `scene.environmentIntensity`→scales_`scene.environment`;`mat.envMapIntensity`→scales_`mat.envMap`_only
}

§API{cameras
  `PerspectiveCamera(fovDeg,aspect,near,far)`:`lookAt(x,y,z)`;Δ{`fov`,`aspect`,`near`,`far`}⇒`updateProjectionMatrix()`
  `OrthographicCamera(l,r,t,b,near,far)`(world_units:`(-fh*aspect)/2,(fh*aspect)/2,fh/2,-fh/2,0.1,1000`);resize⇒recompute_`l`/`r`+`updateProjectionMatrix()`
  `ArrayCamera(cams[])`:1_render/subCam→`sub.viewport=Vector4(x,y,w,h)`;units:WebGL=`CSS*dpr`(buf_px),WebGPU=`CSS_px`(auto-scaled);subCams∉scene_graph⇒`sub.updateMatrixWorld()`_on_move;cull:WebGL_uses_`arrayCam.frustum`(def:`fov=50,aspect=1`),WebGPU_uses_each_`sub.frustum`
  `CubeCamera(near,far,rt)`:WebGL=`new THREE.WebGLCubeRenderTarget(256)`→`CubeCamera(0.1,1000,rt)`;WebGPU=`CubeRenderTarget`∈`"three/webgpu"`;frame:`mesh.visible=false;cubeCam.position.copy(mesh.position);cubeCam.update(r,s);mesh.visible=true`(else_self-reflection_in_envMap)
}

§API{webgl_renderer
  `new THREE.WebGLRenderer({canvas?,antialias:true/*MSAA*/,alpha:true,stencil:true/*def:false*/,powerPreference:"high-performance",preserveDrawingBuffer:true/*readPixels/screenshots*/})`
  `setPixelRatio(Math.min(devicePixelRatio,2))`(cap_hiDPI);`setSize(w,h)`;`setClearColor(0x000000,0)`(alpha=0_for_`alpha:true`)
  `toneMapping`∈{`NoToneMapping`(def),`ACESFilmicToneMapping`,`AgXToneMapping`,`NeutralToneMapping`};`toneMappingExposure=1.0`;`outputColorSpace=THREE.SRGBColorSpace`(def)
  `shadowMap.enabled=true`;`shadowMap.type`∈{`PCFShadowMap`(def,soft),`VSMShadowMap`,`BasicShadowMap`}
}

§API{objects
  `Object3D`(base:`Mesh`,`Group`,`Light`,`Camera`):
    local:`position.set(x,y,z)`,`rotation.set(rx,ry,rz)`(Euler_rad,synced↔`quaternion`),`quaternion.setFromAxisAngle(axisV3,rad)`,`scale.set(x,y,z)`
    world(out_arg):`getWorldPosition(v3)`,`getWorldQuaternion(q)`,`getWorldDirection(v3)`(`+Z`;cam=`-Z`)
    tree:`add(c)`(reparents,keeps_local),`attach(c)`(reparents,keeps_world),`remove(c)`,`visible=false`(hides_subtree)
    layers:`layers.enable(1)`(+L1;`set(1)`_drops_L0),`disable(1)`,`test(cam.layers)`;`traverse(fn)`(self+descendants)
    matrix:`matrixAutoUpdate=true`(def);`false`⇒`updateMatrix()`(composes+flags_world_dirty);direct_`matrix`_write⇒`matrixWorldNeedsUpdate=true`
  `Group`:`Object3D`_container
  `Mesh(geo,mat|mats[])`:1_mat/geo_group(`BoxGeometry`=6:`+x,-x,+y,-y,+z,-z`;missing_`materialIndex`⇒skipped);`castShadow`,`receiveShadow`,`frustumCulled=true`(def,sphere),`renderOrder=10`(later_in_transparency_bucket)
  coords:RHR,`+Y`_up(`+X`_right,`+Z`_viewer,def_cam→`-Z`);`AxesHelper(5)`(R=X,G=Y,B=Z)
}

§API{math
  `Vector3`:`clone()`,`copy(b)`,`add(b)`,`sub(b)`,`multiplyScalar(s)`,`divideScalar(s)`,`lerp(b,t)`,`normalize()`,`negate()`,`cross(b)`(in-place,RHR),`length()`,`lengthSq()`,`distanceTo(b)`,`dot(b)`(`>0`same,`<0`opp,`0`perp),`angleTo(b)`(rad),`applyQuaternion(q)`,`applyMatrix4(m)`,`project(cam)`(world→NDC),`unproject(cam)`(NDC→world)
  `Matrix4`:`identity()`,`makeTranslation(x,y,z)`,`makeRotationY(rad)`,`makeScale(x,y,z)`,`compose(p,q,s)`,`decompose(p,q,s)`,`multiply(o)`(`m=m*o`,o_1st),`premultiply(o)`(`m=o*m`),`invert()`,`lookAt(eye,target,up)`
  `Quaternion`:`setFromEuler(Euler(x,y,z,"YXZ"))`(def:`"XYZ"`),`setFromAxisAngle(axis,rad)`,`setFromRotationMatrix(m)`,`slerp(q2,t)`(in-place),`invert()`
  `Color`:`Color(0xff0000|"#87ceeb"|"rgb(255, 0, 0)"|name)`;`setHex(h)`,`setRGB(r,g,b[,SRGBColorSpace])`(0–1_linear_unless_cs;hex/CSS=sRGB;`setRGB(1,128/255,0,SRGBColorSpace)`≡`0xff8000`),`setHSL(h,s,l[,cs])`(0–1_linear_unless_cs),`lerp(c,t)`,`multiplyScalar(s)`
  `MathUtils`:`clamp(x,min,max)`,`lerp(a,b,t)`,`mapLinear(x,a1,a2,b1,b2)`,`degToRad(d)`,`radToDeg(r)`,`randFloat(min,max)`,`smoothstep(x,min,max)`
}

§API{loading_cleanup
  `LoadingManager`:`onStart(url,loaded,total)`,`onProgress(url,loaded,total)`,`onLoad()`,`onError(url)`→`new *Loader(mgr)`
  cleanup(when_unshared):`scene.remove(m);m.geometry.dispose();∀mat∈(Array.isArray(m.material)?m.material:[m.material]){∀v∈Object.values(mat)if(v?.isTexture)v.dispose();mat.dispose()}m.dispose()`
  notes:`mat.dispose()`_keeps_textures;`Object3D.dispose()`_frees_per-obj_renderer_state_only(WebGPU_bindings/WebGL_instanced_bufs,¬children/geo/mat/tex⇒`traverse`;override⇒`super.dispose()`);`timer.dispose()`;`r.setAnimationLoop(null);r.dispose()`(ctx_alive);`r.forceContextLoss()`(ctx_freed)
}

§R{perf
  cull:boundingSphere(¬box):`geo.boundingSphere`(Mesh)|`obj.boundingSphere`(`InstancedMesh`,`SkinnedMesh`,`BatchedMesh`);computed_once⇒`geo.computeBoundingSphere()`_post_pos_edit∧`obj.computeBoundingSphere()`_post_far_instance/bone_move
  batch:`import * as BufferGeometryUtils from "three/addons/utils/BufferGeometryUtils.js";mergeGeometries([...])`(matching_attrs_req);many_copies⇒`InstancedMesh`(`threejs-geometry`)
  `LOD`:`lod.addLevel(mesh,0|20|60)`;auto_`update(cam)`/frame
  stats(WebGL):`r.info.render.calls`(multi-pass⇒`autoReset=false`+`reset()`_1×/frame);`r.info.memory`(live_geos,textures)
}

§API{webgpu_tsl
  `import * as THREE from "three/webgpu";const r=new THREE.WebGPURenderer({antialias:true});await r.init();`(canvas_transparent_by_def⇒set_`scene.background`)
  `render()`_throws_pre-`init()`;`await init()`_immediately_post-ctor_before_setup(WebGL2_fallback_replaces_`r.backend`_during_`init()`)
  fallback:auto_WebGL2;`{forceWebGL:true}`;`r.backend.isWebGPUBackend`(post-`init()`)
  mats:built-in_auto-convert_to_node;`*NodeMaterial`(e.g.`MeshStandardNodeMaterial`)_for_node_slots
  WebGL_nodes:`WebGLNodesHandler`(`three/addons/tsl/WebGLNodesHandler.js`→`r.setNodesHandler()`),migration_aid(¬VSM,¬MRT,¬transmission,¬WebGPU_postproc);`ShaderMaterial`/`onBeforeCompile`=WebGL_only(`threejs-shaders`)
  no_`r.capabilities`⇒`r.getMaxAnisotropy()`;readback:`await r.getArrayBufferAsync(attr)`
}

§ANTI{mistakes
  `shadowMap.type=PCFSoftShadowMap`→`PCFShadowMap`(depr_r182;warns+fallback,already_soft)
  `new Clock()`→`new Timer();t.connect(document)`(depr_r183;`t.update()`_1st/frame_before_`getDelta`/`getElapsed`)
  `requestAnimationFrame(fn)`→`r.setAnimationLoop(fn)`(WebXR+WebGPU_init)
  `sub.viewport=Vector4(0,0,0.5,0.5)`→`Vector4(x*dpr,y*dpr,w*dpr,h*dpr)`(WebGL_buf_px;WebGPU_auto-scales_CSS_px;fractions_draw_∅)
  `cubeCam.update(r,s)`_w/visible_mesh→hide_mesh_during_`update()`
  `scene.background=tex`→`tex.mapping=EquirectangularReflectionMapping`(else_flat_quad)
  `"three/examples/jsm/..."`→`"three/addons/..."`(importmap_fails_on_`examples/jsm`)
  `<script src="three.min.js">`→`<script type="module">import * as THREE from "three";</script>`(`build/three{.min}.js`_removed_r161)
  `layers.set(1)`→`layers.enable(1)`(`set`_drops_L0_cam/lights)
  `r.outputEncoding=sRGBEncoding`→`r.outputColorSpace=SRGBColorSpace`(removed;already_def)
  `r.physicallyCorrectLights=true`→delete(`physicallyCorrectLights`/`useLegacyLights`_removed;PBR_units_always_on;use_candela_e.g.`PointLight(0xffffff,100)`,`threejs-lighting`)
  `mat.envMapIntensity=0.5`_for_`scene.environment`→`scene.environmentIntensity=0.5`(`envMapIntensity`_only_scales_`mat.envMap`)
  `mesh.dispose()`_alone→`mesh.dispose()`+`geo.dispose()`+dispose_`Object.values(mat)`_textures+`mat.dispose()`
  `import {WebGLCubeRenderTarget} from "three/webgpu"`→`CubeRenderTarget`(WebGLCubeRenderTarget_WebGL-only)
  `await r.renderAsync(s,c)`→`await r.init();r.render(s,c)`(async_render_depr_r181)
}

§REL{`threejs-geometry`,`threejs-materials`,`threejs-textures`,`threejs-lighting`,`threejs-animation`,`threejs-interaction`,`threejs-loaders`,`threejs-shaders`,`threejs-postprocessing`,`threejs-performance`,`threejs-react-three-fiber`}
