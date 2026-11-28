@REF:astro
§DEF{Astro_7(`7.4.x`,Vite_8+Rolldown,Rust_compiler,Node≥22.12,Zod4_via_`astro/zod`):content_SSG_optSSR|static_HTML_default+JS_islands|multi_fw(React,Vue,Svelte,Solid)}
§WHEN{blog∨docs∨marketing∨portfolio∨ecomm|CWV_priority|MD/MDX|SSG⊕SSR|`.astro`∨`Astro.props`∨content_collections∨`client:*`}

§CMD{
  init:`npm create astro@latest my-site && cd my-site && npm install && npm run dev`;
  add:`npx astro add tailwind|react|mdx|sitemap|vercel`;
  build:`npm run build`→verify_`dist/`_JS_minimal;diag:`npx astro build --timings`
}

§LAYOUT{`src/pages/`(routes:`.astro`,`.md`,`.mdx`),`src/layouts/`(shells+`<slot />`),`src/components/`(`.astro`,`.tsx`,`.vue`),`src/content.config.ts`(Content_Layer_config@`src/`_root,¬`src/content/config.ts`),`src/content/`(MD/MDX_files),`src/styles/`(global_CSS),`public/`(static_verbatim),`astro.config.mjs|ts`}

§SYNTAX{
  `---`frontmatter`---`:server_only;
  props:`interface Props{title:string;href:string;description?:string}`→`const{...}=Astro.props`(autocomplete);
  `<style>`:auto_scoped;`:global()`⇔intentional_only
}

§ROUTE{
  `src/pages/index.astro`→`/`;`about.astro`→`/about`;`blog/[slug].astro`→`/blog/:slug`;`blog/[...path].astro`→`/blog/*`;
  SSG(v5+):`import{getCollection,render}from'astro:content';export async function getStaticPaths(){const posts=await getCollection('blog');return posts.map(p=>({params:{slug:p.id},props:{post:p}}));}`→`const{post}=Astro.props;const{Content}=await render(post);`(¬`post.slug`,¬`post.render()`)
}

§CONTENT{
  `src/content.config.ts`(Content_Layer_API;legacy_`src/content/config.ts`_throws_`LegacyContentConfigError`_in_v6/v7):
  `import{defineCollection}from'astro:content';import{glob}from'astro/loaders';import{z}from'astro/zod';const blog=defineCollection({loader:glob({pattern:'**/*.{md,mdx}',base:'./src/content/blog'}),schema:z.object({title:z.string(),date:z.coerce.date(),tags:z.array(z.string()).default([]),draft:z.boolean().default(false)})});export const collections={blog};`;
  consume:`(await getCollection('blog')).filter(p=>!p.data.draft).toSorted((a,b)=>b.data.date.valueOf()-a.data.date.valueOf())`→`/blog/${post.id}`,`post.data.title`,`post.data.date.toLocaleDateString()`;
  watch:content_files_auto|Δ`src/content.config.ts`⇒restart_dev_server
}

§ISLANDS{
  no_directive⇒static_HTML(0_JS);
  `client:load`:page_load;
  `client:visible`:viewport_entry(prefer_over_`client:load`_below_fold);
  `client:idle`:main_thread_idle;
  `client:media="(max-width: 768px)"`:CSS_media_query;
  ex:`<SearchBox client:load />`(`useState`,`e.preventDefault()`,`fetch('/api/search?q=...')`)
}

§SSR{
  modes:`output∈{'static'(default;supports_per-route_SSR_with_adapter),'server'}`(`output:'hybrid'`_REMOVED_v5+);
  adapter:100%_static⇒¬adapter_needed;on-demand_routes|platform_features⇒`import vercel from'@astrojs/vercel';export default defineConfig({output:'static',adapter:vercel()});`(¬`@astrojs/vercel/serverless`);
  opt_out_prerender:`export const prerender=false;`;
  RSS(`src/pages/rss.xml.ts`):`import rss from'@astrojs/rss';export async function GET(ctx){const posts=await getCollection('blog');return rss({title:'...',description:'...',site:ctx.site,items:posts.map(p=>({title:p.data.title,pubDate:p.data.date,link:`/blog/${p.id}/`}))});}`;
  API(`src/pages/api/subscribe.ts`):`export const POST:APIRoute=async({request})=>{const{email}=await request.json();if(!email)return new Response(JSON.stringify({error:'Email required'}),{status:400,headers:{'Content-Type':'application/json'}});...return new Response(JSON.stringify({success:true}),{status:200});};`
}

§R{
  1:most_UI≡`.astro`∧hydrate_interactive_only(¬`client:load`_on_all);
  2:all_MD/MDX∈Content_Layer(`src/content.config.ts`+`glob()`/`file()`+`astro/zod`,¬`type:'content'`,¬`legacy.collections`);
  3:smooth_nav⇒`<ClientRouter />`from`astro:transitions`(replaces_removed_`<ViewTransitions />`;re-init_scripts_on_`astro:page-load`);
  4:layouts_use_`<slot />`;
  5:env:`import.meta.env.PUBLIC_*`⇒client|others⇒server_only;¬secrets_in_frontmatter(may_be_logged);
  6:SSR_routes⇒validate_request_data_before_DB/API;
  7:`set:html`+user_HTML⇒sanitize_first(¬XSS)
}

§PITFALL{
  no_interactivity⇒add_`client:*`;
  empty_collections|`LegacyContentConfigError`⇒move_to_`src/content.config.ts`+explicit_`loader:glob(...)`+restart_dev;
  `post.slug`/`post.render()`_undefined⇒use_`post.id`∧`await render(post)`from`'astro:content'`;
  no_`Astro.props`_types⇒declare_`Props`_interface/type;
  style_leak⇒`<style>`auto_scoped;`:global()`_only_intentional
}

§CHK{create+deps(Node≥22.12)→`output`+adapter(`astro.config.ts`)→`src/content.config.ts`(glob+`astro/zod`)→`src/pages`(use_`post.id`+`render(post)`)→`client:*`_interactive_only→layouts+`<slot />`+`<ClientRouter />`→`PUBLIC_*`_vs_server_env→test_SSR_validation→`npx astro build --timings`+inspect_`dist/`_JS→deploy+monitor_CWV}

§REL{[frontend-development](../SKILL.md)|[nextjs](nextjs.md)|[web-performance](../../web-quality-audit/references/web-performance.md)|[typescript](../../typescript/SKILL.md)}
