# i18n Patterns

## Framework calls

```tsx
// React (react-i18next)
import { useTranslation } from 'react-i18next';
function Welcome() {
  const { t } = useTranslation();
  return <h1>{t('welcome.title')}</h1>;
}

// Next.js (next-intl)
import { useTranslations } from 'next-intl';
export default function HomePage() {
  const t = useTranslations('Home');
  return <h1>{t('title')}</h1>;
}
```

```python
# Python (gettext, .po/.mo catalogs)
from gettext import gettext as _
print(_('Welcome to our app'))
```

## Locale file layout

One language per file. Namespace by feature.

```
locales/
├─ en/  common.json  auth.json  errors.json
├─ tr/  common.json  auth.json  errors.json
└─ ar/  common.json  ...        # RTL
```

## Fixes

| Issue | Fix |
|---|---|
| Missing translation | Configure fallback language (usually `en`) |
| Hard-coded strings | Run the checker below |
| Wrong date format | `new Intl.DateTimeFormat(locale).format(date)` |
| Wrong number format | `new Intl.NumberFormat(locale).format(n)` |
| Plural errors | ICU: `{count, plural, one {# item} other {# items}}` |

## RTL CSS

```css
.container {
  margin-inline-start: 1rem; /* not margin-left */
  padding-inline-end: 1rem;  /* not padding-right */
}
[dir="rtl"] .icon { transform: scaleX(-1); } /* flip directional icons */
```

## Hard-coded string checker (heuristic)

Flags lines in `.tsx/.js/.jsx` that contain `"` and no `t('...')` call. Expect false positives; review output by hand.

```python
import os, re

KEY = re.compile(r"t\(['\"]([^'\"]+)['\"]\)")

def find_hardcoded(root):
    for dirpath, _, files in os.walk(root):
        for f in files:
            if f.endswith(('.tsx', '.js', '.jsx')):
                path = os.path.join(dirpath, f)
                with open(path, encoding='utf8') as fp:
                    for i, line in enumerate(fp, 1):
                        if not KEY.search(line) and '"' in line:
                            yield path, i, line.strip()

if __name__ == '__main__':
    for file, line, text in find_hardcoded('./src'):
        print(f"Hard-coded string in {file}:{line} -> {text}")
```

## Ship checklist

- [ ] All UI text uses translation keys.
- [ ] Locale files exist for every supported language.
- [ ] Dates and numbers use `Intl`.
- [ ] RTL layout verified in an RTL language.
- [ ] Fallback language configured and works.
- [ ] Checker shows no real hard-coded strings.
