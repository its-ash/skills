@REF:threejs-materials
§META{target:three.js@r187;default:WebGLRenderer;webgpu_sec:WebGPURenderer}

§MAT{
  MeshBasicMaterial:{use:"unlit color/tex/wireframe",lit:∅,props:[envMap,reflectivity∈[0,1],combine∈{MultiplyOperation,MixOperation,AddOperation},specularMap(sRGB;masks envMap),color(*map),map,transparent,opacity,side,fog]};
  MeshLambertMaterial:{use:"matte diffuse",lit:diffuse,props:[color,emissive,emissiveIntensity,shared_lm_ph]};
  MeshPhongMaterial:{use:"shiny plastic/cheap spec",lit:diffuse+specular,props:[color,specular,shininess(30),flatShading,shared_lm_ph]};
  shared_lm_ph:[map,emissiveMap,specularMap(sRGB;masks envMap+Phong highlight),normalMap,bumpMap,displacementMap,aoMap,envMap,envMapIntensity,envMapRotation];
  MeshStandardMaterial:{use:"PBR metal/rough(default realistic)",lit:PBR,props:[color(*map),roughness(0=mirror..1=diffuse;*roughnessMap.G),metalness(0=dielectric..1=metal;*metalnessMap.B⇒keep 1 w/ map),ORM(glTF:ao=R,rough=G,metal=B),normalMap(normalScale:Vector2),aoMap(aoMapIntensity),displacementMap(displacementScale,displacementBias),emissive,emissiveIntensity,emissiveMap(sRGB),envMap,fog,lightMap(lightMapIntensity;HDR/EXR=LinearSRGBColorSpace)]};
  MeshPhysicalMaterial:{extends:MeshStandardMaterial,lit:PBR,layers:{
    clearcoat:[clearcoat∈[0,1],clearcoatRoughness,clearcoatMap,clearcoatRoughnessMap,clearcoatNormalMap],
    transmission:[transmission∈[0,1],thickness,attenuationDistance(Infinity=no absorb),attenuationColor,ior∈[1,2.333],transmissionMap,thicknessMap],
    sheen:[sheen,sheenColor,sheenRoughness,sheenColorMap,sheenRoughnessMap],
    iridescence:[iridescence,iridescenceIOR,iridescenceThicknessRange([100,400]nm),iridescenceMap,iridescenceThicknessMap],
    anisotropy:[anisotropy,anisotropyRotation,anisotropyMap],
    other:[dispersion,retroreflectivity,specularIntensity,specularColor,specularIntensityMap,specularColorMap,EON_rough_diffuse_BRDF(r187)]
  },glass_cfg:{color:0xffffff,metalness:0,roughness:0,transmission:1,thickness:0.5,ior:1.5,note:"refracts opaque objs+scene.background;scene.environment adds reflections"}};
  MeshToonMaterial:{use:"cel shading",lit:toon_steps,gradientMap:"DataTexture(Uint8Array,w,1,RedFormat);minFilter=magFilter=NearestFilter(hard)|LinearFilter(blend);needsUpdate=true"};
  MeshNormalMaterial:{use:"RGB normals debug/illustrative",props:[flatShading,wireframe]};
  MeshDepthMaterial:{use:"grayscale depth",packing:BasicDepthPacking(def)|RGBADepthPacking(shader readback)};
  MeshMatcapMaterial:{use:"baked matcap,no lights",lit:baked};
  ShadowMaterial:{use:"transparent shadow-receiver only",lit:shadows_only};
  PointsMaterial:{use:"point clouds",lit:∅,props:[size(px),sizeAttenuation(true;perspective:size*canvasH/2/viewZ),alphaTest]};
  LineBasicMaterial:{use:"1px solid lines",lit:∅};
  LineDashedMaterial:{use:"1px dashed lines",lit:∅,props:[dashSize,gapSize],req:"line.computeLineDistances()(else solid)"};
  ShaderMaterial:{use:"custom GLSL,WebGLRenderer only",lit:custom};
  RawShaderMaterial:{use:"bare GLSL,WebGLRenderer only",lit:custom}
}

