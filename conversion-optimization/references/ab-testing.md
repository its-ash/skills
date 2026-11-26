@REF:ab-testing

§R{
  use_when:compare(A,B/C…)∧validate_pre_rollout∧measurable_metric(CTR|conv|rev)∧traffic_sufficient;
  principles:start_w_hypothesis;test_1_var;pre_calc_N(¬peek∧¬stop_early);primary_KPI→business_val+secondary+guardrails
}

§PAT:Design{
  hypothesis:`Because [observation], we believe [change] will cause [expected outcome] for [audience]. We'll know this is true when [metric].`;
  hyp_chk:{observation(data|insight),specific_change(1_var),expected_effect(dir+mag),audience,success_metric};
  types:{
    AB_split:{1_change,simple,traffic:low-mod},
    ABn:{multi_indep_variants,traffic:higher},
    MVT:{var_interactions,traffic:very_high},
    SplitURL:{major_redesign,diff_URLs,traffic:mod}
  };
  sample_size:{
    inputs:{baseline_conv,MDE,alpha:95%(p<0.05),power:80%};
    quick_ref(baseline→10%/20%/50%_lift):{1%:150k/39k/6k,3%:47k/12k/2k,5%:27k/7k/1.2k,10%:12k/3k/550};
    formula:`N = (Zα/2√[2p(1-p)] + Zβ√[p1(1-p1) + p2(1-p2)])² / (p1-p2)²`(p=pooled,p1=ctrl,p2=var);
    duration:`(N_per_variant)/(Daily_traffic*Baseline_rate)`;bounds:≥1-2_biz_wks∧≤4-6_wks(¬novelty);
    calc:{https://www.evanmiller.org/ab-testing/sample-size.html,https://www.optimizely.com/sample-size-calculator/}
  };
  metrics:{primary:1_KPI,secondary:{time_on_page,scroll_depth,funnel_steps},guardrails:{overall_rev,churn,support_tickets}};
  variants:{ctrl(A):unchanged,var(B+):1_bold_Δ∈{headline|copy,CTA(text|size|color|pos),img|hierarchy,layout|spacing,social_proof};doc:{change,reason,mockup}};
  traffic:{std:50/50∨equal(A/B/n),conservative:90/10∨80/20→equal_post_val,ramp:small%↑,sticky_user_assignment:required};
  impl:{
    client:{tools:{Optimizely,VWO,PostHog,JS},pros:fast∧no_backend,cons:flicker∧JS_dep},
    server:{tools:{LaunchDarkly,Split,middleware},pros:no_flicker∧backend,cons:dev_effort},
    flag:{tools:{LaunchDarkly,Split},note:true_AB⇔split_%_enabled}
  }
}

§CHK:PreLaunch{
  hypothesis_doc;primary_metric;N_calc;duration_est;variants_built_reviewed;tracking_verified;QA_all_variants;stakeholders_notified
}

§PAT:Run_And_Analyze{
  monitor:{errors,load_times,split_balance,log_ext_events(campaigns|holidays)};
  forbid:{peek_pre_N,edit_var_or_alloc_mid_test,add_diff_traffic_sources,early_stop_on_feel};
  peek_exception:sequential(Bayesian_monitoring)+predefined_stopping_rules;
  analysis:1:N_reached?→2:stat_sig(p<0.05∨Bayesian_CI∌0)→3:effect_size_vs_MDE∧biz_impact→4:secondary_align?→5:guardrails_intact?→6:segments(device|geo|new_vs_ret);
  matrix:{
    sig_win(primary)⇒deploy+update_docs,
    sig_lose⇒keep_ctrl+log_learnings,
    no_sig⇒larger_Δ∨more_traffic∨inconclusive,
    mixed(primary↑∧guardrail↓)⇒pause+investigate
  };
  record:{Name,ID,Dates,Owner,Hypothesis,Variants(A,B),Metrics(primary_%Δ+conf,secondary,guardrails),Decision(Winner|Loser|Inconclusive),Action(Deploy|Keep|Re-test),Learnings+Next_ideas}→searchable_repo
}

§ANTI{
  tiny_Δ⇒huge_N;multi_var⇒obscure_cause;early_stop⇒inflates_FP;mid_test_edit⇒invalid_data;ignore_guardrails⇒rev/UX_harm;stat_sig≠practical_sig
}

§REF{
  platforms:{Optimizely,VWO,Google_Optimize(legacy),PostHog,LaunchDarkly,Split.io};
  refs:{Cohen:"Statistical Power Analysis for the Behavioral Sciences",Bayesian_AB_guides};
  rel:{[`conversion-optimization`](../SKILL.md),[`ux-research`](../../ux-research/SKILL.md)}
}
