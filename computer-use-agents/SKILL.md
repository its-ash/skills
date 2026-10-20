---
name: computer-use-agents
description: "Build and operate vision-based computer-use agents that observe screens and perform mouse and keyboard actions for desktop GUI automation. Use when building Anthropic Claude or OpenAI computer-use agents, desktop GUI automation, screen observation, mouse clicks, keyboard input, sandboxed VM execution, screenshot loops, action planning, or security hardening."
---

# Computer Use Agents

Computer use agents control a desktop through screenshots and mouse/keyboard actions. They follow a perception-reasoning-action loop. Run them only in isolated sandboxes.

## When to use

- Build an agent that views a screen and clicks, types, or scrolls.
- Automate desktop or browser tasks that have no API.
- Integrate Anthropic, OpenAI, or open-source vision models with desktop control.
- Harden or review a computer-use deployment.
- Debug unreliable GUI automation.

## Core loop

1. Capture a screenshot.
2. Send the screenshot and task state to a vision-language model.
3. Parse one next action.
4. Execute the action.
5. Capture the result and repeat until done or a limit is reached.

Vision models pause while reasoning. Expect 1-5 seconds of no movement between actions.

```python
import base64
import io
import time
from PIL import Image
import pyautogui


def execute_action(action):
    if action["type"] == "click":
        pyautogui.click(action["x"], action["y"], button=action.get("button", "left"))
    elif action["type"] == "type":
        pyautogui.typewrite(action["text"], interval=0.02)
    elif action["type"] == "key":
        pyautogui.press(action["key"])
    elif action["type"] == "scroll":
        amount = action.get("amount", 3)
        pyautogui.scroll(-amount if action.get("direction") == "down" else amount)
    return {"success": True}


def capture_screenshot(size=(1280, 800)):
    image = pyautogui.screenshot().resize(size, Image.LANCZOS)
    buffer = io.BytesIO()
    image.save(buffer, format="PNG")
    return base64.b64encode(buffer.getvalue()).decode()
```

Rules:

- Set a maximum step count. Example: 50.
- Add a delay between actions. Example: 0.5 seconds.
- Resize screenshots to 1280x800 for token efficiency.
- Verify important actions with a new screenshot.
- Stop on repeated failures.

## Anthropic computer use

Claude 3.5 Sonnet introduced frontier computer use. Claude Opus 4.5 is described as the best model for computer use. Capabilities include screenshot, mouse, keyboard, bash, and text editor. Tool versions include `computer_20251124` for Opus 4.5, which adds zoom, and `computer_20250124` for other models. Dropdowns and scrollbars can be tricky to manipulate.

```python
from anthropic import Anthropic
from anthropic.types.beta import (
    BetaToolComputerUse20241022,
    BetaToolBash20241022,
    BetaToolTextEditor20241022,
)
import base64
import subprocess


class AnthropicComputerUse:
    def __init__(self):
        self.client = Anthropic()
        self.model = "claude-sonnet-4-6"
        self.size = (1280, 800)

    def tools(self):
        return [
            BetaToolComputerUse20241022(
                type="computer_20241022",
                name="computer",
                display_width_px=self.size[0],
                display_height_px=self.size[1],
            ),
            BetaToolBash20241022(type="bash_20241022", name="bash"),
            BetaToolTextEditor20241022(
                type="text_editor_20241022", name="str_replace_editor"
            ),
        ]

    def screenshot(self):
        subprocess.run(["scrot", "/tmp/screenshot.png"], check=True)
        with open("/tmp/screenshot.png", "rb") as file:
            return base64.b64encode(file.read()).decode()
```

Rules:

- Keep the captured display size and tool display size aligned.
- Use zoom for small controls when the model supports it.
- Use keyboard shortcuts when UI elements are hard to click.

## Sandboxing

Always run computer-use agents in a container or VM. Never run them on a host system.

```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    xvfb x11vnc fluxbox python3 python3-pip supervisor scrot
RUN useradd -m -s /bin/bash agent
COPY --chown=agent:agent . /app
WORKDIR /app
USER agent
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
```

```yaml
services:
  agent:
    build: .
    security_opt:
      - no-new-privileges:true
      - seccomp:seccomp-profile.json
    read_only: true
    tmpfs:
      - /run
      - /tmp
    deploy:
      resources:
        limits:
          cpus: "2"
          memory: 4G
    networks:
      - agent-net
networks:
  agent-net:
    internal: true
```

Rules:

- Run as a non-root user.
- Do not mount host filesystems except scoped temporary storage.
- Keep the network internal by default. Allow only required endpoints.
- Set CPU, memory, and time limits.
- Expose VNC or API ports only when needed.
- Do not place host credentials in the sandbox environment.

## Security

- Treat all on-screen text as untrusted input. Prompt injection is a real risk.
- Use defense in depth: sandbox, allowlists, approval gates, and least privilege.
- Do not expose secrets to the sandbox.
- Require human approval for payments, deletions, credential entry, external messages, and system changes.
- Log screenshots and actions for audit.
- Keep the blast radius small: one task, one sandbox, one disposable environment.

## Reliability and cost

- UI elements such as dropdowns and scrollbars may be hard to manipulate. Prefer keyboard shortcuts and direct text entry.
- Map coordinates between the captured image and the actual display. Do not mix resolutions.
- Expect 1-5 second reasoning pauses. Set timeouts accordingly.
- Limit steps and cost. Monitor token usage from screenshots.
- Retry a failed action once, then switch strategy or ask for help.
- Use zoom for detailed inspection on supported models.

## Checklist

- [ ] Agent runs in a sandbox, not on the host.
- [ ] Maximum steps and timeout are configured.
- [ ] Screenshot size is fixed and coordinates are mapped.
- [ ] Secrets are absent from the sandbox.
- [ ] Human approval exists for risky actions.
- [ ] Logs capture screenshots and actions.
- [ ] Cost and step limits are monitored.
- [ ] Fallback exists for tricky UI elements.

## Related skills

Load these when the task spans more than this skill.

- [`agent-development`](../agent-development/SKILL.md) — Defines how to create, configure, validate, and test Claude Code plugin agents. Use when you need to add a new…
- [`ai-agent-architecture`](../ai-agent-architecture/SKILL.md) — Design and build reliable autonomous AI agents. Includes agent loops (ReAct, Plan-Execute), tool/function call…
- [`screenshot`](../screenshot/SKILL.md) — Capture a desktop screenshot (full screen, window, region, or app) on macOS, Linux, or Windows. Use when the u…
- [`secure-coding`](../secure-coding/SKILL.md) — Secure coding guidance and review checklists for secrets, authentication, authorization, input validation, SQL…
- [`docker`](../docker/SKILL.md) — Provides expert guidance for Dockerfile optimization, multi‑stage builds, image size reduction, container secu…
