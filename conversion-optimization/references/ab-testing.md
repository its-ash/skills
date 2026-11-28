@REF:ab-testing

§R{
  parent:[`../SKILL.md`](../SKILL.md);
  use_when:compare(A,B/C…)∧validate_pre_rollout∧measurable_metric(CTR|conv|rev)∧traffic_sufficient;
  principles:start_w_hypothesis;isolate_1_var_per_test;SRM_gate(χ²_p<0.001)≺read_metrics;CUPED_for_variance_reduction;mSPRT_sequential∨fixed_N(¬unadjusted_peek);1_primary_KPI+secondary+guardrails(incl_CWV_RUM)
}

§D{
  data_in_cloud_warehouse(Snowflake|BigQuery|Databricks|Redshift)⇒warehouse_native(GrowthBook|Datadog_Eppo)¬siloed_3p_metric_redef;
  all_in_one_product_stack⇒PostHog∨Amplitude(incl_Statsig)∨LaunchDarkly∨Harness_FME¬legacy_Google_Optimize(sunset_2023);
  web_UI_experiment⇒Edge_Worker(Cloudflare|Vercel|Fastly|Lambda@Edge)∨SSR_flag¬sync_client_JS+body_opacity0_anti_flicker;
  client_JS_unavoidable⇒hide_only_target_container+CSS_containment+monitor_RUM(LCP,INP)_by_variant¬hide_full_body;
  continuous_monitoring_needed⇒sequential(mSPRT|Group_Sequential|always_valid_p)∨Bayesian_with_predefined_stop¬daily_peeking_on_fixed_horizon;
  multi_metric_or_multi_variant⇒Benjamini-Hochberg(FDR_control)¬uncorrected_p<0.05∨over_strict_Bonferroni_killing_power;
  high_variance_metrics⇒CUPED(pre_experiment_covariates)¬oversize_N_or_extend_months;
  SRM_detected(χ²_p<0.001)⇒halt+invalidate+debug(hashing,bots,consent_gate,redirect_drop)¬interpret_or_ship;
  EEA/UK_consent_loss⇒Consent_Mode_v2(default_denied+Advanced_modeling)+SGTM(1p_subdomain)+reconcile_backend_DB¬client_GA4_only
}

