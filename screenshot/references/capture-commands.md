# Capture Commands per OS

Parent: [`screenshot`](../SKILL.md). Each helper prints the full path of each saved file.

## macOS

Permission preflight (once, before the first capture; prompts the user to allow Screen Recording for the terminal or script runner):

```bash
sudo /usr/bin/osascript -e 'tell application "System Events" to set UI elements enabled to true'
```

Helper: `python3 -m screenshot_tool take_screenshot <options>`

| Mode | Options |
|---|---|
| Default location | (none) |
| Temp (internal check) | `--mode temp` |
| Explicit path | `--path /Users/me/Desktop/screen.png` |
| App/window (substring match) | `--app "Codex"` |
| Window by title | `--app "Codex" --window-name "Settings"` |
| List windows (find IDs) | `--list-windows --app "Codex"` |
| Window by ID | `--window-id 12345` |
| Pixel region `x,y,w,h` | `--region 100,200,800,600` |
| Active window | `--active-window` |

Multiple matching windows or displays: one line per file, suffixes such as `-w12345` or `-d1`.

Fallback, built-in `screencapture` (`-x` = no sound):

```bash
screencapture -x /Users/me/Desktop/screen.png      # full screen
screencapture -x -R100,200,800,600 region.png      # region x,y,w,h
screencapture -x -l12345 window.png                # window ID
screencapture -x -i interactive.png                # interactive selection
```

## Linux

Use the first installed tool: `scrot` -> `gnome-screenshot` -> ImageMagick `import`. Check with `command -v <tool>`.

```bash
scrot output.png                                   # full screen
scrot -e 'mv $f /tmp/$f' output.png                # temp location
scrot -a 100,200,800,600 region.png                # region
scrot -u window.png                                # active window
gnome-screenshot -f output.png
gnome-screenshot -w -f window.png                  # active window
gnome-screenshot -a -f region.png                  # interactive area
import -window root output.png
import -window root -crop 800x600+100+200 region.png
```

## Windows

Helper: `powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 <options>`

| Mode | Options |
|---|---|
| Default location | (none) |
| Temp | `-Mode Temp` |
| Explicit path | `-Path "C:\Temp\screen.png"` |
| Pixel region | `-Mode Temp -Region 100,200,800,600` |
| Active window (focus it first) | `-Mode Temp -ActiveWindow` |
| Window handle | `-WindowHandle 123456` |
