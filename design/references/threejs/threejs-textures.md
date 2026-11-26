@REF:threejs-textures
§META{ver:"three.js r186"|"three@0.186.0";def:WebGLRenderer;wgpu:WebGPURenderer}

§BOOT{
  ```js
  import * as THREE from "three";
  const r = new THREE.WebGLRenderer({ antialias: true });
  r.setPixelRatio(devicePixelRatio); r.setSize(innerWidth, innerHeight);
  document.body.appendChild(r.domElement);
  const scene = new THREE.Scene(), cam = new THREE.PerspectiveCamera(60, innerWidth / innerHeight, 0.1, 100);
  cam.position.set(0, 0, 2);
  const tex = new THREE.TextureLoader().load("diffuse.jpg");
  tex.colorSpace = THREE.SRGBColorSpace;
  const mesh = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), new THREE.MeshBasicMaterial({ map: tex }));
  scene.add(mesh);
  r.setAnimationLoop(() => { mesh.rotation.z += 0.01; r.render(scene, cam); });
  ```
}

§LOAD{
  sync:loader.load(url)⇒Texture(async_img);
  post_render_assign:mesh.material.map=tex⇒mesh.material.needsUpdate=true(rebuilds_shader);
  async:await loader.loadAsync(url)(on_Loader_base);
  progress:TextureLoader.onProgress≡unsupported(never_fires)⇒LoadingManager:
  ```js
  const m = new THREE.LoadingManager();
  m.onProgress = (url, loaded, total) => console.log(`${loaded}/${total}: ${url}`);
  const loader = new THREE.TextureLoader(m);
  ```
}

§COL{
  init:colorManagement=ON;def=THREE.NoColorSpace;
  THREE.SRGBColorSpace∈{map,emissiveMap,specularMap,sheenColorMap,sheenSpecularColorMap,LDR_matcaps,color_canvas,color_video};
  THREE.NoColorSpace∈{normalMap,bumpMap,displacementMap,roughnessMap,metalnessMap,aoMap,alphaMap};
  THREE.LinearSRGBColorSpace∈{HDR_env}(auto_set_by_HDR_loaders);
  GLTFLoader⇒auto_sets_colorSpace
}

§XFRM{
  wrapS/T∈{ClampToEdgeWrapping(def),RepeatWrapping(tiling),MirroredRepeatWrapping(mirror_per_repeat)};
  props:{repeat.set(x,y),offset.set(x,y),center.set(x,y),rotation(rad)}
}

§FILT{
  minFilter∈{LinearMipmapLinearFilter(def_trilinear),LinearFilter,NearestFilter(base_only)};
  magFilter∈{LinearFilter(def),NearestFilter};
  mipmaps_off(UI/data):generateMipmaps=false∧minFilter=THREE.LinearFilter(generateMipmaps=true_uploads_mips_regardless_of_filter);
  anisotropy:WebGL⇒r.capabilities.getMaxAnisotropy()|WebGPU⇒r.getMaxAnisotropy();
  NPOT:WebGL2_supports_mips+RepeatWrapping
}

§TYP{
  Texture(img):colorSpace=SRGBColorSpace;img.onload=()=>tex.needsUpdate=true;
  DataTexture(typedArr,w,h):def={minFilter:NearestFilter,magFilter:NearestFilter,flipY:false,generateMipmaps:false};
  ```js
  const dt = new THREE.DataTexture(new Uint8Array(256 * 256 * 4), 256, 256); // RGBA
  dt.needsUpdate = true;
  ```
  CanvasTexture(canvas):sets_needsUpdate_on_ctor;colorSpace=SRGBColorSpace;needsUpdate=true_per_redraw;
  VideoTexture(HTMLVideoElement):loop=true;muted=true;play();colorSpace=SRGBColorSpace;reuploads/frame,mips_off;
  VideoFrameTexture(WebCodecs):colorSpace=SRGBColorSpace;MUST_close_prev_VideoFrame_or_stalls:
  ```js
  const ft = new THREE.VideoFrameTexture(); ft.colorSpace = THREE.SRGBColorSpace;
  new VideoDecoder({ output(f) { if (ft.image instanceof VideoFrame) ft.image.close(); ft.setFrame(f); }, error: console.error });
  ```
  HTMLTexture:HTML-in-Canvas_API(moves_el→canvas,reuploads_on_paint;empty_if_unsupported)
}

