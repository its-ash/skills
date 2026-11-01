# Web Accessibility
Create web pages that work for people with disabilities and comply with WCAG 2.1 and ARIA guidelines.

## When to Use
- Auditing an existing site for accessibility violations
- Implementing WCAG 2.1 Level AA or AAA requirements
- Adding or fixing alt text, form labels, color contrast, keyboard support, ARIA landmarks, or modals
- Preparing for ADA, Section 508, or other legal compliance reviews
- Testing with screen readers or automated tools

## WCAG 2.1 Principles (POUR)
| Principle | What it means |
|-----------|---------------|
| **Perceivable** | Content can be seen or heard by any user |
| **Operable** | All functionality works with keyboard and other input methods |
| **Understandable** | Text, navigation, and UI are clear and predictable |
| **Robust** | Code works with current and future assistive technologies |

## Common Issues & Fixes
### 1. Missing or Incorrect Alt Text
```html
<!-- Informative image -->
<img src="shoes.jpg" alt="Red Nike Air Max running shoes">

<!-- Decorative image -->
<img src="pattern.svg" alt="" role="presentation">

<!-- Linked logo -->
<a href="/"><img src="logo.png" alt="Company Name – Home"></a>
```
- Use descriptive alt for informative images.
- Use empty alt for purely decorative images.
- Provide a longer description in a `<figure>`/`<figcaption>` for complex graphics.

### 2. Insufficient Color Contrast
```css
/* Fail – 2.5:1 */
.low { color:#767676; background:#fff; }

/* Pass – 4.5:1 (AA) */
.normal { color:#595959; background:#fff; }

/* Pass – 7:1 (AAA) */
.high { color:#333; background:#fff; }
```
- Normal text: ≥ 4.5:1 (AA), ≥ 7:1 (AAA).
- Large text (≥ 18 px or ≥ 14 px bold): ≥ 3:1 (AA), ≥ 4.5:1 (AAA).
- UI components: ≥ 3:1.
- Ensure focus outlines also meet contrast.

### 3. Non‑semantic HTML
```html
<!-- Bad -->
<div class="button" onclick="submit()">Submit</div>

<!-- Good -->
<button type="submit" onclick="submit()">Submit</button>
```
Use native elements (`<button>`, `<a>`, `<h1>`‑`<h6>`, `<nav>`, `<main>`, `<section>`, `<article>`, `<aside>`, `<ul>`/`<ol>`/`<li>`, `<table>`). Landmarks (`role="banner"`, `role="navigation"`, `role="main"`, `role="complementary"`, `role="contentinfo"`) help screen readers.

### 4. Missing Form Labels
```html
<!-- Explicit label -->
<label for="email">Email address</label>
<input id="email" type="email" name="email">

<!-- Implicit label -->
<label>
  Email address
  <input type="email" name="email">
</label>
```
- Every input must have a visible label.
- Do not rely on placeholders.
- Use `aria-label` only when a visual label cannot be shown.
- Group related fields with `<fieldset>` and `<legend>`.

### 5. Keyboard Navigation Issues
```html
<!-- Bad: div with click only -->
<div onclick="doIt()">Action</div>

<!-- Good: native button -->
<button onclick="doIt()">Action</button>

<!-- If a div is required -->
<div role="button" tabindex="0" onclick="doIt()" onkeydown="if(event.key==='Enter'||event.key===' ') doIt()">
  Action
</div>
```
- All interactive elements must be reachable with **Tab**.
- Provide a visible focus indicator (`:focus-visible`).
- Ensure a logical tab order that follows visual layout.
- Avoid keyboard traps; users must be able to exit any component.

### 6. Missing ARIA Landmarks
```html
<header role="banner">
  <nav aria-label="Main navigation">…</nav>
</header>
<main role="main">
  <h1>Page title</h1>
</main>
<aside role="complementary" aria-label="Related articles">…</aside>
<footer role="contentinfo">…</footer>
```
Landmarks improve navigation for assistive technology. Use only one `role="main"` per page.

