---
name: i18n-localization
description: "AUTO_INVOKE(silent)⇔prompt∈{i18n,l10n,translate,locale,plural,gender,ICU,t(),react-i18next,useTranslation,next-intl,useTranslations,gettext,.json,.po,.mo,Intl.DateTimeFormat,Intl.NumberFormat,RTL,dir=rtl,logical_CSS,missing_key,stale_key,Bengali,NFC,grapheme,Banglish,web,Python}|SUB:{i18n-sync,bengali-nlp}"
---
@SKL:i18n-localization
§R{
  ∀str∈user_facing_UI⇒t(key)∧¬raw_text∈components
  key_ns≡feature∨module(auth.login.title)
  locale_file≡locales/<lang>/<namespace>.json∧1_lang/file
  ∀msg⇒full_sentence∧¬concat(translated_fragments)
  plurals∨gender⇒ICU_msg_fmt
  fmt(date,num,currency)⇒Intl∨fw_wrapper∧¬manual
  ∃fallback_lang(def=en)
  css_dir⇒logical_props(margin-inline-start,padding-inline-end)∧¬(left∨right)
  RTL⇒plan@start∧<html dir>∧flip(directional_icons)
  ¬fixed_text_len(expansion≥30%)
  pre_ship(RTL)⇒test(RTL_locale)
}
§D{
  React_SPA⇒react-i18next∧useTranslation()¬custom_str_maps;
  Next.js_App_Router⇒next-intl∧useTranslations('Ns')∧locale_routing¬client_only_i18n(RSC);
  Python_app⇒gettext∧(.po/.mo)¬f-strings(literal_text);
  count_dep_text⇒{count,plural,one{# item}other{# items}}¬(count===1?'item':'items');
  val_in_sentence⇒placeholder({name})∈msg¬(t('hello')+name);
  locale∈{ar,he,fa,ur}⇒dir='rtl'∧logical_CSS∧mirror(icons)¬(margin-left∨float:left);
  missing_key@runtime⇒fallback_locale∧log(key)¬show(raw_key);
  Δ(key∨lang)⇒sync(∀locale_files,src_usage)¬manual_edit(1_file);
  Bengali_text⇒NFC_norm∧grapheme_len¬(byte_len∨codepoint_len);
}
§REF{
  fw_snippets,locale_layout,RTL_CSS,fixes_tbl,hardcoded_str_chk,ship_chk→references/i18n-patterns.md;
  translate,sync_JSON_locales,add_keys/langs,missing/stale_keys,placeholders,plurals→references/i18n-sync.md;
  Bengali_NLP,NFC,conjuncts,graphemes,digits,tokenization,collation,Banglish,DB_enc→references/bengali-nlp.md;
}
§REL{
  ../frontend-development/SKILL.md:React,Next.js_app_struct;
  ../frontend-development/references/nextjs.md:App_Router,locale_routing,RSC;
  ../typescript/SKILL.md:typed_i18n_keys;
  ../web-quality-audit/references/web-accessibility.md:lang_attr,WCAG_chk;
}
