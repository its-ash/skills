@REF:threejs-shaders
§META{ver:three.js_r186;WebGL⇒WebGLRenderer;WebGPU/TSL⇒WebGPURenderer}

§PAT{QUICK_START:
```js
import * as THREE from "three";
const r=new THREE.WebGLRenderer({antialias:true});r.setPixelRatio(devicePixelRatio);r.setSize(innerWidth,innerHeight);document.body.appendChild(r.domElement);
const s=new THREE.Scene(),c=new THREE.PerspectiveCamera(60,innerWidth/innerHeight,0.1,100);c.position.set(0,0,2);
const m=new THREE.ShaderMaterial({uniforms:{time:{value:0},color:{value:new THREE.Color(0x0066ff)}},vertexShader:`varying vec2 vUv;void main(){vUv=uv;gl_Position=projectionMatrix*modelViewMatrix*vec4(position,1.0);}`,fragmentShader:`uniform float time;uniform vec3 color;varying vec2 vUv;void main(){float w=sin(vUv.x*10.0+time*2.0)*0.5+0.5;gl_FragColor=vec4(color*w,1.0);\n#include <tonemapping_fragment>\n#include <colorspace_fragment>\n}`});
s.add(new THREE.Mesh(new THREE.PlaneGeometry(2,2),m));
const t=new THREE.Timer();t.connect(document);r.setAnimationLoop(()=>{t.update();m.uniforms.time.value=t.getElapsed();r.render(s,c);});
```
}

§R{SHADER_MAT_VS_RAW:
ShaderMaterial:
- GLSL_ES_3.00(`#version 300 es` prepended;WebGL1_removed);core(¬flags):`texture()`,`textureLod()`,`textureSize()`,`dFdx`/`fwidth`,`gl_FragDepth`.
- `#define` aliases:`texture2D`,`textureCube`,`attribute`,`varying`,`gl_FragColor`⇒GLSL1_mostly_compiles EXCEPT var=`texture`, `gl_FragData`, `#extension`(prepended_decls_precede_src⇒delete `#extension`).
- `glslVersion`:leave_unset(`THREE.GLSL3` drops `gl_FragColor` alias⇒forces custom `out`).
- Auto-declared_VS:uniforms(`modelMatrix`,`modelViewMatrix`,`projectionMatrix`,`viewMatrix`,`normalMatrix`,`cameraPosition`);attrs(`position`,`normal`,`uv`,`instanceMatrix`(`InstancedMesh`),`instanceColor`(post-`setColorAt`),`color`(`vertexColors:true`)).
- ViewSpaceNormal:`vNormal=normalize(normalMatrix*normal);`.
RawShaderMaterial:
- Prepends_ONLY:`#define SHADER_TYPE`,`#define SHADER_NAME`,`defines`(+`#version 300 es`⇔`glslVersion` set);∅_decls;∅_precision.
- Req:`glslVersion:THREE.GLSL3`(else GLSL_ES_1.00⇒¬`texture()`),`precision highp float;`,`in`/`out`,`out highp vec4 fragColor;`.
- BuiltInMatrices(`modelMatrix`,`modelViewMatrix`,`projectionMatrix`,`viewMatrix`,`normalMatrix`,`cameraPosition`):declare_in_GLSL(`uniform mat4 ...;`),¬JS_`uniforms`(renderer auto-sets declared;JS_`uniforms` overwritten/draw:`modelMatrix`/`modelViewMatrix`/`normalMatrix` ∨ overrides_camera:`projectionMatrix`/`viewMatrix`/`cameraPosition`).
}

§PAT{UNIFORMS_COLOR:
- ColorTex:`await new THREE.TextureLoader().loadAsync(url);tex.colorSpace=THREE.SRGBColorSpace`→decodes_linear on `texture(mapValue,vUv)`.
- Types:`float`↔`number`,`vec3`↔`Vector3`∨`Color`(hex sRGB→linear),`mat4`↔`Matrix4`,`sampler2D`↔`Texture`.
- Mutate:`uniforms.x.value=v` ∨ in-place `.value.set(...)`.
- ReservedUniformNames(¬declare⇒VS_redecl_compile_err):`position`,`normal`,`uv`,`modelViewMatrix`,`cameraPosition`.
- OutputEncoding:`ShaderMaterial` raw unless FS ends w/ own-line `#include <tonemapping_fragment>`(`renderer.toneMapping`;no-op if `NoToneMapping`) ∧ `#include <colorspace_fragment>`(`renderer.outputColorSpace`;default `SRGBColorSpace`). Both write `gl_FragColor`⇒req `glslVersion` unset;missing⇒darker mid-tones.
- `VideoTexture`:uploaded ¬sRGB_decode⇒manual `sRGBTransferEOTF(texture(videoMap,vUv))`(in `ShaderMaterial` prefix).
- RenderTarget/`EffectComposer`:includes keep linear;`OutputPass` encodes at end.
}

§PAT{GLSL_PATTERNS:
- Displacement:`pos.z+=sin(pos.x*5.0+time)*amplitude;`+subdivided_mesh(`PlaneGeometry(2,2,64,64)`).
- Fresnel(world_space,uniform_scale):VS `vWorldNormal=normalize(mat3(modelMatrix)*normal);vWorldPosition=(modelMatrix*vec4(position,1.0)).xyz;`;FS `vec3 viewDirection=normalize(cameraPosition-vWorldPosition);float fresnel=pow(1.0-max(dot(viewDirection,vWorldNormal),0.0),3.0);`.
- Rim(view_space;¬mix `normalMatrix` w/ `cameraPosition`):VS `vec4 mvPosition=modelViewMatrix*vec4(position,1.0);vViewDir=-mvPosition.xyz;vNormal=normalMatrix*normal;`;FS `float rim=pow(1.0-max(dot(normalize(vViewDir),normalize(vNormal)),0.0),4.0);`.
- Dissolve:`float noise=texture(noiseMap,vUv).r;if(noise<progress)discard;float edge=smoothstep(progress,progress+0.1,noise);gl_FragColor=vec4(mix(vec3(1.0,0.5,0.0),vec3(0.5),edge),1.0);`(+tonemapping/colorspace).
}

§PAT{INSTANCING_ATTRS:
- Manual `attribute`/`in`:`uv1`..`uv3`,`tangent`,custom_attrs.
- Per-instance:`geometry.setAttribute("aOffset",new THREE.InstancedBufferAttribute(new Float32Array(count*3),3))`;per-vertex:`new THREE.BufferAttribute(new Float32Array(geometry.attributes.position.count*3),3)`.
- `InstancedMesh` VS MUST apply `instanceMatrix`:`gl_Position=projectionMatrix*modelViewMatrix*instanceMatrix*vec4(position+aOffset,1.0);`.
- Set `mesh.frustumCulled=false` when `aOffset` shifts outside `instanceMatrix` bounds.
}

§PAT{EXTEND_CHUNKS_DEBUG:
- `onBeforeCompile=(shader)=>{...}`(`WebGLRenderer` only;runs 1x/program pre-`#include`):
  - Store `material.userData.shader=shader`;frame:`if(material.userData.shader)material.userData.shader.uniforms.time.value=timer.getElapsed();`.
  - VS_hooks:`#include <begin_vertex>`(`vec3 transformed=vec3(position)`),`#include <beginnormal_vertex>`(`vec3 objectNormal`),`#include <project_vertex>`(`gl_Position`).
  - FS_hooks:`#include <color_fragment>`(`diffuseColor` post-map/vertexColors),`#include <opaque_fragment>`(`gl_FragColor` pre-tonemapping),`#include <fog_fragment>`(post-tonemapping/colorspace/fog).
  - Multi-variant(`userData` diffs)⇒define `material.customProgramCacheKey()`→distinct_string/variant(else 1 cached program reused).
- Chunks:`#include <chunk>` valid in `ShaderMaterial`∧`RawShaderMaterial`(e.g.`#include <packing>`→`perspectiveDepthToViewZ(texture(depthTexture,vUv).r,cameraNear,cameraFar)`,`vec3(-viewZ/cameraFar)`).Keys:`Object.keys(THREE.ShaderChunk)`.∅ `output_fragment`(final=`opaque_fragment`).
- Debug(`renderer.debug.checkShaderErrors=true` default):`renderer.debug.onShaderError=(gl,program,vs,fs)=>{gl.getProgramInfoLog(program);gl.getShaderInfoLog(s);gl.getShaderSource(s);}`(`getShaderSource`=assembled shader).Visual:`vec4(vUv,0.0,1.0)`,`vec4(vNormal*0.5+0.5,1.0)`.
}

§PAT{WEBGPU_TSL:
- `ShaderMaterial`,`RawShaderMaterial`,`onBeforeCompile`=`WebGLRenderer`-only(`WebGPURenderer` logs `Material "ShaderMaterial" is not compatible`→plain node mat fallback;`onBeforeCompile` never called).`WebGPURenderer` auto-falls back to WebGL2⇒1 TSL path covers both.
- Imports:`import * as THREE from "three/webgpu";` ∧ `import {...} from "three/tsl";`.
- Init:`await renderer.init()` BEFORE any renderer call(incl.`renderer.compute()`).`scene.background=new THREE.Color(...)`(WebGPU canvas transparent by default).
- NodeMats:`MeshBasicNodeMaterial`(unlit),`MeshStandardNodeMaterial`(lit;black w/o lights∨`scene.environment`).Slots:`colorNode`,`opacityNode`,`emissiveNode`,`normalNode`,`positionNode`,`fragmentNode`(full FS override).
- Uniforms/time:`const amp=uniform(0.5);amp.value=1.0;`;built-in `time` node auto-updates/frame(e.g.`vec3(abs(mx_fractal_noise_float(uv().mul(10).add(time.mul(0.2)))).mul(amp))`).
- Textures/discard:`texture(map,uvNode)`(`texture(map)` uses mesh UVs);scalar data tex keeps `NoColorSpace`;`cond.discard()`.
  - TSL_Dissolve:`Fn(()=>{const n=texture(noiseMap,uv()).r;n.lessThan(progress).discard();return mix(color(1,0.5,0),color(0.5,0.5,0.5),smoothstep(progress,progress.add(0.1),n));})()`.
- Displacement:`positionNode` replaces local pos;build on `positionLocal`(has skinning/morphs/displacement/batching/`InstancedMesh`),¬`positionGeometry`(raw rest-pose only).Needs subdivided mesh(`PlaneGeometry(2,2,96,96)`).`MeshStandardNodeMaterial({flatShading:true})` recomputes surface normals(vertex normals ignore `positionNode`).Ex:`positionLocal.add(normalLocal.mul(sin(positionLocal.y.mul(4).add(time))).mul(0.2))`.
- Reusable:`Fn(([y])=>...)` compiles→GLSL∧WGSL;`varying(node,"name")` passes VS→FS(e.g.`varying(positionWorld.y,"vWorldY")`).
- Porting/Debug:rewrite GLSL as `Fn`(`glslFn`=WebGL2_only,`wgslFn`=WebGPU_only⇒non-portable).Inspect:`await renderer.debug.getShaderAsync(scene,camera,mesh)`→`{vertexShader,fragmentShader}`.
}

§ANTI{COMMON_MISTAKES:
- `new THREE.Clock()`⇒`new THREE.Timer();timer.connect(document)`(`Clock` deprecated r183;call `timer.update()` first,then `getElapsed()`/`getDelta()`).
- `"#include <output_fragment>"`⇒`"#include <opaque_fragment>"`(`output_fragment`∉`ShaderChunk`;replace silently no-ops).
- Omit `#include <tonemapping_fragment>`+`#include <colorspace_fragment>`(own lines)⇒unencoded linear output,darker mid-tones.
- `ShaderMaterial`/`onBeforeCompile` w/ `WebGPURenderer`⇒`MeshBasicNodeMaterial`(`colorNode`)/TSL.
- `positionGeometry.add(...)`⇒`positionLocal.add(...)`(preserves skinning/morphs/batching/instancing).
- `import {time} from "three/nodes"`⇒`"three/tsl"`(`three/nodes`∉;node mats∈`"three/webgpu"`).
- `import {toVarying} from "three/tsl"`⇒`varying(node,"vName")`(`toVarying` only method `node.toVarying("vName")`).
- `uniforms`,`PI2`(`three/tsl`)⇒`uniformArray`(r168),`TWO_PI`(r181).
- `amplitude.label("amp")`⇒`amplitude.setName("amp")`(r179;`label()` warns deprecated).
- `texture(map).uv(uvNode)`⇒`texture(map).sample(uvNode)`(r172).
- `screen`,`viewportTopLeft`,`directionToColor`(`three/tsl`)⇒`blendScreen`(r171),`viewportUV`(r168),`packNormalToRGB`(r185).
- `rangeFog(color,near,far)`⇒`fog(color,rangeFogFactor(near,far))`(`rangeFog` removed).
- `uniform(0)` synced to `timer.getElapsed()`⇒built-in `time` node.
- `glslFn`/`wgslFn`⇒TSL `Fn`(`Fn(([p])=>mx_noise_float(p))`) for dual backend.
- JS `uniforms:{modelViewMatrix:...}`⇒GLSL `uniform mat4 modelViewMatrix;` in `RawShaderMaterial`(JS overwritten/overrides camera;redeclaring in `ShaderMaterial` fails compile).
- `ShaderMaterial({transparent:true,opacity:0.5})`⇒`uniforms:{opacity:{value:0.5}}`+`uniform float opacity` in FS alpha(`ShaderMaterial` ignores `material.opacity`).
- `uniforms:{position:...}`⇒rename(e.g.`offset`;collides w/ VS `position` attr).
- `ShaderMaterial({glslVersion:THREE.GLSL3})`⇒omit `glslVersion`(already GLSL_ES_3.00;`GLSL3` drops `gl_FragColor`).
- `RawShaderMaterial` w/o `glslVersion`⇒`glslVersion:THREE.GLSL3`(else GLSL_ES_1.00⇒¬`texture()`).
- `ShaderMaterial({extensions:{derivatives:true,fragDepth:true}})`⇒omit(WebGL1 keys removed r163,ignored;core in GLSL_ES_3.00;`extensions` holds only `clipCullDistance`,`multiDraw`).
- `blending:THREE.MultiplyBlending`(∨`SubtractiveBlending`) w/o `premultipliedAlpha:true`⇒errors/no blend fn;`ShaderMaterial` w/ `alpha<1` also needs `#include <premultiplied_alpha_fragment>`.
- `InstancedMesh` VS omitting `instanceMatrix *`⇒all instances draw at mesh transform.
- `vUv1=uv1` w/o `attribute vec2 uv1;`⇒declare `uv1`..`uv3` & `tangent` manually.
- `dot(normalize(cameraPosition-vWorldPosition),normalize(normalMatrix*normal))`⇒`mat3(modelMatrix)*normal`(¬mix world `cameraPosition` & view `normalMatrix`).
- `console.log(shader.fragmentShader)` in `onBeforeCompile`⇒`renderer.debug.onShaderError`+`gl.getShaderSource(fs)`(`onBeforeCompile` is pre-include/prefix).
}

§REL{threejs-materials,threejs-textures,threejs-postprocessing}
