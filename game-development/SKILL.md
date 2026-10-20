---
name: game-development
description: "Guides cross-platform game development covering core loop architecture, entity-component-system and state-machine design patterns, fixed-timestep simulation, collision broad-phase narrow-phase strategies, and a 16.67 ms frame budget for 60 FPS targets. Use when building HTML5 WebGL Canvas games, writing render_game_to_text advanceTime deterministic step functions, profiling requestAnimationFrame frame drops, configuring Playwright automated test loops with screenshot diffing, implementing input abstraction for keyboard gamepad touch, selecting AI behavior trees utility systems GOAP, debugging garbage-collection spikes in JavaScript TypeScript WASM, optimizing draw-call batching texture atlases, or deploying progressive web app game bundles to Vercel Netlify."
---

# Game Development

This skill teaches core game development principles, selects the right sub‑skill for platform, dimension, or specialty, and provides a concrete workflow for building and testing HTML5/WebGL games with Playwright.

## When to Use This Skill
- You are starting or extending a game project.
- You need to decide platform, 2D/3D, or specialty (design, networking, art, audio).
- You are implementing a browser‑based game and require a repeatable development‑test loop.

---

## Core Principles (All Platforms)

### 1. The Game Loop
```
INPUT   → read player actions
UPDATE  → process game logic (fixed timestep)
RENDER  → draw the frame (interpolated)
```
- **Fixed timestep** for physics/logic (e.g., 50 Hz).
- Render as fast as possible.
- Interpolate between states for smooth visuals.

### 2. Pattern Selection Matrix
| Pattern | When to Use | Example |
|---|---|---|
| State Machine | 3‑5 discrete states | Player: Idle → Walk → Jump |
| Object Pooling | Frequent spawn/destroy | Bullets, particles |
| Observer / Events | Cross‑system communication | Health → UI updates |
| Entity‑Component‑System (ECS) | Thousands of similar entities | RTS units, particles |
| Command | Undo, replay, networking | Input recording |
| Behavior Tree | Complex AI decisions | Enemy AI |

**Decision rule:** Start with a State Machine. Add ECS only when performance demands.

### 3. Input Abstraction
Map raw keys to **actions**.
```text
"jump" → Space, Gamepad A, Touch tap
"move" → WASD, Left stick, Virtual joystick
```
Benefits: multi‑platform support and easy rebinding.

### 4. Performance Budget (Target 60 FPS = 16.67 ms)
| System | Budget |
|---|---|
| Input | 1 ms |
| Physics | 3 ms |
| AI | 2 ms |
| Game Logic | 4 ms |
| Rendering | 5 ms |
| Buffer | 1.67 ms |

**Optimization priority**
1. Reduce algorithmic complexity (e.g., O(n²) → O(n log n)).
2. Batch draw calls.
3. Pool objects to avoid GC spikes.
4. Apply LOD and culling.

### 5. AI Selection by Complexity
| AI Type | Complexity | Use When |
|---|---|---|
| FSM | Simple | 3‑5 states, predictable behavior |
| Behavior Tree | Medium | Modular, designer‑friendly |
| GOAP | High | Emergent planning |
| Utility AI | High | Scoring‑based decisions |

### 6. Collision Strategy
| Type | Best For |
|---|---|
| AABB | Axis‑aligned rectangles, fast checks |
| Circle | Round objects, cheap math |
| Spatial Hash | Many similar‑sized objects |
| Quadtree | Large worlds with varying sizes |

### 7. Anti‑Patterns (Universal)
| Don't | Do |
|---|---|
| Update everything each frame | Use events or dirty flags |
| Allocate objects in hot loops | Use object pooling |
| Cache nothing | Cache reusable references |
| Optimize without profiling | Profile first |
| Mix input handling with game logic | Keep a separate input abstraction layer |

---

## Development Workflow for Web Games (HTML5 / WebGL)
1. **Define a single, small goal** – a feature or behavior.
2. **Implement the smallest change** that moves the game forward.
3. **Expose two deterministic hooks** on `window`:
   - `window.render_game_to_text()` – returns a concise JSON snapshot of the current state.
   - `window.advanceTime(ms)` – advances the game loop by a given number of milliseconds.
4. **Keep a single `<canvas>`** centered in the page. Render everything inside the canvas; avoid CSS backgrounds.
5. **Add a progress log** (`progress.md`). Record the original prompt, TODOs, decisions, and any open issues. Append after each meaningful change.
6. **Run the Playwright test loop** after every change (see “Automated Test Loop”).
7. **Iterate**: adjust code, re‑run the test loop, and repeat until the feature works without errors.

