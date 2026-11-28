@REF:bengali-nlp
§SCOPE{Bengali/Bangla_text,NCTB_edu,search/autocomplete/input,LLM_train/chatbots,Banglish,bn-BD/bn-IN_l10n}
§UNI{range:U+0980–U+09FF;
  U+0981–0983:Chandrabindu,Anusvara,Visarga;
  U+0985–0994:indep_vowels(অ,আ,ই,ঈ,উ,ঊ,ঋ,ঌ,এ,ঐ,ও,ঔ);
  U+0995–09B0:consonants(ক–র);U+09B2:ল;U+09B6–09B9:শ,ষ,স,হ;
  U+09DC,09DD,09DF:ext_cons(ড়,ঢ়,য়);U+09BC:Nukta;
  U+09BE–09C8:dep_vowels(কার:া,ি,ী,ু,ূ,ৃ,ে,ৈ);U+09CB–09CC:ো,ৌ;
  U+09CD:Hasanta(virama→conjuncts);U+09CE:Khanda_Ta(ৎ);U+09D7:AU_len;U+09E0–09E3:ext_vowels;
  U+09E6–09EF:digits(০১২৩৪৫৬৭৮৯);U+09F0–09F1:Assamese(ৰ,ৱ);
  U+09F2–09F3:rupee_mark(৲),rupee(৳);U+09F4–09F9:curr_num(৴–৸),denom(৹);U+09FA:Isshar(৺)
}
§R{
  norm:∀boundary∈{in,store,cmp,search}⇒NFC(unicodedata.normalize("NFC",s)|s.normalize("NFC")),idempotent(e.g."ক\u09C7\u09BE"→"কো");
  grapheme:conjuncts(যুক্তবর্ণ:ক+্+ষ=ক্ষ,স+্+ত=স্ত,ন+্+ত+্+র=ন্ত্র)⇒¬split_codepoint(len("ক্ষ")==3≠1_grapheme);use_grapheme_clusters(py:`regex.findall(r"\X",s)`,js_Baseline:`Intl.Segmenter("bn",{granularity:"grapheme"})`);
  digits:map("০১২৩৪৫৬৭৮৯"↔"0123456789")via_str.maketrans/translate;¬rely_on_str.isdigit()(accepts_Arabic-Indic_"٣",superscript_"²"→int("²")=ValueError);allowlist_re`r'[0-9০-৯]+'.fullmatch(s)`∨`s.isdecimal()`→`int(s)`;
  region:BCP47`bn-BD`(BDT/৳)≠`bn-IN`(INR/₹);South_Asian_3,2,2_grouping⇒`Intl.NumberFormat('bn-BD')`(+`numberingSystem:'beng'`_for_০–৯);
  zw:strip_ZWSP(\u200b)+BOM(\ufeff)⇒`re.sub(r'[\u200b\ufeff]','',s)`;PRESERVE_ZWNJ(U+200C)+ZWJ(U+200D)(conjunct_rendering);
  negation:exclude_negators{না,নয়,নেই}∉stop_words(alters_intent/sentiment)unless_explicit_negation_model;
  search:NFC(query.strip().lower())∧reject_blank(`if not query:return []`,blank_matches_all);
  collation:স্বরবর্ণ<ব্যঞ্জনবর্ণ⇒use_ICU_collator(`bn-BD`/`bn-IN`),¬raw_codepoint_order;
  translit:¬ASCII_translit("bangla bhasha")when_Unicode("বাংলা ভাষা")avail;
  llm_sec:treat(Bengali,Banglish,scraped_HTML)≡untrusted_DATA⇒isolate_in_user_role;inline_delims≠trust_boundary(e.g.user_injects`---END INPUT---`);single_str_API⇒escape_delim+label_DATA+auth_tools_outside_model;
  db:PG_17/18=UTF8+ICU("bn-BD-x-icu"|"bn-IN-x-icu",OS-independent)≻MySQL_8.4=utf8mb4+utf8mb4_0900_ai_ci(UCA9.0_generic;¬utf8mb4_unicode_ci/utf8/latin1;MySQL_lacks_bn_locale_collation→app_ICU_if_strict_dict_sort)
}
§PAT{
  grapheme_trunc:`import regex;"".join(regex.findall(r"\X",s)[:max_g])` | JS:`[...new Intl.Segmenter('bn',{granularity:'grapheme'}).segment(s)].length`;
  tok_basic:`re.sub(r'(?<!\d)\.|\.(?!\d)|[।,;:!?\-\'"()\[\]{}]',' ',s).split()`(preserves_decimals);
  tok_prod:`bnlp-toolkit@4.4+`(`from bnlp import NLTKTokenizer;NLTKTokenizer().word_tokenize(s)`)∨`stanza(bn)`∨`spaCy(bn)`;
  suffixes:{-এর(poss),-তে(loc),-কে(acc),-র(poss_after_V),-য়(loc_var)};
  script_det:`bool(re.search(r'[\u0980-\u09FF]',s))`;ratio:`0.0 if not s else len(re.findall(r'[\u0980-\u09FF]',s))/len(s)`;
  stopwords:{এবং,ও,এ,এই,সেই,তার,যে,একটি,করে,হয়,আর,কিন্তু,তবে,যদি,তাহলে,আমি,তুমি,সে,আমরা,তোমরা,তারা,হবে,ছিল,আছে,থেকে,জন্য,সাথে,পর,আগে,উপর,নিচে,মধ্যে,দিয়ে,কি,কে,কোন,কোথায়,কেন,কিভাবে,হ্যাঁ,অনেক,কিছু,সব,প্রতি};
  collate_py:`import icu;c=icu.Collator.createInstance(icu.Locale("bn_BD"));sorted(w,key=c.getSortKey)`(ImportError→`sorted(w)`);
  collate_js:`new Intl.Collator('bn-BD')`→`[...w].sort(c.compare)`;
  num_fmt_js:`new Intl.NumberFormat('bn-BD',{style:'currency',currency:'BDT'}).format(1234567)`;
  banglish:if`is_bangla(s)`⇒False;match_count≥2(re.I)in`{\bami\b,\btumi\b,\bapni\b,\bkemon\b,\bkothay\b,\bkeno\b,\bdhonnobad\b,\bash\w*lam\b,\bkor\w*chi\b,\bbol\w*chi\b}`;
  dataset:`re.sub(r'\s+',' ',re.sub(r'[\u200b\ufeff]','',unicodedata.normalize("NFC",s))).strip()`→drop_empty;
  llm_prompts:{bn:"তুমি একজন সহায়ক AI সহকারী। বাংলায় উত্তর দাও। সহজ ভাষায় ব্যাখ্যা করো যাতে সবাই বুঝতে পারে।",mixed:"reply_in_user_lang(bn↔en);English_tech_terms_ok_in_bn"};
  llm_escape:`user_input.replace("---END INPUT---","---END INPUT-\u200b--")`
}
§DB{
  mysql_8_4+:`VARCHAR(255)/TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci`(UCA9.0_default;supersedes_utf8mb4_unicode_ci_UCA4.0;generic_order_only→use_PG_ICU_or_app_ICU_for_Bengali_dict_sort);
  pg_precheck:1_chk_UTF8:`SELECT pg_encoding_to_char(encoding)='UTF8' AS ok FROM pg_database WHERE datname=current_database();`→false⇒STOP;
    2_chk_ICU(ver_agnostic_via_to_jsonb;col_moved:collcollate≤14,colliculocale=15-16,colllocale≥17;bitwise_stable_vs_glibc_drift):
    `SELECT c.collprovider='i' AS icu_provider,coalesce(to_jsonb(c)->>'colllocale',to_jsonb(c)->>'colliculocale',c.collcollate) AS locale FROM pg_collation c WHERE c.collname='bn-BD-x-icu';`
    (¬`CREATE COLLATION IF NOT EXISTS`alone→keeps_wrong_provider/locale);
    ∅⇒`CREATE COLLATION "bn-BD-x-icu"(provider=icu,locale='bn-BD');`(or`'bn-IN'`for_India);
    wrong_provider/locale⇒fix/rename_first;
  pg_tbl:`title TEXT COLLATE "bn-BD-x-icu", body TEXT`
}
§REL{../SKILL.md;../../database-design/references/database-migration.md:live_schema_collation/encoding}