§R{
  colorSpace:tex∈{map,emissiveMap,specularMap,sheenColorMap,specularColorMap,LDR_matcap,canvas_or_video_color}⇒tex.colorSpace=THREE.SRGBColorSpace(else washed out);tex∈{normal,bump,displacement,roughness,metalness,ao,alpha,gradientMap}⇒keep default;HDR/EXR loaders set own(LinearSRGBColorSpace);
  lights_req:lit materials render black w/o lights or scene.environment;
  thick_lines:WebGL∧WebGPU draw LineBasic/LineDashed at 1px(linewidth/linecap/linejoin affect SVGRenderer only);thick WebGL⇒Line2+LineGeometry.setPositions()+LineMaterial(linewidth px) from "three/addons/lines/";thick WebGPU⇒Line2 from "three/addons/lines/webgpu/Line2.js"+Line2NodeMaterial;
  uv_chan:tex.channel∈{0:uv(def),1:uv1,2:uv2,3:uv3};aoMap∧lightMap sample uv by default(no 2nd UV needed);GLTFLoader maps TEXCOORD_1→uv1∧sets channel;separate unwrap⇒geo.setAttribute("uv1",Float32BufferAttribute(pos.count*2,2));aoMap.channel=1;
  multi_mat:Mesh(geo,mats[])=1 mat/group(BoxGeometry=6 groups:+x,-x,+y,-y,+z,-z;36 indices);custom⇒geo.clearGroups();geo.addGroup(start,count,matIdx)(indexed⇒indices,non-indexed⇒verts;outside ranges undrawn)
}

