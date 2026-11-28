@REF:design-system
§REL{../SKILL.md:parent+§map;component-library.md:comp_anatomy+states;visual-design-direction.md:ref_study;brand-theming.md:brand;make-interfaces-feel-better.md:polish}
§WHEN{new_DS,audit_UI,pre_redesign(§14),fix_off_UI,style_PR}
§R:§26_DS{
  flow:principles→tokens(oklch_50-950,60-30-10_balance,tonal_elev,fluid_type,8pt_space,1_radius+concentric,bg_shadows,bp)→light-dark()→atomic_components→WCAG_2.2_AA→docs→semver;
  tokens:1_ver_src;semantic(`color.semantic.surface.card`,`color.semantic.border.subtle`,`color.semantic.accent.primary`)→oklch();¬(#000|#fff);60%canvas/surf+30%sec/type+10%accent/status;
  type_scale:{Disp:36-48px/1.1/700/-0.03em;H1:28-32px/1.2/600-700/-0.02em;H2:20-24px/1.3/600/-0.015em;H3:16-18px/1.4/600/-0.01em;Body:14-16px/1.5/400/0(max-w-prose_60-75ch);BodySm:13-14px/1.45/400-500;Lbl/Cap:12px/1.4/500/0.01em;Overline:11px/1.3/600/0.06em_up};tabular-nums@nums;
  space_8pt:{4:icon_gap/badge,8:ctrl_gap/lbl_in,12:compact_pad/list,16:std_pad/field,24:card_pad/grid_gap,32:sec_sep,48-64:mktg_sec};
  radius:{sm:6px(cb/tag/tip),md:8-10px(btn/in/drop),lg:12-16px(card/modal/drawer),full:9999px(avatar/pill/sw)};concentric(in=max(0,out-pad));
  elev:4_layers(canvas,surface,surface-muted,surface-elevated)+border-subtle(8%)+border-strong(16%);tiers:{elev0:flat+1px,elev1:card_soft,elev2:drop/pop,elev3:modal/cmdk};dark⇒step_L_up(¬heavy_shadow);
  theme:color-scheme:light dark+light-dark();`data-theme="light|dark"`∈<html>_override_only;TW4⇒@theme+light-dark()(¬`dark:`_sprawl);
  comp:atoms→molecules→organisms→templates→pages;props(variant,size,disabled,loading);`<Card.Header>`>bools;as|render;§7:{fullwidth_sq_hdr,filled_round_tabs_muted_track,0_1sided_borders,0_nested_cards,filled_check/radio/switch,soft_tonal_badges};
  a11y(WCAG_2.2_AA):kb_reach,`:focus-visible`¬obscured,targets≥24px(desk≥36px_h,touch≥44px,gap≥8px),`<dialog>`,`[popover]`+anchor,`aria-label`,`aria-expanded`,`role="alert"`,axe-core+manual,Storybook_10_a11y,Playwright_a11y_snap
}
§ANTI:pitfalls{raw_hex,inconsistent_props,no_focus_ring,dark_contrast,unversioned_tokens,1sided_card_border,underline_tabs,`dark:`_sprawl}
§PAT:mode1_gen{
  1:scan(CSS,@theme,styles)→2:extract+count(colors,type,space,radius,shadows,bp)+merge_dupes(`#1a1a1a`≈`#1b1b1b`)→3:opt_3refs(visual-design-direction.md⇔browser∧user_ok)→4:propose(oklch_50-950,1_accent<80%_sat,status[success,warning,danger,info];semantic[canvas,surface,surface-muted,surface-elevated,border-subtle,border-strong,text-primary,text-muted,accent,accent-soft]∈light-dark();clamp()_type;8pt;1_--radius-sm/md/lg_concentric;bg_shadows)→5:DESIGN.md(rationale)→6:design-preview.html(0_deps,all_tokens,data-theme,filled_tabs,tonal_cards,btns,inputs,filled_controls,badges,<dialog>);
  out:{design-tokens.json:DTCG_2025($value,$type,Style_Dict_5_native_DTCG),tokens.css:color-scheme+light-dark(),DESIGN.md,design-preview.html};
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
