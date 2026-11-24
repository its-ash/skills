---
name: browser-extensions
description: "AUTO_INVOKE(silent)⇔prompt∈{Chrome_extension,Firefox_extension,Edge_extension,WebExtension,Manifest_V3,MV3,MV2_to_MV3,manifest.json,content_script,service_worker,popup,options_UI,chrome.storage,chrome.alarms,chrome.runtime,chrome.tabs,declarativeNetRequest,webRequestBlocking,optional_permissions,host_permissions,offscreen,CSP,XSS,web-ext_lint,Chrome_Web_Store}|SUB:{extension-code,publishing}"
---
@SKL:browser-extensions
§R{
  target:{Chrome,Edge,Firefox}∧manifest_version≡3∧folder_per_ctx({background,content,popup,options});
  perm≡min_needed∧on_demand_features→optional_permissions;
  host_permissions≡specific_match_patterns∧¬<all_urls>_if_avoidable;
  sw_stops_when_idle⇒(globals_state≡∅∧persist→chrome.storage);
  schedule_work⇒chrome.alarms¬(setTimeout∨setInterval);
  ¬block_sw_thread:(¬long_loops∧¬sync_XHR);
  msg_listener∧async_reply⇒(sendResponse∧return true);
  content_script:page_data≡untrusted⇒validate_before_use;
  DOM_write⇒(textContent∧createElement)¬(innerHTML∨eval)[XSS,CSP];
  ¬load_remote_scripts(strict_CSP@ext_pages);
  net_filter⇒declarativeNetRequest¬(webRequest∨webRequestBlocking);
  content_scripts⇒set(run_at∧precise_matches);
  target_sites⇒stable_selectors+fallback_logic∧monitor_breakage;
  test∈{Chrome,Edge,Firefox}∧lint:web-ext lint;
}
§D{
  popup→background⇒chrome.runtime.sendMessage¬direct_global_access;
  background→page⇒chrome.tabs.sendMessage(tabId,…)¬content_script_polling;
  content→background⇒chrome.runtime.sendMessage¬window.postMessage_to_worker;
  user_roaming_settings⇒chrome.storage.sync(100KB_tot,8KB_per_item)¬localStorage;
  larger_local_data⇒chrome.storage.local(10MB;5MB_pre_Chrome114)¬sync_bulk_data;
  heavy_work⇒content_script∨offscreen_work¬long_tasks_in_sw;
  periodic_task⇒chrome.alarms¬timers_in_worker;
  block∨redirect_req⇒declarativeNetRequest_rulesets¬webRequestBlocking;
  UI_in_page⇒safe_DOM_nodes+fixed_pos+high_z-index¬innerHTML_templates;
}
§REF{
  folder_layout,manifest.json_tpl,content_script,UI_injection,service_worker,popup,storage,anti_patterns→references/extension-code.md;
  package,store_upload,monetization,release_checklist→references/publishing.md;
}
§REL{
  ../frontend-development/SKILL.md:React_UI@popup,options;
  ../typescript/SKILL.md:typed_ext_code;
  ../typescript/references/javascript.md:event_loop,closures,this;
  ../frontend-development/references/progressive-web-app.md:web_sw,manifest;
  ../web-quality-audit/references/web-accessibility.md:a11y_popup,injected_UI;
  ../secure-coding/SKILL.md:XSS,input_val;
}
