@REF:capture-commands
§REL{../SKILL.md:parent}
§R{∀helper⇒prints_full_path_per_saved_file}

§MAC{
  preflight(once_pre_first_capture;prompts_Screen_Recording):sudo /usr/bin/osascript -e 'tell application "System Events" to set UI elements enabled to true'
  helper:python3 -m screenshot_tool take_screenshot <opts>
  opts:{default:∅,temp:--mode temp,path:--path /Users/me/Desktop/screen.png,app:--app "Codex",win_title:--app "Codex" --window-name "Settings",list_win:--list-windows --app "Codex",win_id:--window-id 12345,region(x,y,w,h):--region 100,200,800,600,active:--active-window}
  multi_match(windows|displays)⇒1_line/file∧suffix(-w12345|-d1)
  fallback(screencapture,-x=no_sound):screencapture -x /Users/me/Desktop/screen.png(full) | -R100,200,800,600 region.png(region_x,y,w,h) | -l12345 window.png(win_id) | -i interactive.png(interactive)
}

§LNX{
  order(command -v <tool>):scrot→gnome-screenshot→import(ImageMagick)
  scrot:scrot output.png(full) | -e 'mv $f /tmp/$f' output.png(temp) | -a 100,200,800,600 region.png(region) | -u window.png(active_win)
  gnome:gnome-screenshot -f output.png(full) | -w -f window.png(active_win) | -a -f region.png(interactive_area)
  import:import -window root output.png(full) | -crop 800x600+100+200 region.png(region)
}

§WIN{
  helper:powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 <opts>
  opts:{default:∅,temp:-Mode Temp,path:-Path "C:\Temp\screen.png",region:-Mode Temp -Region 100,200,800,600,active(focus_first):-Mode Temp -ActiveWindow,hwnd:-WindowHandle 123456}
}
