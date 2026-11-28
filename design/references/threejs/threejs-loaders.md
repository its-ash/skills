@REF:threejs-loaders
§META{ver:"three.js r187",def_renderer:WebGLRenderer,webgpu_sec:WebGPURenderer}

§PAT{quick_start}
```js
import * as THREE from "three";import {GLTFLoader} from "three/addons/loaders/GLTFLoader.js";import {RoomEnvironment} from "three/addons/environments/RoomEnvironment.js";
const r=new THREE.WebGLRenderer({antialias:true}),s=new THREE.Scene(),c=new THREE.PerspectiveCamera(50,innerWidth/innerHeight,.1,100);
c.position.set(2,1.5,3);c.lookAt(0,0,0);
s.environment=new THREE.PMREMGenerator(r).fromScene(new RoomEnvironment(),.04).texture; // PBR black w/o lights|env
s.add((await new GLTFLoader().loadAsync("model.glb")).scene);
r.setAnimationLoop(()=>r.render(s,c));
```

§PAT{loading_manager}
```js
const m=new THREE.LoadingManager();
m.onStart=(url,loaded,total)=>{};m.onProgress=(url,loaded,total)=>{};m.onLoad=()=>{};m.onError=(url)=>{};
await Promise.all([new GLTFLoader(m).loadAsync("model.glb"),new THREE.TextureLoader(m).loadAsync("a.jpg")]);
// abort() cancels FileLoader-based (models,HDR,EXR,KTX2); TextureLoader(<img>) ignores abort()
const tid=setTimeout(()=>m.abort(),30000);
try{s.add((await new GLTFLoader(m).loadAsync("model.glb")).scene);}finally{clearTimeout(tid);}
```
- `loadAsync`rejects on error∧`manager.onError`also fires

§CFG{textures}
```js
const map=new THREE.TextureLoader().load("color.jpg",(t)=>{t.colorSpace=THREE.SRGBColorSpace;mesh.material.map=t;mesh.material.needsUpdate=true;},undefined,(e)=>console.error(e)); // needsUpdate=true if mat rendered w/o map; onProgress unsupported for <img>
map.wrapS=map.wrapT=THREE.RepeatWrapping; // ClampToEdgeWrapping(def),RepeatWrapping,MirroredRepeatWrapping
map.repeat.set(2,2);map.offset.set(.5,.5);map.rotation=Math.PI/4;map.center.set(.5,.5);
map.minFilter=THREE.LinearMipmapLinearFilter;map.magFilter=THREE.LinearFilter; // NearestFilter=pixelated
map.anisotropy=r.capabilities.getMaxAnisotropy(); // WebGPU:r.getMaxAnisotropy()
```
- `TextureLoader.load()`returns`Texture`sync,populates on decode
- Color_spaces:LDR color(albedo,emissive)⇒`THREE.SRGBColorSpace`;scalar(normal,bump,roughness,metalness,ao,alpha)⇒`THREE.NoColorSpace`(def);HDR/EXR⇒`LinearSRGBColorSpace`;`GLTFLoader`auto-sets;manual tex for glTF mat⇒`map.flipY=false`
- Upload_timing:`{wrapS,wrapT,minFilter,magFilter,anisotropy,colorSpace,flipY(true_def)}`apply at upload(set pre-1st-render∨`map.needsUpdate=true`);`{repeat,offset,rotation,center}`apply every frame
- `CubeTextureLoader().loadAsync(["px.jpg","nx.jpg","py.jpg","ny.jpg","pz.jpg","nz.jpg"])`(+X,-X,+Y,-Y,+Z,-Z):auto sets sRGB

