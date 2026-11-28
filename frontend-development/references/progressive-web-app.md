@REF:progressive-web-app
§PILLARS{1:HTTPS(localhost_ok_dev);2:manifest.json;3:ServiceWorker(sw.js)}
§WHEN{offline/slow_net;A2HS(Android|iOS);cache_perf;bg_sync|push|PWA_APIs}
§FILES{index.html:manifest+SW_reg;manifest.json:meta+icons;sw.js:install/activate/fetch;app.js:reg+A2HS_prompt;offline.html:offline_nav_fallback}
§CFG{
  `manifest.json`{name,short_name,description,start_url:"/",scope:"/",display:"standalone"(hide_UI),orientation:"portrait-primary",background_color:"#ffffff",theme_color:"#0055ff",icons:[192x192,512x512 PNG purpose:"any maskable"(Android_adaptive)]};
  `index.html`:`<link rel="manifest" href="/manifest.json">`, `<meta name="theme-color" content="#0055ff">`, `<meta name="mobile-web-app-capable" content="yes">`(std,replaces_Chromium_warning_on_apple_tag), iOS(`<meta name="apple-mobile-web-app-capable" content="yes">`, `apple-mobile-web-app-status-bar-style`="default", `apple-mobile-web-app-title`, `<link rel="apple-touch-icon" href="/assets/icons/icon-192x192.png">`), `<button id="install-btn" hidden>`, `<script src="/app.js"></script>`
}
§PAT{
  `app.js`:
```js
if('serviceWorker'in navigator)window.addEventListener('load',()=>navigator.serviceWorker.register('/sw.js').catch(console.error));
let deferredPrompt;const btn=document.getElementById('install-btn');
window.addEventListener('beforeinstallprompt',e=>{e.preventDefault();deferredPrompt=e;if(btn)btn.hidden=false;});
btn?.addEventListener('click',async()=>{if(!deferredPrompt)return;deferredPrompt.prompt();await deferredPrompt.userChoice;deferredPrompt=null;btn.hidden=true;});
window.addEventListener('appinstalled',()=>{if(btn)btn.hidden=true;});
```
  `sw.js`(v1;bump `CACHE_VERSION` per deploy):
```js
const CACHE_VERSION='v1',STATIC_CACHE=`static-${CACHE_VERSION}`,DYNAMIC_CACHE=`dynamic-${CACHE_VERSION}`;
const APP_SHELL=['/','/index.html','/styles.css','/app.js','/assets/icons/icon-192x192.png','/offline.html'];
self.addEventListener('install',e=>{e.waitUntil(caches.open(STATIC_CACHE).then(c=>c.addAll(APP_SHELL)));self.skipWaiting();});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==STATIC_CACHE&&k!==DYNAMIC_CACHE).map(k=>caches.delete(k)))));self.clients.claim();});
self.addEventListener('fetch',e=>{
  const{request}=e,url=new URL(request.url);
  if(request.method!=='GET'||url.origin!==location.origin)return;
  if(/\.(css|js|png|jpg|svg|woff2)$/.test(url.pathname))return e.respondWith(cacheFirst(request));
  if(request.headers.get('Accept')?.includes('text/html'))return e.respondWith(networkFirst(request));
  if(url.pathname.startsWith('/api/'))return e.respondWith(staleWhileRevalidate(request));
});
const cacheFirst=async q=>(await caches.match(q))||(async r=>{(await caches.open(STATIC_CACHE)).put(q,r.clone());return r;})(await fetch(q));
const networkFirst=async q=>{try{const r=await fetch(q);(await caches.open(DYNAMIC_CACHE)).put(q,r.clone());return r;}catch{return(await caches.match(q))||caches.match('/offline.html');}};
const staleWhileRevalidate=async q=>{const c=await caches.open(DYNAMIC_CACHE),m=await c.match(q),n=fetch(q).then(r=>{c.put(q,r.clone());return r;});return m||n;};
```
}
§EDGE{
  HTTPS:required(local_domain⇒`mkcert`∨tunnel);
  iOS_Safari:¬`beforeinstallprompt`(Apple_meta_tags+Share→"Add to Home Screen");SW_caches_evict~7d_inactivity;
  cross_origin:opaque_responses(200-opaque_risk⇒`staleWhileRevalidate`);
  cache_bust:automate `CACHE_VERSION`(Vite|`vite-plugin-pwa`|Workbox)
}
§WORKBOX{
  bundled(preferred):`vite-plugin-pwa`(Vite)|`@vite-pwa/nuxt`(Nuxt4)+`workbox-build@7.4+`(`registerType:'autoUpdate'`,precaches_`self.__WB_MANIFEST`);
  CDN_fallback:`https://storage.googleapis.com/workbox-cdn/releases/7.4.0/workbox-sw.js`;
  `precacheAndRoute(self.__WB_MANIFEST||[])`;`registerRoute`:`destination==='image'`→`CacheFirst`,`mode==='navigate'`→`NetworkFirst`,`destination==='script'`→`StaleWhileRevalidate`
}
§CHK{HTTPS;manifest(name,short_name,start_url,display,192+512_maskable);`mobile-web-app-capable`+iOS_meta;SW_reg_clean(DevTools→Application→ServiceWorkers);offline_shell+`offline.html`;Lighthouse_PWA_pass;tested_Android_Chrome+iOS_Safari_A2HS}
§REL{
  ../../web-quality-audit/references/web-performance.md:CWV_perf;
  ../../web-quality-audit/references/web-accessibility.md:WCAG_a11y;
  ../SKILL.md:frontend_dev;
  ../../typescript/references/javascript.md:JS_core;
  ../../web-quality-audit/SKILL.md:web_audit;
  ../../browser-extensions/SKILL.md:extensions
}
