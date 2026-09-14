# skills

Single source of truth for GitHub Copilot & Claude Code **skills** and **instructions**.

## Layout

```
skills/
├── copilot.instructions.md      # global instructions (source of truth)
├── setup.sh                      # install / unlink / status
├── design/SKILL.md               # unified frontend design skill (auto-invoked)
├── node/SKILL.md                 # Node.js project conventions
├── perf/SKILL.md                 # web performance audit (Core Web Vitals)
├── …other skills…/SKILL.md
```

## Skills

### design (auto-invoked)

The unified skill for any website design, redesign, landing page, dashboard, product UI, app shell, component build, animation, or frontend UI work. Merges design-foundation rules (accessibility, motion, typography, content discipline), layout composition (hero discipline, section rhythm, grid mechanics, responsive collapse), and engineering depth (animation framework, spring physics, gesture interactions, component craftsmanship, Apple fluid interfaces, performance, redesign protocol, UI library selection, prototyping).

Covers: brief inference (Section 0), three-dial system (Section 1), design-system selection (Section 2), default architecture (Section 3), bias correction directives (Section 4), animation decision framework (Section 5), motion mechanics (Section 6), component building (Section 7), performance guardrails (Section 8), accessibility (Section 9), anti-slop content discipline (Section 10), dial definitions (Section 11), context-aware proactivity (Section 12), UI library selection (Section 13), redesign protocol (Section 14), progressive enhancement (Section 15), debugging (Section 16), component principles (Section 17), Apple design foundations (Section 18), reference vocabulary (Section 19), scope (Section 20), final pre-flight check (Section 21), review checklist (Section 22), prototyping (Section 23), default site packs (Section 24).

## How it works

`setup.sh` symlinks everything into the right global directories:

| Repo file / dir                | Symlinked to                          |
|--------------------------------|---------------------------------------|
| `copilot.instructions.md`      | `~/.copilot/instructions/copilot.instructions.md` |
| ↑ (same file)                  | `~/.claude/CLAUDE.md`                 |
| `<skill>/`                     | `~/.copilot/skills/<skill>/`          |
| `~/.copilot/skills/` (whole dir)| `~/.claude/skills`                   |

Edit a skill here → it's live in both Copilot and Claude instantly.

## Usage

```bash
./setup.sh            # install / update symlinks
./setup.sh --status   # show current link state
./setup.sh --unlink   # remove symlinks (restores nothing; backups kept on first install)
```

## Adding a new skill

1. `mkdir <skill-name> && touch <skill-name>/SKILL.md`
2. Write the skill content.
3. Re-run `./setup.sh`.