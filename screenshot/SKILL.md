---
name: screenshot
description: "Capture desktop screenshots on macOS, Linux, and Windows via native utilities — screencapture, gnome-screenshot, scrot, maim, spectacle, and PowerShell — supporting full-screen, window, region, and app modes with configurable output paths and formats. Use when user says screenshot, screen capture, snap, grab, print screen, screen grab, or capture display; needs image for bug report, documentation, UI audit, design handoff, visual regression, accessibility review, or sharing screen content; hits missing tool fallback, macOS TCC permission prompt, Wayland vs X11 tool selection, or headless CI capture requirements."
---

# Screenshot Capture
Capture a screenshot of the desktop, a specific application, a window, or a pixel region. Save the image to the user‑specified path, the OS default screenshot folder, or a temporary directory for internal inspection.

## When to use
- User explicitly requests a screenshot.
- No dedicated tool (e.g., Figma, Playwright) can provide the needed view.
- You need a quick visual check for your own processing.

## Save‑location rules
1. If the user provides a file path, save the image there.
2. If the user does not provide a path, save to the OS default screenshot location.
3. If the screenshot is for internal inspection, save to a temporary directory (e.g., `/tmp` on macOS/Linux, `%TEMP%` on Windows).

## Tool priority
- Use a tool‑specific capture (Figma, Playwright, etc.) when available.
- Otherwise, fall back to this OS‑level screenshot skill.

## macOS permission preflight
macOS requires Screen Recording permission for any capture.
1. Run the permission helper once before the first capture:
   ```bash
   sudo /usr/bin/osascript -e 'tell application "System Events" to set UI elements enabled to true'
   ```
   (The helper will prompt the user to allow Screen Recording for the terminal or script runner.)
2. After permission is granted, you can run the capture commands directly.

## macOS capture commands (Python helper syntax)
Replace `<options>` with the desired flags.
```bash
python3 -m screenshot_tool take_screenshot <options>
```
### Common option sets
- **Default location** (user asked for a screenshot):
  ```bash
  python3 -m screenshot_tool take_screenshot
  ```
- **Temporary location** (internal check):
  ```bash
  python3 -m screenshot_tool take_screenshot --mode temp
  ```
- **Explicit path**:
  ```bash
  python3 -m screenshot_tool take_screenshot --path /Users/me/Desktop/screen.png
  ```
- **App/window capture** (macOS only, substring match):
  ```bash
  python3 -m screenshot_tool take_screenshot --app "Codex"
  ```
- **Specific window title**:
  ```bash
  python3 -m screenshot_tool take_screenshot --app "Codex" --window-name "Settings"
  ```
- **List matching windows** (to discover IDs):
  ```bash
  python3 -m screenshot_tool take_screenshot --list-windows --app "Codex"
  ```
- **Pixel region** (`x,y,w,h`):
  ```bash
  python3 -m screenshot_tool take_screenshot --region 100,200,800,600
  ```
- **Active (focused) window**:
  ```bash
  python3 -m screenshot_tool take_screenshot --active-window
  ```
- **Specific window ID** (use after `--list-windows`):
  ```bash
  python3 -m screenshot_tool take_screenshot --window-id 12345
  ```
The helper prints the full path of each saved image. When multiple windows or displays match, it prints one line per file with suffixes such as `-w12345` or `-d1`.

## Linux capture commands (fallback tool selection)
The helper selects the first available tool:
1. `scrot`
2. `gnome-screenshot`
3. ImageMagick `import`
If none are installed, ask the user to install one.
### Examples (replace `<options>` as needed)
```bash
scrot <options> output.png
```
- **Full screen (default location):**
  ```bash
  scrot output.png
  ```
- **Temporary location:**
  ```bash
  scrot -e 'mv $f /tmp/$f' output.png
  ```
- **Pixel region:**
  ```bash
  scrot -a 100,200,800,600 region.png
  ```
