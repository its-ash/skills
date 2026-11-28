@REF:tooling-and-testing
§D{
  new_cross_browser_ext⇒WXT(v0.21.x,Vite_native,file_entrypoints,multi_browser_manifest,wxt_zip/submit)¬custom_webpack_setup;
  existing_Vite_app+explicit_manifest⇒CRXJS(`@crxjs/vite-plugin`_v3.0.0,content_script_HMR,Chromium_first)¬full_framework_migration;
  React_only_team+convention_CSUI⇒Plasmo(v0.90.x,Parcel_backed,slower_cadence;audit_dep_freshness_first);
  minimal_zero_dep_ext⇒vanilla_MV3(ESM_`type:"module"`+`web-ext lint`)¬over_engineered_bundler;
}
§CFG{
  Chrome_Edge:identical_MV3_Chromium_bundle(`service_worker`,`sidePanel`,`offscreen`,DNR);
  Firefox_Gecko:req_`browser_specific_settings.gecko.{id,strict_min_version:"140.0",data_collection_permissions}`;bg_compat⇒`background.scripts`+`service_worker`(or_WXT_`-b firefox`);supports_DNR+blocking_`webRequest`;test_under_Firefox_Nova_UI(157+,vertical_tabs/sidebar);
  Safari_MV3:requires_Xcode_host_app_via_`safari-web-extension-converter`;aggressively_unloads_non_persistent_bg/SW(sync_top_level_listeners_mandatory,zero_global_state);prefer_DNR_over_`webRequest`;`web-ext`_does_¬build_Safari;
}
§CMD{
  wxt_init:`npx wxt@latest init my-ext`;
  wxt_dev:`npx wxt`(Chrome)⊕`npx wxt -b firefox`(Firefox);
  wxt_build:`npx wxt build -b chrome`∧`npx wxt build -b firefox`∧`npx wxt build -b edge`∧`npx wxt build -b safari`;
  wxt_zip:`npx wxt zip`∧`npx wxt zip -b firefox`(outputs_ext_zip+sources_zip_for_AMO);
  firefox_lint_run:`npx web-ext lint -s dist-firefox/`∧`npx web-ext run -s dist-firefox/`//keep_web-ext_latest_for_data_collection_permissions_schema;
  safari_convert:`xcrun safari-web-extension-converter dist-safari/ --project-location safari/ --app-name MyExt`;
}
§PAT{
  Playwright_MV3_launch:extensions_req_persistent_ctx(¬default_ephemeral_ctx):```js
  const ctx=await chromium.launchPersistentContext(tmpDir,{channel:'chromium',args:[`--disable-extensions-except=${extPath}`,`--load-extension=${extPath}`]});
  let [sw]=ctx.serviceWorkers();if(!sw)sw=await ctx.waitForEvent('serviceworker');
  const extId=sw.url().split('/')[2];
  ```;
  Playwright_ext_pages:navigate_`chrome-extension://${extId}/popup.html`(or_options/sidepanel)_to_test_UI_flows;
  Playwright_SW_recycle:SW_terminates_after_~30s_idle;Playwright_keeps_`.evaluate()`_handle_across_restarts_but_in_flight_calls_drop⇒test_state_reload_after_SW_wake;
  Playwright_ShadowDOM:built_in_locators(`getByRole`,`getByText`,CSS)_auto_pierce_`mode:'open'`_Shadow_DOM;`mode:'closed'`_returns_`shadowRoot===null`⇒use_`mode:'open'`_for_testable_injected_UI;
  DNR_and_opt_perm_tests:mock/assert_quota_errors(30k_safe/5k_unsafe_dynamic);test_optional_host_permission_grant_before_asserting_DNR_interception;
  unit_tests:Vitest+`wxt/testing`(`fakeBrowser`)∨typed_`chrome.*`_mocks_for_pure_routers,storage_migrations,DNR_rule_builders;
  debugging:Chrome(`chrome://extensions`→Inspect_SW+DevTools);Firefox(`about:debugging#/runtime/this-firefox`);Safari(`Develop>Web Extension Background Content`∨Xcode/`Console.app`_filtered_by_bundle_ID);
}
§ANTI{
  Chrome_only_test⇒Firefox_gecko/data_collection_reject∨Safari_SW_missed_events⇒test_Chrome+Firefox(+Safari);
  outdated_web-ext⇒false_schema_err_on_`data_collection_permissions`⇒upgrade_`web-ext`;
  closed_ShadowDOM_without_need⇒breaks_standard_Playwright_locators⇒use_`mode:'open'`;
  skip_SW_sleep_testing⇒in_memory_state_bugs_only_hit_prod⇒verify_storage_hydration_on_cold_SW;
}
