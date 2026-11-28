@REF:i18n-patterns
§VER{
  web:{next-intl:4.16,i18next:27.2,react-i18next:18.0,i18next-cli:1.95,@inlang/paraglide-js:3.2,@lingui/core:6.12,react-intl:12.2,vue-i18n:11.4};
  py:{Babel:2.19,gettext:stdlib,fluent.runtime:Project_Fluent};
  std:{MF2:CLDR_47/48_spec_stable(messageformat@4;TC39_Intl.MessageFormat=Stage1),Intl.DurationFormat:Baseline_2025,Intl.Locale.getTextInfo():Baseline_2026,CSS_:dir():Baseline}
}
§D{
  Next.js_16⇒next-intl@4(proxy.ts+defineRouting+createNavigation+hasLocale+setRequestLocale+AppConfig)¬middleware.ts|unstable_setRequestLocale;
  React_enterprise/multi_fw⇒i18next@27+react-i18next@18+i18next-cli¬i18next-parser(deprecated);
  compiler_first_zero_bloat⇒@inlang/paraglide-js@3(tree-shaken_m.key(),URL_l10n)∨@lingui/core@6(SWC/Babel_macros,~2KB_runtime);
  strict_ICU_heavy_grammar⇒react-intl@12(FormatJS)∨@lingui/core@6;
  Vue_3⇒vue-i18n@11;
  Python⇒Babel+gettext(standard_web/TMS_.po)⊕fluent.runtime(.ftl,multi-var_declensions);
  msg_fmt⇒ICU_MF1(default_prod_TMS_compat)⊕MF2(greenfield_if_TMS+messageformat@4_supported);
  dir_CSS⇒:dir(rtl)(inherits+dir="auto")≻[dir="rtl"];
  dir_JS⇒new Intl.Locale(loc).getTextInfo().direction¬nonstd_locale.textInfo;
  hardcoded_audit⇒AST_linter(eslint-plugin-i18next|i18next-cli_lint)≻regex_scan
}
§PAT{
  next-intl_routing:`src/i18n/routing.ts`:`defineRouting({locales:['en','de','ar'],defaultLocale:'en'})`;
  next-intl_proxy:`src/proxy.ts`(Next16_network_boundary):`export default createMiddleware(routing);export const config={matcher:'/((?!api|trpc|_next|_vercel|.*\\..*).*)'}`;
  next-intl_nav:`src/i18n/navigation.ts`:`export const {Link,redirect,usePathname,useRouter,getPathname}=createNavigation(routing)`;
  next-intl_req:`src/i18n/request.ts`:`getRequestConfig(async({requestLocale})=>{const req=await requestLocale;const locale=hasLocale(routing.locales,req)?req:routing.defaultLocale;return{locale,messages:(await import(\`../../messages/\${locale}.json\`)).default}})`;
  next-intl_layout:`src/app/[locale]/layout.tsx`:`generateStaticParams()`+`const {locale}=await params;if(!hasLocale(routing.locales,locale))notFound();setRequestLocale(locale);`;
  next-intl_usage:RSC=`const t=await getTranslations('Home')`|CC=`const t=useTranslations('Home')`|experimental_inline=`useExtracted('Hello')`(compile-time_key_hash);
  next-intl_TS:`declare module 'next-intl'{interface AppConfig{Locale:(typeof routing.locales)[number];Messages:typeof en;Formats:typeof formats;}}`(strict_useLocale()+keys);
  react-i18next:`const {t}=useTranslation('common');t('welcome.title',{name})`;RSC⇒`createInstance()`+explicit_lng;TS⇒`i18next-cli`_gen_types;
  paraglide_v3:`import * as m from '@/paraglide/messages';m.welcome_title({name})`(tree-shaken_per_route,native_RSC,localized_URLs);
  lingui_v6:`<Trans>Hello {name}</Trans>`∨`t\`Save\``(SWC/Babel_extract→compiled_catalog,native_ICU);
  py_gettext:`from gettext import gettext as _,ngettext,pgettext`;`_("Hi %(u)s")%{"u":u}`;`ngettext("%(n)d file","%(n)d files",n)%{"n":n}`;`pgettext("direction","Right")`;
  py_babel_fmt:`babel.dates.format_datetime(dt,locale='de_DE')`∧`babel.numbers.format_currency(9.5,'EUR',locale='de_DE')`;
  py_fluent:`files = {$user} added {$n -> [one] 1 file *[other] {$n} files}`(`.ftl`+`fluent.runtime`);
  layout:1_lang/dir,feat_ns⇒`locales/{en,de,ar}/{common,auth,errors}.json`;
  icu_mf1:`{count,plural,=0{No items}one{# item}other{# items}}`∧`{gender,select,female{She}male{He}other{They}}`;
  mf2_syntax:`.input {$n :number} .match $n 1 {{1 item}} * {{{$n} items}}`∧markup:`{#b}text{/b}`;
  intl_apis:`Intl.DateTimeFormat(loc,{dateStyle:'medium'})`∧`Intl.NumberFormat(loc,{style:'currency',currency:'EUR'})`∧`Intl.RelativeTimeFormat(loc,{numeric:'auto'})`∧`Intl.ListFormat(loc,{type:'conjunction'})`∧`Intl.DurationFormat(loc,{style:'short'}).format({hours:2,minutes:15})`∧`Intl.Segmenter(loc,{granularity:'grapheme'})`∧`new Intl.Locale(loc).getTextInfo().direction`;
  rtl_html:`<html lang={loc} dir={dir}>`;UGC:`<p dir="auto">{msg}</p>`;inline_var:`<bdi>{user}</bdi>`;LTR_in_RTL:`<span dir="ltr">{email|url|phone|code}</span>`;no_xlat:`<span translate="no">Brand</span>`;
  rtl_css:`margin-inline-start:1rem`,`padding-inline-end:1rem`,`inset-inline-start:0`,`border-inline-start:2px solid`,`border-start-start-radius:.5rem`,`text-align:start`,`unicode-bidi:isolate`,`:dir(rtl) .icon-dir{transform:scaleX(-1)}`¬flip(clock,checkmark,play,brand_logo);
  url_seo:subpath(`/de/about`)≻subdomain≻cookie_only;negotiate_Accept-Language_once→persist_explicit_user_choice;emit`<link rel="alternate" hreflang="xx-YY">`+`hreflang="x-default"`+self_canonical;
  pseudoloc:expand_+35%+accented_chars+delims(`[!! Ẅéĺćőḿé !!]`)→catch_truncation,concat,hardcoded_str_pre_xlat
}
§CFG{
  babel_cfg:`[python: **.py]\n[jinja2: **.html]\ninput_encoding = utf-8`
}
§CMD{
  i18next_cli:`npx i18next-cli extract`∧`npx i18next-cli sync --changed-only`∧`npx i18next-cli lint`∧`npx i18next-cli status`;
  pybabel:`pybabel extract -F babel.cfg -o locale/messages.pot .`→`pybabel init -i locale/messages.pot -d locale -l es`→`pybabel update -i locale/messages.pot -d locale`→`pybabel compile -d locale`→`pybabel check`;
  hardcoded_fallback(heuristic_if_no_AST_linter,`./src/*.{tsx,jsx,ts,js}`,FP→manual_review):`KEY=re.compile(r"t\(['\"]([^'\"]+)['\"]\)")`→flag_text_lines_missing_`KEY`
}
§ANTI{
  Next16_middleware.ts(use_proxy.ts);next-intl_v3_legacy(unstable_setRequestLocale,createLocalizedPathnamesNavigation,global_IntlMessages);
  i18next-parser(deprecated→i18next-cli);locale.textInfo(nonstd→getTextInfo());
  CSS_direction:rtl@root(use_HTML_dir);[dir="rtl"]_alone_w/_dir="auto"(use_:dir(rtl));
  physical_CSS(margin-left,padding-right,left,float:left,text-align:left);
  concat_fragments;count===1?a:b;fixed_px_width/height_on_text;flip_symmetric/clock/media/brand_icons;missing_CLDR_plurals(zero/one/two/few/many/other)
}
§CHK{
  UI_0_raw_str(AST_lint∨pseudoloc);BCP47_locales+fallback_ok;strict_TS_keys_green;Intl_Baseline_fmt(no_manual_date/num/dur);
  CLDR_plurals_complete;HTML_lang+dir_set;logical_CSS+:dir(rtl)+<bdi>+dir="auto"_verified;RTL_visual_QA_done;hreflang+x-default_valid
}
§REL{../SKILL.md;../../frontend-development/references/nextjs.md;../../seo/SKILL.md}