- **Active window:**
  ```bash
  scrot -u window.png
  ```
- **Using `gnome-screenshot`:**
  ```bash
  gnome-screenshot -f output.png
  gnome-screenshot -w -f window.png   # active window
  gnome-screenshot -a -f region.png   # interactive area
  ```
- **Using ImageMagick `import`:**
  ```bash
  import -window root output.png
  import -window root -crop 800x600+100+200 region.png
  ```

## Windows capture commands (PowerShell helper)
Run the PowerShell script directly. Replace `<options>` with the desired flags.
```powershell
powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 <options>
```
### Common option sets
- **Default location:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1
  ```
- **Temporary location:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 -Mode Temp
  ```
- **Explicit path:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 -Path "C:\Temp\screen.png"
  ```
- **Pixel region:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 -Mode Temp -Region 100,200,800,600
  ```
- **Active window:** (focus the window first)
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 -Mode Temp -ActiveWindow
  ```
- **Specific window handle:**
  ```powershell
  powershell -ExecutionPolicy Bypass -File Take-Screenshot.ps1 -WindowHandle 123456
  ```
The script outputs the full file path.

## Direct OS commands (fallback when helpers are unavailable)
### macOS (built‑in `screencapture`)
- Full screen to a path:
  ```bash
  screencapture -x /Users/me/Desktop/screen.png
  ```
- Pixel region (`x,y,w,h`):
  ```bash
  screencapture -x -R100,200,800,600 region.png
  ```
- Specific window ID:
  ```bash
  screencapture -x -l12345 window.png
  ```
- Interactive selection:
  ```bash
  screencapture -x -i interactive.png
  ```
### Linux (raw commands shown above under Linux section)
### Windows (raw commands shown above under Windows section)

## Multi‑display behavior
- **macOS:** Full‑screen capture creates one file per monitor.
- **Linux & Windows:** Full‑screen capture creates a single image that contains all monitors (virtual desktop). Use `--region` to isolate a single display if needed.

## Error handling
- **macOS permission errors:** Run the permission preflight helper again and ensure Screen Recording is allowed for the terminal or script runner.
- **Sandbox block messages:** Rerun the command with elevated permissions or from an unsandboxed terminal.
- **No matching windows (macOS):** Run `--list-windows --app "AppName"` to see IDs, then capture with `--window-id`.
- **Linux tool missing:** Verify with `command -v scrot`, `command -v gnome-screenshot`, or `command -v import`. Prompt the user to install the missing tool.
- **Saving to default location fails:** Check write permissions for the default screenshot folder; fall back to an explicit path the user can access.
- **Always report the saved file path** in the response so the user knows where to find the image.

## Checklist
- [ ] Determine OS (macOS, Linux, Windows).
- [ ] Run macOS permission preflight if on macOS and no permission yet.
- [ ] Choose capture mode: full screen, app, window, region, active window, or temporary.
- [ ] Apply save‑location rule (user path → default → temp).
- [ ] Execute the appropriate command.
- [ ] Capture the printed file path(s) and include them in the reply.
- [ ] Verify the file exists; if not, report the error and suggest a retry.

## Related skills

Load these when the task spans more than this skill.

- [`image-enhancer`](../image-enhancer/SKILL.md) — Enhances image resolution, sharpness, and reduces compression artifacts for screenshots, photos, and graphics.…
- [`playwright`](../playwright/SKILL.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`web-quality-audit`](../web-quality-audit/SKILL.md) — Runs a full web quality audit that checks performance (Core Web Vitals, resource loading), accessibility, SEO,…
- [`ux-research`](../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) — Unified guide for using web‑scraping APIs (Firecrawl, Tavily, Cloudflare Browser Rendering, and Xquik) to extr…
- [`computer-use-agents`](../computer-use-agents/SKILL.md) — Build and operate vision-based computer-use agents that observe screens and perform mouse/keyboard actions. Us…
