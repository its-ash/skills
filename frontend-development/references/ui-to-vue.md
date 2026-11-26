@REF:ui-to-vue
§GOAL{batch_UI_screenshots→Vue3_CompositionAPI_comps+router_via_ui-to-vue-converter_CLI}
§USE{
  do⇔dir(screenshots)∧Vue3∧first_pass(pages,shared,router)∧ui∈{vant,element-plus,antd-vue};
  ¬do⇔{1_screenshot_custom⇒[vue.md](vue.md);¬Vue;needs_complex_logic/data/a11y;private_data_blocked_from_ext_API}
}
§IN{
  tree:`screenshots/HomePage/{HomePage-Default@3x.png,cut-images/,List/{HomePage-List-Default@3x.png,cut-images/}}+root_cut-images/`;
  cut_dirs∈{assets,icons,sprites,cut,images,cut-images}
}
§MDL{
  page_group:states(list,detail,form,loading,empty)→1_page;
  ui_map:native→vant|element-plus|antd-vue;
  cut_prio:page>module>global;
  extract:repeated_UI(>1)→shared_comps
}
§CMD{
  `export DASHSCOPE_API_KEY=<key>`
  `npx ui-to-vue-converter@1.0.2 --input ./screenshots --ui vant --output ./src`
  opts:{--input(./screenshots),--ui(vant|element-plus|antd-vue,def=vant),--output(./src),--config(./.ui-to-vue.config.json)}
}
§CFG{
  env(`DASHSCOPE_API_KEY`)>cfg_file;
  `.ui-to-vue.config.json`:`{"apiKey":"...","input":"./designs","ui":"vant","output":"./src"}`∧add_`.gitignore`
}
§SEC{
  ext_API⇒permission_for_private_designs;pin=`@1.0.2`(¬`@latest`);
  ¬commit:{.ui-to-vue.config.json,API_keys,secrets,customer_screenshots};review_output_pre_commit
}
§CHK{pages∈views/|output;shared∈components/_iff_clear_reuse;router_matches_project;consistent_--ui;CSS_units_match_baseline;fmt+lint+tsc+build_pass;copy/mocks/assets_reviewed}
§DBG{
  401/auth⇒check_DASHSCOPE_API_KEY_in_shell;
  cmd_not_found:ui-to-vue⇒`npx ui-to-vue-converter@1.0.2`;
  cut_ignored⇒dir∈cut_dirs_under_page/module;
  wrong_UI_lib⇒explicit_`--ui`+check_imports;
  wrong_dims⇒match_export_width_to_lib_baseline
}
§REL{[vue.md](vue.md);[figma.md](../../design/references/figma.md)}
