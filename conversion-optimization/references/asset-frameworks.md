@REF:asset-frameworks
§R{parent:[`../SKILL.md`](../SKILL.md);read_only_audited_section}

§PAT:Page(home|LP|pricing|feat|blog){
  val≤5s:outcome_head∧¬jargon;
  head:specific+val+ad_match;win:nums∨proof("Join 12 000+ teams");
  CTA:1_prim_ATF+val("Submit"→"Start Free Trial");repeat_sec_post_sections;
  hier:H1→H2→body+space+prod_shots>stock+big_benefit;
  trust:logos+testim+reviews("Trusted by"_above_prim_CTA);
  obj:FAQ_accordion(BTF)+guarantees+pricing_clarity;
  fric:cut_weight+hide_nav(1_purpose_LP)+fewer_links;
  AB:{head,CTA_color,hero_img_vs_vid,"Most Popular"_badge}
}

§PAT:Form(lead|contact|demo|quote|survey|checkout){
  cost:3=base|4-6→-10-25%|7+→-25-50%;
  req:email(∨phone)+pw(signup)+opt_name;
  email:1_fld+inline_val+typo+mob_email_kbd;
  name:1_"Full name"(split_only_pers);
  phone:opt+auto_fmt+cc_pick;
  co:auto_suggest+post_enrich;
  opts:>5⇒searchable+vis_labels;
  layout:1_col(2_col_paired_short:first/last);
  multi:>5_flds∨sections⇒prog_bar+easy_1st+back+save;
  err:inline+spec+focus_1st+keep_data;
  sub:act+benefit("Get My Free Quote")+hi_contrast+≥44px;
  trust:privacy+sec_badge+resp_time;
  mob:big_targets+right_kbds+sticky_sub;
  kpi:{start,comp,fld_drop,err,ttc}
}

§PAT:Popup_Modal{
  trig:{scroll:25-50%(blog),exit:desk(→close)|mob(back_scroll∨delay),delay:30-60s(¬<10s),click:user_init,behav:cart_aband|pricing|repeat};
  ord:head>val>form/CTA>close;w:400-600px(desk)|full_btm∨ctr(mob);
  close:vis_X+"No thanks";
  copy:benefit_head+subhead+spec_CTA+privacy;
  freq:1/sess;dismiss:7-30d;
  comp:GDPR(PII)+kbd/SR_a11y;
  kpi:{impr,conv,close_rate,ttc}
}

§PAT:Signup{
  req:email/phone+pw;opt_name;defer(co,role,phone)→onboard;
  social:first(>email);
  steps:≤3→1_step;>3→multi+prog;
  trust:"No credit card required"+privacy+sec_badge+testim;
  err:inline+clear+keep_data;
  mob:big_targets+autofill+social+sticky_CTA;
  post:inst_conf+next_prev+defer_email_ver
}

§PAT:Onboarding{
  aha:1st_act_pred_ret;1_goal/sess+defer_sec;interactive>static;
  chk:3-7_hi_val(by_impact)+prog_bar+celebrate;
  empty:purpose+prev+prim_CTA(create_1st);
  tour:≤5_steps+dismiss+hide_ret;
  chan:welcome_email+in_app+timed_push(¬immed);
  kpi:{act_rate,tta,comp,D1/D7/D30_ret}
}

§PAT:Paywall{
  trig:post_aha∨usage_lim(post_val_only);
  head:benefit_1st("Unlock unlimited projects")¬price_1st;
  proof:paid_prev∨before/after∨ROI;
  cmp:key_diffs+mark_rec;
  price:simple+yr/mo_toggle+per_seat;
  CTA:act+benefit("Upgrade to Pro – Get Unlimited");
  esc:"Maybe later"|"Continue with Free"+¬guilt;
  path:in_ctx+prefill+few_steps+sec_badges;
  mob:full_ok+swipe_dismiss+big_targets;
  freq:1-2/sess+cooldown_days;
  kpi:{impr,CTR,upg_comp,ARPU,post_upg_churn}
}
