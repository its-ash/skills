---
name: design
description: "Frontend UI design: accessibility, typography, layout, motion, gestures, components, design tokens, theming, dark mode, modern CSS (Grid, subgrid, container queries, cascade layers, :has(), oklch, scroll-driven animations, view transitions, anchor positioning). Use for websites, landing pages, dashboards, product UIs, animations, CSS, responsive layouts, or hero sections. Sub-skills: immersive-web, figma, mobile-design, brand-theming, motion-canvas, visual-design-direction, design-system, make-interfaces-feel-better, motion-react, html-slides, shadcn-ui, tailwind-css, threejs, gsap."
---

# Design

Make frontend UI that is specific to the brief, accessible, and free of AI-default tells. Sections §0-§26 live in the files in "Load on demand".

## Core rules

- Before code, output one line: "Reading this as: <page kind> for <audience>, with a <vibe> language, leaning toward <system/aesthetic>." (§0). Declare the three dials (§1).
- Quiet constraints (a11y-first, public-sector, regulated, kids) override aesthetics (§0).
- Use one design system per project. Never hand-roll CSS for an official package (§2).
- Lock one theme, one accent (saturation < 80%), one gray family, one radius scale per page. Define them as `oklch()` tokens with `color-scheme` + `light-dark()`. No pure `#000`/`#fff` (§4.2, §4.4, §4.11).
- Pass WCAG 2.2 AA: contrast on CTAs, inputs, placeholders, focus rings, helper and error text; targets 24px minimum, 44px on touch; focus never obscured by sticky chrome (§4.5, §9).
- Native first: `<dialog>`, `popover`, anchor positioning, `<details name>`, container queries, view transitions. No div modals, no JS-positioned tooltips (§7, §25).
- Keep CTAs on one line at desktop, one label per intent. Keep the hero inside the viewport (§4.5, §4.7).
- Use real images, real or labeled-mock numbers, and audited copy. No fake div screenshots (§4.8, §4.9).
- Justify each animation in one sentence. Animate only `transform`/`opacity`. Never `ease-in`. Keep UI motion < 300ms (§5, §6).
- For reduced motion, cross-fade; do not remove all motion (§9).
- Make the header full-width with square edges. Fill and round active tabs. Never mark selection with a one-side border. Fill checked checkbox and radio (§7).
- Never use scroll listeners, `scrollY` in state, or rAF loops on React state. Use scroll-driven animations, `IntersectionObserver`, and motion values (§8, §12).
- Check `package.json`; output the install command for each missing dependency (§3).
- Ban every anti-slop tell: em-dashes, banned words, placeholder names, default purple glow (§10).
- For raw CSS, apply the §25.B rules.
- **Run the mandatory pre-flight (§21, [preflight.md](references/preflight.md)) before you deliver.**

## Decisions

### §1 Dials

`DESIGN_VARIANCE` (1 symmetric - 10 chaos), `MOTION_INTENSITY` (1 static - 10 cinematic), `VISUAL_DENSITY` (1 airy - 10 cockpit). Baseline `8 / 6 / 4`. Definitions: §11.

| Signal / use case | VAR | MOT | DEN |
|---|---|---|---|
| Minimalist / editorial / Linear-style | 5-6 | 3-4 | 2-3 |
| Premium consumer / luxury | 7 | 6 | 3 |
| Playful / Awwwards / agency | 9-10 | 8-10 | 3 |
| Landing (SaaS default) | 7 | 6 | 4 |
| Portfolio designer / developer | 8 / 6 | 7 / 5 | 3 / 4 |
| Editorial / blog | 6 | 4 | 3 |
| Dashboard / product UI | 4-5 | 4-5 | 6-8 |
| Trust-first / public-sector | 3 | 2 | 5 |
| Redesign preserve / overhaul | = / +2 | +1 / +2 | = |

### §2 Design system

| Brief | Use | Avoid |
|---|---|---|
| Microsoft / enterprise | `@fluentui/react-components` | Custom Fluent look-alike |
| Material | `@material/web` + M3 Expressive tokens | Hand-rolled Material CSS |
| IBM B2B | `@carbon/react` | Mixing a second system |
| Shopify / Atlassian / GitHub | Polaris / `@atlaskit/*` / `@primer/*` | Copying their CSS |
| UK / US public-sector | `govuk-frontend` / `uswds` | Custom aesthetics |
| Accessible React base / own components | Base UI 1.0 / `@radix-ui/themes` / shadcn/ui (CLI 3) | Default shadcn look (§10) |
| Tailwind SaaS | Tailwind 4.3 CSS-first `@theme` + `light-dark()` tokens | `tailwind.config.js`, runtime CSS-in-JS, `dark:` on every class |
| No library (aesthetic) | Glassmorphism (`backdrop-filter` + layered borders, solid fallback for `prefers-reduced-transparency`), bento, brutalism, editorial, dark tech, mesh gradients, kinetic type | Calling a web Liquid Glass copy real (label it an approximation) |

## Load on demand

| Need | Read |
|---|---|
| §0 brief, §3 default stack, §4 bias correction (type, color, layout, cards, states, forms, hero, images, copy, theme), §11 dial definitions, §14 redesign, §20 out of scope, §23 prototype variants, §24 site packs | [direction.md](references/direction.md) |
| §5 animation decisions, §6 springs and gestures, §7 components, §8 performance, §9 a11y, §12-§13 tools and libraries, §15-§19 enhancement, debugging, vocabulary, §22 review fixes | [motion.md](references/motion.md) |
| §10 anti-slop, §21 pre-flight checklist | [preflight.md](references/preflight.md) |
| §25 CSS rules, CSS decision guide, CSS topic files, CSS pre-flight | [css-implementation.md](references/css-implementation.md) |
| §26 tokens and theming; extract tokens, 10-dimension audit, AI-slop check | [design-system.md](references/design-system.md) |
| iOS/Android, touch, React Native, Flutter layouts | [mobile-design.md](references/mobile-design.md) |
| Brand colors, type, identity across decks, docs, UI | [brand-theming.md](references/brand-theming.md) |
| Figma node to code with 1:1 parity | [figma.md](references/figma.md) |
| GSAP ScrollTrigger, parallax, R3F, WebGL | [immersive-web.md](references/immersive-web.md) |
| Motion Canvas scenes, video export | [motion-canvas.md](references/motion-canvas.md) |
| Opinionated visual direction; product UI evidence contract | [visual-design-direction.md](references/visual-design-direction.md) |
| Polish: concentric radius, optical alignment, tabular numbers, hit areas | [make-interfaces-feel-better.md](references/make-interfaces-feel-better.md) |
| `motion/react` code patterns | [motion-react.md](references/motion-react.md) |
| HTML slide decks, PPTX to HTML | [html-slides.md](references/html-slides.md) |
| shadcn/ui components, registries, CLI | [shadcn-ui.md](references/shadcn-ui.md) |
| Tailwind 4.3 setup, CSS-first config, dark mode | [tailwind-css.md](references/tailwind-css.md) |
| Three.js r186+ API, shaders/TSL, R3F 9 | [threejs.md](references/threejs.md) |
| GSAP API, timelines, ScrollTrigger, `useGSAP` | [gsap.md](references/gsap.md) |

## Related skills

- [`frontend-development`](../frontend-development/SKILL.md) - React/Next.js, TypeScript, MUI, TanStack
- [`ux-research`](../ux-research/SKILL.md) - personas, journeys, usability tests
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) - WCAG 2.2 and ARIA 1.3 audits
- [`web-performance`](../web-quality-audit/references/web-performance.md) - Core Web Vitals diagnosis
