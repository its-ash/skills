---
name: browser-extensions
description: "Guides building, testing, and publishing cross-browser WebExtensions for Chrome, Edge, and Firefox with Manifest V3: project structure, manifest, content scripts, service worker background, popup and options UI, permissions, storage, and cross-context messaging. Use when creating a chrome extension, firefox addon, edge extension, manifest v3 project, content script injection, background service worker, popup html, options page, chrome storage api, runtime messaging, host permissions, web store publishing, MV2 to MV3 migration, or debugging CSP violations or service worker lifecycle issues."
---

# Browser Extensions (Manifest V3)
Build cross-browser extensions for Chrome, Edge, and Firefox.

## Core rules
- Use `manifest_version: 3`. Keep each context (background, content, popup, options) in its own folder.
- Request only needed permissions. Put on-demand features in `optional_permissions`.
- Use specific `host_permissions` match patterns. Avoid `<all_urls>` when you can.
- The service worker stops when idle. Keep no state in globals; persist in `chrome.storage`.
- Schedule work with `chrome.alarms`, not `setTimeout`/`setInterval`.
- Never block the service worker thread: no long loops, no sync XHR.
- In message listeners, call `sendResponse` and `return true` for async replies.
- Treat page data as untrusted in content scripts. Validate it before use.
- Use `textContent` and `createElement`. Never use `innerHTML` or `eval` (XSS, CSP violation).
- Do not load remote scripts. Chrome applies a strict CSP to extension pages.
- Use `declarativeNetRequest` for network filtering, not `webRequest` (no `webRequestBlocking` needed).
- Set `run_at` and precise `matches` on content scripts.
- Use stable selectors with fallback logic on target sites; monitor for breakage.
- Test in Chrome, Edge, and Firefox. Lint with `web-ext lint`.

## Decisions
| Situation | Do | Avoid |
|---|---|---|
| Popup → background | `chrome.runtime.sendMessage` | Direct global access |
| Background → page | `chrome.tabs.sendMessage(tabId, …)` | Polling from the content script |
| Content → background | `chrome.runtime.sendMessage` | `window.postMessage` to the worker |
| Settings that follow the user | `chrome.storage.sync` (100 KB total, 8 KB per item) | `localStorage` |
| Larger local data | `chrome.storage.local` (10 MB; 5 MB before Chrome 114) | `sync` for bulk data |
| Heavy work | Content script or offscreen work | Long tasks in the service worker |
| Periodic task | `chrome.alarms` | Timers in the worker |
| Block or redirect requests | `declarativeNetRequest` rulesets | `webRequestBlocking` |
| UI in a page | Safe DOM nodes, fixed position, high `z-index` | `innerHTML` templates |

## Load on demand
| Need | Read |
|---|---|
| Folder layout, `manifest.json` template, content script, UI injection, service worker, popup, storage, anti-patterns | [references/extension-code.md](references/extension-code.md) |
| Package, store upload, monetization, release checklist | [references/publishing.md](references/publishing.md) |

## Related skills
- [`frontend-development`](../frontend-development/SKILL.md) — React UI for popup and options
- [`typescript`](../typescript/SKILL.md) — typed extension code
- [`javascript`](../typescript/references/javascript.md) — event loop, closures, `this`
- [`progressive-web-app`](../frontend-development/references/progressive-web-app.md) — web service workers and manifest
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) — accessible popup and injected UI
- [`secure-coding`](../secure-coding/SKILL.md) — XSS, input validation
