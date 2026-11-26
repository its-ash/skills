@REF:design-system
§REL{../SKILL.md:parent+§map;visual-design-direction.md:ref_study;brand-theming.md:brand;make-interfaces-feel-better.md:polish}
§WHEN{new_DS,audit_UI,pre_redesign(§14),fix_off_UI,style_PR}
§R:§26_DS{
  flow:principles→tokens(oklch_50-950,tonal_elev,fluid_type,8pt_space,1_radius+concentric,bg_shadows,bp)→light-dark()→atomic_components→WCAG_2.2_AA→docs→semver;
  tokens:1_ver_src;semantic(`color.semantic.surface.card`,`color.semantic.border.subtle`,`color.semantic.accent.primary`)→oklch();¬(#000|#fff);
  elev:4_layers(canvas,surface,surface-muted,surface-elevated)+border-subtle+border-strong;dark⇒step_L_up(¬heavy_shadow);
  theme:color-scheme:light dark+light-dark();`data-theme="light|dark"`∈<html>_override_only;TW4⇒@theme+light-dark()(¬`dark:`_sprawl);
  comp:atoms→molecules→organisms→templates→pages;props(variant,size,disabled,loading);`<Card.Header>`>bools;as|render;§7:{fullwidth_sq_hdr,filled_round_tabs_muted_track,0_1sided_borders,0_nested_cards,filled_check/radio/switch,soft_tonal_badges};
  a11y(WCAG_2.2_AA):kb_reach,`:focus-visible`¬obscured,targets≥24px(touch≥44px),`<dialog>`,`[popover]`+anchor,`aria-label`,`aria-expanded`,`role="alert"`,axe-core+manual,Storybook_10_a11y,Playwright_a11y_snap
}
§ANTI:pitfalls{raw_hex,inconsistent_props,no_focus_ring,dark_contrast,unversioned_tokens,1sided_card_border,underline_tabs,`dark:`_sprawl}
§PAT:mode1_gen{
  1:scan(CSS,@theme,styles)→2:extract+count(colors,type,space,radius,shadows,bp)+merge_dupes(`#1a1a1a`≈`#1b1b1b`)→3:opt_3refs(visual-design-direction.md⇔browser∧user_ok)→4:propose(oklch_50-950,1_accent<80%_sat,status[success,warning,danger,info];semantic[canvas,surface,surface-muted,surface-elevated,border-subtle,border-strong,text-primary,text-muted,accent,accent-soft]∈light-dark();clamp()_type;8pt;1_--radius-sm/md/lg_concentric;bg_shadows)→5:DESIGN.md(rationale)→6:design-preview.html(0_deps,all_tokens,data-theme,filled_tabs,tonal_cards,btns,inputs,filled_controls,badges,<dialog>);
  out:{design-tokens.json:DTCG_2025($value,$type,Style_Dict_4/5),tokens.css:color-scheme+light-dark(),DESIGN.md,design-preview.html};
  must:1_accent∧1_gray∧1_radius∧concentric∧uniform_pad∧0_1sided∧filled_tabs∧AA
}
```json
{"color":{"primitive":{"slate":{"50":{"$type":"color","$value":"oklch(98.5% 0.004 250)"},"950":{"$type":"color","$value":"oklch(14% 0.01 250)"}}},"semantic":{"surface":{"canvas":{"$type":"color","$value":"{color.primitive.slate.50}"}}}}}
```
§PAT:mode2_audit{
  score:0..10∀dim+examples+fix(`file:line`);fmt:row(Dimension,Score,Example,`Fix (file:line)`);
  dims:{1_Color:oklch_vs_hex;2_Type:h1>h2>h3>body>cap+balance/pretty+tabular-nums;3_Space:4/8/16_vs_arb;4_Craft:filled_tabs+tonal_cards(¬1sided,¬nested)+concentric+filled_ctrl;5_Resp:fluid_@container_vs_break;6_Dark:light-dark()+elev_vs_`dark:`;7_Anim:§5.B+transform/opacity+reduced_motion;8_A11y:AA+:focus-visible+24/44+<dialog>/popover;9_Density:dial_§1;10_Polish:hover/active+skeleton+empty/error+optical}
}
§CMD:scans{
```bash
rg -o '#[0-9a-fA-F]{3,8}\b' src | sort | uniq -c | sort -rn
rg -o 'border-[ltbr]-[248]\b' src | sort | uniq -c
rg -o 'rounded(-[a-z0-9]+)?' src | sort | uniq -c
rg -o '\bdark:[a-z0-9-]+' src | sort | uniq -c | sort -rn
rg -o '\b(p|m|gap)[trblxy]?-\[?[0-9.]+(px|rem)?\]?' src | sort | uniq -c
```
}
§PAT:mode3_slop{
  vs:{§0_anti_default,§10_anti_slop};report:`file:line`+rule;
  hits:{`border-l-4`/`border-t-4`(§7),underline/bare_tabs(§7),nested_cards(§4.4),all_grad/purple-blue/neon,purposeless_glass∨no_reduced_transparency,pill_hdr_vs_sq_fullwidth(§7),`dark:`_sprawl,excess_scroll/`transition:all`/stock_hero_grad,Inter/Roboto_no_hier}
}
