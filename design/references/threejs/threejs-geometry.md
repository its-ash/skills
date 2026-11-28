@REF:threejs-geometry
§META{ver:three.js@r187;def:WebGLRenderer;alt:WebGPURenderer(three/webgpu+three/tsl)}

§PAT{quickstart:WebGL}
```js
import * as THREE from "three";
const r = new THREE.WebGLRenderer({ antialias: true });
r.setPixelRatio(window.devicePixelRatio); r.setSize(innerWidth, innerHeight);
document.body.appendChild(r.domElement);
const s = new THREE.Scene(), cam = new THREE.PerspectiveCamera(75, innerWidth / innerHeight, 0.1, 100);
cam.position.set(0, 0, 5);
s.add(new THREE.Mesh(new THREE.BoxGeometry(1, 1, 1), new THREE.MeshNormalMaterial())); // 1 geo shared ∀ meshes
r.setAnimationLoop(() => r.render(s, cam));
```

§API{builtin_geometries}
- `BoxGeometry(w,h,d,wSeg,hSeg,dSeg)`
- `SphereGeometry(r,wSeg=32,hSeg=16,phiStart,phiLen,thetaStart,thetaLen)` // half(poles):`(1,32,16,0,π)`; dome(equator):`(1,32,16,0,2π,0,π/2)`; `32x16` std, ↑only close-up
- `PlaneGeometry(w,h,wSeg,hSeg)` | `CircleGeometry(r,seg,thetaStart,thetaLen)`
- `CylinderGeometry(rTop,rBot,h,radSeg,hSeg,openEnded,thetaStart,thetaLen)` // `radSeg=6`⇒hex prism
- `ConeGeometry(r,h,radSeg,hSeg,openEnded,thetaStart,thetaLen)`
- `TorusGeometry(r,tube,radSeg,tubSeg,arc,thetaStart,thetaLen)` // `arc=π`⇒half
- `TorusKnotGeometry(r,tube,tubSeg,radSeg,p,q)` // note:`tubSeg` before `radSeg`
- `RingGeometry(inR,outR,thetaSeg,phiSeg,thetaStart,thetaLen)`
- `CapsuleGeometry(r,h,capSeg,radSeg,hSeg)` // `h`=mid only; `r176`:`length`→`height`+`hSeg`
- `IcosahedronGeometry(r,detail)`(20@0)|`DodecahedronGeometry`|`OctahedronGeometry`|`TetrahedronGeometry` // `detail` subdivides ∀ face
- `PolyhedronGeometry(flatVerts,indices,r,detail)`
- `LatheGeometry(vec2Pts,seg,phiStart,phiLen)` // rotates Y
- `ExtrudeGeometry(Shape,{steps,depth,bevelEnabled,bevelThickness,bevelSize,bevelSegments})` // `Shape.moveTo/lineTo` pushed +Z
- `TubeGeometry(Curve3,tubSeg,r,radSeg,closed)` // e.g. `CatmullRomCurve3(vec3[])`
- `TextGeometry(str,{font,size,depth,curveSegments,bevelEnabled,bevelThickness,bevelSize,direction})` // `FontLoader`+`TextGeometry` from `three/addons/{loaders/FontLoader.js,geometries/TextGeometry.js}`; `.typeface.json`; `direction∈{'ltr','rtl','tb'}`; `geo.center()`; `r163`:`height`→`depth`(old `height` ignored⇒50)

§PAT{BufferGeometry}
Base ∀ geos; default mat attrs: `position`(f32,3), `normal`(f32,3), `uv`(f32,2); opt `color`(3) w/ `mat.vertexColors=true`.
- Index: `Uint16Array` (`0..65534`; `65535`=primitive-restart) ∨ `geo.setIndex([...])` (auto `Uint16`/`Uint32`).
- Byte color: `new THREE.BufferAttribute(new Uint8Array(n*3), 3, true)` (`normalized=true`⇒`0.0-1.0`; `false`⇒`0.0-255.0` blowout).
- Update: `pos=geo.attributes.position; pos.setXYZ(i,x,y,z); pos.getX(i); pos.needsUpdate=true; geo.computeVertexNormals(); geo.computeBoundingBox(); geo.computeBoundingSphere();`
  - Array ¬grow post-1st-render ⇒ alloc max + `geo.setDrawRange(0, n)`; bounds drive culling+raycasting.
