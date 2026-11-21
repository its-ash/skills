# Anti-Slop and Pre-Flight Check

Sections §10 and §21 of [`design`](../SKILL.md). Run §21 before you deliver any UI. § map: §0, §3-4, §11, §14 in [direction.md](direction.md); §5-9, §12-19, §22 in [motion.md](motion.md); §25 in [css-implementation.md](css-implementation.md); §1-2 in SKILL.md.

## 10. Anti-Slop

* **Banned words:** Elevate, Seamless, Unleash, Next-Gen, Game-changer, Delve, Revolutionize.
* **Banned content:** John Doe, Acme, Nexus, Lorem Ipsum, egg avatars, fake-perfect numbers.
* **Banned visuals & dated UI:** neon glows, gradient text headers, custom cursors, oversized H1s, 3 equal feature cards, default unstyled shadcn, **underline-only tabs**, **one-sided borders on cards/callouts/selection (`border-l-4`, `border-t-4`, etc.)**, **nested cards inside cards**, heavy muddy gray drop shadows, loud solid-block status badges, floating pill top navbars by default, `dark:` class sprawl instead of `light-dark()` semantic tokens.
* **Banned tells:** em-dashes anywhere (hyphen only); hero version labels; `01 / 4` and section-number eyebrows; date-range labels; > 1 middle-dot per line; decorative/pulsing status dots; default `<br>` italic headlines; rotated text; crosshair grids; fake hero UI; "Quietly trusted by"; "Field notes" labels; weather/city strips; micro-meta sentences; "Phase 01"; pills over images; photo credits; version footers; hero-bottom strips; floating top-right sub-text; filled-track score bars; scroll cues; bordered every-row lists.

## 21. Pre-Flight Check (mandatory)

- [ ] Design read + dials declared (§0-1); system honest (§2); redesign audited (§14)
- [ ] One theme, one accent (< 80% sat), one gray family, one radius scale; `oklch()` + `light-dark()` tokens; no pure `#000`/`#fff`; zero em-dashes; no banned serif/palette; descender clearance (§4)
- [ ] Tonal surface hierarchy (`canvas -> card -> elevated`); **zero one-sided borders** on cards, callouts, alerts, or selection; **no nested cards**; uniform card padding; concentric border radius (§4.4, §7)
- [ ] Full-width square-edged header; **filled rounded tabs** in a muted track (no underline-only tabs); filled checkbox/radio/switch; tonal badges; `tabular-nums` on dynamic numbers (§4.6, §7)
- [ ] WCAG 2.2 AA contrast on CTAs/forms/badges/focus; targets 24px (44px touch); focus not obscured; CTAs one line; one label per intent; empty/loading/error states; reduced motion; light & dark mode via `light-dark()` tested (§4.5, §9)
- [ ] Hero rules; eyebrow cap; no split headers; zigzag cap; >= 4 layout families; bento cell count; logo wall under hero (§4.7)
- [ ] Nav one line <= 80px; explicit mobile collapse; `min-h-dvh`
- [ ] Real images (AVIF/WebP, inset outline); no fake screenshots; lists > 5 reshaped; quotes <= 3 lines (§4.8-4.10)
- [ ] No §10 anti-slop tells
- [ ] Every animation justified; motion shown if claimed; one marquee max; no scroll listeners (scroll-driven animations or `IntersectionObserver`); native `<dialog>`/`popover`; `useEffect` cleanup (§5-8, §12)
- [ ] Allowed icon library (§3); CWV plausible (§8); one design system
- [ ] Raw CSS written: CSS pre-flight passes (§25.E)
