# Progressive Web Apps (PWAs)

A PWA is a web application that works offline, loads quickly, and can be installed on a device. Three pillars are required:

1. **HTTPS** – Service workers run only on secure origins (localhost is allowed for development).
2. **Web App Manifest** (`manifest.json`) – Describes the app name, icons, start URL, and display mode.
3. **Service Worker** (`sw.js`) – Intercepts network requests, caches assets, and provides offline fallback.

---

## When to Use
- You want the app to function when the network is unavailable or slow.
- You need an "Add to Home Screen" experience on Android or iOS.
- You want to improve load performance with caching.
- You plan to use background sync, push notifications, or other PWA APIs.

---

## Required Files
| File | Purpose |
|------|---------|
| `index.html` | Links the manifest and registers the service worker. |
| `manifest.json` | Provides metadata and icons for installation. |
| `sw.js` | Implements install, activate, and fetch handlers with caching strategies. |
| `app.js` | Registers the service worker and handles the install prompt UI. |
| `offline.html` | Shown when navigation fails while offline. |

---

## 1. Web App Manifest (`manifest.json`)
```json
{
  "name": "My Awesome PWA",
  "short_name": "MyPWA",
  "description": "Fast, offline‑capable web app.",
  "start_url": "/",
  "scope": "/",
  "display": "standalone",
  "orientation": "portrait-primary",
  "background_color": "#ffffff",
  "theme_color": "#0055ff",
  "icons": [
    {
      "src": "/assets/icons/icon-192x192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/assets/icons/icon-512x512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ]
}
```
**Key fields**
- `display: "standalone"` hides the browser UI.
- `purpose: "maskable"` lets Android show adaptive icons.
- Include at least 192 px and 512 px PNG icons.

---

## 2. HTML Shell (`index.html`)
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Awesome PWA</title>
  <link rel="manifest" href="/manifest.json">
  <meta name="theme-color" content="#0055ff">
  <!-- iOS support -->
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="default">
  <meta name="apple-mobile-web-app-title" content="MyPWA">
  <link rel="apple-touch-icon" href="/assets/icons/icon-192x192.png">
  <link rel="stylesheet" href="/styles.css">
</head>
<body>
  <div id="app">
    <header><h1>My PWA</h1></header>
    <main id="content">Loading…</main>
    <button id="install-btn" hidden>Install App</button>
  </div>
  <script src="/app.js"></script>
</body>
</html>
```
The `install-btn` is hidden until the browser fires `beforeinstallprompt`.

---

## 3. Service Worker Registration & Install Prompt (`app.js`)
```javascript
// Register service worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', async () => {
    try {
      const reg = await navigator.serviceWorker.register('/sw.js');
      console.log('SW registered, scope:', reg.scope);
    } catch (e) {
      console.error('SW registration failed:', e);
    }
  });
}

// Handle install prompt
let deferredPrompt;
const installBtn = document.getElementById('install-btn');

window.addEventListener('beforeinstallprompt', e => {
  e.preventDefault();
  deferredPrompt = e;
  if (installBtn) installBtn.hidden = false;
});

if (installBtn) {
  installBtn.addEventListener('click', async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    console.log('Install outcome:', outcome);
    deferredPrompt = null;
    installBtn.hidden = true;
  });
}

window.addEventListener('appinstalled', () => {
  console.log('PWA installed');
  if (installBtn) installBtn.hidden = true;
});
```
iOS Safari does not fire `beforeinstallprompt`; users must use the Share → "Add to Home Screen" flow.

---

## 4. Service Worker (`sw.js`)
```javascript
const CACHE_VERSION = 'v1';
const STATIC_CACHE = `static-${CACHE_VERSION}`;
const DYNAMIC_CACHE = `dynamic-${CACHE_VERSION}`;

const APP_SHELL = [
  '/',
  '/index.html',
  '/styles.css',
  '/app.js',
  '/assets/icons/icon-192x192.png',
  '/offline.html',
];

// Install – pre‑cache app shell
self.addEventListener('install', event => {
  console.log('SW install');
  event.waitUntil(
    caches.open(STATIC_CACHE).then(cache => cache.addAll(APP_SHELL))
  );
  self.skipWaiting();
});

// Activate – delete old caches
self.addEventListener('activate', event => {
  console.log('SW activate');
  event.waitUntil(
    caches.keys().then(names => Promise.all(
      names.filter(name => name !== STATIC_CACHE && name !== DYNAMIC_CACHE)
           .map(name => caches.delete(name))
    ))
  );
  self.clients.claim();
});

