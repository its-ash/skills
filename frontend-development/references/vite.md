@REF:vite
§SCOPE{Vite 8.4+(`vite.config.ts|js`):Rolldown+Oxc|cfg|env|proxy|build_opt|`build.lib`|`optimizeDeps`|HMR|SSR|plugins|pitfalls}
§MECH{
  dev:native_ESM(¬bundle)→Oxc_transform/mod⇒fast_cold_start∧precise_HMR;
  build:Rolldown(v8_unified_Rust_bundler;replaces_Rollup+esbuild,10x-30x_faster)⇒tree_shake∧code_split∧Oxc_minify;
  prebundle:Rolldown(CJS|UMD→ESM;replaces_esbuild)→cache:`node_modules/.vite`;
  plugins:unified_iface(dev∧build,Rollup_API_compat);
  env:static_inline@build;`VITE_*`⇒pub_client_const;¬prefixed⇒invisible_client
}
§CFG{
  base:```ts
import{defineConfig,loadEnv}from'vite';import react from'@vitejs/plugin-react';
export default defineConfig(({command,mode})=>{
  const env=loadEnv(mode,process.cwd()); // VITE_ only
  return{plugins:[react()],resolve:{alias:{'@':new URL('./src',import.meta.url).pathname}},
    server:command==='serve'?{port:3000}:undefined,define:{__API_URL__:JSON.stringify(env.VITE_API_URL)}};
});
```;
  keys:{root:'.'(index.html);base:'/';envPrefix:'VITE_';oxc:{jsx:{runtime:'automatic'}}(replaces_`esbuild`);build.outDir:'dist';build.minify:'oxc'('oxc'|'terser'|false);build.sourcemap:false(true|'inline'|'hidden')}
}
§PLG{
  std:{
    '@vitejs/plugin-react'(v6):default_React_HMR(Babel-free,Oxc_FastRefresh,opt_Rust_ReactCompiler:`react({compiler:true})`);
    '@vitejs/plugin-react-swc':legacy_SWC_alt(¬needed_on_Vite8+);
    '@vitejs/plugin-vue':Vue3_SFC;
    'vite-plugin-checker':worker(tsc+ESLint)+HMR_overlay(REQ∀TS|`tsc --noEmit`@CI∵`vite build`¬typecheck);
    'vite-tsconfig-paths':honors_tsconfig_paths;
    'vite-plugin-dts':emit_.d.ts@lib_mode;
    'vite-plugin-svgr':SVG→React_comp;
    'rollup-plugin-visualizer':bundle_treemap/sunburst(`enforce:'post'`);
    'vite-plugin-pwa':PWA+Workbox
  };
  custom:inline@vite.config.ts→extract_if_reused;`function myPlugin():Plugin{return{name:'my-plugin',enforce:'pre',apply:'build',transform(code,id){if(id.endsWith('.custom'))return{code:transformCustom(code),map:null}}}}`;
  hooks:`transform`|`resolveId`+`load`(virtual_mod:`\0virtual:my-id`,import:`'virtual:my-id'`)|`transformIndexHtml`|`configureServer`|`hotUpdate`(v7+,replaces_`handleHotUpdate`);
  docs:https://vite.dev/guide/api-plugin;debug:`vite-plugin-inspect`
}
§HMR{
  scope:vanilla/custom_stores/devtools(framework_plg_auto);tree_shaken@prod;
  `if(import.meta.hot){import.meta.hot.data.count=import.meta.hot.data.count??0;import.meta.hot.dispose((d)=>clearInterval(d.intervalId));import.meta.hot.accept()}`(MUTATE props;¬reassign `.data`)
}
§ENV{
  order(later_wins):`.env`→`.env.local`→`.env.[mode]`→`.env.[mode].local`(`*.local`=gitignored_secrets);
  client:`import.meta.env.{VITE_API_URL,MODE('development'|'production'|custom),BASE_URL,DEV,PROD,SSR}`
}
§SEC{
  `VITE_`≠sec_boundary(static_inline;minify|base64|¬sourcemap¬hide)⇒only_public(URLs,flags,pub_keys)∈`VITE_*`;secrets(tokens,DB_URL,priv_keys)⇒server_API/serverless;
  loadEnv_trap:`loadEnv(mode,cwd,'')`❌(loads_ALL_secrets)⇒`loadEnv(mode,cwd,['VITE_','APP_'])`✅;
  sourcemap:`build.sourcemap:false`(prod)⊕upload→Sentry/Bugsnag∧rm_local;
  gitignore:[`.env.local`,`.env.*.local`,`dist/`,`node_modules/.vite`]
}
§NET{proxy:`server:{proxy:{'/foo':'http://localhost:4567','/api':{target:'http://localhost:8080',changeOrigin:true,rewrite:(p)=>p.replace(/^\/api/,''),ws:true}}}`}
§BUILD{
  minify_opts:`build:{rolldownOptions:{output:{minify:{compress:{drop_console:true}}}}}`(Oxc_snake_case,replaces_`esbuild`/`terserOptions`);
  manualChunks_obj:`build:{rolldownOptions:{output:{manualChunks:{'react-vendor':['react','react-dom'],'ui-vendor':['@radix-ui/react-dialog','@radix-ui/react-popover']}}}}`;
  manualChunks_fn:`manualChunks(id){if(id.includes('node_modules/react'))return'react-vendor';if(id.includes('node_modules'))return'vendor'}`;
  worker:`worker:{rolldownOptions:{...}}`(replaces_`worker.rollupOptions`);
  lib:`build:{lib:{entry:'src/index.ts',formats:['es','cjs'],fileName:(f)=>\`my-lib.\${f}.js\`},rolldownOptions:{external:['react','react-dom','react/jsx-runtime']}}`(+`vite-plugin-dts`|`tsc --emitDeclarationOnly`);
  ssr:bare_`createServer({middlewareMode:true})`⇒framework_authors(apps:Nuxt4|ReactRouter_v7|SvelteKit|Astro7|TanStackStart_v1);`ssr:{external:['node-native-package'],noExternal:['esm-only-package'],target:'node'}`(`'node'|'webworker'`);
  optimizeDeps:`optimizeDeps:{include:['lodash-es','cjs-package','deep-lib/components/**'],exclude:['local-esm-package'],force:true}`(excluded_valid_ESM;`force:true`=debug_only)
}
§PERF{
  no_barrels:`import{slash}from'@/utils/slash'`✅ ¬`'@/utils'`❌(#1_dev_slowdown);
  explicit_ext:`import C from'./Component.tsx'`✅ ¬`'./Component'`❌(avoids≤6_FS_checks);narrow_`tsconfig.json`:`allowImportingTsExtensions`+`resolve.extensions`;
  warmup:`server:{warmup:{clientFiles:['./src/main.tsx','./src/routes/**/*.tsx']}}`;
  profile:`vite --profile`→interact→`p+enter`→`.cpuprofile`@https://www.speedscope.app(check_`buildStart|config|configResolved`)
}
§PITFALL{
  dev≠build:dev(native_ESM+Oxc/Rolldown_prebundle)≠build(Rolldown_bundle,CJS_diff)⇒verify:`vite build && vite preview`;
  stale_chunks:hash_Δ→active_sessions_404⇒keep_old_`dist/assets/`_during_window∨catch_dynamic_import_err→reload;
  docker:`server:{host:true,hmr:{clientPort:3000}}`(`host:true`→`0.0.0.0`;`clientPort`→reverse_proxy);
  monorepo:`server:{fs:{allow:['..']}}`
}
§ANTI{
  `envPrefix:''`→leaks_all_secrets;
  `require('lib')`→ESM_only⇒`import`;
  1_chunk/pkg(`id.split('node_modules/')[1].split('/')[0]`)→hundreds_tiny_files;
  `build.lib`¬`external`→dup_runtime;
  `build.rollupOptions`/`esbuild`_cfg_block→deprecated_v8⇒`build.rolldownOptions`+`oxc`;
  `build.minify:'esbuild'`→removed⇒`'oxc'|'terser'`;
  `import.meta.hot.data={}`→reassign_breaks⇒mutate_props;
  `vite preview`≠prod_server(smoke_test_only→deploy_`dist/`@NGINX|CF_Pages|Vercel|multi-stage_Docker);
  `vite build`¬typecheck⇒`vite-plugin-checker`∨`tsc --noEmit`@CI;
  `@vitejs/plugin-legacy`¬default(~40%_bloat,breaks_sourcemap_analyzers;95%+_modern_browsers⇒gate_on_analytics);
  30+_manual_`resolve.alias`⇒`vite-tsconfig-paths`;
  stale_`node_modules/.vite`→phantom_errs⇒clear_on_dep/branch_Δ
}
§REL{../SKILL.md|../../devops-iac/references/docker.md|nextjs.md}
