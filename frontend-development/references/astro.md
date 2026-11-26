@REF:astro
§DEF{Astro:content_SSG_optSSR|static_HTML_default+JS_islands|multi_fw(React,Vue,Svelte,Solid)}
§WHEN{blog∨docs∨marketing∨portfolio∨ecomm|CWV_priority|MD/MDX|SSG⊕SSR|`.astro`∨`Astro.props`∨content_collections∨`client:*`}

§CMD{
  init:`npm create astro@latest my-site && cd my-site && npm install && npm run dev`;
  add:`npx astro add tailwind|react|mdx|sitemap|vercel`;
  build:`npm run build`→verify_`dist/`_JS_minimal
}

§LAYOUT{`src/pages/`(routes:`.astro`,`.md`,`.mdx`),`src/layouts/`(shells+`<slot />`),`src/components/`(`.astro`,`.tsx`,`.vue`),`src/content/`(typed_MD/MDX:`config.ts`),`src/styles/`(global_CSS),`public/`(static_verbatim),`astro.config.mjs`}

§SYNTAX{
  `---`frontmatter`---`:server_only;
  props:`interface Props{title:string;href:string;description?:string}`→`const{...}=Astro.props`(autocomplete);
  `<style>`:auto_scoped;`:global()`⇔intentional_only
}

§ROUTE{
  `src/pages/index.astro`→`/`;`about.astro`→`/about`;`blog/[slug].astro`→`/blog/:slug`;`blog/[...path].astro`→`/blog/*`;
  SSG:`export async function getStaticPaths(){const posts=await getCollection('blog');return posts.map(p=>({params:{slug:p.slug},props:{post:p}}));}`→`const{post}=Astro.props;const{Content}=await post.render();`
}

§CONTENT{
  `src/content/config.ts`:`import{z,defineCollection}from'astro:content';const blog=defineCollection({type:'content',schema:z.object({title:z.string(),date:z.coerce.date(),tags:z.array(z.string()).default([]),draft:z.boolean().default(false)})});export const collections={blog};`;
  consume:`(await getCollection('blog')).filter(p=>!p.data.draft).sort((a,b)=>b.data.date.valueOf()-a.data.date.valueOf())`→`/blog/${post.slug}`,`post.data.title`,`post.data.date.toLocaleDateString()`;
  watch:content_files_auto|Δ`content/config.ts`⇒restart_dev_server
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
  `astro.config.mjs`:`import{defineConfig}from'astro/config';import vercel from'@astrojs/vercel/serverless';export default defineConfig({output:'hybrid',adapter:vercel()});`(`output∈{'static','server','hybrid'}`);
  opt_out_prerender:`export const prerender=false;`;
  RSS(`src/pages/rss.xml.ts`):`import rss from'@astrojs/rss';export async function GET(ctx){const posts=await getCollection('blog');return rss({title:'...',description:'...',site:ctx.site,items:posts.map(p=>({title:p.data.title,pubDate:p.data.date,link:`/blog/${p.slug}/`}))});}`;
  API(`src/pages/api/subscribe.ts`):`export const POST:APIRoute=async({request})=>{const{email}=await request.json();if(!email)return new Response(JSON.stringify({error:'Email required'}),{status:400,headers:{'Content-Type':'application/json'}});...return new Response(JSON.stringify({success:true}),{status:200});};`
}

§R{
  1:most_UI≡`.astro`∧hydrate_interactive_only(¬`client:load`_on_all);
  2:all_MD/MDX∈content_collections(z_schema);
  3:smooth_nav⇒`<ViewTransitions />`from`astro:transitions`;
  4:layouts_use_`<slot />`;
  5:env:`import.meta.env.PUBLIC_*`⇒client|others⇒server_only;¬secrets_in_frontmatter(may_be_logged);
  6:SSR_routes⇒validate_request_data_before_DB/API;
  7:`set:html`+user_HTML⇒sanitize_first(¬XSS)
}

§PITFALL{
  no_interactivity⇒add_`client:*`;
  `getStaticPaths`_stale⇒restart_dev_on_`content/config.ts`_Δ;
  no_`Astro.props`_types⇒declare_`Props`_interface/type;
  style_leak⇒`<style>`auto_scoped;`:global()`_only_intentional
}

§CHK{create+deps→`output`+adapter(`astro.config.mjs`)→`content/config.ts`_schemas→`src/pages`(`.astro`/`.md`/`.mdx`)→`client:*`_interactive_only→layouts+`<slot />`→`PUBLIC_*`_vs_server_env→test_SSR_validation→`npm run build`+inspect_`dist/`_JS→deploy+monitor_CWV}

§REL{[frontend-development](../SKILL.md)|[nextjs](nextjs.md)|[web-performance](../../web-quality-audit/references/web-performance.md)|[typescript](../../typescript/SKILL.md)}
