---
name: screenshot
description: "Capture desktop screenshots on macOS, Linux, and Windows via native utilities (screencapture, gnome-screenshot, scrot, maim, spectacle, PowerShell) in full-screen, window, region, and app modes with set output paths. Use when user says screenshot, screen capture, snap, grab, print screen, or capture display; needs an image for a bug report, docs, UI audit, design handoff, visual regression, or a11y review; or hits missing-tool fallback, macOS TCC permission prompts, Wayland vs X11 tool choice, or headless CI capture. Sub-skills: screenshot-feature-extractor."
---

# Screenshot

Capture the desktop, an app, a window, or a pixel region, and report where the file is.

## Core rules

- Prefer a tool-specific capture (Figma, Playwright) when one gives the needed view. Use OS capture only as fallback.
- Detect the OS first.
- On macOS, run the Screen Recording permission preflight before the first capture.
- Pick the save location in this order: user path -> OS default screenshot folder -> temp dir (`/tmp`, `%TEMP%`) for internal checks.
- Report every saved file path in the reply.
- Verify that the file exists. If not, report the error and suggest a retry.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| macOS permission error | Rerun the preflight; allow Screen Recording for the terminal or runner | Retrying the same capture |
| Sandbox block message | Rerun with elevated permissions or from an unsandboxed terminal | Silent failure |
| macOS: no matching window | `--list-windows --app "Name"`, then `--window-id` | Guessing window IDs |
| Linux: no tool found | Check `command -v scrot`, `gnome-screenshot`, `import`; ask the user to install one | Installing without asking |
| Default folder not writable | Fall back to an explicit path the user can reach | Writing to an unknown path |
| Need one display of many | macOS: one file per monitor already; Linux/Windows: crop with region (one image spans all monitors) | Full virtual-desktop image |
| Capture for own inspection | Temp mode | Cluttering the user's folder |

## Load on demand

| Need | Read |
|---|---|
| macOS helper flags, `screencapture`, Linux `scrot`/`gnome-screenshot`/`import`, Windows PowerShell helper | [capture-commands.md](references/capture-commands.md) |
| Turn UI screenshots or mockups into a feature and task checklist | [screenshot-feature-extractor.md](references/screenshot-feature-extractor.md) |

## Related skills

- [`playwright`](../unit-testing-patterns/references/playwright.md) - browser screenshots and e2e capture
- [`web-quality-audit`](../web-quality-audit/SKILL.md) - perf, a11y, SEO audits
- [`ux-research`](../ux-research/SKILL.md) - personas, journeys, usability tests
- [`web-scraping-apis`](../web-scraping-apis/SKILL.md) - remote page capture via scraping APIs