- Interleaved: `ib=new THREE.InterleavedBuffer(f32Arr, stride); geo.setAttribute("position", new THREE.InterleavedBufferAttribute(ib,3,0)); geo.setAttribute("uv", new THREE.InterleavedBufferAttribute(ib,2,3));` ∨ `BufferGeometryUtils.interleaveAttributes([pos,norm,uv])`.

§PAT{edges_wire_points_lines}
- Edges/Wire: `EdgesGeometry(geo, thresholdDeg)` (e.g. `15`, +open boundaries) | `WireframeGeometry(geo)` (all tri edges+diags, shared 1x) → `LineSegments(eg, LineBasicMaterial)`.
- Points: `Points(geo, PointsMaterial({size,color}))`; `sizeAttenuation:true`⇒CSS px=`size*(canvasCssH/2)/depth`. WebGPURenderer⇒1px always (use `Sprite`+`PointsNodeMaterial`).
- Lines: `BufferGeometry().setFromPoints(pts)` → `Line`(open) | `LineLoop`(closed, WebGPURenderer⇒error+skip; repeat `pts[0]`+`Line`) | `LineSegments`(pairs `0-1,2-3...`).
- Thick lines (`linewidth` ignored⇒1px in WebGL/WebGPU): WebGL=`Line2`+`LineGeometry.setPositions(xyz)`+`LineMaterial({linewidth})` (`three/addons/lines/`); WebGPU=`three/addons/lines/webgpu/Line2.js`+`Line2NodeMaterial`(`three/webgpu`).

§PAT{instancing_batching}
- `InstancedMesh(geo,mat,count)`: 1 draw call; `MeshBasicMaterial`×`instanceColor`, `MeshNormalMaterial` ignores.
  - Setup: `setMatrixAt(i,m4)`→`instanceMatrix.needsUpdate=true`(req post-render); `setColorAt(i,Color)`(creates `instanceColor` 1st use)→`instanceColor.needsUpdate=true`.
  - Runtime: `getMatrixAt(i,m)`→modify→`setMatrixAt(i,m)`→`instanceMatrix.needsUpdate=true`→`computeBoundingSphere()`; `Raycaster.intersectObject(mesh)[0]?.instanceId` (`undefined` if ¬instanced).
- `InstancedBufferGeometry`: `geo.copy(src)` copies index+attrs ¬`instanceCount` ⇒ must set `geo.instanceCount=count` (else 0 drawn); `setAttribute("offset", new THREE.InstancedBufferAttribute(f32,3))` (WebGL `ShaderMaterial`: `in vec3 offset;`; WebGPU: TSL node).
- `BatchedMesh(maxInst,maxVert,maxIdx,mat)`: mixed geos, 1 mat; WebGL=1 multi-draw(`WEBGL_multi_draw`), WebGPU=1 draw/instance.
  - `gid=bm.addGeometry(geo)` (matching attrs+index state); `iid=bm.addInstance(gid)` (`r166+`: geo renders only via `addInstance`); `bm.setMatrixAt(iid,m4)`.

§PAT{utils_transform_morph}
```js
import * as BufferGeometryUtils from "three/addons/utils/BufferGeometryUtils.js";
import * as MikkTSpace from "three/addons/libs/mikktspace.module.js";
const merged = BufferGeometryUtils.mergeGeometries([g1, g2], true); // same attrs & all indexed∨all non-indexed (else null); useGroups=true⇒mat[]
const welded = BufferGeometryUtils.mergeVertices(g2); // welds dupes + builds index
welded.computeTangents(); // core method; req index+position+normal+uv
await MikkTSpace.ready; BufferGeometryUtils.computeMikkTSpaceTangents(merged, MikkTSpace); // glTF std; mutates non-indexed in-place
```
- Transform (mutating⇒`geo.clone()` 1st): `geo.center()`, `computeBoundingBox()`, `boundingBox.getSize(v)`, `geo.scale(s,s,s)`, `rotateX(rad)`, `translate(x,y,z)`.
- Pivot (¬mutate verts): `mesh.pivot = new THREE.Vector3(x,y,z)` (def `null`, local space).
- Morph: `geo.morphAttributes.position=[BufferAttribute]` BEFORE `new THREE.Mesh(geo,mat)`; if added post-construction⇒call `mesh.updateMorphTargets()` before `mesh.morphTargetInfluences[0]=0.5`.

