@REF:nuxt
§SCOPE{Nuxt4(`4.6.x`;Nuxt3_EOL_2026-07-31⇒migrate_to_v4):`app/`_dir,hydration,routeRules,lazy,SSR_fetch;Vue3→vue.md;when:hydration_mismatch|render_mode(prerender,SWR,ISR,CSR)|lazy/payload|`useFetch`/`useAsyncData`/`$fetch`|params/middleware/SSR_diff}
§PROJ{`app/{app.vue(<NuxtPage/>),pages/,components/,composables/,layouts/,middleware/}`,`server/api/`,`public/`,`nuxt.config.ts`}
§HYD{1st_render_det:¬(Date.now()|Math.random()|browser_APIs|storage) in SSR_tmpl;browser→`onMounted()`|`import.meta.client`|`<ClientOnly>`|`.client.vue`;route:Nuxt `useRoute()`(¬`vue-router`);¬`route.fullPath` in SSR(fragments_client⇒mismatch);`ssr:false`=escape_hatch(browser_only),¬mismatch_fix}
§FETCH{
  `await useFetch()`:SSR_reads(payload_fwd,no_re-fetch);
  `useAsyncData(keyFn,fn)`:non-simple `$fetch()`|custom_key|multi_async;stable_key;side-effect_free(SSR+hyd);
  `$fetch()`:user_writes|client_actions,¬top_page_data;
  non_crit:`lazy:true`|`useLazyFetch()`|`useLazyAsyncData()`(non-blocking;handle `status==='pending'`∈`{'idle','pending','success','error'}`);
  `server:false`:ONLY ¬SEO∧¬1st_paint;trim:`pick`∧shallow_payload;
  ex:`const{data,status,error,refresh}=await useAsyncData(()=>`article:${route.params.slug}`,()=>$fetch(`/api/articles/${route.params.slug}`))`;`await useFetch(`/api/articles/${route.params.slug}/comments`,{lazy:true,server:false})`
}
§CFG{`nuxt.config.ts` `defineNuxtConfig({routeRules:{...}})` per_group(¬global):`'/'`:`{prerender:true}`(build_HTML);`'/products/**'`:`{swr:3600}`(cached+bg_reval);`'/blog/**'`:`{isr:true}`(platform_ISR);`'/admin/**'`:`{ssr:false}`(CSR);`'/api/**'`:`{cache:{maxAge:3600}}`(Nitro_cache|redirect);PWA⇒`@vite-pwa/nuxt`}
§PERF{auto_route_split(clean route_bounds pre-micro-split);`Lazy`+`v-if`(`<LazyRecommendations v-if="show"/>`⇒on-demand);lazy_hyd(below-fold/non-crit_SFC):`<LazyProductGallery hydrate-on-visible/>`∨`defineLazyHydrationComponent()`(visibility|idle;SFC_only,new_props⇒immediate);`<NuxtLink>`⇒prefetch chunks+payloads}
§CHK{`app/`_dir_layout;SSR≡client_markup;page_data∈{useFetch,useAsyncData}(¬top_$fetch);lazy+`status==='pending'`_UI;routeRules_fit_SEO/freshness;lazy_load/hydrate_islands}
§REL{vue.md:Vue3_Pinia3_Router;vite.md:Vite8_Nuxt_build}