§PAT:Design{
  hypothesis:`Because [observation], we believe [change] will cause [expected outcome] for [audience]. We'll know this is true when [metric].`;
  hyp_chk:{observation(data|insight),specific_change(1_var),expected_effect(dir+mag),audience,success_metric};
  types:{
    AB_split:{1_change,simple,traffic:low-mod},
    ABn:{multi_indep_variants,apply_FDR_correction,traffic:higher},
    MVT:{var_interactions,traffic:very_high},
    SplitURL:{major_redesign,diff_URLs,edge_rewrite_preferred,traffic:mod},
    Switchback_or_Cluster:{network_effects|marketplace_interference,time/geo_clusters}
  };
  sample_size:{
    inputs:{baseline_conv,MDE,alpha:95%(p<0.05),power:80%};
    quick_ref(N_visitors_per_variant@baseline→10%/20%/50%_rel_lift):{1%:150k/39k/6k,3%:47k/12k/2k,5%:27k/7k/1.2k,10%:12k/3k/550};
    formula:`N = (Zα/2√[2p(1-p)] + Zβ√[p1(1-p1) + p2(1-p2)])² / (p1-p2)²`(p=pooled,p1=ctrl,p2=var;CUPED_cuts_N_up_to_50%);
    duration:`(N_per_variant * num_variants) / daily_eligible_traffic`(≡`N_per_variant/(daily_eligible_traffic*variant_alloc)`);
    bounds:≥1-2_full_biz_wks(weekday_cycles)∧≤4-6_wks(¬cookie_churn∨novelty_decay);
    calc:{https://www.evanmiller.org/ab-testing/sample-size.html,https://www.optimizely.com/sample-size-calculator/}
  };
  metrics:{
    primary:1_OEC_or_KPI(SQL_source_of_truth);
    secondary:{scroll_depth,funnel_steps,time_to_convert,AOV};
    guardrails:{rev_per_user,churn,support_tickets,err_rate,RUM_CWV(LCP≤2.5s,INP≤200ms,CLS≤0.1)}
  };
  variants:{ctrl(A):unchanged,var(B+):1_bold_Δ∈{headline|copy,CTA,pricing_frame,layout|hierarchy,flow_steps,social_proof};doc:{change,reason,mockup}};
  traffic:{std:50/50∨equal(A/B/n),conservative:90/10∨80/20→equal_post_smoke,ramp:small%↑,deterministic_hash_bucketing+sticky_assignment:required}
}

§PAT:Delivery_And_Privacy{
  edge:{tools:{Cloudflare_Workers,Vercel_Edge,Fastly_Compute,Lambda@Edge},flow:read/set_1p_cookie→rewrite_HTML_in_memory→stream,CWV:zero_flicker∧LCP/INP_intact};
  server_flag:{tools:{GrowthBook,PostHog,LaunchDarkly,Harness_FME,Amplitude_Statsig,Datadog_Eppo},pros:backend+SSR+no_flicker,cons:eng_integration};
  client_fallback:{tools:{Optimizely,VWO,PostHog},mitigate:async_load+target_container_hide_only+CSS_contain+variant_RUM_audit};
  consent_v2:{params:{ad_storage,analytics_storage,ad_user_data,ad_personalization},EEA_default:denied_pre_CMP,mode:Advanced_cookieless_pings_for_modeling};
  sgtm:{host:1p_subdomain(metrics.domain.com),benefits:ITP_resilience+PII_hash/strip+consent_aware_forwarding+Enhanced_Conversions};
  attribution_audit:segment_by_consent_state∧validate_exp_conversions_vs_backend_orders/warehouse
}

§CHK:PreLaunch{
  hypothesis_doc;primary_KPI+guardrails(incl_CWV);N_calc+CUPED_plan+duration_est;SRM_alert_armed(p<0.001);variants_QA_all_devices;deterministic_sticky_bucketing;consent_gate_verified(¬bucket_skew);tracking_end_to_end;stakeholders_notified
}

§PAT:Run_And_Analyze{
  monitor:{SRM_chi_sq(χ²=Σ(O-E)²/E,alert_p<0.001),err_rate,RUM_LCP/INP_by_variant,log_ext_events(campaigns|holidays|outages)};
  forbid:{unadjusted_peek_pre_N,edit_var_or_alloc_mid_test,mix_unbalanced_traffic_sources,early_stop_on_feel};
  analysis_order:1:SRM_pass(p≥0.001)?→2:N_or_seq_boundary_reached?→3:stat_sig(p<0.05|mSPRT|Bayesian_CI∌0;CUPED_adj)→4:FDR_adj(Benjamini-Hochberg)_for_multi_metrics→5:effect_vs_MDE∧biz_impact→6:guardrails_intact(rev,churn,CWV)?→7:segments(device|geo|consent|new_vs_ret);
  matrix:{
    SRM_fail⇒halt+discard+fix_instrumentation,
    sig_win(primary∧guardrails_ok)⇒rollout+holdout_check_if_major+update_docs,
    sig_lose⇒keep_ctrl+log_learnings,
    no_sig⇒bolder_Δ∨CUPED/more_traffic∨inconclusive,
    mixed(primary↑∧guardrail↓)⇒pause+investigate_tradeoff
  };
  record:{Name,ID,Dates,Owner,Hypothesis,Variants,SRM_p,Stats_Method(Fixed|mSPRT|Bayesian+CUPED),Metrics(primary_%Δ+CI,secondary,guardrails,CWV),Decision,Action,Learnings+Next_ideas}→searchable_repo
}

§ANTI{
  skip_SRM⇒ship_broken_assignment;body_anti_flicker⇒destroys_LCP/INP;tiny_Δ⇒huge_N;multi_var_no_FDR⇒inflated_FP;unadjusted_peek⇒false_wins;mid_test_alloc_change⇒Simpson_paradox;ignore_CWV_guardrail⇒SEO/rev_loss;client_GA4_without_consent_audit⇒modeled_bias;stat_sig≠practical_sig
}

§REF{
  platforms:{
    warehouse_native:{GrowthBook(OSS/SQL),Datadog_Eppo(acq_2025)},
    saas_all_in_one:{PostHog,Amplitude_Statsig(Statsig_acq_OpenAI_2025→Amplitude_2026),LaunchDarkly,Harness_FME(Split.io_acq_2024),Optimizely,VWO},
    retired:{Google_Optimize(sunset_2023-09-30)}
  };
  stats_refs:{Deng_CUPED(Microsoft),Fabijan_SRM(Microsoft),Johari_mSPRT,Benjamini-Hochberg_FDR,Cohen_Power};
  rel:{[`conversion-optimization`](../SKILL.md),[`ux-research`](../../ux-research/SKILL.md),[`web-performance`](../../web-quality-audit/references/web-performance.md)}
}
