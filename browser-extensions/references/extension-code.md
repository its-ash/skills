# MV3 Extension Code Templates

## Project layout
Keep each context in its own folder. Manifest paths are relative to the extension root.
```
extension/
├─ manifest.json
├─ background/service-worker.js
├─ content/content.js
├─ popup/{popup.html,popup.css,popup.js}
├─ options/{options.html,options.js}
└─ icons/{icon16,icon48,icon128}.png
```

## manifest.json
`declarativeNetRequest` permission is required for the `declarative_net_request` block. Remove both if you do not filter requests.
```json
{
  "manifest_version": 3,
  "name": "My Extension",
  "version": "1.0.0",
  "description": "Brief description of the extension.",
  "action": {
    "default_popup": "popup/popup.html",
    "default_icon": { "16": "icons/icon16.png", "48": "icons/icon48.png", "128": "icons/icon128.png" }
  },
  "background": { "service_worker": "background/service-worker.js" },
  "content_scripts": [{ "matches": ["<all_urls>"], "js": ["content/content.js"], "run_at": "document_idle" }],
  "options_page": "options/options.html",
  "permissions": ["storage", "activeTab", "declarativeNetRequest"],
  "optional_permissions": ["tabs"],
  "host_permissions": ["https://*/*"],
  "declarative_net_request": {
    "rule_resources": [{ "id": "ruleset_1", "enabled": true, "path": "ruleset_1.json" }]
  }
}
```

## Content script
```javascript
// content/content.js
document.querySelector('.target')?.style.setProperty('background-color', 'yellow');

chrome.runtime.onMessage.addListener((msg, sender, respond) => {
  if (msg.action === 'GET_DATA') respond({ data: document.querySelector('.data')?.textContent });
  return true; // keep channel open for async response
});
```

## Inject UI into a page (safe DOM, no innerHTML)
```javascript
function injectUI() {
  const box = Object.assign(document.createElement('div'), { id: 'my-ext-ui' });
  box.style.cssText = 'position:fixed;bottom:20px;right:20px;background:#fff;padding:12px;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,.2);z-index:10000';
  const h = Object.assign(document.createElement('h3'), { textContent: 'My Extension' });
  const btn = Object.assign(document.createElement('button'), { id: 'my-ext-btn', textContent: 'Click' });
  btn.addEventListener('click', () => { /* handle click */ });
  box.append(h, btn);
  document.body.appendChild(box);
}
injectUI();
```

## Background service worker
```javascript
// background/service-worker.js
chrome.runtime.onInstalled.addListener(() => console.log('Extension installed'));

chrome.runtime.onMessage.addListener((msg, sender, respond) => {
  if (msg.type === 'GREET') respond({ reply: 'Hello from Service Worker', from: sender.tab?.url });
  return true; // async response
});

chrome.alarms.create('refresh', { periodInMinutes: 15 }); // needs "alarms" permission
chrome.alarms.onAlarm.addListener(a => { if (a.name === 'refresh') { /* light work */ } });
```

## Popup
```html
<!-- popup/popup.html -->
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8" /><link rel="stylesheet" href="popup.css" /></head>
<body>
  <h2>My Extension</h2>
  <button id="saveBtn">Save</button>
  <script type="module" src="popup.js"></script>
</body>
</html>
```
```javascript
// popup/popup.js
document.getElementById('saveBtn').addEventListener('click', () => chrome.storage.sync.set({ enabled: true }));
```

## Storage
MV3 `chrome.storage` methods return promises. For callback-only targets, wrap them:
```javascript
const get = keys => new Promise(r => chrome.storage.local.get(keys, r));
const set = data => new Promise(r => chrome.storage.local.set(data, r));

const { settings } = await get(['settings']);
await set({ settings: { ...settings, theme: 'dark' } });
```

## Anti-patterns
| Anti-pattern | Why it hurts | Fix |
|---|---|---|
| Request all permissions | User distrust, store rejection, larger attack surface | Only needed permissions; `optional_permissions` for on-demand features |
| Heavy background work | Worker killed when idle; drains battery | Keep it minimal; move heavy work to content scripts; use `chrome.alarms` |
| `innerHTML` / `eval` | XSS, CSP violation | `textContent`, `createElement`, safe DOM APIs |
| Block the worker thread | Unresponsive; may be terminated | Async work; no long loops or sync XHR |
| Brittle selectors on target sites | Breaks after site updates | Stable selectors, fallback logic, error monitoring |