§KTX2{
  ```js
  import { KTX2Loader } from "three/addons/loaders/KTX2Loader.js";
  const ktx2 = new KTX2Loader();
  ktx2.detectSupport(r); // req before load; WebGPU: after await r.init()
  const map = await ktx2.loadAsync("diffuse.ktx2");
  ```
  transcoder:from_three_pkg;setTranscoderPath()_ONLY_if_self_hosted@"three@0.186.0";
  colorSpace:auto_from_file;fmt:Basis_Universal→GPU_compressed(fallback:uncompressed_RGBA);
  limits:flipY=false(author_UVs),embedded_mips_req;detectSupportAsync_deprecated_r181
}

§ENV{
  cube:CubeTextureLoader().load(["px.jpg","nx.jpg","py.jpg","ny.jpg","pz.jpg","nz.jpg"])(auto_sRGB);
  assign:scene.background=t;scene.environment=t(lights_Standard/Physical;WebGL+Lambert/Phong);
  equirect:{HDRLoader("three/addons/loaders/HDRLoader.js",ex_RGBELoader_r180),EXRLoader("three/addons/loaders/EXRLoader.js"),UltraHDRLoader}(auto_LinearSRGBColorSpace);
  ```js
  import { HDRLoader } from "three/addons/loaders/HDRLoader.js";
  const env = await new HDRLoader().loadAsync("environment.hdr");
  env.mapping = THREE.EquirectangularReflectionMapping; // w/o⇒flat screen quad
  scene.environment = env; scene.background = env;
  ```
  prefilter:renderers_convert_equirect→larger_cubemap(ship_low_res_for_mem;¬PMREMGenerator.fromEquirectangular);
  scene_ctrl:scene.{environmentIntensity(≠mat.envMapIntensity),environmentRotation.y,backgroundBlurriness(0..1),backgroundIntensity,backgroundRotation.y};
  generated:PMREMGenerator+RoomEnvironment("three/addons/environments/RoomEnvironment.js"):
  ```js
  const pmrem = new THREE.PMREMGenerator(r), room = new RoomEnvironment();
  scene.environment = pmrem.fromScene(room, 0.04).texture;
  room.dispose(); pmrem.dispose();
  ```
}

§RT{
  std:new THREE.WebGLRenderTarget(512,512);rtScene∌sampling_mesh;r.setRenderTarget(rt);r.render(rtScene,cam);r.setRenderTarget(null);mesh.material.map=rt.texture;
  depth:rt.depthTexture=new THREE.DepthTexture(512,512)(def:UnsignedIntType);
  msaa:new THREE.WebGLRenderTarget(512,512,{samples:4})(auto_resolved→.texture);
  mrt:new THREE.WebGLRenderTarget(512,512,{count:2})⇒.textures[0..n-1](WebGLMultipleRenderTargets_removed_r162)
}

§REFL{
  WebGL:new THREE.WebGLCubeRenderTarget(256,{generateMipmaps:true,minFilter:THREE.LinearMipmapLinearFilter});
  WebGPU:new THREE.CubeRenderTarget(256)("three/webgpu");
  loop:CubeCamera(0.1,1000,cubeRT);scene.add(cam);mesh.material.envMap=cubeRT.texture;
  frame:mesh.visible=false;cam.position.copy(mesh.position);cam.update(r,scene);mesh.visible=true(¬self_reflection)
}

§UV{
  tex.channel∈{0:"uv"(def),1:"uv1",2:"uv2",3:"uv3"};
  ao/lightMap:use_"uv"(ch=0)_by_def;separate_unwrap⇒geo.setAttribute("uv1",new THREE.BufferAttribute(new Float32Array(cnt*2),2))+mat.aoMap.channel=1
}

