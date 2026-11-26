@REF:nextjs
§BASE{
  Next.js_16.4(AppRouter)∧React_19.3∧Turbopack∧CacheComponents∧ServerActions∧Supabase(@supabase/ssr);
  Node≥20.9(24|26_LTS)∧next.config.ts∧(ESLint9(`eslint-config-next`)∨Biome2);`next lint` removed⇒run `eslint`∨`biome`
}
§COMP{
  default:Server(¬directive;fetch,static,layout,SEO);
  client:'use client'@top⇔useState|useEffect|handlers|browser_APIs;
  hybrid⇒Server_parent(await fetchStats())→<DashboardClient stats={stats}/>('use client'@top,owns useState)
}
§FETCH{
  Next15+ `fetch` uncached_default⇒opt_in;
  patterns:{dynamic:fetch(url)(no_cache,per_req);isr:fetch(url,{next:{revalidate:60}})(throw if !res.ok);cache_comp:next.config.ts{cacheComponents:true}∧`'use cache'`+cacheLife('hours')+cacheTag('posts')←`next/cache`(PPR_shells)};
  async_APIs:∀(params:Promise<{id:string}>,searchParams,cookies(),headers(),draftMode())⇒ALWAYS `await`
}
§ROUTE{
  files:{page.tsx:UI,layout.tsx:shared_nested,loading.tsx:streaming_fallback,error.tsx:error_boundary,not-found.tsx:404};
  org:{`(group)`:no_URL,`@slot`:parallel,`(.seg)`:intercepting_modal}
}
§API{
  `app/api/<resource>/route.ts`;Zod4(`z.email()`,safeParse→400|201)∧JSON_errors∧HTTP_status;
  runtime:Node_default(`export const runtime='edge'` ONLY light_edge);`after()`(`next/server`)⇒post-response_work(logs,analytics)
}
§PERF{
  `next/image`(auto_resize,lazy,AVIF|WebP)+`priority`(above_fold)+`blurDataURL`;
  split:`dynamic(()=>import('@/components/HeavyChart'),{ssr:false})`∧auto_per_route∧`experimental.optimizePackageImports`;
  analyze:`@next/bundle-analyzer`({enabled:process.env.ANALYZE==='true'})→`ANALYZE=true next build`;Next.js_DevTools_MCP
}
§META{
  static:`export const metadata`(layout|page);
  dynamic:`generateMetadata({params}:{params:Promise<{id:string}>}):Promise<Metadata>`({title,description,openGraph:{images:[{url}]},alternates:{canonical}});
  seo:title∈50..60c∧description∈150..160c
}
§CACHE{
  req:fetch({next:{revalidate,tags},cache});fn:`'use cache'`+cacheLife()+cacheTag();
  inval:{revalidateTag('posts'):bg,updateTag('posts'):immediate_ServerAction,revalidatePath():path};
  route:`export const revalidate=<sec>` in page.tsx ∨ PPR+CacheComponents
}
§ACT{
  `'use server'`@top(`app/actions.ts`);client:useActionState+useOptimistic;
  `createPost(prev:{error?:string},formData:FormData)`→`schema.safeParse(Object.fromEntries(formData))`→mutate→`updateTag('posts')`→typed_plain_val(¬raw_errors)
}
§AUTH{
  @supabase/ssr cookies;NEVER service_role_key in browser|SSR(`NEXT_PUBLIC_SUPABASE_URL`+`NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`);
  authz:ALWAYS `supabase.auth.getUser()`(¬`getSession()`);new_client_per_req;
  `lib/supabase/server.ts`:
```ts
export async function createClient(){
  const c=await cookies();
  return createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,{
    cookies:{getAll:()=>c.getAll(),setAll:l=>{try{l.forEach(({name,value,options})=>c.set(name,value,options))}catch{}}}
  });
}
```
  `proxy.ts`(@root,Node_default):
```ts
export async function proxy(request:NextRequest){
  let response=NextResponse.next({request});
  const supabase=createServerClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,{
    cookies:{getAll:()=>request.cookies.getAll(),setAll:l=>{l.forEach(({name,value})=>request.cookies.set(name,value));response=NextResponse.next({request});l.forEach(({name,value,options})=>response.cookies.set(name,value,options));}}
  });
  const{data:{user}}=await supabase.auth.getUser(),url=request.nextUrl.clone();
  if(['/dashboard','/account'].some(p=>url.pathname.startsWith(p))&&!user){url.pathname='/login';return NextResponse.redirect(url);}
  return response;
}
export const config={matcher:['/((?!api|_next/static|_next/image|favicon.ico).*)']};
```
  oauth_cb(`app/auth/callback/route.ts`):`code`∈searchParams→`exchangeCodeForSession(code)`→redirect `/`,else→`/login`;
  client_logout:`createBrowserClient(URL,PUBLISHABLE_KEY)`→`await supabase.auth.signOut()`→`window.location.href='/login'`
}
§TURBO{
  Turbopack default(`next dev`,`next build`,`.next` FS_cache—¬clear w/o reason);`--webpack` legacy_only;
  `proxy.ts`@root replaces `middleware.ts`,exports `proxy`(Node_default);NEVER flag/rename→`middleware.ts`(breaks);ref:https://nextjs.org/docs/app/getting-started/proxy
}
§ANTI{
  `'use client'` everywhere⇒Server_default;fetch in CC⇒SC|ServerAction+props;unawaited `params`/`cookies()`⇒await;skip `loading.tsx`⇒add;unsplit_CC⇒`dynamic()`;`getSession()`⇒`getUser()`;service_role_key in SSR⇒publishable_key+cookies
}
§CHK{SC_vs_CC;fetch_reval|cacheLife;req_APIs_awaited;route_conventions;Zod_API+status;next/image+priority;dynamic_heavy_CC;generateMetadata;cacheTag+revalidateTag/updateTag;ServerActions;Supabase_ssr+publishable_key;proxy.ts+getUser();OAuth_cb;loading/error_tested;`ANALYZE=true next build`}
§REL{../../typescript/SKILL.md:TypeScript;../../database-design/references/prisma.md:Prisma;../../seo/SKILL.md:SEO;../../web-quality-audit/references/web-performance.md:CWV_perf;astro.md:Astro;../../i18n-localization/SKILL.md:i18n}
