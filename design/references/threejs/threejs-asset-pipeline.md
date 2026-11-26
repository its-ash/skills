@REF:threejs-asset-pipeline
§META{target:three.js@r186;renderers:{WebGLRenderer(default),WebGPURenderer(WebGPU/TSL)}}
§CMD{inspect_validate:
  "npx @gltf-transform/cli inspect model.glb [--format csv]";//overview(generator,extensionsUsed,extensionsRequired)+scenes/meshes/materials/textures/animations tables;writing cmds log in/out bytes
  "npx @gltf-transform/cli validate model.glb --ignore ACCESSOR_WEIGHTS_NON_NORMALIZED";//official validator;nonzero exit on error(CI gate)
  contract(extensionsRequired):{wire:{KHR_draco_mesh_compression→DRACOLoader,EXT_meshopt_compression→MeshoptDecoder,KHR_texture_basisu→KTX2Loader};none:{KHR_mesh_quantization,EXT_mesh_gpu_instancing,EXT_texture_webp,EXT_texture_avif}}
}
§CMD{optimize:
  order:"dedup→instance→palette→flatten→join→weld→simplify→resample→prune→sparse→texture_compress→geometry_compress";
  no_flags:"meshopt + recompress textures in orig fmt";
  "npx @gltf-transform/cli optimize model.glb model.opt.glb --compress draco --texture-compress webp --texture-size 2048";
  "npx @gltf-transform/cli optimize model.glb model.opt.glb --texture-compress ktx2 --simplify false";
  flags(bools_req_val e.g."--simplify false"):{
    "--compress":"draco|meshopt|quantize(def meshopt)";
    "--texture-compress":"ktx2|webp|avif(def auto=orig fmt;ktx2 auto-splits:UASTC→normal/occlusion/metallic-roughness,ETC1S→rest)";
    "--texture-size":"<px>(def 2048)";
    "--simplify <bool>,--simplify-ratio <0-1>(0),--simplify-error <frac>(0.0001),--simplify-lock-border <bool>";
    "--instance <bool>,--instance-min <n>";
    "--join <bool>,--join-meshes <bool>,--join-named <bool>,--flatten <bool>(join req flatten)";
    "--weld <bool>(draco welds always;simplify welds only unindexed⇒keep --weld true w/ simplify)";
    "--prune <bool>,--resample <bool>,--palette <bool>,--sparse <bool>,--meshopt-level medium|high"
  };
  alt:"gltfpack"
}
§D{geometry:"pick/model,¬project;draco|meshopt|optimize MUST BE LAST(other rewriting cmds decode Draco/meshopt on read⇒warn 'Decoded KHR_draco_mesh_compression. Further compression will be lossy.'+write uncompressed)":
  draco:"--compress draco|draco;triangles ONLY(¬anim/morphs/textures/pts/lines);runtime:DRACOLoader";
  meshopt:"--compress meshopt|meshopt;pts/lines/tris/morphs/anim tracks;fast decode;pair w/ gzip|brotli;runtime:MeshoptDecoder";
  quantize:"quantize;KHR_mesh_quantization(8/16-bit ints);disk+GPU mem;0 decoder";
  gzip:"gzip model.opt.glb→model.opt.glb.gz;Content-Encoding:gzip;low gain on Draco/JPEG,high on meshopt/quantize"
}
§CMD{geo_cli:
  "npx @gltf-transform/cli draco model.glb model.opt.glb --method edgebreaker --quantize-position 14";
  "npx @gltf-transform/cli meshopt model.glb model.opt.glb --level high";
  "npx @gltf-transform/cli quantize model.glb model.opt.glb";
  "npx @gltf-transform/cli gzip model.opt.glb"
}
§D{textures:
  ktx2:"BasisU;stays GPU-compressed if supported(else RGBA fallback)+fast upload⇒GPU mem/perf;req KTX-Software>=4.4.0 `ktx` CLI;runtime:KTX2Loader.detectSupport";
  webp_avif:"in-process encode;download ONLY;decompresses to raw GPU pixels(4-8x GPU mem);runtime:browser"
}
§CMD{tex_cli:
  "npx @gltf-transform/cli etc1s model.glb model.opt.glb --quality 128";//color,smaller,lossier
  "npx @gltf-transform/cli uastc model.glb model.opt.glb --level 4";//normal maps,larger,cleaner
  "npx @gltf-transform/cli webp model.glb model.opt.glb --quality 80";//q=1-100;same for avif
  "npx @gltf-transform/cli resize model.glb model.opt.glb --width 1024 --height 1024";//caps PNG/JPEG;¬enlarge
  note:"etc1s/uastc convert all textures to 1 bitstream;--slots selects texture roles by name"
}
§CMD{scene_opt:"draw-call|vert-count bottlenecks":
  "npx @gltf-transform/cli weld in.glb out.glb";//merges bitwise-id verts+indexes(skips pts);run BEFORE simplify&meshopt(meshopt reorder skips unindexed+warns)
  "npx @gltf-transform/cli simplify in.glb out.glb --ratio 0.5 --error 0.001 [--lock-border true]";//lossy;keeps ratio verts within error*extent
  "npx @gltf-transform/cli join in.glb out.glb";//merges compat prims(runs dedup+flatten);inflates reused meshes⇒use instance
  "npx @gltf-transform/cli instance in.glb out.glb --min 5";//EXT_mesh_gpu_instancing→InstancedMesh(0 runtime setup);skips animated;req shared mats
  "npx @gltf-transform/cli dedup in.glb out.glb";//merges dup accessors/mats/meshes/skins/textures
  "npx @gltf-transform/cli prune in.glb out.glb"//drops unref props+orphaned anims
}
§PAT{loader_webgpu:
  lighting:"glTF PBR(MeshStandardMaterial) renders black without lights/env";
  paths:"Draco/Basis load from three pkg by default;setDecoderPath/setTranscoderPath ONLY if self-hosted(pin to shipped three release)";
  ktx2:"1 shared KTX2Loader/app(multi instances spawn extra workers/transcoders+warn)";
  ```js
  import{GLTFLoader}from"three/addons/loaders/GLTFLoader.js";
  import{DRACOLoader}from"three/addons/loaders/DRACOLoader.js";
  import{KTX2Loader}from"three/addons/loaders/KTX2Loader.js";
  import{MeshoptDecoder}from"three/addons/libs/meshopt_decoder.module.js";
  //WebGPU:import*as THREE from"three/webgpu";await renderer.init() BEFORE KTX2Loader.detectSupport(renderer);loaded mats auto-convert to node mats(mesh.material class unchanged)
  const gltf=await new GLTFLoader().setDRACOLoader(new DRACOLoader()).setMeshoptDecoder(MeshoptDecoder).setKTX2Loader(new KTX2Loader().detectSupport(renderer)).loadAsync("model.opt.glb");
  ```
  errors:{draco:"No DRACOLoader instance provided",meshopt:"setMeshoptDecoder must be called before loading compressed files",ktx2:"setKTX2Loader must be called before loading KTX2 textures",ktx2_init:"Missing initialization with `.detectSupport( renderer )`"}
}
§PAT{sdk:"node pipeline.mjs;deps:@gltf-transform/core @gltf-transform/extensions @gltf-transform/functions draco3dgltf":
  ```js
  import{NodeIO}from"@gltf-transform/core";import{ALL_EXTENSIONS}from"@gltf-transform/extensions";import{dedup,prune,weld,draco}from"@gltf-transform/functions";import draco3d from"draco3dgltf";
  const io=new NodeIO().registerExtensions(ALL_EXTENSIONS).registerDependencies({"draco3d.decoder":await draco3d.createDecoderModule(),"draco3d.encoder":await draco3d.createEncoderModule()});//missing ext dropped on read,throws if req,invalid output on write(webp/quantize)
  const doc=await io.read("model.glb");await doc.transform(dedup(),weld(),prune(),draco({method:"edgebreaker",quantizePosition:14}));await io.write("model.opt.glb",doc);//compress runs on write⇒last
  ```
  alt:"meshopt:await MeshoptEncoder.ready;reg{'meshopt.encoder':MeshoptEncoder};meshopt({encoder:MeshoptEncoder})(from meshoptimizer) | tex:textureCompress({encoder:sharp,targetFormat:'webp'})"
}
§CMD{gltfjsx:"npx gltfjsx model.glb --transform [--types] [--simplify --ratio ... --error ...]⇒Model.jsx(.tsx)+model-transformed.glb(palette,joined,welded,pruned,Draco,WebP≤--resolution(1024),normal JPEG≤max(2048,--resolution))"}
§ANTI{mistakes:
  "three/examples/jsm/..."⇒"three/addons/...";
  "optimize ... --compress ktx2"⇒"--compress draco --texture-compress ktx2";
  "draco a && webp b"⇒"webp a && draco b";
  "missing setDRACOLoader|setMeshoptDecoder|setKTX2Loader|detectSupport"⇒"wire matching loader+detectSupport(renderer)";
  "dracoLoader.setDecoderPath(otherReleaseCDN)"⇒"new DRACOLoader()";
  "dracoLoader.setDecoderConfig({type:'js'})"⇒"new DRACOLoader() (deprecated r185;auto WASM)";
  "ktx2Loader.detectSupportAsync(renderer)"⇒"await renderer.init();ktx2Loader.detectSupport(renderer) (deprecated r181)";
  "dequantize in out"⇒"quantize in out (dequantize ONLY if app needs float verts in model units;quantized attrs=norm ints scaled by node transform)"
}
§REL{threejs-loaders:runtime load/cache/clone/dispose;threejs-react-three-fiber:Canvas/useGLTF/Suspense/drei;threejs-performance:draw calls/GPU mem/renderer.info}
