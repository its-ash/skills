@REF:publishing
§PUB{
  1:check(manifest_version=3,icons,req_fields);
  2:test(Chrome:`chrome://extensions`+DevMode_load_unpacked;Firefox:`web-ext lint`);
  3:pkg(zip_root,¬VCS);
  4:upload(CWS|AMO,justify_every_perm)
}
§MONETIZE{opt;donate_on_chrome.runtime.onInstalled;premium_via_optional_permissions;store_payment_policy}
§CHK{
  std_layout;mv3+paths;min_perms+optional_permissions;SW_onInstalled+non_blocking;cs(run_at+precise_matches);UI_type=module;onMessage_sendResponse+return_true;chrome.storage+err_handle;web-ext_lint+0_warnings;Chrome+Edge+Firefox;zip_needed_only;perm_justifications+screenshots
}
