@REF:asset-frameworks
§R{
  parent:[`../SKILL.md`](../SKILL.md);
  read_only_audited_section;
  global_gates:{CWV(LCP≤2.5s,INP≤200ms,CLS≤0.1),WCAG_2.2_AA(SC_2.5.8_target≥24×24px,SC_2.4.11_focus_not_obscured,SC_3.2.6_consistent_help,SC_3.3.7_redundant_entry),EAA(EU/2019/882),EU_DSA/DFA_&_FTC_Sec5(¬dark_patterns,cancel_parity)}
}

§PAT:Page(home|LP|feat|blog){
  val≤5s:outcome_head∧¬jargon;
  head:specific+val+ad/intent_match;win:nums∨proof("Join 12,000+ teams");
  CTA:1_prim_ATF+action_val("Submit"→"Start Free Trial");repeat_sec_post_sections;
  hier:H1→H2→body+whitespace+real_prod_shots/interactive_demo>stock+big_benefit;
  trust:logos+testim+verified_reviews("Trusted by"_near_prim_CTA);
  obj:FAQ_accordion(BTF)+guarantees+transparent_pricing;
  fric:fast_LCP(preload_hero,¬render_blocking_3p)+hide_nav(1_purpose_LP)+fewer_exit_links;
  AB:{head,CTA_copy/contrast,hero_interactive_demo_vs_static,social_proof_pos}
}

§PAT:Pricing_Page{
  tiers:rule_of_3(Starter|Pro|Enterprise;¬2_binary_hesitation∧¬4+_paralysis);
  anchor:visually_emphasize_middle_target_tier("Most Popular"_badge+border_contrast);
  annual_toggle:frame_savings_in_abs_currency("Save $120/yr")≻raw_%_alone;
  mobile:stacked_vertical_cards+collapsible_features(≤8-10_visible_bullets)¬wide_horizontal_scroll_table(55-60%+_mobile_traffic);
  usage_or_hybrid:{
    model:hybrid(base_platform_fee+consumption_tiers)≻pure_opaque_metering_for_enterprise;
    calc:real_time_interactive_cost_calculator/slider_on_page(tokens|API_calls|contacts);
    trust:automated_in_app_usage_alerts(e.g._80%_threshold)⇒¬bill_shock
  };
  obj:transparent_seat/usage_defs+FAQ+security/SOC2_badges+clear_downgrade/cancel_terms;
  AB:{annual_default_vs_monthly,abs_$_vs_%_savings,calculator_placement,middle_tier_anchor}
}

§PAT:Form_And_Checkout(lead|contact|demo|quote|checkout){
  baymard_benchmarks:{avg_cart_aband:~70%,too_long_complex:17-26%_aband,forced_account:24%_aband,opt_guest_checkout:6-8_fields(¬12-15+)};
  lead_cost:3_flds=base|4-6→-10-25%|7+→-25-50%;
  guest_first:default_guest_checkout_prominently¬force_account_wall(offer_1_click/passkey_post_purchase);
  express_wallets:place_Apple_Pay|Google_Pay|Shop_Pay|Link_early(cart+top_of_checkout)∧still_optimize_native_guest_form;
  promo_code:collapse_coupon_field_behind_low_prominence_text_link¬open_promo_box(stops_code_hunting_aband);
  fields:{
    email:1_fld+autocomplete="email"+inputmode="email"+typo_check;
    name:1_"Full name"(split_only_if_shipping/pers_req)+autocomplete="name|shipping given-name";
    phone:opt_when_possible+auto_fmt+cc_pick+explicit_helper("Only used for delivery updates";39%_fail_to_explain);
    co:auto_suggest+post_enrich;
    opts:>5⇒searchable_combobox+visible_labels
  };
  validation:on_blur_inline_err(¬premature_mid_keystroke)+positive_green_valid_state+specific_fix+focus_1st_err+keep_user_data;
  layout:1_col(2_col_only_paired_short:city/zip);multi_step_if_>5_flds∨logical_sections+prog_bar+easy_1st+back+save+¬redundant_entry(WCAG_3.3.7);
  sub:action+benefit("Get My Free Quote"|"Complete Order")+hi_contrast+≥44px_touch;
  trust:privacy_note+sec_badge+delivery/response_ETA;
  mob:tap_target≥44px+right_inputmode/autocomplete+WebOTP+sticky_sub;
  kpi:{start_rate,completion_rate,fld_drop_off,err_rate,ttc,wallet_share}
}

