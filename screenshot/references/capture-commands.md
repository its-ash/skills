@REF:capture-commands
§REL{
  ../SKILL.md:parent;
  ../../unit-testing-patterns/references/playwright.md:playwright_visual_tests;
  ../../swift-ios/SKILL.md:iOS_simctl,ScreenCaptureKit;
}

§R{
  self_contained_native_cmds⇒¬assume_uninstalled_helper_scripts(screenshot_tool,Take-Screenshot.ps1);
  every_capture⇒output(exact_abs_path)∧verify(exists∧bytes>0∧valid_dims∧¬blank);
  macOS_15_Sequoia|26_Tahoe⇒TCC_Screen_Recording_enforced(periodic_reconsent,¬MDM_silent_bypass);CLI_inherits_parent_terminal_grant;
  Linux_display_detect⇒probe(XDG_SESSION_TYPE,WAYLAND_DISPLAY,DISPLAY)≺selecting_tool;
  Win11_DPI⇒SetProcessDpiAwarenessContext((IntPtr)(-4))≺loading_Forms|reading_bounds;always_Dispose(Graphics,Bitmap);
}

§CMD{
  # macOS (native /usr/sbin/screencapture + Swift CoreGraphics)
  mac_preflight:swift -e 'import CoreGraphics; print(CGPreflightScreenCaptureAccess())'
  mac_request_tcc:swift -e 'import CoreGraphics; print(CGRequestScreenCaptureAccess())'
  mac_reset_tcc_dev:tccutil reset ScreenCapture <bundle_id>
  mac_list_windows:swift -e 'import CoreGraphics; (CGWindowListCopyWindowInfo([.optionOnScreenOnly,.excludeDesktopElements],kCGNullWindowID) as? [[String:Any]] ?? []).forEach{print("\($0[kCGWindowNumber as String] ?? 0)|\($0[kCGWindowLayer as String] ?? 0)|\($0[kCGWindowOwnerName as String] ?? "")|\($0[kCGWindowName as String] ?? "")")}'
  mac_full:screencapture -x /tmp/screen.png
  mac_display_n:screencapture -x -D 1 /tmp/display1.png # -D 1=main, -D 2=secondary; -m=main_only
  mac_multi_display:screencapture -x /tmp/d1.png /tmp/d2.png # 1_file/screen
  mac_window_clean:screencapture -x -o -l<window_id> /tmp/win.png # -o=no_shadow, -a=no_attached_sheets
  mac_region:screencapture -x -R100,200,800,600 /tmp/region.png # x,y,w,h
  mac_opts:-C(include_cursor) | -c(clipboard) | -t<png|jpg|pdf|tiff> | -T<sec>(delay) | -r(omit_DPI_meta) | -H(HDR) | -i(interactive;-s=rect,-w=win)
  mac_downscale_hidpi:sips -Z 1600 /tmp/screen.png --out /tmp/screen_1600.png

  # Linux session detection + Wayland (preferred) + X11 (legacy fallback)
  lnx_detect:printf 'session=%s wayland=%s x11=%s\n' "${XDG_SESSION_TYPE:-}" "${WAYLAND_DISPLAY:-}" "${DISPLAY:-}"
  lnx_wlroots_full:grim /tmp/screen.png # flags:-t<png|jpeg|ppm> -s<scale> -l<0-9> -c(cursor)
  lnx_wlroots_display:grim -o DP-1 /tmp/dp1.png
  lnx_wlroots_rect:grim -g "100,200 800x600" /tmp/region.png
  lnx_wlroots_interactive:grim -g "$(slurp)" /tmp/region.png
  lnx_wlroots_pipe:grim -g "$(slurp)" - | wl-copy # annotate: grim -g "$(slurp)" - | satty --filename -
  lnx_kde_plasma6:spectacle -b -n -f -o /tmp/screen.png # -b=bg,-n=nonotify,-f=full,-a=active_win,-m=cur_monitor,-r=region,-u=under_cursor
  lnx_gnome_portal:gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop --method org.freedesktop.portal.Screenshot.Screenshot "" '{}'
  lnx_x11_probe:for t in maim scrot import; do command -v "$t" && break; done
  lnx_x11_maim:maim /tmp/screen.png | maim -g 800x600+100+200 /tmp/region.png | maim -i "$(xdotool getactivewindow)" /tmp/win.png
  lnx_x11_scrot:scrot /tmp/screen.png | scrot -a 100,200,800,600 /tmp/region.png | scrot -u /tmp/win.png
  lnx_x11_import:import -window root /tmp/screen.png | import -window root -crop 800x600+100+200 /tmp/region.png

  # Windows 11 (PowerShell pwsh/powershell.exe, inline DPI-aware)
  win_list_hwnd:Get-Process | ? MainWindowHandle -ne 0 | Select Name,Id,MainWindowHandle,MainWindowTitle
  win_full_virtual:pwsh -NoProfile -Command 'Add-Type "using System;using System.Runtime.InteropServices;public class D{[DllImport(\"user32.dll\")]public static extern bool SetProcessDpiAwarenessContext(IntPtr c);}"; [D]::SetProcessDpiAwarenessContext([IntPtr](-4))|Out-Null; Add-Type -AssemblyName System.Windows.Forms,System.Drawing; $b=[System.Windows.Forms.SystemInformation]::VirtualScreen; $bmp=[System.Drawing.Bitmap]::new($b.Width,$b.Height); $g=[System.Drawing.Graphics]::FromImage($bmp); try{$g.CopyFromScreen($b.Left,$b.Top,0,0,$bmp.Size,[System.Drawing.CopyPixelOperation]::SourceCopy); $bmp.Save("$env:TEMP\screen.png",[System.Drawing.Imaging.ImageFormat]::Png)}finally{$g.Dispose();$bmp.Dispose()}'
  win_single_monitor:$b=[System.Windows.Forms.Screen]::AllScreens[0].Bounds # or ::PrimaryScreen.Bounds
  win_region:$g.CopyFromScreen($x,$y,0,0,[System.Drawing.Size]::new($w,$h),[System.Drawing.CopyPixelOperation]::SourceCopy)

  # Browser / Headless CI / Mobile
  chrome_headless:google-chrome --headless --screenshot=/tmp/page.png --window-size=1280,800 https://example.com
  playwright_cli_update_ci:docker run --rm -v "${PWD}:/work" -w /work mcr.microsoft.com/playwright:<ver>-jammy npx playwright test --update-snapshots
  android_adb:adb exec-out screencap -p > /tmp/android.png # exec-out prevents CRLF corruption vs shell
  ios_simctl:xcrun simctl io booted screenshot /tmp/ios.png
}