§ATLAS{
  pad_borders(filter/mip_bleed);atlas.clone()_shares_source(1_GPU_upload);
  ```js
  function spriteTexture(atlas, row, col, g = 2) {
    const s = atlas.clone();
    s.offset.set(col / g, 1 - (row + 1) / g); s.repeat.set(1 / g, 1 / g);
    return s;
  }
  ```
}

§MAT{
  ch:{aoMap:R,roughnessMap:G,metalnessMap:B(ORM),alphaMap:G};
  MeshStandardMaterial:{emissiveMap:req_emissive≠0,roughness/metalness:map_multipliers,aoMapIntensity,alphaMap:req_transparent:true∨alphaTest,displacementMap:displacementScale+displacementBias+subdiv_mesh,normalMap:normalScale(Vector2)+normalMapType∈{TangentSpaceNormalMap(def),ObjectSpaceNormalMap}}
}

§MEM{
  dispose:tex.dispose()_frees_GPU_upload_if_unshared(img_kept);
  ```js
  function disposeMaterial(m) {
    for (const k of Object.keys(m)) if (m[k]?.isTexture) m[k].dispose();
    m.dispose();
  }
  ```
  stats:r.info.memory.textures,r.capabilities.maxTextureSize;share_tex_instances
}

§WGPU{
  ```js
  import * as THREE from "three/webgpu";
  import { texture, uv } from "three/tsl";
  const r = new THREE.WebGPURenderer({ antialias: true });
  await r.init(); // before any renderer/KTX2.detectSupport call
  scene.background = new THREE.Color(0x111111); // canvas starts transparent
  map.anisotropy = r.getMaxAnisotropy(); // no .capabilities
  const mat = new THREE.MeshBasicNodeMaterial();
  mat.colorNode = texture(map); // uv() + tex offset/repeat/rotation
  mat.colorNode = texture(map, uv().mul(0.5).add(0.25)); // explicit UV overrides transform
  mat.colorNode = texture(map, uv(1)); // samples "uv1"
  ```
  classic_slots(map,normalMap,roughnessMap,aoMap)_work_on_node_materials
}

§ANTI{
  geo.setAttribute("uv2",uv)→use_channel=0(uv)_or_uv1+ch=1;
  RGBELoader→HDRLoader(r180);
  "three/examples/jsm/"→"three/addons/";
  tex.encoding=sRGBEncoding→tex.colorSpace=THREE.SRGBColorSpace;
  LDR_color@NoColorSpace→washed_out;
  LinearFilter_alone→still_gens_mips(set_generateMipmaps=false);
  NPOT+ClampToEdge+noMips→unneeded(WebGL2_supports_NPOT);
  WebGPU:r.capabilities.getMaxAnisotropy()→r.getMaxAnisotropy();
  mat.envMapIntensity→only_mat.envMap;use_scene.environmentIntensity;
  pmrem.fromEquirectangular(hdr)→redundant;
  scene.background=hdr_w/o_mapping→flat_quad;
  ktx2.detectSupportAsync→deprecated_r181(await r.init();ktx2.detectSupport(r));
  ktx2.setTranscoderPath→only_self_host@0.186.0;
  WebGLMultipleRenderTargets→removed_r162(WebGLRenderTarget(w,h,{count:2}));
  WebGPU:WebGLCubeRenderTarget→CubeRenderTarget;
  loader.load(...,onProgress)→unsupported(LoadingManager.onProgress);
  post_render_map_assign_w/o_needsUpdate=true→invisible;
  normalMap:LinearSRGBColorSpace→NoColorSpace;
  manual_Promise(loader.load)→loader.loadAsync(url);
  cubeCam.update_mesh_visible→self_reflection
}

§REL{threejs-materials:props/blend/phys;threejs-loaders:mgr/glTF;threejs-shaders:GLSL_WebGL;threejs-lighting:env/units;threejs-asset-pipeline:KTX2/WebP/AVIF_gltf-transform}