// Fetch – apply caching strategy per request type
self.addEventListener('fetch', event => {
  const { request } = event;
  const url = new URL(request.url);

  // Only handle same‑origin GET requests
  if (request.method !== 'GET' || url.origin !== location.origin) return;

  // Static assets – Cache First
  if (/\.(css|js|png|jpg|svg|woff2)$/.test(url.pathname)) {
    event.respondWith(cacheFirst(request));
    return;
  }

  // HTML pages – Network First
  if (request.headers.get('Accept')?.includes('text/html')) {
    event.respondWith(networkFirst(request));
    return;
  }

  // API calls – Stale‑While‑Revalidate
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(staleWhileRevalidate(request));
    return;
  }
});

// ----- Strategy implementations -----
async function cacheFirst(req) {
  const cached = await caches.match(req);
  if (cached) return cached;
  const response = await fetch(req);
  const cache = await caches.open(STATIC_CACHE);
  cache.put(req, response.clone());
  return response;
}

async function networkFirst(req) {
  try {
    const response = await fetch(req);
    const cache = await caches.open(DYNAMIC_CACHE);
    cache.put(req, response.clone());
    return response;
  } catch (_) {
    const cached = await caches.match(req);
    return cached || caches.match('/offline.html');
  }
}

async function staleWhileRevalidate(req) {
  const cache = await caches.open(DYNAMIC_CACHE);
  const cached = await cache.match(req);
  const fetchPromise = fetch(req).then(resp => {
    cache.put(req, resp.clone());
    return resp;
  });
  return cached || fetchPromise;
}
```
**Versioning** – Increment `CACHE_VERSION` on each deployment. The activate handler will delete old caches.

---

## 5. Edge Cases & Platform Notes
- **HTTPS**: Service workers require HTTPS. Use `mkcert` or a tunneling service for local testing with a custom domain.
- **iOS Safari**: No `beforeinstallprompt`. Use the Apple meta tags shown in `index.html`. Service worker caches may be cleared after ~7 days of inactivity.
- **Cross‑origin requests**: Responses are opaque. Cache them only if you accept the risk of storing a 200‑status opaque response. Prefer `staleWhileRevalidate` for such resources.
- **Cache busting**: Automate `CACHE_VERSION` updates with your build tool (e.g., Vite, Webpack) to avoid stale assets.

---

## 6. Workbox (Optional Production Helper)
Workbox simplifies strategy code and adds expiration handling.
```javascript
importScripts('https://storage.googleapis.com/workbox-cdn/releases/7.0.0/workbox-sw.js');

const { registerRoute } = workbox.routing;
const { CacheFirst, NetworkFirst, StaleWhileRevalidate } = workbox.strategies;
const { precacheAndRoute } = workbox.precaching;

precacheAndRoute(self.__WB_MANIFEST || []);

registerRoute(
  ({ request }) => request.destination === 'image',
  new CacheFirst()
);

registerRoute(
  ({ request }) => request.mode === 'navigate',
  new NetworkFirst()
);

registerRoute(
  ({ request }) => request.destination === 'script',
  new StaleWhileRevalidate()
);
```
Include Workbox via npm or CDN and let the build plugin generate `self.__WB_MANIFEST`.

---

## Checklist Before Shipping
- Site served over HTTPS.
- `manifest.json` contains `name`, `short_name`, `start_url`, `display`, `icons` (192 px & 512 px, maskable).
- Icons are correctly referenced and sized.
- Service worker registers without errors (DevTools → Application → Service Workers).
- App shell loads from cache when network is set to "Offline" in DevTools.
- `offline.html` is cached and served for failed navigations.
- Lighthouse PWA audit passes.
- Tested install flow on Android Chrome (prompt) and iOS Safari (Share → Add to Home Screen).

## Related skills

Load these when the task spans more than this skill.

- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`web-accessibility`](../../web-quality-audit/references/web-accessibility.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
- [`frontend-development`](../SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`javascript`](../../typescript/references/javascript.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`web-quality-audit`](../../web-quality-audit/SKILL.md) — Runs a full web quality audit that checks performance (Core Web Vitals, resource loading), accessibility, SEO,…
- [`browser-extensions`](../../browser-extensions/SKILL.md) — Provides step‑by‑step guidance for building, testing, and publishing Chrome, Edge, and Firefox WebExtensions u…
