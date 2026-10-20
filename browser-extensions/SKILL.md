---
name: browser-extensions
description: "Guides building, testing, and publishing cross-browser WebExtensions for Chrome, Edge, and Firefox using Manifest V3, covering project structure, manifest, content scripts, service worker backgrounds, popup and options UI, permissions, storage, and cross-context messaging. Use when creating a chrome extension, firefox addon, edge extension, manifest v3 project, content script injection, background service worker, popup html, options page, chrome storage api, runtime messaging, host permissions, web store publishing, or debugging extension errors like CSP violations or service worker lifecycle issues."
---

# Browser Extension Development (Manifest V3)

Create cross‑browser extensions that run in Chrome, Edge, and Firefox. Use this guide when you need a new extension, are migrating from MV2, or must implement background service workers, content scripts, UI pages, or secure storage.

## When to use
- Starting a new Chrome/Edge/Firefox extension.
- Updating an existing MV2 extension to MV3.
- Adding a popup, options page, or content‑script UI.
- Implementing background logic with a service worker.
- Managing permissions, storage, or cross‑context messaging.

---

## 1. Project Structure
```
extension/
├─ manifest.json            # Extension configuration
├─ background/
│  └─ service-worker.js    # Background logic (MV3)
├─ content/
│  └─ content.js           # Runs in web pages
├─ popup/
│  ├─ popup.html
│  ├─ popup.css
│  └─ popup.js
├─ options/
│  ├─ options.html
│  └─ options.js
├─ icons/
│  ├─ icon16.png
│  ├─ icon48.png
│  └─ icon128.png
└─ README.md
```
Keep each context in its own folder. The manifest references files relative to the extension root.

---

## 2. Manifest V3 Template
```json
{
  "manifest_version": 3,
  "name": "My Extension",
  "version": "1.0.0",
  "description": "Brief description of the extension.",
  "action": {
    "default_popup": "popup/popup.html",
    "default_icon": {
      "16": "icons/icon16.png",
      "48": "icons/icon48.png",
      "128": "icons/icon128.png"
    }
  },
  "background": {
    "service_worker": "background/service-worker.js"
  },
  "content_scripts": [
    {
      "matches": ["<all_urls>"],
      "js": ["content/content.js"],
      "run_at": "document_idle"
    }
  ],
  "options_page": "options/options.html",
  "permissions": ["storage", "activeTab"],
  "optional_permissions": ["tabs"],
  "host_permissions": ["https://*/*"],
  "declarative_net_request": {
    "rule_resources": [{
      "id": "ruleset_1",
      "enabled": true,
      "path": "ruleset_1.json"
    }]
  }
}
```
*Only request the permissions you need.* Use `optional_permissions` for features that may be enabled later.

---

## 3. Content Scripts
### 3.1 Basic Content Script
```javascript
// content/content.js
document.addEventListener('DOMContentLoaded', () => {
  const target = document.querySelector('.target');
  if (target) target.style.backgroundColor = 'yellow';
});

chrome.runtime.onMessage.addListener((msg, sender, respond) => {
  if (msg.action === 'GET_DATA') {
    const data = document.querySelector('.data')?.textContent;
    respond({ data });
  }
  return true; // keep channel open for async response
});
```
### 3.2 Injecting UI into a Page
```javascript
function injectUI() {
  const container = document.createElement('div');
  container.id = 'my-ext-ui';
  container.innerHTML = `
    <div style="position:fixed;bottom:20px;right:20px;background:#fff;padding:12px;border-radius:6px;box-shadow:0 2px 8px rgba(0,0,0,0.2);z-index:10000;">
      <h3>My Extension</h3>
      <button id="my-ext-btn">Click</button>
    </div>`;
  document.body.appendChild(container);
  document.getElementById('my-ext-btn').addEventListener('click', () => {
    // handle click
  });
}

injectUI();
```
---

## 4. Background Service Worker
```javascript
// background/service-worker.js
chrome.runtime.onInstalled.addListener(() => {
  console.log('Extension installed');
});

chrome.runtime.onMessage.addListener((msg, sender, respond) => {
  if (msg.type === 'GREET') {
    console.log('Message from', sender.tab?.url);
    respond({ reply: 'Hello from Service Worker' });
  }
  return true; // async response
});

// Example periodic task using alarms
chrome.alarms.create('refresh', { periodInMinutes: 15 });
chrome.alarms.onAlarm.addListener(alarm => {
  if (alarm.name === 'refresh') {
    // perform lightweight work
  }
});
```
**Note:** Service workers are terminated when idle. Use `chrome.alarms` for scheduled work instead of `setTimeout`/`setInterval`.

---

