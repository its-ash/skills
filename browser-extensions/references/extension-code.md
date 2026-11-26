@REF:extension-code
§LAYOUT{
  extension/{manifest.json,background/service-worker.js,content/content.js,popup/{popup.html,popup.css,popup.js},options/{options.html,options.js},icons/{icon16,icon48,icon128}.png}
  // manifest paths relative to extension/ root
}
§MANIFEST{
  // MV3; declarativeNetRequest perm required iff declarative_net_request block present
  ```json
  {"manifest_version":3,"name":"...","version":"1.0.0","description":"...",
   "action":{"default_popup":"popup/popup.html","default_icon":{"16":"icons/icon16.png","48":"icons/icon48.png","128":"icons/icon128.png"}},
   "background":{"service_worker":"background/service-worker.js"},
   "content_scripts":[{"matches":["<all_urls>"],"js":["content/content.js"],"run_at":"document_idle"}],
   "options_page":"options/options.html",
   "permissions":["storage","activeTab","declarativeNetRequest"],
   "optional_permissions":["tabs"],"host_permissions":["https://*/*"],
   "declarative_net_request":{"rule_resources":[{"id":"ruleset_1","enabled":true,"path":"ruleset_1.json"}]}}
  ```
}
§APIS{
  content_DOM:safe_only(createElement,Object.assign,textContent,style.setProperty,style.cssText,append,appendChild,z-index:10000);¬innerHTML;
  messaging:`chrome.runtime.onMessage.addListener((msg,sender,respond)=>{ ... return true; })` // return true keeps channel open for async respond();
  SW_lifecycle:`chrome.runtime.onInstalled.addListener(...)`;
  SW_alarms:`chrome.alarms.create('refresh',{periodInMinutes:15})`+`chrome.alarms.onAlarm.addListener(...)` // needs "alarms" perm;
  popup_UI:`<script type="module" src="popup.js"></script>`;`chrome.storage.sync.set({...})`;
  storage:MV3 `chrome.storage` returns Promises; callback wrapper `new Promise(r=>chrome.storage.local.get(k,r))` / `set(d,r)`
}
§ANTI{
  all_perms⇒distrust+reject+attack_surface⇒minimal+optional_permissions;
  heavy_SW⇒idle_kill+battery⇒content_script+chrome.alarms;
  innerHTML|eval⇒XSS+CSP⇒textContent+createElement;
  blocking_SW⇒unresponsive/killed⇒async_only(¬long_loops|sync_XHR);
  brittle_selectors⇒site_breakage⇒stable_selectors+fallback+err_mon
}
