@REF:threejs-performance

§META{target:"three.js r186";default_renderer:WebGLRenderer;webgpu_sec:WebGPURenderer+TSL}

§PAT:Measure{
  rule:"optimize measured bottlenecks; read renderer.info AFTER render()";
  WebGL_info:{
    render:{calls,triangles,lines,points};
    memory:{geometries,textures}; // upload counts (shared across meshes; drops on matching dispose()), NOT bytes
    programs:"programs.length" // cached compiled shaders
  };
  autoReset:{
    default:true⇒"resets at start of each render(); pre-render read = prev frame; multi-render() frames show last pass only";
    multi_pass:"renderer.info.autoReset=false → render()... → read → renderer.info.reset() once/frame"
  };
  shadows:"castShadow lights re-draw casters from light view inside render() → included in calls & triangles";
  frame_timing:{
    tool:"const timer=new THREE.Timer(); timer.connect(document)"; // pauses when tab hidden
    fn:"timer.update(); dt=timer.getDelta()"; // ≥1 display refresh (16.7ms@60Hz) ⇒ detects drops, NOT headroom
    cpu:"t0=performance.now(); renderer.render(scene,camera); cpu+=performance.now()-t0"; // GPU executes async later
    avg:"average interval & cpu over ~60 frames (1s) — single frames jitter"
  };
  deep_prof:["Chrome DevTools Performance (main-thread tasks, script vs render, GPU track)","stats-gl (live overlay)"]
}

§PAT:DrawCalls{
  cost:"1 visible mesh = 1 draw (or 1/geometry-group if material is Array)";
  multipliers:{
    double_transparent:"transparent:true ∧ side:THREE.DoubleSide ⇒ 2x draws (back→front); fix: forceSinglePass:true";
    transmission:"any MeshPhysicalMaterial(transmission>0) in view ⇒ ALL opaque meshes drawn 2x (transmission buffer)"
  };
  reducers:{
    merge_static:{
      use:"static meshes sharing 1 material";
      api:`import * as BufferGeometryUtils from "three/addons/utils/BufferGeometryUtils.js";
baked.applyMatrix4(m); BufferGeometryUtils.mergeGeometries(parts);`;
      req:"matching attributes & index state";
      edge:"1 bounding sphere ⇒ all-or-nothing frustum cull; merge per world-sized cluster, ¬whole level"
    };
    instancing:{
      use:"1 geometry, N transforms ⇒ 1 draw";
      api:"const im=new THREE.InstancedMesh(geom,mat,N); im.setMatrixAt(i,m);";
      edge:"lazy 1-sphere cull around all instances; after move: im.instanceMatrix.needsUpdate=true; im.computeBoundingSphere();"
    };
    batching:{
      use:"multiple geometries sharing 1 material in shared buffers";
      api:`const bm=new THREE.BatchedMesh(maxInst,maxVerts,maxIdx,mat); // e.g.(500,20000,20000,mat)
const gId=bm.addGeometry(geom); const iId=bm.addInstance(gId); bm.setMatrixAt(iId,mat4);`;
      props:"perObjectFrustumCulled:true, sortObjects:true (defaults); geom renders ONLY via addInstance()";
      backend:"WebGL: 1 multi-draw if WEBGL_multi_draw supported, else 1/instance; WebGPU: 1/instance ⇒ see threejs-geometry"
    };
    lod:{
      api:"const lod=new THREE.LOD(); lod.addLevel(mesh,dist);";
      behavior:"autoUpdate:true in render(); selects mesh by cam distance ⇒ cuts triangles, NOT draw calls"
    };
    culling:{
      default:"mesh.frustumCulled=true via geometry.boundingSphere";
      silent_break:[
        "CPU vertex edit ¬geometry.computeBoundingSphere() ⇒ stale smaller sphere hides visible mesh",
        "shader vertex displacement leaves CPU sphere static ⇒ set mesh.frustumCulled=false on THAT mesh only, ¬scene-wide"
      ]
    }
  }
}