§PAT{
  macOS_programmatic_Swift:ScreenCaptureKit(SCShareableContent.excludingDesktopWindows(false,onScreenWindowsOnly:true)→SCContentFilter→SCScreenshotManager.captureImage(contentFilter:configuration:));bundled_.app+Info.plist(NSScreenCaptureUsageDescription)+codesign;
  Win11_window_PrintWindow:P/Invoke(SetProcessDpiAwarenessContext(-4)→GetWindowRect($hwnd)→Bitmap(w,h)→hdc=$g.GetHdc()→PrintWindow($hwnd,$hdc,0x2/*PW_RENDERFULLCONTENT*/)→ReleaseHdc→Save→Dispose);
  Playwright_deterministic:page.clock.setFixedTime(...)→page.goto(...)→await page.evaluate(()=>document.fonts.ready)→expect(locator).toHaveScreenshot({animations:'disabled',caret:'hide',mask:[...],maxDiffPixelRatio:0.01});
  CI_visual_diff_review:commit(*.spec.ts-snapshots/)∧upload_CI_artifact(test-results/_on_fail)∧match_OS_Docker_image;
}

§ANTI{
  ¬sudo_osascript_UI_elements_enabled(wrong_perm:Accessibility≠Screen_Recording);
  ¬CGWindowListCreateImage|CGDisplayCreateImage(deprecated_macOS_14,obsoleted_macOS_15+→blank_or_compile_err);
  ¬gnome-screenshot(officially_deprecated;use_portal|GNOME_Shell_UI);
  ¬scrot|maim|import_on_Wayland(X11_root_unavailable→blank_or_fail);
  ¬grim_on_GNOME_Mutter(lacks_wlr-screencopy-unstable-v1);
  ¬Win11_CopyFromScreen_without_PerMonitorV2(clipped/blurry_mixed_DPI)∨PrintWindow_flag_0(black_frame_on_Chromium/Electron/DirectComposition);
  ¬adb_shell_screencap_redirect(CRLF_corrupts_PNG_on_Win;always_use_exec-out);
  ¬generate_Playwright_baselines_on_macOS_for_Linux_CI(font_hinting/subpixel_drift);
}

§CHK{
  [ ] detected_OS_and_display_server(Wayland|X11|macOS|Win11|headless);
  [ ] preferred_native_tool(Playwright|MCP|adb|simctl)≺OS_screen_grab;
  [ ] macOS:CGPreflightScreenCaptureAccess_checked|Win11:PerMonitorV2_set;
  [ ] verified(file_exists∧size>0∧valid_dims∧¬blank_wallpaper_only);
  [ ] redacted_PII_secrets_if_shared_or_committed;
  [ ] reported_exact_saved_path(s);
}
