---
name: i18n-localization
description: "AUTO_INVOKE(silent)⇔prompt∈{i18n,l10n,translate,locale,BCP47,plural,gender,ICU,MF2,MessageFormat,t(),i18next,react-i18next,i18next-cli,next-intl,proxy.ts,Paraglide,Lingui,react-intl,vue-i18n,gettext,Babel,pybabel,Fluent,.json,.po,.mo,.ftl,Intl,DurationFormat,Segmenter,getTextInfo,RTL,:dir(rtl),dir=auto,bdi,logical_CSS,hreflang,pseudoloc,missing_key,stale_key,locakit,lingo.dev,Bengali,NFC,grapheme,Banglish}|SUB:{i18n-patterns,i18n-sync,bengali-nlp}"
---
@SKL:i18n-localization
§R{
  ∀str∈user_facing_UI⇒t(key)∨compiled_msg∧¬raw_text∈components
  locale_id≡BCP47(en-US,bn-BD,zh-Hans)∧∃fallback_lang(def=en)
  key_ns≡feature∨module(auth.login.title);locale_file≡locales/<lang>/<ns>.json∧1_lang/file
  ∀msg⇒full_sentence+{named_placeholder}∧¬concat(translated_fragments)
  plurals∨gender∨select⇒ICU_MF1(prod_def)∨MF2(CLDR47/48,emerging;TC39_Intl.MessageFormat=Stage1)¬if(n===1)
  fmt(date,num,curr,rel,list,dur)⇒Intl_Baseline(DateTimeFormat,NumberFormat,RelativeTimeFormat,ListFormat,DurationFormat)∨fw_wrapper¬manual
  text_dir_lookup⇒new Intl.Locale(loc).getTextInfo().direction(Baseline2026)¬nonstd_.textInfo
  RTL⇒plan@start∧<html lang dir>∧CSS_logical(margin-inline-start,padding-inline-end,inset-inline-start,text-align:start)¬(left|right)
  RTL_hooks⇒:dir(rtl)(Baseline,inherits+dir=auto)≻[dir="rtl"]∧mirror(dir_icons)¬CSS_direction@root
  bidi⇒dir="auto"@UGC∧<bdi>∨unicode-bidi:isolate@inline_vars∧dir="ltr"@(email,URL,phone,code)∧translate="no"@(brands,code)
  layout⇒¬fixed_text_len(expansion≥30–50%)∧test(pseudoloc∧RTL_locale)@pre_ship
  TS_safety⇒strict_typed_keys(AppConfig|i18next-cli|Paraglide|Lingui)¬untyped_string_keys
  sync⇒automated_CLI(i18next-cli|pybabel|lingo.dev)∧preserve(struct,placeholders,unrelated)¬manual_1_file_edit
  SEO_i18n⇒localized_URLs∧<link rel="alternate" hreflang>∧x-default
  Python_app⇒Babel+gettext(ngettext,pgettext,%(k)s)∨fluent.runtime(.ftl)¬f-strings(literal_UI)
  Bengali⇒NFC_norm@∀boundary∧grapheme_clusters(Intl.Segmenter|regex_\X)∧ICU_collation(bn-BD|bn-IN)¬(byte|codepoint_len)
}
§D{
  Next.js_16_App_Router⇒next-intl@4(proxy.ts,defineRouting,createNavigation,hasLocale,setRequestLocale,getTranslations,AppConfig)¬middleware.ts|unstable_setRequestLocale|client_only_RSC;
  React_multi_fw_enterprise⇒i18next@27+react-i18next@18+i18next-cli¬deprecated_i18next-parser|custom_str_maps;
  Vite/SvelteKit/Next_max_TS+tiny_bundle⇒@inlang/paraglide-js@3(m.key())∨@lingui/core@6(SWC_macros)¬heavy_runtime_parsers;
  heavy_ICU_linguistics⇒react-intl@12(FormatJS)∨@lingui/core@6¬ad_hoc_plural_regex;
  Vue_3⇒vue-i18n@11¬custom_reactive_maps;
  Python_standard_web⇒Babel@2.19(pybabel)+gettext(.pot/.po/.mo,ngettext,pgettext)¬if_count>1|str_concat;
  Python_complex_grammar⇒fluent.runtime(.ftl)¬nested_gettext_hacks;
  count_dep_text⇒{count,plural,one{# item}other{# items}}¬(count===1?'item':'items');
  val_in_sentence⇒placeholder({name})∈msg¬(t('hello')+name);
  locale∈{ar,he,fa,ur}⇒<html dir="rtl">∧logical_CSS∧:dir(rtl)_mirror¬(margin-left|float:left|[dir="rtl"]_only);
  dynamic_mixed_dir_var⇒<bdi>{val}</bdi>∧dir="auto"@UGC¬raw_inline_interp;
  missing_key@runtime⇒fallback_locale∧log(key)¬render_raw_key;
  Δ(key∨lang)⇒i18next-cli_sync(--changed-only)∨context_aware_patch(i18n-sync)¬manual_edit(1_file)|locakit_0.1.0_apply;
  Bengali_DB_sort⇒PG_UTF8+ICU("bn-BD-x-icu"|"bn-IN-x-icu")≻MySQL_utf8mb4_0900_ai_ci¬utf8mb4_unicode_ci|latin1;
  Bengali_len/trunc⇒Intl.Segmenter|regex_\X¬(byte_len|codepoint_len);
}
§REF{
  fw_versions,next-intl_v4,proxy.ts,i18next,Paraglide,Lingui,FormatJS,vue-i18n,Babel,Fluent,Intl_Baseline,MF2,RTL_CSS,:dir(rtl),bdi,pseudoloc,ship_chk→references/i18n-patterns.md;
  translate,sync_JSON_locales,add_keys/langs,missing/stale_keys,placeholders,plurals,i18next-cli,lingo.dev,locakit→references/i18n-sync.md;
  Bengali_NLP,NFC,conjuncts,graphemes,digits,tokenization,collation,Banglish,MySQL_0900,PG_ICU→references/bengali-nlp.md;
}
§REL{
  ../frontend-development/SKILL.md:React,Next.js_app_struct;
  ../frontend-development/references/nextjs.md:App_Router,proxy.ts,locale_routing,RSC;
  ../typescript/SKILL.md:typed_i18n_keys,AppConfig;
  ../seo/SKILL.md:hreflang,localized_URLs;
  ../web-quality-audit/references/web-accessibility.md:lang_attr,WCAG_chk;
}
