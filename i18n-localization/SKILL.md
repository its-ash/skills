---
name: i18n-localization
description: "Adds internationalization and localization to web and Python apps, including string extraction, translation catalogs, pluralization, locale-aware date and number formatting, and RTL layout support. Use when implementing i18n, l10n, react-i18next, next-intl, gettext, .json or .po/.mo translation files, locale routing, language switchers, ICU messages, t() calls, Intl.DateTimeFormat, Intl.NumberFormat, or fixing missing translations and RTL bugs. Sub-skills: i18n-sync, bengali-nlp."
---

# i18n & Localization

Add internationalization (i18n) and localization (L10n) to an application. Use translation keys instead of hard‑coded text, store translations in locale files, and handle plural forms, dates, numbers, and RTL layout.

## When to use
- Public web apps and SaaS products that reach users in multiple languages.
- Internal tools that may be shared with multilingual teams.
- Projects that may expand to new regions in the future.
- Personal projects only if you plan to support more than one language.

## Implementation patterns
### React (react‑i18next)
```tsx
import { useTranslation } from 'react-i18next';

function Welcome() {
  const { t } = useTranslation();
  return <h1>{t('welcome.title')}</h1>;
}
```

### Next.js (next‑intl)
```tsx
import { useTranslations } from 'next-intl';

export default function HomePage() {
  const t = useTranslations('Home');
  return <h1>{t('title')}</h1>;
}
```

### Python (gettext)
```python
from gettext import gettext as _

print(_('Welcome to our app'))
```

## File structure
```
locales/
├─ en/
│  ├─ common.json
│  ├─ auth.json
│  └─ errors.json
├─ tr/
│  ├─ common.json
│  ├─ auth.json
│  └─ errors.json
└─ ar/   # right‑to‑left language
   ├─ common.json
   └─ …
```

## Best practices
### DO
- Store every user‑facing string in a translation key.
- Group keys by feature or module (namespace).
- Use ICU message format for pluralization and gender.
- Format dates and numbers with the Intl API.
- Design layout with logical CSS properties (`margin-inline-start`, `padding-inline-end`).
- Plan RTL support from the start.

### DON'T
- Write raw text inside components.
- Concatenate translated strings; let the translation include the full sentence.
- Assume a fixed text length; some languages expand.
- Forget to test RTL layout when a RTL language is supported.
- Mix multiple languages in the same JSON file.

## Common issues and solutions
| Issue | Solution |
|---|---|
| Missing translation | Provide a fallback language (usually `en`). |
| Hard‑coded strings | Run a linter script to detect them (see script example). |
| Incorrect date format | Use `new Intl.DateTimeFormat(locale).format(date)`. |
| Incorrect number format | Use `new Intl.NumberFormat(locale).format(number)`. |
| Pluralization errors | Use ICU syntax: `{count, plural, one {# item} other {# items}}`. |

## RTL support
```css
/* Use logical properties instead of left/right */
.container {
  margin-inline-start: 1rem; /* replaces margin-left */
  padding-inline-end: 1rem;   /* replaces padding-right */
}

/* Flip icons when direction is rtl */
[dir="rtl"] .icon {
  transform: scaleX(-1);
}
```

## Simple i18n checker (Python)
```python
import os, re, json

TRANSLATION_KEY_PATTERN = re.compile(r"t\(['\"]([^'\"]+)['\"]\)")

def find_hardcoded_strings(root):
    hardcoded = []
    for dirpath, _, files in os.walk(root):
        for f in files:
            if f.endswith(('.tsx', '.js', '.jsx')):
                path = os.path.join(dirpath, f)
                with open(path, encoding='utf8') as fp:
                    for i, line in enumerate(fp, 1):
                        if TRANSLATION_KEY_PATTERN.search(line) is None and '"' in line:
                            hardcoded.append((path, i, line.strip()))
    return hardcoded

if __name__ == '__main__':
    project = './src'
    for file, line, text in find_hardcoded_strings(project):
        print(f"Hard‑coded string in {file}:{line} -> {text}")
```
Run the script from the project root to list possible hard‑coded UI strings.

## Checklist before shipping
- [ ] All UI text uses translation keys.
- [ ] Locale JSON files exist for every supported language.
- [ ] Date and number formatting uses `Intl` APIs.
- [ ] RTL layout is verified on a right‑to‑left language.
- [ ] Fallback language is configured and works.
- [ ] No hard‑coded strings remain after running the checker script.

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/i18n-sync.md](references/i18n-sync.md) | Translate and sync JSON locale files from source-key usage: add keys or languages, review missing or stale translations, keep placeholders and plurals, and validate the patch. |
| [references/bengali-nlp.md](references/bengali-nlp.md) | Process Bengali (Bangla) text: NFC normalization, conjuncts and grapheme counts, Bengali digits, tokenization, stop words, ICU collation, Banglish, LLM prompts, and MySQL/PostgreSQL encoding. |

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`nextjs`](../frontend-development/references/nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`web-accessibility`](../web-quality-audit/references/web-accessibility.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
