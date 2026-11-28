@REF:publishing
§R{
  CWS_policy:single_purpose;zero_remote_code;justify_every_perm+host_pattern;Limited_Use("Strictly_Necessary":¬broad_URL/page/form_analytics_unrelated_to_core_feature);disclose_data_collection_in_UI_before_capture;prohibited:{real_money_prediction_markets,AI_safety_guardrail_bypass};
  CWS_API_v2:API_v1_shut_down_Oct_15_2026⇒all_CI/CD_must_use_CWS_Publish_API_v2(Service_Accounts+Workload_Identity_Federation,percentage_rollouts,cancel_pending_submissions,separate_draft_vs_published_status);
  AMO_policy:mandatory_`browser_specific_settings.gecko.data_collection_permissions`(enforced_Nov_3_2025_new_exts,H1_2026_all_updates;use_`required:["none"]`_if_zero_collection;native_consent_UX_Firefox_140_Desktop/142_Android);upload_unminified_source_zip+build_steps_if_bundled/minified/TS;
  AMO_enterprise:dedicated_Enterprise_Channel(from_Dec_1_2026)⇒`browser_specific_settings.gecko.admin_install_only:true`_bypasses_consumer_queue;
  Edge_Addons:Chromium_MV3_parity;manually_create_initial_listing_in_Microsoft_Partner_Center_to_get_Product_ID→automate_updates_via_Partner_Center_API;
  Safari_AppStore:package_via_`safari-web-extension-converter`+Xcode_host_app→App_Store_Connect_review+App_Privacy_disclosures;
}
§PAT{
  multi_store_CI:use_`wxt submit`(wraps_`publish-browser-extension`)_for_Chrome+Firefox+Edge;
  setup_secrets:`npx wxt submit init`(generates_`.env.submit`;store_secrets_in_CI_vault,¬commit);
  safe_release:build_per_target→`web-ext lint`→`wxt submit --dry-run`→tag+live_submit;
  manual_pkg:zip_contents_of_dist/_root(manifest.json_at_zip_root,¬parent_folder,¬`.git`,¬`node_modules`,¬`.env`);
}
§CMD{
  lint_AMO:`npx web-ext lint -s .output/firefox-mv3/`;
  pack_WXT:`npx wxt zip`∧`npx wxt zip -b firefox`;
  dry_run:`npx wxt submit --dry-run --chrome-zip .output/*-chrome.zip --firefox-zip .output/*-firefox.zip --firefox-sources-zip .output/*-sources.zip`;
  submit:`npx wxt submit --chrome-zip .output/*-chrome.zip --firefox-zip .output/*-firefox.zip --firefox-sources-zip .output/*-sources.zip --edge-zip .output/*-edge.zip`;
}
§MONETIZE{
  opt;external_billing/license_auth(CWS/AMO/Edge_compliant);Safari/iOS_App_Store⇒follow_Apple_IAP_rules;opt_non_intrusive_donate_on_`onInstalled`;gate_extra_perms_via_`optional_permissions`;
}
§CHK{
  MV3_manifest+icons(16,48,128_PNG)+version_bump+zero_remote_code;
  min_perms+optional_permissions+optional_host_permissions+per_perm_justifications;
  SW_sync_top_level_listeners+zero_globals+chrome.alarms(>=30s)+offscreen_1_doc_guard+onMessage_Chrome144_safe;
  content_scripts(precise_matches+run_at+Shadow_DOM_open+createElement/textContent+scoped_WAR);
  Firefox:gecko.id+data_collection_permissions+web-ext_lint(0_err)+sources_zip_if_bundled;
  CWS:Limited_Use+pre_collection_UI_disclosure+CWS_API_v2(ServiceAccount/WIF)_in_CI;
  tests:Playwright_MV3_E2E(SW_wake)+smoke_Chrome/Edge/Firefox(+Safari);
  clean_zip_root+screenshots+privacy_policy_URL;
}
