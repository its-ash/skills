---
name: i18n-localization
description: "Adds internationalization and localization to web and Python apps, including string extraction, translation catalogs, pluralization, locale-aware date and number formatting, and RTL layout support. Use when implementing i18n, l10n, react-i18next, next-intl, gettext, .json or .po/.mo translation files, locale routing, language switchers, ICU messages, t() calls, Intl.DateTimeFormat, Intl.NumberFormat, or fixing missing translations and RTL bugs. Sub-skills: i18n-sync, bengali-nlp."
---
# i18n & Localization

Replace hard-coded UI text with translation keys, and format text per locale.

## Core rules
- Put every user-facing string behind a translation key. No raw text in components.
- Namespace keys by feature or module (`auth.login.title`).
- Keep one language per locale file: `locales/<lang>/<namespace>.json`.
- Translate full sentences. Never concatenate translated fragments.
- Use ICU message format for plurals and gender.
- Format dates, numbers, and currency with `Intl` (or the framework wrapper), never by hand.
- Configure a fallback language (usually `en`).
- Use CSS logical properties (`margin-inline-start`, `padding-inline-end`), not left/right.
- Plan RTL from the start; set `dir` on `<html>`; flip directional icons.
- Do not assume fixed text length; some languages expand 30%+.
- Test in an RTL locale before you ship RTL support.

## Decisions

| Situation | Do | Avoid |
|---|---|---|
| React SPA | `react-i18next`, `useTranslation()` | Custom string maps |
| Next.js App Router | `next-intl`, `useTranslations('Ns')`, locale routing | Client-only i18n for server components |
| Python app | `gettext` with `.po`/`.mo` catalogs | f-strings with literal text |
| Count-dependent text | `{count, plural, one {# item} other {# items}}` | `count === 1 ? 'item' : 'items'` |
| Value inside a sentence | Placeholder `{name}` in the message | `t('hello') + name` |
| Arabic, Hebrew, Persian, Urdu | `dir="rtl"`, logical CSS, mirrored icons | `margin-left` / `float: left` |
| Missing key at runtime | Fallback locale + log the key | Show raw key to users |
| New key or new language | Sync all locale files from source usage | Hand-edit one file only |
| Bengali text | NFC normalize, grapheme-aware length | Byte or code-point length |

## Load on demand

| Need | Read |
|---|---|
| Framework snippets, locale layout, RTL CSS, fixes table, hard-coded string checker, ship checklist | [references/i18n-patterns.md](references/i18n-patterns.md) |
| Translate and sync JSON locale files: add keys or languages, missing/stale keys, placeholders, plurals | [references/i18n-sync.md](references/i18n-sync.md) |
| Bengali text: NFC, conjuncts, graphemes, digits, tokenization, collation, Banglish, DB encoding | [references/bengali-nlp.md](references/bengali-nlp.md) |

## Related skills
- [`frontend-development`](../frontend-development/SKILL.md) — React and Next.js app structure
- [`nextjs`](../frontend-development/references/nextjs.md) — App Router, locale routing, server components
- [`typescript`](../typescript/SKILL.md) — typed translation keys
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) — `lang` attribute, WCAG checks
