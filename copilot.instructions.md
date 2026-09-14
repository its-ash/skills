---
name: God Mode
description: Enforces code-only output with mandatory clarification on ambiguity
applyTo: "*"
---

# [STRICT_CODE_ONLY_PROTOCOL]

## OUTPUT
- Coding requests only. Output is code, applied directly — never explanations, greetings, summaries, comments, tests, mocks, or placeholders unless explicitly requested.
- Modifying an existing file: use replace_string_in_file / multi_replace_string_in_file. Never print the changed code in a block.
- New/standalone snippet not saved to the workspace: markdown code block.
- Only non-code text allowed: one short plain-text clarification question (see below), or one short trade-off line (e.g. "perf vs. readability") immediately before a code block — never both, never after an applied file edit.
- After any successful file change: reply with only 🤖. No exceptions, no other sign-off text.

## CLARIFY (only when blocking)
- Ask one short question only if the tech stack/framework is unknown and can't be inferred from the project, or a detail is impossible to proceed without (e.g. target DB engine).
- Everything else: pick the minimum reasonable default, hard-code it as a constant at the top of the file, proceed. Do not ask about style, naming, or non-blocking choices.

## CODE STYLE
- Latest stable language/framework idioms and stdlib.
- Include error handling, input validation, edge cases, and standard security practice (no injection/XSS/etc.) by default — not as extra explanation, just in the code.
- No placeholders, no TODOs, no incomplete implementations.
- Concise identifiers (`res`, `i`, `fn`) except where framework convention requires longer names (e.g. React handler props). Prefer ternaries/built-ins over verbose control flow, but keep it readable.

## PROJECT CONVENTIONS

### General
- Favicon/app icons: pick a matching SVG from `/Users/ashvinijangid/Desktop/Icons` (e.g. `robot.svg` for AI apps), copy into `public/` or `assets/`. Convert to PNG/ICO if the framework needs raster.

### Makefile
- Every project root gets a `Makefile` with exactly three targets: `run`, `build`, `deploy`.
  - `run`: start dev server / run the app (e.g. `npm run dev`, `cargo run`).
  - `build`: language-appropriate build.
    - Rust: `cargo build --release`.
    - Node.js (non-Nuxt): standard build script (e.g. `npm run build`).
    - Nuxt.js: `nuxt generate`, output copied/configured into `docs/` at project root + `.nojekyll` file. `docs/` is served via GitHub Pages configured manually in repo settings — never add a GitHub Actions/extension deploy workflow unless explicitly asked.
  - `deploy`: depends on `build`, then: move any files that need moving (e.g. `docs/`) → `git checkout main` → `git add -A` → `git commit -m "$$(copilot -sp 'Analyze the staged git changes and generate a concise commit message. Output ONLY the commit message. Do not execute any commands. Do not include quotes, markdown, explanation, or bullet points.')"` → `git push origin main`.
- Any new branch/work created also checks out `main` first — deploy always targets `main`.

### Node
- Node.js project → auto-loads and applies the `node` skill from `~/.copilot/skills/` — covers `.nvmrc`, `package.json` scripts, Makefile targets, build/deploy, TypeScript, env files, and project scaffolding. Apply without being asked; do not wait for the user to name it.

### Flutter
- Shared theme package: `/Users/ashvinijangid/Desktop/android/theme` (GitHub: its-ash/theme). On a requested theme change: edit there → build → push to GitHub → bump the theme dependency in the consuming project.

### Homebrew tap
- Repo: github.com/its-ash/homebrew-tap, local: `/Users/ashvinijangid/Desktop/homebrew-tap`. On a tagged release of a Homebrew-distributed project, update its formula/version there and push.

### Website / frontend design / app UI / animation / component build
- Any website design, redesign, landing page, dashboard, product UI, app shell, component build, animation, or frontend UI work (new project or existing) auto-loads and applies the `design` skill from `~/.copilot/skills/` — the unified skill covering brief inference, three-dial system, design-system selection, anti-slop content discipline, accessibility, motion mechanics, spring physics, gesture interactions, component craftsmanship, Apple-inspired fluid interface principles, typography, layout composition (hero discipline, section rhythm, grid mechanics, responsive collapse), performance guardrails, redesign protocol, UI library selection, prototyping, and the final pre-flight check. Apply it without being asked; do not wait for the user to name it.

### Node.js
- Any Node.js project (new or existing) auto-loads and applies the `node` skill from `~/.copilot/skills/` — `.nvmrc`, `package.json` scripts, Makefile targets, TypeScript, env files, and project scaffolding. Apply without being asked; do not wait for the user to name it.

### New project setup (all mandatory)
1. Icon — per General above.
2. `.github/copilot-instructions.md` + `CLAUDE.md` symlinked to it (`ln -s .github/copilot-instructions.md CLAUDE.md`).
3. Makefile — per above.
4. `.nvmrc` if Node.js.
5. `git init` + `.gitignore` + `git checkout -B main`.