§SHD{
  init_loop:renderer.setAnimationLoop(fn);timer=new THREE.Timer();timer.connect(document);in loop:timer.update()(no args);t=timer.getElapsed();//Clock deprecated r183;
  ShaderMaterial:{target:"GLSL ES 3.00(texture/textureLod/dFdx/gl_FragDepth built in;texture2D/gl_FragColor aliases)";leave glslVersion unset;auto_decl:{uniforms:[modelMatrix,modelViewMatrix,projectionMatrix,viewMatrix,normalMatrix,cameraPosition],attrs:[position,normal,uv,instanceMatrix(InstancedMesh:projectionMatrix*modelViewMatrix*instanceMatrix*vec4(pos,1.0)),color(if vertexColors)]};manual_decl:[uv1+,tangent]};
  RawShaderMaterial:{prepends_only:[#version(from glslVersion),SHADER_TYPE,SHADER_NAME,defines];set glslVersion:THREE.GLSL3 for texture()+out vec4 fragColor(else ES 1.00);renderer still sets [projectionMatrix,modelViewMatrix,viewMatrix,normalMatrix,modelMatrix,cameraPosition]⇒declare in shader∧NEVER pass in uniforms(overwritten/replaces camera)};
  webgpu_incompat:[ShaderMaterial,RawShaderMaterial,onBeforeCompile]
}

§PROP{
  common:{visible:true,transparent:false,opacity:1.0,alphaTest:0,side:FrontSide|BackSide|DoubleSide,depthTest:true,depthWrite:true,blending:NormalBlending|AdditiveBlending|CustomBlending|MultiplyBlending|SubtractiveBlending,polygonOffset:false,polygonOffsetFactor:0,polygonOffsetUnits:0,toneMapped:true(false=exact UI colors),dithering:false,vertexColors:false};
  blend_req:blending∈{MultiplyBlending,SubtractiveBlending}⇒premultipliedAlpha=true(both renderers;else error+no blend fn);
  stencil:{renderer:"new WebGLRenderer/WebGPURenderer({stencil:true})(off by def)";mask:{colorWrite:false,depthWrite:false,stencilWrite:true,stencilRef:1,stencilZPass:THREE.ReplaceStencilOp,stencilFail,stencilZFail};content:{stencilWrite:true,stencilRef:1,stencilFunc:THREE.EqualStencilFunc,stencilFuncMask:0xff,stencilWriteMask:0xff};order:"mask.renderOrder < content.renderOrder"}
}

§ENV{
  hdr:`import {HDRLoader} from "three/addons/loaders/HDRLoader.js"`(renamed from RGBELoader r180);`env.mapping=THREE.EquirectangularReflectionMapping`(else flat quad);both renderers prefilter(no PMREM);`scene.environment=env;scene.background=env;scene.environmentIntensity=0.8;scene.environmentRotation`;
  cube:`CubeTextureLoader().load([px,nx,py,ny,pz,nz])`→`mat.envMap`, `mat.envMapIntensity`(scales mat.envMap only,NOT scene.environment), `mat.envMapRotation=new THREE.Euler(...)`;
  lit_scope:scene.environment lights Standard+Physical(both);Lambert+Phong(WebGLRenderer only,NOT WebGPURenderer)
}

§LIFE{
  runtime_upd:uniforms(color,roughness)⇒no recompile;shader_flags⇒mat.needsUpdate=true for Δ{transparent,side,blending,flatShading,vertexColors,dithering,premultipliedAlpha,alphaHash,add/rm map slot,shader src}(alphaTest∧envMap auto-recompile);
  clone:mat.clone()⇒copies vals,shares map textures,clones ShaderMaterial uniforms;
  dispose:mat.dispose()⇒frees GPU programs when unused;textures need separate texture.dispose();
  perf_order:[1:"share 1 mat instance across meshes(avoids uniform re-upload)",2:"prefer opaque(transparent sorted back-to-front per obj after opaque,writes depth unless depthWrite:false⇒overdraw/misorder;alphaTest cutouts stay opaque)",3:"cheapest mat:Basic<Lambert<Phong<Standard<Physical"]
}

§WGPU{
  compat:built-ins auto-convert to node mats under WebGPURenderer;ShaderMaterial/RawShaderMaterial/MeshDepthMaterial/MeshDistanceMaterial⇒no node equiv(logs "is not compatible");
  imports:`import * as THREE from "three/webgpu"`(node mats)+`import {...} from "three/tsl"`(TSL fns);WebGL fallback:`WebGLNodesHandler`("three/addons/tsl/WebGLNodesHandler.js")→`renderer.setNodesHandler()`(no VSM shadows,MRT,transmission,WebGPU post-proc);
  init:`const r=new THREE.WebGPURenderer({antialias:true});await r.init();`+`scene.background=new THREE.Color(0x111111)`(WebGPU canvas transparent by def);
  nodes:{
    unlit:`new THREE.MeshBasicNodeMaterial()` + `colorNode=mix(color(0x0066ff),color(0xff0066),sin(time.mul(0.5)).mul(0.5).add(0.5))`,
    lit:`new THREE.MeshStandardNodeMaterial()`(needs light/env) + `colorNode=texture(map);roughnessNode=float(0.2)`,
    displace:`shell.positionNode=positionLocal.add(normalLocal.mul(sin(positionLocal.y.mul(6))).mul(0.05))`
  };
  points_quad:WebGPU Points always 1px⇒`const pts=new THREE.Sprite(new THREE.PointsNodeMaterial({positionNode:instancedBufferAttribute(posAttr),size:4,sizeAttenuation:false}));pts.count=N;pts.frustumCulled=false`(avoids 0.7u origin sphere cull)
}

§ANTI{
  "geo.setAttribute('uv2',geo.attributes.uv) for aoMap"⇒no extra attr needed(channel=0 reads uv;uv2 only w/ channel=2;separate unwrap→uv1+channel=1);
  "new RGBELoader()"⇒"new HDRLoader()" from "three/addons/loaders/HDRLoader.js"(r180 rename);
  '"three/examples/jsm/..."'⇒'"three/addons/..."'(import maps lack three/examples/);
  "blending=MultiplyBlending/SubtractiveBlending alone"⇒add `premultipliedAlpha=true`;
  "mat.stencilMask=0xff"⇒doesn't exist;use `stencilFuncMask=0xff;stencilWriteMask=0xff`;
  "WebGLRenderer({antialias:true}) w/ stencil"⇒add `stencil:true`;
  "mat.envMapIntensity=0.5 for scene.environment"⇒use `scene.environmentIntensity=0.5`;
  "clock.getElapsedTime()"⇒deprecated r183;use `THREE.Timer` (`connect(document)`, `update()`, `getElapsed()`);
  "ShaderMaterial({glslVersion:THREE.GLSL3})"⇒leave unset(already ES 3.00;GLSL3 breaks `gl_FragColor`);
  "RawShaderMaterial uniforms:{modelViewMatrix}"⇒declare `uniform mat4 modelViewMatrix;` in GLSL,omit from `uniforms`;
  "LineBasicMaterial({linewidth:5})"⇒`new Line2(new LineGeometry().setPositions(...),new LineMaterial({linewidth:5}))`;
  "ShaderMaterial under WebGPURenderer"⇒use `MeshBasicNodeMaterial`/TSL;
  '"three/nodes"'⇒'"three/tsl"'(nodes from `"three/tsl"`,node mats from `"three/webgpu"`);
  'import {MeshStandardNodeMaterial} from "three"'⇒import from `"three/webgpu"`;
  "PointsMaterial({size:5}) on WebGPU"⇒`Sprite(PointsNodeMaterial({positionNode:instancedBufferAttribute(...)}))`+`count`;
  "positionNode=positionGeometry.add(...)"⇒use `positionLocal`(carries skinning/morphs/batching/instancing);
  "map.encoding=THREE.sRGBEncoding"⇒`map.colorSpace=THREE.SRGBColorSpace`;
  "MeshStandardNodeMaterial unlit"⇒use `MeshBasicNodeMaterial`(Standard renders black w/o lights/env);
  "ShaderMaterial({extensions:{derivatives:true}})"⇒omit(ES 3.00 has dFdx/gl_FragDepth/textureLod built in)
}

§REL{
  "threejs-textures":"loading, color spaces, filters, channels";
  "threejs-shaders":"GLSL authoring, shader chunks, WebGLRenderer debug";
  "threejs-lighting":"lights, shadows, material interaction"
}
