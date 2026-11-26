@REF:i18n-patterns
§PAT{
  react(`react-i18next`):`useTranslation()`→`t('welcome.title')`;
  nextjs(`next-intl`):`useTranslations('Home')`→`t('title')`;
  py(`gettext`,.po/.mo):`from gettext import gettext as _; _('Welcome to our app')`;
  layout:1_lang/dir,ns_by_feat⇒`locales/{en,tr,ar(RTL)}/{common,auth,errors}.json`;
  icu:`{count, plural, one {# item} other {# items}}`;
  intl:`new Intl.DateTimeFormat(locale).format(d)`∧`new Intl.NumberFormat(locale).format(n)`;
  rtl:`margin-inline-start:1rem`(¬`margin-left`),`padding-inline-end:1rem`(¬`padding-right`),`[dir="rtl"] .icon{transform:scaleX(-1)}`
}
§D{missing⇒fallback(us.`en`);hardcoded⇒run_checker;date/num⇒Intl;plural⇒ICU}
§CMD{checker(heuristic,`./src/*.{tsx,js,jsx}`,utf8,FP→manual_review):
`KEY=re.compile(r"t\(['\"]([^'\"]+)['\"]\)")`→walk`./src`→flag`l`if`'"' in l and not KEY.search(l)`}
§CHK{UI_uses_keys;locales_∀lang;Intl_dates/nums;RTL_verified;fallback_ok;checker_clean}
