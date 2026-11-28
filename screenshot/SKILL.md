---
name: screenshot
description: "AUTO_INVOKE(silent)⇔prompt∈{screenshot,screen_capture,snap,grab,print_screen,capture_display,full_screen,window,region,app_capture,macOS,Linux,Windows,screencapture,ScreenCaptureKit,TCC,Screen_Recording,Wayland,grim,slurp,satty,spectacle,xdg-desktop-portal,X11,maim,scrot,gnome-screenshot,import,PowerShell,DPI_aware,PrintWindow,headless_CI,Playwright_screenshot,adb_screencap,simctl,bug_report,docs,UI_audit,design_handoff,visual_regression,a11y_review,redact_PII,missing_tool_fallback}|SUB:{screenshot-feature-extractor}"
---
@SKL:screenshot
§R{
  goal≡capture(desktop∨app∨window∨px_region∨browser∨mobile)∧report(∀saved_file_path);
  target_prio:tool_native(Playwright∨Chrome_DevTools_MCP∨Figma∨adb∨simctl)≻OS_capture(fallback_only);
  step1⇒detect(OS∧display_server(Wayland|X11|macOS|Win11|headless));
  macOS⇒preflight(CGPreflightScreenCaptureAccess)≺first_capture;¬run(sudo_osascript_UI_elements);
  macOS_prog_API⇒ScreenCaptureKit(SCScreenshotManager)¬CGWindowListCreateImage(obsolete≥macOS_15);
  Linux⇒detect(XDG_SESSION_TYPE∨WAYLAND_DISPLAY)≺tool_pick;Wayland⇒(grim+slurp|spectacle|xdg-desktop-portal)¬(scrot|maim|import|gnome-screenshot);
  Win11⇒call(SetProcessDpiAwarenessContext(-4)_PerMonitorV2)≺screen_bounds∧window_capture⇒PrintWindow(PW_RENDERFULLCONTENT=0x2);
  headless_CI∨web_visual_regression⇒Playwright(animations:'disabled',caret:'hide',mask,fonts.ready,fixed_clock,Docker_CI_parity);
  save_path_prio:user_path→OS_default_screenshot_dir→temp_dir(/tmp,%TEMP%)@internal_chk;
  privacy⇒redact|mask(PII,tokens,emails,secrets)≺share|commit;
  post⇒verify(exists(file)∧size>0∧valid_dims∧¬blank_wallpaper_only);fail⇒report(exact_err)∧remediation;
  reply⇒report(∀saved_file_path);
}
§D{
  macOS_TCC_denied∨wallpaper_only⇒guide_user(System_Settings>Privacy&Security>Screen_Recording@calling_terminal|runner;note_macOS_15+/26_reconsent)¬loop_retry;
  sandbox_block⇒rerun(elevated_perms∨unsandboxed_terminal)¬silent_fail;
  macOS∧target_window⇒list_CGWindowID(swift_CGWindowListCopyWindowInfo)→screencapture(-x -o -l<wid>)¬guess_wid;
  Linux_Wayland∧wlroots(Hyprland|Sway)⇒grim(-g "$(slurp)"|-o <out>)¬X11_tools;
  Linux_Wayland∧KDE_Plasma_6⇒spectacle(-b -n -f|-a|-m|-r -o <path>)¬gnome-screenshot;
  Linux_Wayland∧GNOME⇒xdg-desktop-portal(gdbus_Screenshot)¬grim(no_wlr_screencopy)¬gnome-screenshot(deprecated);
  Linux_X11_only⇒probe(maim→scrot→import);all_missing⇒ask_user(install)¬install_unasked;
  Win11∧occluded|GPU|Chromium_window⇒PrintWindow(PW_RENDERFULLCONTENT=0x2)¬plain_PrintWindow(black_frame)¬CopyFromScreen(occluded);
  Win11∧mixed_DPI|multi_monitor⇒PerMonitorV2_DPI_context+Screen::AllScreens[$i]|VirtualScreen¬unscaled_GDI;
  web_UI_capture⇒Playwright|Chrome_DevTools_MCP|chrome(--headless --screenshot)¬desktop_screen_grab;
  mobile_emulator|device⇒(Android:adb exec-out screencap -p|iOS:xcrun simctl io booted screenshot)¬host_window_crop;
  need_1_of_N_displays⇒(macOS:-D <n>|Wayland:grim -o <out>|KDE:spectacle -m|Win:Screen::AllScreens[$i]|X11:crop)¬full_virtual_desktop;
  default_dir_¬writable⇒fallback(explicit_user_reachable_path)¬write_unknown_path;
  capture_for_own_inspection⇒temp_dir(/tmp|%TEMP%)¬clutter_user_dir;
  Retina_HiDPI_for_LLM_or_docs⇒downscale(sips -Z|magick)⇔oversized_4K/5K;
}
§REF{
  macOS_TCC,screencapture,ScreenCaptureKit,Linux_Wayland(grim,slurp,satty,spectacle,portal),X11,Win11_PowerShell_DPI_PrintWindow,Playwright,Headless_Chrome,adb,simctl→references/capture-commands.md;
  UI_screenshots∨mockups→feature_task_checklist,PRD_extraction,gap_analysis→references/screenshot-feature-extractor.md;
}
§REL{
  ../unit-testing-patterns/references/playwright.md:browser_screenshots,visual_regression,e2e_capture;
  ../web-quality-audit/SKILL.md:perf,a11y,SEO_audits;
  ../design/SKILL.md:UI_audit,design_handoff,tokens;
  ../ux-research/SKILL.md:personas,journeys,usability_tests;
  ../product-strategy/SKILL.md:PRD,competitor_benchmark,white_space;
  ../web-scraping-apis/SKILL.md:remote_page_capture_scraping_APIs;
}
