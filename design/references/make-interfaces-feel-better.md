@REF:make-interfaces-feel-better
§REL{parent:[`design`](../SKILL.md)(wins_on_conflict;§4.4,§4.5,§7,§9);siblings:[`design-system`](design-system.md)[audit_consistency_first],[`motion-react`](motion-react.md)[when_CSS_insufficient]}
§USE{UI(off|flat|generic|cramped|jumpy|unfinished);build(controls|cards|lists|dashboards|nav|forms|toolbars);states(hover|active|focus|enter|exit|loading|empty);review(before/after_recs)}
§R{
  concentric_radius:`outer_radius = inner_radius + padding`∈single_radius_scale(parent_§4.4);large_pad⇒separate_surfaces;
  optical_align:visual≠geometric_center(icon_btns,play_triangles,arrows,stars,asymmetric)⇒fix_SVG_first⊕adjust_margin/pad(1-2px);
  shadows_borders:borders→separation+focus_rings;layered_subtle_transparent_bg_tinted_shadows(parent_§4.4)→depth(card,btn,dropdown,popover);selection→parent_§7(¬one_side_border);
  text_wrap:headings/short_titles⇒`text-wrap:balance`;short_med_body/captions/desc/li⇒`text-wrap:pretty`;¬(long_prose|code|pre);
  tabular_nums:counters/timers/prices/tables/updating_nums⇒`font-variant-numeric:tabular-nums`;
  font_smooth:macOS_root_if_unset→`html{-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale}`;
  img_outline:neutral_alpha(¬brand_tint)→`img{outline:1px solid light-dark(rgb(0 0 0 / 0.1),rgb(255 255 255 / 0.1));outline-offset:-1px}`;
  motion:interactive⇒CSS_transitions(retargetable);keyframes⇒1shot_entrance/loading_only;enter=`@starting-style`+opacity+small_translateY+opt_blur;exit=shorter+quieter(~150ms);press=parent_§4.5,§7(allow_disable);icon_swap=crossfade(opacity,scale,blur;¬instant);
  transition_scope:¬`transition:all`→`transition-property:transform,background-color,box-shadow;transition-duration:150ms;transition-timing-function:var(--ease-out)`;`will-change`⇔first_frame_stutter(transform|opacity|filter)∧¬`will-change:all`;
  hit_area:≥24x24px(WCAG_2.2)∧≥44x44px_touch(parent_§9);small_icon⇒`.icon-btn{position:relative}.icon-btn::after{content:"";position:absolute;inset:-10px}`(¬overlap)
}
§OUT{polish_pass:before/after_rows(Principle|Before|After)+file_paths+props_if_unclear;omit_unchanged}
§CHK{concentric_radii;optical_icons;border_vs_shadow;clean_wrap;tabular_nums;neutral_img_outlines;distinct_interruptible_enter/exit;tactile_active;¬all_transitions/will_change;usable_hit_areas}