§PAT{hdr_env}
```js
import {HDRLoader} from "three/addons/loaders/HDRLoader.js";import {EXRLoader} from "three/addons/loaders/EXRLoader.js";
import {UltraHDRLoader} from "three/addons/loaders/UltraHDRLoader.js"; // gain-map JPEGs
import {RoomEnvironment} from "three/addons/environments/RoomEnvironment.js";
const env=await new HDRLoader().loadAsync("env.hdr"); // or EXRLoader / UltraHDRLoader
env.mapping=THREE.EquirectangularReflectionMapping;scene.environment=scene.background=env; // w/o mapping:background=flat quad
// Generated env ONLY -> PMREMGenerator:
const pmrem=new THREE.PMREMGenerator(r),room=new RoomEnvironment();
scene.environment=pmrem.fromScene(room,.04).texture;room.dispose();pmrem.dispose();
```
- Renderers auto-prefilter equirect env⇒¬`pmrem.fromEquirectangular`
- `scene.environmentIntensity`∧`scene.environmentRotation`scale/rotate`scene.environment`(`material.envMapIntensity`scales`material.envMap`only)

§PAT{gltf_glb}
- Result:`{scene,animations,cameras,asset:{version,generator},userData}`
```js
import {GLTFLoader} from "three/addons/loaders/GLTFLoader.js";import {DRACOLoader} from "three/addons/loaders/DRACOLoader.js";
import {KTX2Loader} from "three/addons/loaders/KTX2Loader.js";import {MeshoptDecoder} from "three/addons/libs/meshopt_decoder.module.js";
const loader=new GLTFLoader().setDRACOLoader(new DRACOLoader()).setMeshoptDecoder(MeshoptDecoder).setKTX2Loader(new KTX2Loader().detectSupport(r));
const gltf=await loader.loadAsync("model.glb"),model=gltf.scene;
model.traverse((c)=>{if(c.isMesh)c.castShadow=c.receiveShadow=true;});model.getObjectByName("Head");
const box=new THREE.Box3().setFromObject(model),ctr=box.getCenter(new THREE.Vector3()),sz=box.getSize(new THREE.Vector3());
const sc=1/Math.max(sz.x,sz.y,sz.z);model.scale.setScalar(sc);model.position.copy(ctr).multiplyScalar(-sc);
if(gltf.animations.length){const mixer=new THREE.AnimationMixer(model);mixer.clipAction(gltf.animations[0]).play();const timer=new THREE.Timer();timer.connect(document);} // frame:timer.update();mixer.update(timer.getDelta());
```
- Draco/Basis load from`three`pkg by def;call`setDecoderPath`/`setTranscoderPath`ONLY if self-hosting,pinned to shipped`three`release
- `EXT_meshopt_compression`/`KHR_meshopt_compression`fail unless`setMeshoptDecoder`is set

§PAT{other_formats}
- `OBJ+MTL`:`MTLLoader`+`materials.preload()`+`new OBJLoader().setMaterials(materials).loadAsync("model.obj")`
- `FBX`:`FBXLoader`(`three/addons/loaders/FBXLoader.js`);often cm⇒`object.scale.setScalar(.01)`;`AnimationMixer(object)`
- `STL`:`STLLoader`(`three/addons/loaders/STLLoader.js`)→`BufferGeometry`⇒`Mesh(geo,MeshStandardMaterial)`+lights
- `PLY`:`PLYLoader`(`three/addons/loaders/PLYLoader.js`)→`BufferGeometry`;`double`props→`Float64Array`(WebGL throws`Unsupported buffer data format`)⇒convert→`Float32BufferAttribute(a.array,a.itemSize)`;`if(!g.hasAttribute("normal"))g.computeVertexNormals()`;`vertexColors:g.hasAttribute("color")`(true w/o`color`⇒black);add lights
- `USD`:`USDLoader`(`three/addons/loaders/USDLoader.js`;USD,USDA,USDC,USDZ)

§PAT{async_and_sources}
- Parallel:`await Promise.all([l1.loadAsync(...),l2.loadAsync(...)])`;in-memory:`await new GLTFLoader().parseAsync(buf,"")`
- Blob/DataURL:`u=URL.createObjectURL(blob);t=await new THREE.TextureLoader().loadAsync(u);URL.revokeObjectURL(u);`
- Paths:`loader.setPath("assets/models/")`,`loader.setResourcePath("assets/textures/")`,`manager.setURLModifier(u=>...)`
- Cache:`THREE.Cache.enabled=true;THREE.Cache.clear();`
- Small payloads(Draco/meshopt/KTX2 per`threejs-asset-pipeline`)+placeholder mesh while loading