### 7. Inaccessible Modals / Dialogs
```html
<div role="dialog" aria-modal="true" aria-labelledby="modal-title" aria-describedby="modal-desc">
  <h2 id="modal-title">Confirm delete</h2>
  <p id="modal-desc">Are you sure you want to delete this item?</p>
  <button onclick="confirm()">Confirm</button>
  <button onclick="close()">Cancel</button>
</div>
```
- Add `role="dialog"` (or `alertdialog`).
- Set `aria-modal="true"`.
- Provide `aria-labelledby` and optional `aria-describedby`.
- When opened, move focus to the first focusable element and trap focus inside the dialog.
- Return focus to the element that opened the dialog when it closes.
- Close on **Escape** and prevent background scrolling.

### 8. Missing Skip Links
```html
<a href="#main" class="skip-link">Skip to main content</a>
<main id="main" tabindex="-1">…</main>
```
```css
.skip-link { position:absolute; top:-40px; left:0; background:#000; color:#fff; padding:8px; }
.skip-link:focus { top:0; }
```
Place the link as the first focusable element on the page.

## ARIA Best Practices
### States & Properties
- **States**: `aria-checked`, `aria-disabled`, `aria-expanded`, `aria-hidden`, `aria-pressed`, `aria-selected`.
- **Properties**: `aria-label`, `aria-labelledby`, `aria-describedby`, `aria-live`, `aria-required`, `aria-invalid`.

### Live Regions
```html
<div aria-live="polite" aria-atomic="true">Item added to cart</div>
<div role="alert" aria-live="assertive">Error: Payment failed</div>
```
Use `polite` for non‑urgent updates, `assertive` for errors.

### Custom Widgets (Examples)
#### Accordion
```html
<button aria-expanded="false" aria-controls="panel-1" id="acc-1">Section 1</button>
<div id="panel-1" role="region" aria-labelledby="acc-1" hidden>Content</div>
```
#### Tabs
```html
<div role="tablist" aria-label="Product info">
  <button role="tab" aria-selected="true" aria-controls="tab-1" id="tab-1">Description</button>
  <button role="tab" aria-selected="false" aria-controls="tab-2" id="tab-2" tabindex="-1">Reviews</button>
</div>
<div role="tabpanel" id="tab-1" aria-labelledby="tab-1">…</div>
<div role="tabpanel" id="tab-2" aria-labelledby="tab-2" hidden>…</div>
```
Prefer native elements; use ARIA only when native semantics are unavailable.

## Media Alternatives
```html
<!-- Video with captions and audio description -->
<video controls>
  <source src="demo.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English" default>
  <track kind="descriptions" src="descriptions.vtt" srclang="en" label="Descriptions">
</video>

<!-- Audio with transcript -->
<audio controls><source src="podcast.mp3" type="audio/mp3"></audio>
<details><summary>Transcript</summary><p>Full text…</p></details>
```
Provide captions, subtitles, or transcripts for all audio‑visual content.

## Motion & Reduced‑Motion Preference
```css
@media (prefers-reduced-motion: reduce) {
  * { animation-duration: 0.01ms !important; transition-duration: 0.01ms !important; }
}
```
Respect the user’s system setting.

## Language & Navigation
```html
<html lang="en">
<p>The French word for hello is <span lang="fr">bonjour</span>.</p>
```
- Declare the page language with `lang` attribute.
- Keep navigation structure consistent across pages.
- Use clear, descriptive link text.

## Robust HTML
- Ensure unique IDs and proper element nesting.
- Validate markup with the W3C validator.
- Prefer native elements over ARIA‑only roles.

## WCAG 2.2 Additions
| Criterion | Rule |
|-----------|------|
| 2.4.11 Focus Not Obscured | A sticky header, banner, or overlay must not hide the focused element. |
| 2.5.7 Dragging Movements | Give a single-pointer alternative (buttons, click-to-move) for each drag action. |
| 2.5.8 Target Size (Minimum) | Interactive targets are at least **24x24 CSS px** (native apps: 44x44 pt iOS, 48x48 dp Android). |
| 3.3.3 Error Suggestion | Error text tells the user how to correct the input. |
| 3.3.7 Redundant Entry | Do not ask for the same data two times in one process; prefill or let the user select it. |
| 1.4.10 Reflow | Content reflows at 400% zoom with no loss of function. |