§R{perf_disposal}
- Draw calls: static⇒`mergeGeometries`, repeated⇒`InstancedMesh`, mixed+1mat⇒`BatchedMesh`.
- Disposal: `scene.remove(m); m.dispose(); m.geometry.dispose(); m.material.dispose();` (`Object3D.dispose()`=self renderer state only; `geo.dispose()`=immediate GPU free even if shared; `mat` textures need `tex.dispose()`; `InstancedMesh.dispose()` also frees morph tex).
- Subtree: `root.traverse(c=>{c.geometry?.dispose(); for(const m of [c.material??[]].flat()){for(const v of Object.values(m))if(v?.isTexture)v.dispose(); m.dispose();} c.dispose();})`.

§PAT{WebGPU_TSL}
```js
import * as THREE from "three/webgpu";
import { instancedBufferAttribute, positionLocal } from "three/tsl";
const r = new THREE.WebGPURenderer({ antialias: true }); await r.init(); // init() required before use
scene.background = new THREE.Color(0x111111); // canvas transparent by default
// Thick points (Points renders 1px in WebGPU):
const pts = new THREE.Sprite(new THREE.PointsNodeMaterial({
  positionNode: instancedBufferAttribute(new THREE.InstancedBufferAttribute(posF32, 3)),
  size: 0.5, // depth-scaled; sizeAttenuation:false⇒CSS px; or sizeNode
}));
pts.count = count; pts.frustumCulled = false; // culling checks 0.7-unit sphere @ origin
// Per-instance displacement (no ShaderMaterial in WebGPU):
const mat = new THREE.MeshBasicNodeMaterial();
mat.positionNode = positionLocal.add(instancedBufferAttribute(jitterAttr).mul(0.5)); // positionLocal carries skin/morph/batch/instance
```

§ANTI{common_mistakes}
- `BufferGeometryUtils.computeTangents(g)` ⇒ `g.computeTangents()` (not on Utils; req index+pos+normal+uv)
- `BufferAttribute(uint8,3)` ⇒ `BufferAttribute(uint8,3,true)` (else `0..255` color blowout)
- `instancedGeo.copy(src)` w/o `instanceCount` ⇒ set `instancedGeo.instanceCount=count` (copy overwrites w/ `undefined`⇒0 drawn)
- `batchedMesh.addGeometry(g)` alone ⇒ `batchedMesh.addInstance(batchedMesh.addGeometry(g))` (`r166+`)
- `LineLoop` on WebGPU ⇒ repeat `pts[0]` + `Line` (WebGPU logs error+skips `LineLoop`)
- `three/examples/jsm/...` ⇒ `three/addons/...` (import map resolves `addons/`, not `examples/`)
- `capsule.parameters.length` ⇒ `capsule.parameters.height` (`r176` rename + 5th param `heightSegments`)
- `TextGeometry(...,{height})` ⇒ `{depth}` (`r163` rename; `height` ignored⇒default `50`)
- `Points`+`PointsMaterial({size})` on WebGPU ⇒ `Sprite`+`PointsNodeMaterial({positionNode:instancedBufferAttribute(...)})`
- `ShaderMaterial` on WebGPU ⇒ `positionNode=positionLocal.add(...)` on `*NodeMaterial` (ShaderMaterial incompatible⇒fallback plain `NodeMaterial`)
- `positionGeometry.add(offset)` ⇒ `positionLocal.add(offset)` (`positionGeometry` is raw attr; `positionLocal` has skin/morph/batch/instance)
- `mesh.morphTargetInfluences[0]=0.5` after late target ⇒ `mesh.updateMorphTargets()` first
- `gltf.scene.dispose()` alone ⇒ traverse children+geometries+materials+textures
- `new THREE.*BufferGeometry` (e.g. `BoxBufferGeometry`) ⇒ removed; use `BoxGeometry`
- `BufferGeometryUtils.mergeBufferGeometries` ⇒ `mergeGeometries` (old throws `TypeError`)
- `geo.setAttribute("uv2", geo.attributes.uv)` for `aoMap` ⇒ `aoMap` reads `uv`(ch 0) default; separate unwrap uses `uv1` + `aoTexture.channel=1`
- `LineBasicMaterial({linewidth:4})` ⇒ 1px always; use `Line2`+`LineGeometry`+`LineMaterial` (`three/addons/lines/`, WebGPU: `lines/webgpu/Line2.js`+`Line2NodeMaterial`)

§REL{see_also}
`threejs-fundamentals`, `threejs-materials`, `threejs-shaders`, `threejs-animation`, `threejs-loaders`, `threejs-performance`