§PAT{clone_and_dispose}
```js
import * as SkeletonUtils from "three/addons/utils/SkeletonUtils.js";
const copy=SkeletonUtils.clone(gltf.scene); // Object3D.clone() shares skeleton across skinned copies
scene.remove(model);
model.traverse((c)=>{c.dispose();if(c.geometry){c.geometry.dispose();for(const mat of[c.material??[]].flat()){for(const v of Object.values(mat))if(v?.isTexture)v.dispose();mat.dispose();}}}); // Object3D.dispose()=per-object renderer state only; material.dispose()¬textures
```

§CFG{webgpu_tsl}
```js
import * as THREE from "three/webgpu";import {GaussianSplat} from "three/addons/objects/GaussianSplat.js";
const r=new THREE.WebGPURenderer({antialias:true});await r.init(); // MUST precede ktx2Loader.detectSupport & PMREMGenerator.{fromScene,fromEquirectangular,fromCubemap}
scene.background=new THREE.Color(0x111827); // WebGPU canvas transparent def
```
- `GLTFLoader`auto-converts loaded materials→node materials
- Max anisotropy:`renderer.getMaxAnisotropy()`(`renderer.capabilities`∉`WebGPURenderer`)
- Gaussian splats(require`WebGPURenderer`):`{SPLATLoader,SPZLoader,KSPLATLoader,GaussianSplatPLYLoader}`→`new GaussianSplat(data)`

§ANTI{common_mistakes}
- `three/examples/jsm/loaders/GLTFLoader.js`(import-map fail)⇒`three/addons/loaders/GLTFLoader.js`
- `three/addons/loaders/RGBELoader.js`(renamed r180,warns)⇒`three/addons/loaders/HDRLoader.js`
- `new Promise((res,rej)=>loader.load(url,res,undefined,rej))`⇒`loader.loadAsync(url)`
- `mat.map=new TextureLoader().load("color.jpg")`(def`NoColorSpace`→washed out)⇒`map.colorSpace=THREE.SRGBColorSpace`
- `normalMap.colorSpace=LinearSRGBColorSpace`⇒`THREE.NoColorSpace`(scalar:normal,bump,roughness,metalness,ao,alpha)
- `texture.encoding=sRGBEncoding`(removed)⇒`texture.colorSpace=THREE.SRGBColorSpace`
- `mat.envMapIntensity=.5`(scales`material.envMap`only)⇒`scene.environmentIntensity=.5`
- `scene.environment=pmrem.fromEquirectangular(hdr).texture`(redundant)⇒`hdr.mapping=EquirectangularReflectionMapping;scene.environment=hdr`
- `scene.background=hdr`(flat quad)⇒`hdr.mapping=EquirectangularReflectionMapping;scene.background=hdr`
- `ktx2.setTranscoderPath(otherVer)`(mismatch)⇒`new KTX2Loader().detectSupport(r)`
- `ktx2.detectSupportAsync(r)`(deprecated r181)⇒`await r.init();ktx2.detectSupport(r);`
- `r.capabilities.getMaxAnisotropy()`(fails WebGPU)⇒`r.getMaxAnisotropy()`on WebGPURenderer
- `PLYLoader`raw upload(`Float64Array`throws`Unsupported buffer data format`)⇒convert`Float64Array`→`Float32BufferAttribute`
- `gltf.scene.clone()`(shares skeleton)⇒`SkeletonUtils.clone(gltf.scene)`
- `gltf.scene.dispose()`(shallow;leaks geo/mat/tex)⇒traverse:dispose`geometry`,`mat`textures,`mat`,`child`
- `fetch(url,{signal:c.signal})`⇒`setTimeout(()=>manager.abort(),30000)`
- `new USDZLoader()`(deprecated r179)⇒`new USDLoader()`

§REL{threejs-fundamentals,threejs-textures,threejs-materials,threejs-asset-pipeline,threejs-animation}