## Cross-Platform Mapping (Web, iOS, Android)
| Feature | Web (HTML/ARIA) | iOS (SwiftUI) | Android (Compose) |
|---------|-----------------|---------------|-------------------|
| Primary label | `aria-label` / `<label>` | `.accessibilityLabel()` | `contentDescription` |
| Secondary hint | `aria-describedby` | `.accessibilityHint()` | `Modifier.semantics { stateDescription = ... }` |
| Action role | `role="button"` | `.accessibilityAddTraits(.isButton)` | `Modifier.semantics { role = Role.Button }` |
| Live updates | `aria-live="polite"` | `.accessibilityLiveRegion(.polite)` | `Modifier.semantics { liveRegion = LiveRegionMode.Polite }` |

```swift
Button(action: deleteItem) { Image(systemName: "trash") }
  .accessibilityLabel("Delete item")
  .accessibilityHint("Permanently removes this item from your list")
```

## React and Next.js Patterns
### Forms: required fields and linked errors
```tsx
<label htmlFor="email">
  Email <span aria-hidden="true">*</span>
</label>
<input
  id="email"
  type="email"
  required
  aria-required="true"
  aria-invalid={!!error}
  aria-describedby={error ? 'email-error' : undefined}
  autoComplete="email"
/>
{error && <span id="email-error" role="alert">{error}</span>}
```
- In JSX, use `htmlFor`, not `for`.
- A visual asterisk alone gives no data to a screen reader. Add `required` and `aria-required`.
- Link the error text with `aria-describedby` and set `aria-invalid`.

### aria-label or aria-labelledby
```tsx
// No visible text: aria-label
<button aria-label="Close modal"><XIcon aria-hidden="true" /></button>

// Visible heading exists: aria-labelledby
<section aria-labelledby="orders-title">
  <h2 id="orders-title">Recent Orders</h2>
</section>
```

### Accordion with useId
```tsx
export function Accordion({ title, children }: { title: string; children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false);
  const contentId = useId();
  return (
    <div>
      <button aria-expanded={isOpen} aria-controls={contentId} onClick={() => setIsOpen(o => !o)}>
        {title}
      </button>
      <div id={contentId} hidden={!isOpen}>{children}</div>
    </div>
  );
}
```

### Custom dropdown keyboard support
```tsx
const handleKeyDown = (e: React.KeyboardEvent) => {
  switch (e.key) {
    case 'ArrowDown': e.preventDefault(); setActive(i => Math.min(i + 1, options.length - 1)); break;
    case 'ArrowUp': e.preventDefault(); setActive(i => Math.max(i - 1, 0)); break;
    case 'Enter':
    case ' ': e.preventDefault(); if (isOpen) onSelect(options[active]); setIsOpen(o => !o); break;
    case 'Escape': setIsOpen(false); break;
  }
};
// Container: role="combobox" aria-expanded aria-haspopup="listbox" aria-controls={listId} tabIndex={0}
// Items: role="option" aria-selected={index === active}
```

### Modal focus restore
```tsx
useEffect(() => {
  if (isOpen) {
    previousFocusRef.current = document.activeElement as HTMLElement;
    modalRef.current?.focus();
  } else {
    previousFocusRef.current?.focus();
  }
}, [isOpen]);
// <div ref={modalRef} role="dialog" aria-modal="true" aria-labelledby="modal-title" tabIndex={-1}
//      onKeyDown={e => e.key === 'Escape' && onClose()}>
```
For a full Tab/Shift+Tab focus trap, use a library such as `focus-trap-react`. Also restore focus to the trigger when a dropdown or menu closes.

### Reduced-motion hook
```tsx
export function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(false);
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReduced(mq.matches);
    const onChange = (e: MediaQueryListEvent) => setReduced(e.matches);
    mq.addEventListener('change', onChange);
    return () => mq.removeEventListener('change', onChange);
  }, []);
  return reduced;
}
```

