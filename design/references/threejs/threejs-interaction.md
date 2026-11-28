@REF:threejs-interaction

§META{target:three.js@r187;renderers:WebGLRenderer⊕WebGPURenderer("three/webgpu");addons:"three/addons/..."}

§PAT{quick_start|
  events:pointerdown|pointermove|pointerup⇒mouse+touch+pen(¬separate touch listeners);
  ndc:r=domElement.getBoundingClientRect();pointer.set(((e.clientX-r.left)/r.width)*2-1,-((e.clientY-r.top)/r.height)*2+1);
  timer:new THREE.Timer();timer.connect(document)⇒freezes delta when tab hidden(Clock deprecated r183);
  loop:renderer.setAnimationLoop(()=>{timer.update();controls.update(timer.getDelta());renderer.render(scene,camera);})(WebXR compat;¬rAF);
  pick:raycaster.setFromCamera(pointer,camera);hits=raycaster.intersectObject(mesh)
}

§PAT{raycasting|
  rules:backface¬hit unless material.side=THREE.DoubleSide;grazing shared edge⇒≤2 coincident hits;invisible meshes ARE raycast(tests layers,¬visible⇒invisible simple proxy valid);
  api:intersectObject(obj)/*recursive=true def*/;prefer intersectObjects(clickables,false)/*minimal mesh list,¬scene.children;sorted closest-first*/;
  hit:{distance:num/*world*/,point:Vector3/*world*/,face:{a,b,c,normal/*obj*/,materialIndex}/*plain obj;¬Face3*/,faceIndex:num,object:Object3D,uv?:Vector2,uv1?:Vector2,normal:Vector3/*interp obj normal,flipped toward ray*/,barycoord:Vector3,instanceId?:num/*InstancedMesh*/,batchId?:num/*BatchedMesh*/,distanceToRay?:num/*Points*/};
  cfg:raycaster.set(origin,dir.normalize());near=0.1;far=10;params.Points.threshold=0.2;params.Line.threshold=0.2/*world units,def=1*/;
  layers:mesh.layers.enable(1)/*keeps 0(cam renders)+1*/;mesh.layers.set(1)/*strips 0⇒pick-only proxy*/;raycaster.layers.set(1)/*tests 1 only;enable(1) tests 0∧1*/;
  plane_drag:groundPlane=new THREE.Plane(new THREE.Vector3(0,1,0),0);e.buttons!==0∧raycaster.ray.intersectPlane(groundPlane,hit)!==null⇒mesh.position.copy(hit)/*intersectPlane=null if parallel∨pointing away*/
}

§CFG{camera_controls|base:Controls|
  base:ctor(camera,domElement)/*except DragControls(objects,camera,domElement)*/,auto-wires listeners;enabled=false;disconnect();connect(el);dispose();update(deltaSec)/*pass timer.getDelta() for Orbit,Fly,FirstPerson;no args for Trackball*/;
  OrbitControls("three/addons/controls/OrbitControls.js"):{enableDamping:true/*req update()/frame*/,dampingFactor:0.05,minDistance,maxDistance,minPolarAngle,maxPolarAngle/*rad,e.g.Math.PI/2*/,minAzimuthAngle,maxAzimuthAngle,target:Vector3,zoomToCursor:true,autoRotate:true/*req update(delta) for Hz-indep;stops at azimuth limit*/,autoRotateSpeed:2.0,events:["change","start","end"]};
  MapControls("three/addons/controls/MapControls.js"):OrbitControls_sub{LMB:pan,RMB∨(LMB+ctrl|meta|shift):orbit,MMB|wheel:zoom,screenSpacePanning:false/*ground-parallel*/,inherits_OrbitOpts};
  FlyControls("three/addons/controls/FlyControls.js"):{movementSpeed:10,rollSpeed:Math.PI/24,dragToLook:true,update:"req delta(else NaN)"};
  FirstPersonControls("three/addons/controls/FirstPersonControls.js"):{input:"drag-look(speed∝dist,eased via dampingFactor)+WASD/arrows+R/F(up/down)+LMB(fwd)+RMB(back)+touch(1f:fwd,2f:back)",movementSpeed:10,lookSpeed:0.005/*0 disables;¬activeLook*/,dampingFactor:0.1/*1 disables easing*/,constrainVertical:true,verticalMin,verticalMax,update:"req delta(else NaN)"};
  PointerLockControls("three/addons/controls/PointerLockControls.js"):{ctor:"(camera,document.body)",pointerSpeed:1.0,events:["lock","unlock"],lock:"controls.lock()/*req user gesture*/",isLocked:bool,move:"moveForward(d)|moveRight(d)/*xz-plane*/",damp:"THREE.MathUtils.damp(vel.z,target,10,delta)",flags:"let moveForward=false/*¬const*/",object:"controls.object/*getObject() removed r168;scene.add(object) only if cam has children*/"};
  TrackballControls("three/addons/controls/TrackballControls.js"):{rotateSpeed:2.0,zoomSpeed:1.2,panSpeed:0.8,staticMoving:true/*no inertia;else dynamicDampingFactor def 0.2*/,update:"no delta",resize:"controls.handleResize()"}
}