## 5. Popup & Options UI
### 5.1 Popup HTML
```html
<!-- popup/popup.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="popup.css" />
</head>
<body>
  <h2>My Extension</h2>
  <button id="saveBtn">Save</button>
  <script src="popup.js"></script>
</body>
</html>
```
### 5.2 Popup JavaScript (using storage)
```javascript
// popup/popup.js
document.getElementById('saveBtn').addEventListener('click', async () => {
  await chrome.storage.sync.set({ enabled: true });
  console.log('Enabled flag saved');
});
```
---

## 6. Cross‑Context Messaging
| Direction | API | Typical Use |
|-----------|-----|-------------|
| Popup → Background | `chrome.runtime.sendMessage` | Request data, trigger actions |
| Background → Content | `chrome.tabs.sendMessage(tabId, ...)` | Push updates to page |
| Content → Background | `chrome.runtime.sendMessage` | Report page events |

Always provide a `sendResponse` callback and return `true` if you will respond asynchronously.

---

## 7. Permissions & Security
- **Principle of Least Privilege**: List only required permissions in `permissions`. Move rarely‑used ones to `optional_permissions`.
- **Host Permissions**: Use specific URL patterns instead of `<all_urls>` when possible.
- **Declarative Net Request**: Prefer `declarativeNetRequest` over `webRequest` for network filtering; it works without the `webRequestBlocking` permission.
- **Content‑Script Safety**: Validate any data received from the page before using it. Avoid `innerHTML` and `eval`; use `textContent` and safe DOM methods.
- **CSP**: Chrome automatically applies a strict Content Security Policy. Do not load remote scripts.

---

## 8. Persistent Storage
### 8.1 Chrome Storage API (Async/Await wrapper)
```javascript
function get(keys) {
  return new Promise(resolve => chrome.storage.local.get(keys, resolve));
}
function set(data) {
  return new Promise(resolve => chrome.storage.local.set(data, resolve));
}
// Usage
(async () => {
  const { settings } = await get(['settings']);
  await set({ settings: { ...settings, theme: 'dark' } });
})();
```
### 8.2 Limits
- `chrome.storage.local`: 5 MB total.
- `chrome.storage.sync`: 100 KB total, 8 KB per item. Use sync for settings that should follow the user across devices.
---

## 9. Publishing & Monetization
1. **Prepare**: Verify manifest version, icons, and required fields.
2. **Test**: Load the unpacked extension in `chrome://extensions` with Developer Mode enabled.
3. **Package**: Zip the extension root (exclude source‑control files).
4. **Store**: Upload to Chrome Web Store or Mozilla Add‑ons. Provide a clear description of requested permissions.
5. **Monetization** (optional):
   - Use `chrome.runtime.onInstalled` to open a donation page.
   - Offer a premium version with additional optional permissions.
   - Follow each store’s policy on payments.
---

## 10. Anti‑Patterns & How to Avoid Them
| Anti‑Pattern | Why it hurts | Recommended fix |
|--------------|--------------|------------------|
| Requesting all permissions | Users distrust, store may reject, larger attack surface | Request only needed permissions; use `optional_permissions` for on‑demand features |
| Heavy background processing | Service workers are killed when idle; drains battery | Keep background work minimal; move heavy work to content scripts or use `chrome.alarms` |
| Using `innerHTML` or `eval` | XSS risk, CSP violation | Use `textContent`, `createElement`, and safe DOM APIs |
| Blocking the service worker thread | Extension becomes unresponsive; may be terminated | Perform async work; avoid long loops or synchronous XHR |
| Ignoring selector changes on target sites | Breaks after site updates | Use stable selectors, fallback logic, and monitor for errors |
---

## 11. Checklist
- [ ] Project folders follow the recommended layout.
- [ ] `manifest.json` uses `manifest_version: 3` and references correct files.
- [ ] Only required permissions are listed; optional permissions are used where appropriate.
- [ ] Service worker contains `onInstalled` handler and does not block.
- [ ] Content scripts declare `run_at` and match patterns precisely.
- [ ] All UI pages (popup, options) load scripts with `type="module"` if using ES modules.
- [ ] Messaging includes `sendResponse` and returns `true` for async replies.
- [ ] Storage reads/writes use the Chrome Storage API with proper error handling.
- [ ] Extension passes linting (`web-ext lint` for Firefox, `chrome://extensions` warnings for Chrome).
- [ ] Tested in Chrome, Edge, and Firefox (if using WebExtension APIs).
- [ ] Packaged zip contains only necessary files and icons.
- [ ] Store listing explains each permission and includes screenshots.

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`javascript`](../javascript/SKILL.md) — A concise reference of core JavaScript concepts—primitives, type coercion, scope, closures, this, event loop,…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`progressive-web-app`](../progressive-web-app/SKILL.md) — Guides you to build a Progressive Web App (PWA) with HTTPS, a web app manifest, a service worker, offline fall…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
