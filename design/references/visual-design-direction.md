@REF:visual-design-direction
§D{
  parent:[design](../SKILL.md)(§0-§10_in_force);
  use⇔brief∈{"distinct visual identity","modern premium look","not generic",Awwwards,FWA,Linear,Stripe,Vercel,Raycast}∨public_site|landing|portfolio|marketing|opinionated_UI
}

§FLOW{
  1:clarify(industry,user,purpose)→1line_read(§0)+3_dials(§1);
  2:study_3-5_refs(leaders+niche)→log(font1,font2,palette[oklch/hex],DNA,1_sig_interaction);
  3:tokens(oklch()+light-dark():canvas,surface,surface-muted,surface-elevated,border-subtle,border-strong,1_gray,1_accent[sat<80%],¬#000,¬#fff;type+clamp();8px_unit,concentric_r[outer=inner+pad],bg_tinted_shadows);
  4:pick_1_DNA(§LAY);
  5:plan(Color[oklch+light-dark],Type[fonts+roles],Layout[1sent+ASCII],Principles[3-4]);
  6:validate_vs_brief+§ANTI→log_cliché_fixes;
  7:impl(global_tokens[CSS_vars|TW4_@theme]→1_component_at_a_time[full-w_sq_header,hero,filled_seg_tabs,tonal_cards_no_1sided_border],keep_func);
  8:critique(breakpoints,vs_refs,prune_decor,1_focal/viewport,mute_rest)
}

§TYPO{
  sans:1∈{Geist,Satoshi,"Cabinet Grotesk","Plus Jakarta Sans",Outfit}+mono∈{"Geist Mono","JetBrains Mono"}(meta/code/KPI);
  serif:∈{Newsreader,"Source Serif 4"}(if_brand_justifies);BAN:{Fraunces,"Instrument Serif"};
  ```css
  h1{font-size:clamp(2.25rem,1.5rem+3.5vw,4.5rem);text-wrap:balance}
  p{font-size:clamp(1rem,0.95rem+0.25vw,1.125rem);text-wrap:pretty}
  ```
  metrics:tracking=-0.03em(disp);leading=1.5-1.6(body);measure=45-75ch(max-inline-size:65ch);tabular-nums;text-box:trim-both cap alphabetic;
  ¬:{all_caps_eyebrows_every_h,uniform_size_hier,faux_bold/italic}
}

§COL{
  neutral_hierarchy_first;color_only⇒{hierarchy,state,action};
  oklch()+color-scheme:light dark+light-dark();
  canvas:light=oklch(98.5% 0.004 250);dark=oklch(13.5% 0.01 250);¬{#fff,#000};
  accent:1(sat<80%);states←oklch(from...)∨color-mix();
  ¬:{purple_blue_grad,neon_on_dark,SaaS_kit_gray_white_accent}
}

§LAY{
  DNA(pick_1)∈{"Index Manuscript","Sticky Horizontal Diorama","Two-Pane Permanent Split","Slide Sequence","Staged Object on a Plinth","Pinned Narrative (Scrollytelling)","Bento Grid","Sidebar + Column","Chapter Gates","Ledger / Registry","Collage / Grid-Breaker","Single Object, No Chrome","Product UI Slate","Dashboard Tile Grid","Conversation Timeline"};
  marketing:break_grids(full-w+narrow_cols),gap≥6-8rem;UI:8pt_rhythm;measure:45-75ch;
  ¬:{sym_3card_rows,uniform_card_walls,centered_only@VARIANCE>4}
}

§MOT{
  1_orchestrated_reveal/page;animate_only∈{user_action(expand,confirm,switch),focal_highlight};
  150-250ms;--ease-out:cubic-bezier(0.23,1,0.32,1);exit<enter;
  ¬:{scroll_fade_every_section,identical_hover_scales,transition:all,spinners_over_skeletons}
}

§3D{1_purposeful_scene(Three.js|R3F|Spline)_representing_product;¬primitive_boxes/cylinders;atmosphere_only_if_2D_hero;lazy_init+offscreen_pause}

§ANTI{
  ¬border-l-4|t-4_on∈{cards,tiles,callouts,alerts,selected};
  ¬underline/bare_tabs(use_filled_rounded_tabs_in_muted_track);
  ¬cards_in_cards(use_inset_muted|hairlines);
  ¬cream+terracotta/brass/oxblood;¬near_black+acid_green_neon;
  ¬purple_blue_grad|glowing_orbs|neon|gradient_text_h;
  ¬SaaS_card_kit(identical_cards,muddy_grey_shadows,grad_washes);
  ¬all_caps_eyebrows("01 / FEATURES");
  ¬uniform_Inter/Poppins/Montserrat;¬{Fraunces,"Instrument Serif"};
  ¬hero→3col→testimonial→CTA→footer;
  ¬blobs/geom_bg|div_fake_screenshots|pulsing_status_dots
}

§CHK{
  bold:1_hero/viewport,mute_rest;
  craft:filled_tabs,tonal_cards+1px_full_hairline,0_1sided_borders,concentric_r;
  resp:375px,768px,1024px,1440px;
  a11y:WCAG2.2_AA≥4.5:1,:focus-visible,prefers-reduced-motion_crossfade;
  perf:AVIF>WebP,srcset,fetchpriority="high"(LCP),lazy_below_fold;
  hygiene:oklch()+light-dark(),flat_selectors,TW4_@theme;
  iterate:inspect_rendered/major_Δ∧compare_refs
}

§TPL{
  ```css
  :root{color-scheme:light dark;--color-canvas:light-dark(oklch(98.5% 0.004 245),oklch(13% 0.01 245));--color-surface:light-dark(oklch(99.5% 0.002 245),oklch(17% 0.01 245));--color-surface-muted:light-dark(oklch(95.5% 0.006 245),oklch(21% 0.012 245));--color-border-subtle:light-dark(oklch(18% 0.015 245/.09),oklch(94% 0.006 245/.1));--color-text:light-dark(oklch(18% 0.015 245),oklch(94% 0.006 245));--color-text-muted:light-dark(oklch(46% 0.015 245),oklch(68% 0.01 245));--color-accent:light-dark(oklch(55% 0.17 160),oklch(68% 0.15 160));--color-accent-soft:color-mix(in oklch,var(--color-accent) 12%,transparent);--font-display:"Satoshi",system-ui,sans-serif;--font-body:"Geist",system-ui,sans-serif;--font-mono:"JetBrains Mono",ui-monospace,monospace;--radius-control:.5rem;--radius-track:.75rem;--radius-card:1rem;--shadow-card:0 1px 2px oklch(15% 0.01 245/.06),0 8px 24px oklch(15% 0.01 245/.04)}
  ```
  note:Two-Pane_Permanent_Split+<250ms_ease-out+@starting-style;replace_vals_from_research
}

§UI{
  scope:repeat_use_product_UI(apps,tools,dashboards);parent_§0-§10_apply;ops=dense+quiet+scannable(¬landing_comp);
  pre:{1:Purpose,2:Audience(repeat+first_scan),3:Tone∈{utilitarian,editorial,industrial,technical,calm,dense,playful},4:Memorable_detail(1),5:Constraints(fw,a11y,perf,resp,DS)};
  evidence:log(surface,job,primary_action,hierarchy,viewports,ref_obs/choice;checkable;palette≠evidence);
  states(log_trigger+feedback+safe_next;N/A⇒reason;untestable⇒"untested",¬"N/A"):{
    Loading:layout_skeleton+progress,cancel_if_supported;
    Empty:explain_missing+next_action;
    Error:specific_fail+recovery;
    Partial:show_avail+mark_unavail;
    Success:confirm+next|undo;
    Permission:explain_boundary+request|return
  };
  build:{1st_screen=usable(¬marketing);reuse_project(comps,tokens,icons,routing)_first;real/gen_assets;contextual_type(¬hero_oversize);oklch()+light-dark()_vars;tabular-nums+stable_dims(no_jump);wrap/resize_long_labels(¬overflow)};
  anti:{cards_in_cards,1sided_border(border-l-4|t-4),underline_tabs,hidden_workflow,dep_for_flourish,prose_explaining_controls,motion_hiding_latency};
  finish_gate(src_only=FAIL):{inspect_rendered@all_contract_viewports;verify(kb,focus,labels,contrast,reduced_motion,touch_targets,narrow+wide_long_txt,all_states+partial);keep_screenshots/test_artifacts+log;fix→reverify;report_untested+limits(¬fabricate)}
}
