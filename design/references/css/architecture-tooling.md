@REF:architecture-tooling
§R{
1_sys/repo∈{utility,BEM|Modules,CSS-in-JS}∧doc(¬mix→spec_wars);
cascade:@layer(reset→base→components→utilities)∧1-cls_spec;
tokens:prim(--blue-600)→sem(--color-action)→comp(--btn-bg);comp∈{sem,comp};
native>preproc(if_sup):vars,nesting,color-mix(),@layer,@scope,math_fns;
0-rt(Modules,vanilla-extract,Tailwind,Panda,StyleX)>rt-CSS-in-JS(styled-components,Emotion⇒JS_cost∧RSC_conflict);
lint:Stylelint18(ESM,stylelint-config-standard)|Biome2;fmt:Biome2|Prettier;CI:fail_err;
targets:1_browserslist(LightningCSS∧JS)
}
§PAT{
BEM:.block,.block__element,.block--modifier;1-cls∧¬DOM_nest;Sass(&__el)✓,native(&__el)✗;
Atomic(Tailwind,Atomizer):1_decl/cls⇒O(1)_size;extract∈FW(¬@apply_abuse);
CUBE:Composition,Utility,Block,Exception([data-state]);use_cascade;
EveryLayout:{Stack,Cluster,Sidebar,Switcher,Grid,Center,Cover}⇒intrinsic∧¬MQ;
ITCSS:settings→tools→generic→elements→objects→components→utilities⇒@layer;
state:[aria-expanded="true"],[data-state="open"]¬classes
}
§TOK{
`@layer tokens{:root{--blue-600:oklch(55% .2 260);--color-action:var(--blue-600)}}` `.btn{--btn-bg:var(--color-action);background:var(--btn-bg)}`;
SOT:DTCG2025($value,$type)→StyleDictionary5(native_DTCG)→{CSS,iOS,Android};
theme:swap_sem([data-theme]|light-dark())∧¬override_internals;docs:Storybook∧DevTools_names
}
§TW{
v4(4.3.5+):CSS-first(¬tailwind.config.js);`@import "tailwindcss";`@theme{--color-brand:…}|@utility|@variant|@custom-variant|@source;
layers:@layer(theme,base,components,utilities);unlayered>TW;
engine:LightningCSS(¬PostCSS|Autoprefixer);
scan:whole_cls_in_src;¬`bg-${color}-500`⇒map→full_str;
`bg-red-500!`:last_resort;merge:tailwind-merge;variants:cva|tailwind-variants;@apply:3rd-party_HTML_only∧¬BEM
}
§TOOL{
Sass:@use "tokens" as t;@forward;(¬@import);$radius:4px !default;→@use "lib" with($radius:8px);mixins(@content)>%extend(bloat);math.div()>/;@each/@for_small;compile=Sass_var,rt=CSS_var;
LightningCSS(Rust):prefix,lower_nest,color_fb,minify,Modules(Vite8_Rolldown∧TW4_default)>PostCSS;
PostCSS:plugins_only(postcss-preset-env_drafts,custom-media);¬lower_sup;
Modules(.module.css):hash/file;`composes:base from "./base.module.css"`;
FW:Vue(<style scoped>),Svelte,Astro(:where(.astro-xyz));:global()_rare;native:@scope;
CSS-in-JS:0-rt(vanilla-extract,Linaria,Panda,StyleX⇒createTheme,style,recipe,Sprinkles);rt(¬in_render∧vars_dyn);
WebComp:Shadow⇒vars∧::part();share:adoptedStyleSheets;Light⇒global/util_CSS
}
§LINT{
Stylelint:{selector-max-id:0,selector-max-specificity,declaration-no-important,color-no-hex|token_plugin,selector-class-pattern,no-descending-specificity};
unused:DevTools_Coverage,PurgeCSS,CSS_Stats,Project_Wallace;CI:size_budget;visual:Playwright(toHaveScreenshot),Chromatic
}
§CMS{
WP:theme.json(settings.{color.palette,typography.fontSizes[fluid],spacing,custom})→--wp--preset--*;
order:core→theme.json→/styles/*.json→Global_Styles;prefer:theme.json(styles.{elements,blocks})>custom_CSS
}
§ANTI{
unlayered_vendor>layers⇒`@import url(lib.css) layer(vendor);`;
rt_CSS-in-JS_order⇒hydration_flash;barrels∧circular⇒slow_DS∧¬tree-shake;
purge_misses_CMS/JSON⇒safelist;over-abstract(1-off)⇒arbitrary_vals|inline
}
