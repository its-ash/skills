@REF:gsap-frameworks
§SCOPE{
  use:Vue|Nuxt|Svelte|SvelteKit|Angular22|lifecycle_frameworks;
  react⇒gsap-react(useGSAP,gsap.context(),contextSafe);
  rel:{gsap-core:tweens,gsap-timeline:timelines,gsap-scrolltrigger:scroll,gsap-react:React}
}
§R{
  1:create_tweens+ScrollTriggers_ONLY_after_DOM_mounted;
  2:revert_on_unmount/destroy(`ctx.revert()`)⇒kills_anims+ScrollTriggers,reverts_inline_styles,no_detached_leaks;
  3:scope_selectors:`gsap.context(cb,scopeRoot)`(prevents_global_bleed)
}
§VUE3{
  ex:`examples/vue/`;
  reg:`gsap.registerPlugin(ScrollTrigger)`_once_at_app_root(main.js);
  pat:```js
// Composition API & <script setup>
const container=ref(null); let ctx;
onMounted(()=>{ if(!container.value)return; ctx=gsap.context(()=>{ gsap.to(".box",{x:100,duration:0.6}); gsap.from(".item",{autoAlpha:0,y:20,stagger:0.1}); },container.value); });
onUnmounted(()=>ctx?.revert());
```
}
§NUXT4{
  ex:`examples/nuxt/`;
  pat:`composables/useGSAP.ts`→register_core+typed_`lazyLoadPlugin`(reduces_initial_bundle);
  code:```ts
import {gsap} from "gsap";
import {ScrollTrigger} from "gsap/ScrollTrigger";
const pluginMap={
  CSSRulePlugin:()=>import("gsap/CSSRulePlugin"),CustomBounce:()=>import("gsap/CustomBounce"),
  CustomEase:()=>import("gsap/CustomEase"),CustomWiggle:()=>import("gsap/CustomWiggle"),
  Draggable:()=>import("gsap/Draggable"),DrawSVGPlugin:()=>import("gsap/DrawSVGPlugin"),
  EaselPlugin:()=>import("gsap/EaselPlugin"),EasePack:()=>import("gsap/EasePack"),
  Flip:()=>import("gsap/Flip"),GSDevTools:()=>import("gsap/GSDevTools"),
  InertiaPlugin:()=>import("gsap/InertiaPlugin"),MorphSVGPlugin:()=>import("gsap/MorphSVGPlugin"),
  MotionPathHelper:()=>import("gsap/MotionPathHelper"),MotionPathPlugin:()=>import("gsap/MotionPathPlugin"),
  Observer:()=>import("gsap/Observer"),Physics2DPlugin:()=>import("gsap/Physics2DPlugin"),
  PhysicsPropsPlugin:()=>import("gsap/PhysicsPropsPlugin"),PixiPlugin:()=>import("gsap/PixiPlugin"),
  ScrambleTextPlugin:()=>import("gsap/ScrambleTextPlugin"),ScrollSmoother:()=>import("gsap/ScrollSmoother"),
  ScrollToPlugin:()=>import("gsap/ScrollToPlugin"),ScrollTrigger:()=>import("gsap/ScrollTrigger"),
  SplitText:()=>import("gsap/SplitText"),TextPlugin:()=>import("gsap/TextPlugin"),
} as const;
type PluginMap=typeof pluginMap; type Plugins=keyof PluginMap;
type PluginModule<K extends Plugins>=Awaited<ReturnType<PluginMap[K]>>;
type PluginExport<K extends Plugins>=PluginModule<K>[K&keyof PluginModule<K>];
export default function(){
  gsap.registerPlugin(ScrollTrigger);
  async function lazyLoadPlugin<K extends Plugins>(plugin:K):Promise<PluginExport<K>>{
    const m=await pluginMap[plugin](); const p=(m as any)[plugin];
    gsap.registerPlugin(p); return p;
  }
  return {gsap,ScrollTrigger,lazyLoadPlugin};
}
```;
  use:`const {gsap,ScrollTrigger,lazyLoadPlugin}=useGSAP()`+`gsap.context(scope)`+`onUnmounted→ctx.revert()`
}
§SVELTE{
  v5:`$effect`+`bind:this={container}`+`return()=>ctx.revert()`;
  v4:`onMount`+`return()=>ctx.revert()`;
  pat:```js
let container;
$effect(()=>{ const ctx=gsap.context(()=>{ gsap.to(".box",{x:100}); gsap.from(".item",{autoAlpha:0,stagger:0.1}); },container); return()=>ctx.revert(); });
```
}
§ANGULAR22{create:`afterNextRender()`;destroy:`DestroyRef.onDestroy()`;signals:`effect()`}
§SCROLLTRIGGER{
  ctx:`scrollTrigger`vars∨`ScrollTrigger.create()`_in_`gsap.context()`⇒auto-reverted_by_`ctx.revert()`;
  refresh:`ScrollTrigger.refresh()`_after_async_DOM/layout_updates(Vue:`nextTick`,Svelte:`tick`)
}
§ANTI{
  ¬create_before_mount(setup_without_onMounted∨sync_top_level);
  ¬global_selectors_without_scope_in_`gsap.context()`;
  ¬skip_`ctx.revert()`;
  ¬`gsap.registerPlugin()`_in_per-render_component_body(app_root_once)
}
