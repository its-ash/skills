@REF:vue
§SCOPE{Vue3(`<script setup>`)|Pinia|Vue_Router|Vitest|Vue3.5+|Nuxt_diffs([nuxt.md](nuxt.md))}
§PROJ{
  tree:`src/{api,assets,components/{base,features},composables,layouts,pages,router,stores,types,utils,App.vue}`;
  naming:{`PascalCase.vue`:comps(`vue/multi-word-component-names`);`useCamelCase.ts`:composables;`camelCase.ts`:utils|api|types;`kebab-case/`:routes|features}
}
§COMP{
  sfc:`<script setup lang="ts">`[1:imports(vue→eco→abs→rel);2:props/emits/slots;3:composables;4:state(ref/reactive);5:computed;6:methods;7:watch;8:lifecycle]→`<template>`→`<style scoped>`;
  split:Container(fetch,state,effects)→Presentational(props_in,emits_out,¬API,¬store);
  props:`const props=withDefaults(defineProps<{label:string;variant?:"primary"|"secondary";disabled?:boolean;items:Item[]}>(),{variant:"primary",disabled:false})`;
  emits:`const emit=defineEmits<{submit:[];"update:modelValue":[value:string];select:[id:string,index:number]}>()`;
  rules:type+`required`/`default`;bool=`isXxx|hasXxx|canXxx`;¬mutate_props(emit|v-model|`defineModel()`@3.4+);tpl_kebab(`@update:model-value`)∧script_camel(`emit("update:modelValue",v)`)
}
§COMP_API{
  ex:`export function useDebounce<T>(value:MaybeRef<T>,delay:number):Ref<T>{const debounced=ref(toValue(value))as Ref<T>;let t:ReturnType<typeof setTimeout>;watch(()=>toValue(value),(v)=>{clearTimeout(t);t=setTimeout(()=>{debounced.value=v},delay)});onUnmounted(()=>clearTimeout(t));return readonly(debounced)}`;
  rules:`use*`_prefix;return_reactive(`ref|computed|reactive`,¬primitives);accept_`MaybeRef|toRef()|toValue()`;cleanup@`onUnmounted`|watcher_`onCleanup`;¬module_side_effects;replaces_Vue2_mixins(opaque_flow,source/name_collisions)
}
§STATE{
  tier:{local:`ref()/reactive()`;parent_child:Props+Emits;DI:`provide/inject`(theme,cfg,plugin);global:Pinia_Setup_Store;server:fetch/TanStack_Query_composable};
  pinia:`export const useCartStore=defineStore("cart",()=>{const items=ref<CartItem[]>([]),isLoading=ref(false),totalPrice=computed(()=>items.value.reduce((s,i)=>s+i.price*i.quantity,0));async function addItem(id:string){isLoading.value=true;try{const item=await fetchProduct(id),ex=items.value.find(i=>i.id===item.id);ex?ex.quantity++:items.value.push({...item,quantity:1})}finally{isLoading.value=false}}return{items,isLoading,totalPrice,addItem}})`;
  rules:Setup_Store>Options_Store;actions_for_mutations;`$patch()`_grouped_updates;async_handles_loading+success+error
}
§ROUTER{
  route:`{path:"/users/:id",name:"user-detail",component:()=>import("@/pages/UserDetail.vue"),props:true,meta:{requiresAuth:true}}`;
  guard:`router.beforeEach((to)=>{if(to.meta.requiresAuth&&!useAuthStore().isLoggedIn)return{name:"login",query:{redirect:to.fullPath}}})`;
  param:`const id=computed(()=>useRoute().params.id as string);watch(id,(v)=>fetchItem(v))`
}
§TPL{
  cond:`v-if`/`v-else-if`/`v-else`⊕`v-show`(frequent_toggle);
  list:`v-for="item in activeItems" :key="item.id"`(computed_filter,¬`v-if`+`v-for`on_same_el);
  forms:`@submit.prevent`,`<input v-model="name"/>`,`<CustomInput v-model="v" v-model:title="t"/>`
}
§PERF{`v-memo`:rare_list_Δ|`v-once`:static_forever|`shallowRef()`:wholesale_replace|`shallowReactive()`:top_level_only|`v-show`>`v-if`:frequent_toggle|`<KeepAlive :max="10">`:cache_views|lazy:`()=>import(...)`|`Suspense`:async_fallback}
§TEST{
  stack:Vitest|`@vue/test-utils`|`@pinia/testing`|Playwright;
  ex:`beforeEach(()=>setActivePinia(createPinia()));const w=mount(UserCard,{props:{user:{id:"1",name:"Alice"}}});expect(w.text()).toContain("Alice");await w.find("button").trigger("click");expect(w.emitted("select")![0]).toEqual(["1"])`
}
§NUXT{
  auto_import:`ref,computed,watch,useFetch,useAsyncData`(explicit_import_in_non-Nuxt);
  fetch:`const{data,pending,error,refresh}=await useAsyncData("user",()=>$fetch(\`/api/users/\${id}\`))`;`await useFetch("/api/posts",{query:{page:1},key:"posts-page-1"})`;
  api(`server/api/users/[id].ts`):`defineEventHandler(async(e)=>{const{id}=await getValidatedRouterParams(e,z.object({id:z.string().uuid()}).parse)})`;
  cfg(`nuxt.config.ts`):`defineNuxtConfig({runtimeConfig:{apiSecret:"",public:{apiBase:"https://api.example.com"}}})`
}
§V35{
  props_destructure:`const{count=0,msg="hello"}=defineProps<{count?:number;msg?:string}>()`∧`watch(()=>count,(v)=>{...})`(getter_req);
  `useTemplateRef<HTMLInputElement>("input")`(matches_`ref="input"`,dynamic:`useTemplateRef(id)`);
  `onWatcherCleanup(()=>ctrl.abort())`(sync_inside_watch_cb);
  `useId()`(SSR-stable_ID);
  `<Teleport defer to="#container">`(same-cycle_target);
  lazy_SSR:`defineAsyncComponent({loader:()=>import("./Comp.vue"),hydrate:hydrateOnVisible()})`
}
§ANTI{
  destructure_`defineProps()`@Vue<3.5→loses_reactivity⇒`props.x`|`toRefs()`;
  `watch(destructuredProp)`@3.5+→compile_err⇒`watch(()=>count,...)`;
  `v-if`+`v-for`same_el→ambiguous⇒computed_list;
  `:key="index"`→broken_reorder⇒stable_DB_ID;
  mutate_props→emit|`v-model`;
  `v-html`+user_input→XSS⇒DOMPurify;
  mixins@Vue3→composables;
  module_effects@composable→`onMounted`+`onUnmounted`;
  `reactive()`_replaceable_state→`ref()`;
  watcher_no_cleanup→leak/race⇒`onCleanup`|`onWatcherCleanup()`;
  Options_API@Vue3→`<script setup>`;
  plain_ref_template_ref→`useTemplateRef()`@3.5+
}
§REL{nuxt.md|vite.md|ui-to-vue.md|../../web-quality-audit/references/web-accessibility.md|../../typescript/SKILL.md|../../clean-code/SKILL.md}
