# Anti-Slop and Pre-Flight Check

Sections §10 and §21 of [`design`](../SKILL.md). Run §21 before you deliver any UI. § map: §0, §3-4, §11, §14 in [direction.md](direction.md); §5-9, §12-19, §22 in [motion.md](motion.md); §25 in [css-implementation.md](css-implementation.md); §1-2 in SKILL.md.

## 10. Anti-Slop

* **Banned words:** Elevate, Seamless, Unleash, Next-Gen, Game-changer, Delve, Revolutionize.
* **Banned content:** John Doe, Acme, Nexus, Lorem Ipsum, egg avatars, fake-perfect numbers.
* **Banned visuals:** neon glows, gradient text headers, custom cursors, oversized H1s, 3 equal feature cards, default shadcn.
* **Banned tells:** em-dashes anywhere (hyphen only); hero version labels; `01 / 4` and section-number eyebrows; date-range labels; > 1 middle-dot per line; status/decorative dots; default `<br>` italic headlines; rotated text; crosshair grids; fake hero UI; "Quietly trusted by"; "Field notes" labels; weather/city strips; micro-meta sentences; "Phase 01"; pills over images; photo credits; version footers; hero-bottom strips; floating top-right sub-text; filled-track score bars; scroll cues; bordered every-row lists.

## 21. Pre-Flight Check (mandatory)

- [ ] Design read + dials declared (§0-1); system honest (§2); redesign audited (§14)
- [ ] One theme, accent, radius scale; zero em-dashes; no banned serif/palette; descender clearance (§4)
- [ ] AA contrast on CTAs/forms/focus; CTAs one line; one label per intent; empty/loading/error states; reduced motion; dark mode tested
- [ ] Hero rules; eyebrow cap; no split headers; zigzag cap; >= 4 layout families; bento cell count; logo wall under hero (§4.7)
- [ ] Nav one line <= 80px; explicit mobile collapse; `100dvh`
- [ ] Real images; no fake screenshots; lists > 5 reshaped; quotes <= 3 lines
- [ ] Filled rounded tabs; selection not border-only; filled checkbox/radio (§7)
- [ ] No §10 tells
- [ ] Every animation justified; motion shown if claimed; one marquee max; no scroll listeners; `useEffect` cleanup
- [ ] Allowed icon library (§3); CWV plausible (§8); one design system
- [ ] Raw CSS written: CSS pre-flight passes (§25.E)
