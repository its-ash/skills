@REF:extension-code
§CFG{
  vanilla_layout:ext/{manifest.json,background/sw.js,content/content.js,popup/{index.html,main.js},sidepanel/{index.html,main.js},options/{index.html,main.js},offscreen/{index.html,main.js},rules/ruleset_1.json,icons/{16,48,128}.png};
  wxt_layout:{wxt.config.ts,entrypoints/{background.ts,content.ts,popup/,sidepanel/,options/},public/icons/};
  manifest_MV3_cross_browser:```json
  {"manifest_version":3,"name":"...","version":"1.0.0","description":"...",
   "action":{"default_popup":"popup/index.html","default_icon":{"16":"icons/16.png","48":"icons/48.png","128":"icons/128.png"}},
   "side_panel":{"default_path":"sidepanel/index.html"},
   "background":{"service_worker":"background/sw.js","type":"module","scripts":["background/sw.js"]},
   "content_scripts":[{"matches":["https://example.com/*"],"js":["content/content.js"],"run_at":"document_idle"}],
   "options_ui":{"page":"options/index.html","open_in_tab":false},
   "permissions":["storage","activeTab","alarms","sidePanel","declarativeNetRequestWithHostAccess"],
   "optional_permissions":["offscreen"],
   "optional_host_permissions":["https://*.example.org/*"],
   "web_accessible_resources":[{"resources":["assets/*"],"matches":["https://example.com/*"]}],
   "declarative_net_request":{"rule_resources":[{"id":"ruleset_1","enabled":true,"path":"rules/ruleset_1.json"}]},
   "browser_specific_settings":{"gecko":{"id":"ext@example.com","strict_min_version":"140.0","data_collection_permissions":{"required":["none"]}}}}
  ```;
}
§PAT{
  SW_lifecycle:ephemeral(~30s_idle_kill)⇒register_all_listeners_sync@top_level(`onInstalled`,`onStartup`,`onAlarm`,`onMessage`)∧zero_in_memory_state;
  native_promises:MV3_`chrome.*`_returns_Promises⇒`const {k}=await chrome.storage.local.get('k')`¬callback_wrappers;
  onMessage_pre144_and_universal:`chrome.runtime.onMessage.addListener((msg,sender,sendResponse)=>{if(msg.type!=='X')return;handle(msg).then(sendResponse);return true;})`;
  onMessage_Chrome144+:returning_Promise_directly_supported;CRITICAL:¬pass_`async (msg)=>...`_for_selective_listener(always_returns_Promise<undefined>⇒hijacks_channel+sends_empty_reply);return_`false|undefined`_sync_when_unhandled;
  storage_areas:sync(100KB_tot,8KB/item,roaming)⊕local(10MB;5MB_pre_Chrome114;`unlimitedStorage`_perm_opt)⊕session(10MB_RAM,flushes_on_browser_close);
  storage_session_access:default≡TRUSTED_CONTEXTS_only(hidden_from_content_scripts)⇒unlock_iff_needed:`chrome.storage.session.setAccessLevel({accessLevel:'TRUSTED_AND_UNTRUSTED_CONTEXTS'})`;
  alarms:`chrome.alarms.create('sync',{periodInMinutes:0.5})`//min_30s(Chrome120+);needs_"alarms"_perm;check_`alarms.get('sync')`_to_avoid_resetting_on_SW_wake;
  sidePanel:needs_"sidePanel"_perm;`chrome.sidePanel.setPanelBehavior({openPanelOnActionClick:true})`;per_tab:`chrome.sidePanel.setOptions({tabId,path:'sidepanel/index.html',enabled:true})`;
  offscreen_guard:max_1_open_doc/ext;check_`const c=await chrome.runtime.getContexts({contextTypes:['OFFSCREEN_DOCUMENT']});if(c.length)return;`→`chrome.offscreen.createDocument({url,reasons:['DOM_PARSER'],justification:'...'})`+catch_race(`Only a single offscreen document`);
  scripting:needs_"scripting"_perm+host/activeTab;`chrome.scripting.executeScript({target:{tabId},world:'ISOLATED'|'MAIN',func|files})`;`world:'MAIN'`_only_for_page_JS_globals(treat_page_globals_untrusted);
  userScripts:isolated_world_for_user_code;Chrome138+⇒per_ext_"Allow_User_Scripts"_toggle@`chrome://extensions/?id=<id>`(replaces_global_DevMode);feature_detect_before_call;
  DNR_quotas:GUARANTEED_MINIMUM_STATIC_RULES≡30000;MAX_NUMBER_OF_ENABLED_STATIC_RULESETS≡50(of_100_max_declared);check_`getAvailableStaticRuleCount()`;MAX_NUMBER_OF_DYNAMIC_RULES≡30000(safe:`block`,`allow`,`allowAllRequests`,`upgradeScheme`);MAX_NUMBER_OF_UNSAFE_DYNAMIC_RULES≡5000(redirect,modifyHeaders);ephemeral→`updateSessionRules()`;
  DNR_host_access:prefer_`declarativeNetRequestWithHostAccess`+`optional_host_permissions`¬broad_install_warnings;dynamic/session_rules_on_optional_hosts_stay_inactive_until_granted;Firefox_MV3_retains_blocking_`webRequest`;
  content_UI_ShadowDOM:`const host=document.createElement('div');const sr=host.attachShadow({mode:'open'});`+build_nodes(`createElement`,`textContent`,`style.setProperty`,high_`z-index`)¬`innerHTML`¬unisolated_page_CSS;
  UI_modules:`<script type="module" src="main.js"></script>`(zero_inline_JS,strict_MV3_CSP);
}
§R{
  no_remote_code:bundle_100%_JS+Wasm_in_pkg;¬CDN_scripts∧¬`eval`∧¬`new Function`;
  msg_auth:verify_`sender.id===chrome.runtime.id`∧check_`sender.tab`/`sender.origin`_before_privileged_SW_actions;
  WAR_scope:restrict_`web_accessible_resources.matches`_to_exact_origins¬`<all_urls>`(prevents_extension_fingerprinting);
  secret_isolation:¬expose_API_keys/tokens_to_content_scripts∨`TRUSTED_AND_UNTRUSTED_CONTEXTS`_session_storage;
  resilient_DOM:prefer_semantic/ARIA/data_attrs+fallback_selectors+disconnect_MutationObserver_on_cleanup;
}
§ANTI{
  all_perms∨<all_urls>⇒install_distrust+review_reject+wide_attack_surface⇒activeTab+optional_permissions+optional_host_permissions;
  SW_globals∨setInterval⇒wiped_on_~30s_idle_kill⇒chrome.storage+chrome.alarms;
  top_level_async_onMessage⇒Chrome144+_hijacks_unhandled_msgs_with_undefined⇒sync_router+return_true∨conditional_Promise;
  async_listener_registration(`await`→`addListener`)⇒missed_wake_events(Chrome+Safari)⇒sync_top_level_registration;
  unchecked_offscreen_create⇒throws_if_already_open⇒runtime.getContexts_guard+race_catch;
  innerHTML∨eval∨unisolated_CSS⇒XSS+CSP_fail+host_style_bleed⇒Shadow_DOM(open)+createElement+textContent;
  blocking_SW_loop|sync_XHR⇒unresponsive/killed⇒async_only+offscreen/content_offload;
}