§CFG{transform_drag|
  TransformControls("three/addons/controls/TransformControls.js"):{note:"EventDispatcher,¬Object3D⇒scene.add(tc.getHelper())",api:"attach(mesh)|detach()|setMode('translate'|'rotate'|'scale')|setSpace('local'|'world')/*scale always local*/|setSize(0.8)|setTranslationSnap(0.5)|setRotationSnap(THREE.MathUtils.degToRad(15))|setScaleSnap(0.25)",events:{"dragging-changed":"orbitControls.enabled=!e.value",objectChange:"fires on move"},keys:"g:translate,r:rotate,s:scale,Escape:detach()"};
  DragControls("three/addons/controls/DragControls.js"):{ctor:"([mesh],camera,renderer.domElement)",input:"LMB|MMB:screen-parallel pan;RMB:rotate around cam up/right",rotateSpeed:1,mouseButtons:{LEFT:THREE.MOUSE.PAN,MIDDLE:THREE.MOUSE.PAN,RIGHT:THREE.MOUSE.ROTATE},transformGroup:"true⇒drags outermost Group(objects=[group]);e.object=Group(no material⇒e.object.material?.emissive?.set(...))",events:["dragstart","drag","dragend"],r168:"dc.raycaster(was getRaycaster())|dc.objects(was getObjects())|dc.connect(el)/disconnect()(was activate/deactivate;connect() req el or TypeError)"}
}

§PAT{selection_coords|
  single_select:hit=raycaster.intersectObjects(selectable,false)[0];clear prev selected.material.emissive.set(0x000000)→set new 0x444444;hover:document.body.style.cursor=hit?"pointer":"default";
  teardown:keep named listener refs for removeEventListener;controls.dispose() ∀controls;timer.dispose();
  box_select("three/addons/interactive/SelectionBox.js","SelectionHelper.js"):{SelectionBox:"new SelectionBox(camera,scene);selects bounding-sphere center∈screen rect;InstancedMesh→sb.instances;BatchedMesh→sb.batches",SelectionHelper:"new SelectionHelper(renderer,'selectBox')⇒<div class='selectBox'>(CSS req position:fixed,border,background)",flow:"ndc(e)=Vector3((clientX/innerWidth)*2-1,-(clientY/innerHeight)*2+1,0.5);pointerdown→startPoint.copy(ndc);pointermove(if helper.isDown)→endPoint.copy(ndc);pointerup→endPoint.copy(ndc)+sb.select()",teardown:"helper.dispose()"};
  world_to_screen:ndc=mesh.getWorldPosition(new THREE.Vector3()).project(camera);x=((ndc.x+1)/2)*innerWidth;y=((-ndc.y+1)/2)*innerHeight;ndc.z∉[-1,1]⇒outside near..far;
  screen_to_world:wp=new THREE.Vector3(nx,ny,0.5).unproject(camera);dir=wp.sub(camera.position).normalize();dist=-camera.position.z/dir.z/*misses if dir.z===0*/;world=camera.position.clone().addScaledVector(dir,dist)/*equiv setFromCamera+intersectPlane*/
}

§CFG{webgpu_tsl|
  neutral:Controls∧Raycaster run unchanged on WebGPURenderer("three/webgpu");
  init:const renderer=new THREE.WebGPURenderer({antialias:true});await renderer.init()/*req before any use*/;
  bg:WebGPU canvas transparent by default⇒set scene.background;
  picking:Raycaster tests CPU geometry only⇒ignores TSL positionNode displacement⇒pick undisplaced proxy mesh
}

§ANTI{common_mistakes|
  "scene.add(tc)"→"scene.add(tc.getHelper())"/*TransformControls=EventDispatcher,¬Object3D*/;
  "new OrbitControls(cam)"→"new OrbitControls(cam,renderer.domElement)"/*no input listeners*/;
  "controls.update(clock.getDelta())"→"timer.update();controls.update(timer.getDelta())"/*Clock deprecated r183*/;
  "three/examples/jsm/..."→"three/addons/..."/*import maps omit three/examples/*/;
  "requestAnimationFrame(animate)"→"renderer.setAnimationLoop(animate)"/*WebXR compat*/;
  "flyControls.update()|firstPersonControls.update()"→"pass timer.getDelta()"/*else NaN pos*/;
  "orbitControls.update()"→"pass timer.getDelta()"/*autoRotate speed tied to Hz without delta*/;
  "mesh.layers.set(1)"→"mesh.layers.enable(1)"/*set strips layer 0⇒cam stops rendering*/;
  "hit.face instanceof THREE.Face3"→"hit.face.normal"/*Face3 removed;plain obj*/;
  "const moveForward=false"→"let moveForward=false"/*keydown reassign throws TypeError*/;
  "controls.getObject()"→"controls.object"/*removed r168*/;
  "dc.getObjects()|dc.getRaycaster()"→"dc.objects|dc.raycaster"/*removed r168*/;
  "dc.activate()|dc.deactivate()"→"dc.connect(el)|dc.disconnect()"/*renamed r168;connect() req el*/;
  "firstPersonControls.activeLook=false"→"firstPersonControls.lookSpeed=0"/*no activeLook prop*/
}

§REL{threejs-fundamentals:scene_camera_renderer_loop;threejs-animation:animate_on_interaction;threejs-postprocessing:outline_bloom_selection;threejs-loaders:interactive_gltf;threejs-react-three-fiber:r3f_pointer_events_drei_controls}
