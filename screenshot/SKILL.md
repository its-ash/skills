---
name: screenshot
description: "AUTO_INVOKE(silent)⇔prompt∈{screenshot,screen_capture,snap,grab,print_screen,capture_display,full_screen,window,region,app_capture,macOS,Linux,Windows,screencapture,gnome-screenshot,scrot,maim,spectacle,import,PowerShell,TCC,Screen_Recording,Wayland,X11,headless_CI,bug_report,docs,UI_audit,design_handoff,visual_regression,a11y_review,missing_tool_fallback}|SUB:{screenshot-feature-extractor}"
---
@SKL:screenshot
§R{
  goal≡capture(desktop∨app∨window∨px_region)∧report(file_path);
  tool_capture(Figma∨Playwright)⇒prefer≻OS_capture(fallback_only);
  step1⇒detect(OS);
  OS≡macOS⇒preflight(Screen_Recording_perm)≺first_capture;
  save_path_prio:user_path→OS_default_screenshot_dir→temp_dir(/tmp,%TEMP%)@internal_chk;
  reply⇒report(∀saved_file_path);
  post⇒verify(exists(file));¬exists⇒report(err)∧suggest(retry);
}
§D{
  macOS_perm_err⇒rerun(preflight)+allow(Screen_Recording@(terminal∨runner))¬retry_same_capture;
  sandbox_block_msg⇒rerun(elevated_perms∨unsandboxed_terminal)¬silent_fail;
  macOS∧no_match_window⇒(--list-windows --app "Name")→(--window-id)¬guess_window_id;
  Linux∧tool≡∅⇒chk(command -v scrot,gnome-screenshot,import)+ask_user(install)¬install_unasked;
  default_dir_¬writable⇒fallback(explicit_user_reachable_path)¬write_unknown_path;
  need_1_of_N_displays⇒(macOS:already_1_file/monitor|Linux∨Win:crop_region)¬full_virtual_desktop_img;
  capture_for_own_inspection⇒temp_mode¬clutter_user_dir;
}
§REF{
  macOS_flags,screencapture,Linux(scrot,gnome-screenshot,import),Win_PowerShell_helper→references/capture-commands.md;
  UI_screenshots∨mockups→feature_task_checklist→references/screenshot-feature-extractor.md;
}
§REL{
  ../unit-testing-patterns/references/playwright.md:browser_screenshots,e2e_capture;
  ../web-quality-audit/SKILL.md:perf,a11y,SEO_audits;
  ../ux-research/SKILL.md:personas,journeys,usability_tests;
  ../web-scraping-apis/SKILL.md:remote_page_capture_scraping_APIs;
}