### Anti-patterns
```tsx
<div aria-label="Navigation">...</div>          // aria-label on a div with no role
<button tabIndex={3}>Submit</button>            // positive tabIndex breaks tab order
<button aria-hidden="true">Open</button>        // focusable element hidden from screen readers
<div role="button" onClick={go}>Submit</div>    // no tabIndex={0}, no Enter/Space handler
<h1>Dashboard</h1><h4>Recent</h4>               // skipped heading levels
```
- Do not show status with color only (for example, a red border with no text).
- Do not write "Image of..." in alt text. The screen reader already announces "image".

## Testing Checklist
### Automated Tests
```bash
# Lighthouse accessibility audit (Chrome)
npx lighthouse https://example.com --only-categories=accessibility

# axe‑core CLI
npm install -g @axe-core/cli
axe https://example.com
```
- Run axe or WAVE extensions.
- Check HTML validation.
- Verify color contrast ratios (use Colour Contrast Analyser).
- Ensure heading hierarchy (`<h1>`‑`<h6>`).
- Detect missing alt attributes.

### Manual Tests
- Navigate the entire site using **Tab**, **Enter**, **Space**, **Esc**, and arrow keys.
- Test with a screen reader (NVDA, JAWS, VoiceOver, TalkBack).
- Verify visible focus indicators.
- Confirm form error messages are announced (`role="alert"` or `aria-live`).
- Test modal focus trapping and Escape key closing.
- Use skip links to bypass repetitive navigation.
- Zoom page to 200 % and confirm readability.
- Enable Windows High‑Contrast mode.
- Set `prefers-reduced-motion: reduce` and ensure animations stop.
- Disable JavaScript and verify core functionality remains.

### Screen‑Reader Commands (quick reference)
| Action | VoiceOver (Mac) | NVDA (Windows) |
|--------|----------------|----------------|
| Start/Stop | ⌘ + F5 | Ctrl + Alt + N |
| Next item | VO + → | ↓ |
| Previous item | VO + ← | ↑ |
| Activate | VO + Space | Enter |
| List headings | VO + U then arrows | H / Shift + H |
| List links | VO + U | K / Shift + K |

## Quick Checklist (before launch)
- [ ] All images have appropriate `alt` text.
- [ ] Text meets required contrast ratios.
- [ ] Semantic HTML and proper landmarks are used.
- [ ] Every form control has a visible label.
- [ ] Keyboard navigation works with visible focus.
- [ ] Skip link present and functional.
- [ ] Modals trap focus and restore it on close.
- [ ] Video/audio provide captions, subtitles, or transcripts.
- [ ] Page language declared; language changes marked.
- [ ] No ARIA misuse; native elements preferred.
- [ ] Automated tools (axe, Lighthouse) report no critical violations.
- [ ] Manual screen‑reader test confirms content is understandable.

## Resources
- **WCAG 2.1 Quick Reference**: https://www.w3.org/WAI/WCAG21/quickref/
- **ARIA Authoring Practices**: https://www.w3.org/WAI/ARIA/apg/
- **Deque axe Rules**: https://dequeuniversity.com/rules/axe/
- **Colour Contrast Analyser** (download from WebAIM)
- **Screen readers**: NVDA (free), JAWS (commercial), VoiceOver (built‑in macOS/iOS)

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`web-quality-audit`](../SKILL.md) — Runs a full web quality audit that checks performance (Core Web Vitals, resource loading), accessibility, SEO,…
- [`playwright`](../../unit-testing-patterns/references/playwright.md) — Playwright skill for building reliable end‑to‑end test suites and browser automation. Use it to set up Playwri…
- [`ux-research`](../../ux-research/SKILL.md) — Provides a step‑by‑step workflow for senior UX researchers and designers to generate data‑driven personas, map…
- [`i18n-localization`](../../i18n-localization/SKILL.md) — Guides developers to add internationalization (i18n) and localization (L10n) to web and Python projects, cover…
