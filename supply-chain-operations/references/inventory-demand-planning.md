@REF:inventory-demand-planning
§CFG{CTX_AND_SYSTEMS
  role:sr_demand_planner(40-200_stores,reg_DCs,300-800_SKUs∈{grocery,gen_merch,seasonal,promo});
  sys:{BlueYonder,Oracle_Cloud_SCP(Demantra_EOL),Kinaxis_Maestro(ex-RapidResponse,concurrent_AI_planning),ERP(SAP,Oracle),WMS(DC),POS(store),vendor_portals(PO)};
  stakeholders:{merch(assort/price),SC(wh_cap/transport),fin(inv_budget/GMROI)};
  obj:commercial_intent→POs∧min(stockout,excess,unsold_waste);
  flow:1:collect(POS_sellthrough,orders,ships,returns)→cleanse_outliers→2:method(ABC/XYZ,pattern)→3:apply(promo_lift,cannib,causal)→4:calc_SS(probabilistic/MEIO,d_var,LT_var,fill_rate)→5:gen_PO(MOQ/EOQ_round)→review→6:monitor(WMAPE,bias,TS)→adj_next_cycle
}
§PAT{FORECASTING_AND_METRICS
  MA(SMA,WMA,trailing):use(stable,low_var,recent_rel);4wk_SMA=staples;WMA(recent↑)=stable+slight_drift;¬seasonal(lags_trend_by_win/2);
  exp_smooth:{SES(α∈[0.1,0.3]):stationary+noise;Holt(DES):trend(up|down);Holt-Winters(TES):seasonal(52wk|12mo);α>0.3→chase_noise;α<0.1→slow_regime_resp;opt(α,β,γ)∈holdout_data(¬fit_data)};
  seasonal_decomp(STL,classical,X-13ARIMA-SEATS):isolate(trend,seasonal,resid);STL(Loess)=outlier_robust;use(YoY_shift_season∨pre_model_deseason∨promo_lift_on_clean_base);
  causal_reg:ext_drivers(price_elast,promo_flags,weather,comp,local_events);promo_flags={%off_depth,display,circular,cross_cat_promo};pitfall=overfit(sparse_promo)⇒Lasso|Ridge∧validate(out-of-time¬out-of-sample);
  ML(GBDT/NN,LightGBM/XGBoost):req(≥1000_SKUs×≥2yr_wkly,multi_ext_reg,ML_eng);+10-20%_WAPE_vs_simple(promo/intermittent);req(cont_monitor∧≥qtr_retrain_for_drift);
  probabilistic_fcst:model_full_demand_distribution(quantiles/ranges¬single_point)⇒captures_asymmetric_tail_risk(high_returns,EU_ESPR_unsold_waste_limits)∧feeds_service_level_SS_directly;
  metrics:{
    MAPE:breaks_low_vol(÷~0)⇒use_iff≥50u/wk;
    WMAPE:Σ|err|/Σactual(no_low_vol_skew,$-weighted_fin_metric);
    Bias:avg(signed_err);+bias→overstock;-bias→stockout;healthy<±5%;|bias|>10%⇒structural_issue(¬noise);
    TS:cum_err/MAD;|TS|>4⇒drift→reparam∨switch_method
  }
}
§PAT{SAFETY_STOCK_MEIO_AND_REORDER
  SS_basic:`SS = Z * σ_d * √(LT + RP)`(normal,stationary_only);
  SL:{A:95%(Z=1.65);crit/A+:99%(Z=2.33,stockout>>hold);C:90%(Z=1.28);95%→99%≈2×SS⇒quantify_inv_cost_Δ_first};
  SS_LT_var:`SS = Z * √(LT_avg * σ_d² + d_avg² * σ_LT²)`;CV_LT>0.3⇒SS+40-60%_vs_d_only;
  MEIO:multi_echelon_inventory_optimization_across_factory/DC/store_tiers(paired_with_probabilistic_fcst)⇒decouples_pooled_SS_vs_local_SS,cuts_overproduction_&_working_capital_vs_single_echelon_silos;
  SS_lumpy:normal_SS_fails⇒Croston|SBA(interval+size)+bootstrap_dist;
  SS_NPI:∅_σ_d⇒3-5_analogs(same_lifecycle)σ_d_proxy+(20-30%_buffer,wk1..8)→taper;
  IP:`IP = OnHand + OnOrder - Backorders - Committed`;¬reorder(OnHand_only)⇒double_order;
  min_max:stable+const_LT;Min=d_avg_LT+SS;Max=Min+EOQ;IP≤Min→order(Max-IP);¬auto_adapt;
  ROP_EOQ:`ROP = d_avg_LT + SS`;`EOQ = √(2DS/H)`(D=ann_d,S=order_$,H=hold_$/u/yr);round→case_pack|layer|pallet(e.g.847→case_24);
  periodic(R,S):review_qR(vendor_sched,e.g.Tue_ord/Thu_pick);`S = d_avg_(R+LT) + SS_(R+LT)`;
  vendor_tier_freq:{A(top10_spend):wkly;B(next20):biwkly;C(rest):monthly}
}
§PAT{PROMO_ABC_XYZ_AND_SEASONAL
  promo_clean_base:strip_promo_vol_from_hist;apply_multiplicative_promo_lift_layer;
  promo_lift:{1:YoY_promo_vs_non;2:cross_elast(depth,display,media);3:analog_cat_lift};typ_lift:{TPR:15-40%;TPR+disp+circ:80-200%;doorbuster/loss-lead:300-500%+};
  cannib:10-30%_lifted_vol(close_subs_same_cat_sim_price);ignore_cross_cat_unless_traffic_driver_shifts_basket;
  fwd_buy_dip:corr(shelf_life,depth)(e.g.30%off_12mo_pantry→2-4wk_dip;15%off_perish→~0);post_promo_dip=1-3wk,30-50%_inc_lift(conc_wk+1);¬fcst_dip⇒excess+MD;
  ABC(margin_contrib¬rev):{A:top20%SKUs→80%;B:next30%→15%;C:bot50%→5%};
  XYZ(CV_deseason_depromo):{X:<0.5;Y:0.5-1.0;Z:>1.0};
  matrix:{AX:auto+tight_SS;AZ:human_rev_qcycle;CX:auto+gen_R;CZ:disco∨MTO};
  seasonal_buy:commit_12-20wk_pre;init=60-70%_exp;OTB_reserve=30-40%(early_sellthrough_reord);
  seasonal_MD:start@mid_sellthrough<60%_plan;early_shallow(20-30%off)>late_deep(50-70%off);1wk_delay=-3-5pp_margin_rem_inv;
  seasonal_liq:hard_cutoff=2-3wk_pre_next_season→outlet|liq|donate(EU_apparel:comply_ESPR_no_destroy);¬hold_next_yr(dating+wh_cost)
}
§D{DECISION_RULES
  fcst_stable_high_¬seas⇒prim:WMA(4-8wk)|fb:SES|rev:WMAPE>25%×4wk;
  fcst_trending⇒prim:Holt_DES|fb:LinReg(26wk)|rev:|TS|>4;
  fcst_seasonal_rep⇒prim:Holt-Winters(mult=grow,add=stable)|fb:STL+SES(resid)|rev:SoS_corr<0.7;
  fcst_intermittent(>30%_0)⇒prim:Croston∨SBA|fb:bootstrap(intervals)|rev:Δmean_int>30%;
  fcst_promo_driven⇒prim:causal_reg(base+lift)|fb:analog_lift+base|rev:post_promo_dev>40%;
  fcst_NPI(0-12wk)⇒prim:analog_profile+lifecycle|fb:cat_avg(decay→actual)|rev:own_WMAPE<analog_WMAPE;
  fcst_event(weather,local)⇒prim:reg(ext_reg)|fb:manual_override(doc_rationale)|rev:corr<0.6∨err>30%×2_events;
  multi_tier_network∨high_return_vol⇒use(probabilistic_fcst+MEIO)¬single_point_local_SS;
  SS_SL:{AX⇒97.5%(Z=1.96);AY⇒95%(Z=1.65);AZ⇒92-95%(Z=1.41-1.65)+expedite;BX|BY⇒95%(Z=1.65);BZ⇒90%(Z=1.28);CX|CY⇒90-92%(Z=1.28-1.41);CZ⇒85%(Z=1.04,disco_cand)};
  promo_lift_seq:1:own_SKU_promo_hist(last3=50/30/20)→2:analog_lift(adj_price,brand_tier)→3:cat_avg×0.8+wider_SS→4:cross_promo(def:+0.15_halo)→5:post_promo_dip(40%_inc_lift,60/30/10_wk+1/2/3);
  MD_timing(mid_sellthrough):{≥80%⇒hold_price,cautious_reord_if_WOS<3;60-79%⇒20-25%off,¬reord;40-59%⇒30-40%off_imm,cancel_open_POs;<40%⇒50%+off,liq_chan,buying_postmortem};
  slow_mover_kill(eval_qtr):flag⇔(WOS>26∧last13wk_vel<0.5×first13wk∧∅_promo_8wk∧¬contract_oblig∧(sub_SKU∨cat_absorbs))→30%off×4wk→(¬moving⇒50%off∨liq)→hard_exit@wk8
}
§ANTI{EDGE_CASES_AND_TRAPS
  1_NPI_0_hist:analog(price,cat,brand,demo,¬just_type);init_buy=60%_analog;wkly_auto_replen;
  2_viral_spike(+500-2000%):¬chase(4-8wk_LT);sell_OH,allocate(anti-hoard),revise_base_iff_sustained≥4wk_post;
  3_LT_doubles:recalc_SS_imm;emerg_PO(Δ),partial_ships,2nd_suppliers;warn_merch(SL↓);
  4_unplanned_promo_cannib(comp|other_dept):daily_POS_break→manual_down_override→defer_inbound_POs;
  5_regime_change(reformul|pkg|comp):|TS|>4×2_periods→model_reselect;
  6_phantom_inv(WMS=200,phys=40):SL↓_despite_OK_OH→cycle_count_unexpected_stockouts;
  7_MOQ_conflict(EOQ=150,MOQ=500):consolidate_vendor_SKUs($)∨neg_MOQ∨accept_overage(iff_hold$<alt_supp);
  8_holiday_shift(Easter_wk13↔16):align_weeks_relative_to_holiday(¬calendar_wk);
  9_legacy_batch_silos:relying_on_EOL_Oracle_Demantra_or_static_point_fcst⇒misses_reverse_logistics_&_concurrent_signals
}
§CMD{COMMS_AND_TEMPLATES
  vendor_reord:transactional,PO_ref("PO #XXXX for delivery week of MM/DD per our agreed schedule.");
  vendor_LT_esc:firm,fact,impact("Lead time increased 14→22d over 8wk causing X stockouts; corrective plan needed by [date].");
  int_stockout:urgent,cust_impact_first("SKU X stocks out at 12 locations by Thu; lost sales $XXK; rec:[expedite/reallocate/sub].");
  MD_rec:data+margin,¬blame("sell-through pace requires price action to meet margin targets"¬"bought too much");
  promo_fcst:base+lift+dip+CI("Base 500u/wk; lift 180%(+900); post-dip -35%×2wk; CI ±25%.");
  NPI_fcst:auditable_assump("Analogs[list]→200u/wk(wk1-4)→120u/wk(wk8); price $X, 80 doors, no comp launch.")
}
§R{ESCALATION
  triggers:{
    A_stockout≤7d⇒alert(plan_mgr+cat_merch)≤4h;
    vendor_LT↑>25%⇒notify(SC_dir)+recalc_open_POs≤1bd;
    promo_miss>40%⇒debrief(merch+vendor)≤1wk_post;
    excess>26_WOS(A/B)⇒MD_rec(merch_VP)≤1wk;
    |bias|>10%×4wk⇒model_rev+reparam≤2wk;
    NPI_sellthrough<40%@4wk⇒assort_rev(merch)≤1wk;
    cat_SL<90%⇒RCA+corr_plan≤48h
  };
  chain:L1(Demand_Planner)→L2(Planning_Mgr,24h)→L3(Dir_SC_Plan,48h)→L4(VP_SC,72h+∨A_stockout@ent_cust)
}
§CHK{KPIS_AND_ARTIFACTS // track weekly, trend monthly
  WMAPE:<25%|red>35%;Bias:±5%|red>±10%×4+wk;in_stock_A:>97%|red<94%;in_stock_all:>95%|red<92%;
  WOS_agg:4-8wk|red>12∨<3;excess(>26wk):<5%_SKUs|red>10%;dead_stock(0_sales,13+wk):<2%_SKUs|red>5%;
  vendor_PO_fill:>95%|red<90%;promo_WMAPE:<35%|red>50%;
  artifacts:{SKU_seg_model,SL_policy,planner_override_audit_log,postmortems(promo_misses,vendor_delays,fcst_overrides)}
}