§PAT:GPUMemory{
  math:"RGBA8=4 B/px; WebGPURenderer default mip chain ×1.333 (2048×2048≈22MB VRAM)";
  ktx2:{
    why:"Basis Universal (ETC1S|UASTC) transcodes to GPU block-compressed (ASTC|BC7|BC1|BC3|ETC2|ETC1|PVRTC) instead of 4B/px PNG/JPEG";
    fallback:"uncompressed RGBA if incompatible: ASTC←UASTC only, ETC1←no alpha, PVRTC←PoT";
    api:`import { KTX2Loader } from "three/addons/loaders/KTX2Loader.js";
const loader=new KTX2Loader().detectSupport(renderer);
const map=await loader.loadAsync("color.ktx2");
map.colorSpace=THREE.SRGBColorSpace; // only needed if color file tagged linear
mesh.material.map=map; mesh.material.needsUpdate=true; // if mat previously had no map`
  };
  sizing:"1024 = 1/4 VRAM of 2048; author at max screen size, let mipmaps handle distance";
  disposal:{
    rules:[
      "geometry.dispose() frees GPU buffers immediately even if shared",
      "texture.dispose() frees GPU texture once 0 undisposed clones share it (clone() shares image+GPU while wrap/filter/format/colorSpace match)",
      "no mesh refcounting ⇒ dispose only unrendered assets (active mesh re-uploads on next render)",
      "material.dispose() frees shader programs (when 0 materials use them), NEVER textures",
      "object.dispose() frees per-object state ONLY; does NOT visit children"
    ];
    subtree:`root.traverse(c=>{c.geometry?.dispose(); for(const m of [c.material??[]].flat()){for(const v of Object.values(m))if(v?.isTexture)v.dispose(); m.dispose();} c.dispose();});`
  }
}

§PAT:FillRate{
  pixel_ratio:"buffer=(w*r)×(h*r) ⇒ cost∝r² (3×=9× of 1×); cap: renderer.setPixelRatio(Math.min(window.devicePixelRatio,2))";
  overdraw:{
    order:"opaque (group→renderOrder→material→dist) → transmissive → transparent (back-to-front)";
    risk:"stacked transparent layers never early-Z reject; full-screen transparent quad re-shades every pixel; invisible in renderer.info (calls/tris identical, only frame time rises)";
    fix:"prefer opaque; keep transparent quads few & small"
  };
  shadows:{
    cost:"each castShadow light re-draws in-frustum castShadow meshes (included in info.render.calls); PointLight≤6 cube faces; VSMShadowMap also draws receiveShadow + 2 blur passes";
    cfg:`renderer.shadowMap.enabled=true; sun.castShadow=true; sun.shadow.mapSize.set(1024,1024); // default 512×512`;
    bounds:"tighten sun.shadow.camera.{left,right,top,bottom} + updateProjectionMatrix()";
    freeze:"static scenery: renderer.shadowMap.autoUpdate=false; renderer.shadowMap.needsUpdate=true; (or per-light sun.shadow.autoUpdate=false; sun.shadow.needsUpdate=true;)"
  }
}

§PAT:CPULoop{
  static_xform:{
    why:"render() runs scene.updateMatrixWorld(), recomposing all matrixAutoUpdate:true objects";
    fix:"mesh.matrixAutoUpdate=false; mesh.updateMatrix(); // re-call updateMatrix() manually if moved"
  };
  raycast:{
    why:"intersectObjects(objs,true) walks every descendant (layers→boundingSphere→triangles); hot on pointermove";
    fix:`raycaster.layers.set(1); child.layers.enable(1); // keeps layer 0
const hits=raycaster.intersectObjects(pickables,false); // explicit list, no recursion`;
    accel:"large static meshes ⇒ three-mesh-bvh"
  };
  zero_alloc:"preallocate Vector3/Matrix4 outside loop; per-frame new allocations trigger GC frame spikes"
}

§PAT:ShaderStalls{
  lazy_build:"first render with unseen state (light count, fog) stalls compiling shader";
  precompile:`await renderer.compileAsync(scene,camera); // uses KHR_parallel_shader_compile; shadow-depth programs still compile on 1st shadow render`;
  sync_vs_async:"compile() queues & returns immediately ⇒ 1st render still blocks; prefer compileAsync()";
  runtime_rebuild:"avoid toggling shader-compiled flags: transparent, side, blending, flatShading, vertexColors, dithering, premultipliedAlpha, alphaHash, adding/removing map (need material.needsUpdate=true) ⇒ see threejs-materials"
}