§PAT:Popup_Modal{
  trig:{scroll:25-50%(blog),exit:desk(→close)|mob(back_scroll∨delay),delay:30-60s(¬<10s),click:user_init,behav:cart_aband|pricing|repeat};
  impl:native_<dialog>_or_[popover]+inert_bg(auto_ESC,focus_trap/return,SR_a11y)¬custom_div_overlay;
  ord:head>val>form/CTA>close;w:400-600px(desk)|full_btm_sheet∨ctr(mob);
  close:vis_X(≥24×24px_min,≥44px_mob)+"No thanks"¬disguised_close∨confirm_shaming;
  copy:benefit_head+subhead+spec_CTA+privacy;
  freq:1/sess;honor_dismiss:7-30d;
  comp:{GDPR/Consent_Mode_v2(PII),WCAG_2.2(SC_2.5.8_target,SC_2.4.11_focus_not_obscured),Google_¬intrusive_interstitials,EU_DSA/DFA(¬fake_countdowns)};
  kpi:{impr,conv,close_rate,ttc,bounce_delta}
}

§PAT:Signup_And_Auth{
  req:email/phone+auth;opt_name;defer(co,role,phone)→Day1_onboarding;
  auth_order:passkeys(WebAuthn/biometric)∨social_SSO_first→magic_link/email_pwd_second;
  steps:≤3→1_step;>3→multi+prog_bar;
  trust:"No credit card required"+privacy+sec_badge+social_proof;
  err:on_blur_inline+clear+keep_data;
  mob:≥44px_targets+autofill/conditional_passkey_UI+sticky_CTA;
  post:instant_entry+next_step_preview+defer_email_verification_until_needed
}

§PAT:Onboarding_And_Reverse_Trial{
  day1_seg:micro_survey(2-3_Qs:role,team_size,primary_goal)→route_to_tailored_checklist_for_Aha_moment;
  aha:1st_action_predicting_retention;1_goal/sess+defer_secondary;interactive_sandbox>static_linear_tour;
  chk:3-7_high_val_tasks(ordered_by_impact)+prog_bar+celebrate;
  empty:purpose+template/sample_preview+prim_CTA(create_1st);
  tour:≤5_steps+easy_dismiss+never_re_show_returning;
  reverse_trial:{
    when:long_TTV∨complex_workflows_requiring_Pro_features_to_grasp_value;
    flow:full_Pro_day1→non_intrusive_feature_banners+clear_downgrade_preview→graceful_auto_downgrade_to_Free(¬hard_lockout);
    follow_up:trigger_targeted_nudges_or_sales_outreach_on_high_Pro_usage_pre_downgrade
  };
  chan:welcome_email+in_app+timed_push(¬immediate);
  kpi:{activation_rate,TTV/tta,checklist_comp,trial_to_paid,D1/D7/D30_ret}
}

§PAT:Paywall_And_Cancel_Flows{
  trig:post_aha∨value_metric_limit(capacity,seats,exports,automation)¬gate_core_utility_on_arrival;
  head:benefit_1st("Unlock unlimited projects")¬price_1st;
  proof:paid_feature_preview∨before/after∨ROI_calc;
  cmp:key_diffs+mark_recommended;
  price:simple+yr/mo_toggle(abs_$_savings)+transparent_usage/per_seat;
  CTA:action+benefit("Upgrade to Pro – Get Unlimited");
  esc:"Maybe later"|"Continue with Free"+¬guilt_trip/confirm_shame;
  path:in_ctx+prefill+express_wallets+sec_badges;
  mob:full_sheet_ok+swipe_dismiss+≥44px_targets;
  freq:1-2/sess+cooldown_days;
  cancel_compliance:{FTC_Sec5_&_EU_DSA/DFA:click_to_cancel_parity(same_or_fewer_steps_as_signup),¬phone_only_wall,¬multi_step_retention_maze,¬hidden_toggle_defaults;ethical_save:1_clear_pause/downgrade_option_with_direct_confirm_cancel};
  kpi:{impr,CTR,upgrade_comp,ARPU,NRR,post_upg_churn,save_rate}
}

§ANTI{
  forced_account_checkout;open_coupon_box;premature_mid_typing_errors;unexplained_phone_req;4+_pricing_tiers_or_horizontal_mobile_tables;on_load_modal_or_<10s_popup;disguised_close_<24px;fake_scarcity_timers;roach_motel_cancel_flows;hard_lockout_before_aha
}