### Minimal `render_game_to_text` Example (JavaScript)
```js
window.render_game_to_text = () => {
  const payload = {
    mode: state.mode,
    player: { x: state.player.x, y: state.player.y, r: state.player.r },
    entities: state.entities.map(e => ({ x: e.x, y: e.y, r: e.r })),
    score: state.score,
  };
  return JSON.stringify(payload);
};
```
Include only currently visible and interactive data.

### Minimal `advanceTime` Example
```js
window.advanceTime = ms => {
  const steps = Math.max(1, Math.round(ms / (1000 / 60)));
  for (let i = 0; i < steps; i++) update(1 / 60);
  render();
};
```
The test script will call this to step the simulation deterministically.

### Fullscreen Toggle (Optional)
- Bind `f` to toggle fullscreen.
- Allow `Esc` to exit.
- Resize the canvas on toggle to keep input mapping correct.

---

## Automated Test Loop (Playwright)
1. **Verify Playwright is available** – run `npx playwright --version`. If missing, install with `npm install -g @playwright/mcp`.
2. **Prepare an action payload** (JSON) describing per‑frame inputs. Use the provided reference payloads as a template.
3. **Run the client** (replace placeholders with your project’s URL):
   ```bash
   npx playwright run --url http://localhost:5173 \
       --actions-file path/to/actions.json \
       --click-selector "#start-btn" \
       --iterations 3 --pause-ms 250
   ```
4. **Review artifacts** after each run:
   - Latest screenshot(s).
   - JSON output from `window.render_game_to_text`.
   - Console error log.
5. **Validate** that the screenshot matches the expected visual state and that the JSON reflects the same information.
6. **Fix the first new error** before proceeding.
7. **Reset between scenarios** to avoid cross‑test contamination.
8. **Repeat** until the feature passes all checks.

### Example Action Payload (inline JSON)
```json
{
  "steps": [
    { "buttons": ["left_mouse_button"], "frames": 2, "mouse_x": 120, "mouse_y": 80 },
    { "buttons": [], "frames": 6 },
    { "buttons": ["right"], "frames": 8 },
    { "buttons": ["space"], "frames": 4 }
  ]
}
```
Each step describes which inputs are active for a number of frames.

---

## Test Checklist
- [ ] Primary movement and interaction inputs (move, jump, shoot, confirm/select).
- [ ] Win/lose or success/fail transitions.
- [ ] Score, health, or resource changes.
- [ ] Collision handling at walls, boundaries, and other entities.
- [ ] Menu, pause, and start flow if present.
- [ ] Any special abilities, power‑ups, or puzzle mechanics requested.
- [ ] No new console errors.
- [ ] Screenshots show expected visuals for each tested scenario.
- [ ] `render_game_to_text` JSON matches on‑screen state.

---

## Common Pitfalls & Mitigations
- **Missing deterministic hook** – Without `advanceTime`, Playwright tests become flaky. Add the hook early.
- **Large state payload** – Overly verbose JSON slows test analysis. Keep payload minimal and focused on visible entities.
- **Hard‑coded input keys** – Breaks multi‑platform support. Use the action abstraction layer.
- **Creating objects in hot loops** – Leads to GC spikes. Implement object pooling for bullets, particles, etc.
- **Skipping profiling** – Optimize only after measuring frame time with browser dev tools or Playwright’s timing output.
- **Ignoring console errors** – Even a single uncaught error can halt the game loop. Fix immediately.

---

## Routing to Sub‑Skills
| Context | Recommended Sub‑Skill |
|---|---|
| Web browser target (HTML5 / WebGL) | `game-development/web-games` |
| Mobile (iOS / Android) | `game-development/mobile-games` |
| PC (Steam, Desktop) | `game-development/pc-games` |
| VR/AR headset | `game-development/vr-ar` |
| 2D sprite‑based | `game-development/2d-games` |
| 3D mesh‑based | `game-development/3d-games` |
| Game design, balancing, psychology | `game-development/game-design` |
| Multiplayer networking | `game-development/multiplayer` |
| Visual art pipeline | `game-development/game-art` |
| Audio and adaptive music | `game-development/game-audio` |

Use this matrix to jump to a more detailed skill when deeper platform‑specific guidance is required.

---

## Final Advice
Prototype fast, iterate often, and keep the development loop small. Profile before optimizing, and always verify both visual output and the deterministic text state. Good games emerge from disciplined iteration, not from perfect code written once.

## Related skills

Load these when the task spans more than this skill.

- [`playwright`](../playwright/SKILL.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