§PAT:WebGPU_TSL{
  init:`import * as THREE from "three/webgpu";
const r=new THREE.WebGPURenderer({antialias:true}); await r.init(); // required before any use (or setAnimationLoop awaits init)
scene.background=new THREE.Color(0x111111); // WebGPU canvas transparent by default`;
  compute_particles:`import { Fn, cos, hash, instanceIndex, instancedArray, sin, time, TWO_PI, vec3 } from "three/tsl";
const pos=instancedArray(count,"vec3");
const sim=Fn(()=>{const r=hash(instanceIndex),a=r.mul(TWO_PI).add(time); pos.element(instanceIndex).assign(vec3(cos(a).mul(8),sin(r.mul(97).add(time.mul(2))).mul(2).add(2),sin(a).mul(8)));}).compute(count);
const mat=new THREE.SpriteNodeMaterial(); mat.positionNode=pos.toAttribute(); mat.colorNode=vec3(1,0.7,0.3);
const p=new THREE.Sprite(mat); p.count=count; p.frustumCulled=false; // origin sphere ≠ particles
// loop: r.compute(sim); r.render(scene,camera);`;
  info:{
    render:"render.drawCalls (per-frame draws); render.calls (cumulative render passes incl. internal/output); info.calls (cumulative render+compute)",
    compute:"compute.frameCalls (per-frame compute)",
    memory:"memory.total (byte estimate: vertex/index/storage buffers, textures, uniforms, programs via texturesSize, attributesSize, *Size); compressed textures fallback=1B ⇒ KTX2 under-reported"
  }
}

§ANTI{
  "requestAnimationFrame(animate)"⇒"renderer.setAnimationLoop(animate) (WebXR requires it; WebGPU awaits init())";
  "new THREE.Clock() (deprecated r183; getElapsedTime() calls getDelta() ⇒ subsequent getDelta()≈0)"⇒"new THREE.Timer(); timer.update(); timer.getDelta(); timer.getElapsed()";
  "read renderer.info before render()"⇒"read AFTER render()";
  "info.autoReset=false without reset()"⇒"call renderer.info.reset() once/frame after last render()";
  "webgpuRenderer.info.render.calls for frame draws"⇒"webgpuRenderer.info.render.drawCalls (WebGL uses render.calls)";
  "renderer.compile(scene,camera)"⇒"await renderer.compileAsync(scene,camera)";
  "THREE.PCFSoftShadowMap (deprecated r182; falls back to PCF + warning)"⇒"THREE.PCFShadowMap";
  "mesh.material.dispose() alone"⇒"dispose textures in Object.values(material) before material.dispose()";
  "gltf.scene.dispose() alone"⇒"traverse subtree to dispose geometry, materials, textures, and each child";
  "raycaster.intersectObjects(scene.children,true)"⇒"raycaster.layers.set(1) + explicit pickables + false";
  "scene.traverse(c=>c.frustumCulled=false)"⇒"geometry.computeBoundingSphere() after CPU vertex edit (frustumCulled=false only on shader-displaced mesh)";
  "new THREE.Vector3() inside animate()"⇒"preallocate outside loop";
  "const dt=uniform(0) fed manually from Timer in TSL"⇒"use built-in TSL time & deltaTime nodes (renderer-updated)"
}

§REL{
  "threejs-fundamentals":"renderer construction, render loop, resize handling";
  "threejs-geometry":"full instancing, batching, merging, attribute APIs";
  "threejs-materials":"shader-compiled material flags & rebuild triggers";
  "threejs-loaders":"KTX2, Draco, meshopt loader wiring";
  "threejs-lighting":"light types, units, shadow setup";
  "threejs-postprocessing":"composer buffers, MSAA, pixel-ratio settings";
  "threejs-asset-pipeline":"gltf-transform CLI for KTX2, compressed/instanced/joined glTF"
}
