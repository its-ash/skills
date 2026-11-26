@REF:production-scheduling

§CTX{
  scope:discrete∧batch_mfg(lines:3-8,headcount:50-300_direct/shift,WC:{machining,assembly,finishing,packaging});
  sys:{ERP:{SAP_PP,Oracle_Mfg,Epicor},FCS/APS:{Preactor,PlanetTogether,Opcenter_APS},MES,CMMS};
  stakeholders:{prod_mgmt:targets+headcount,planning:MRP_WOs,quality:release_gate,maint:equip_avail};
  goal:WOs(due_dates,routings,BOMs)→minute_exec_seq⇒max(constraint_throughput)∧meet(OTD,labor_rules,QA)
}

§TRIG{
  WC_contention ∨ disruption∈{breakdown,shortage,absenteeism} ∨ CO_vs_campaign_tradeoff ∨ hot_order_slot(¬churn) ∨ shift_bottleneck_Δ→drum_reassign
}

§PROC[6_step]{
  1:ID_constraint(OEE,cap_util);
  2:classify(demand)∈{past_due,constraint_feeding,remaining};
  3:sequence(dispatch∈{EDD,SPT,setup_aware_EDD}|mix);
  4:opt_CO(setup_matrix→nearest_neighbor→2_opt);
  5:lock(stabilization_window:24-48h);
  6:on_disruption⇒reseq(unlocked_only)→publish(MES)
}

§EX{
  breakdown:L2_CNC_down(4h)⇒eval(reroute→L3_alt_routing ⊕ wait)→reseq_queue⇒min(Σlateness);
  campaign_vs_mixed:15_jobs×4_fam(CO=45m)⇒calc_crossover(CO_cost,carrying_cost);
  hot_order:rush(LT=2d)∈full_wk⇒eval_slack→absorb(1_shift_delay|¬miss_due)→slot(∉frozen_window)
}

§FUND{
  sched_dir:{
    backward:due_date→latest_start[default:preserve_flex∧min(WIP)];
    forward:mat_avail→earliest_done(use⇔backward.latest_start<now⇒expedite)
  };
  cap:{MRP:infinite_cap("what")⇒¬executable; FCS:finite_cap(machines,shifts,PM_win,tooling)("when")};
  DBR_TOC:{
    drum:=argmax(load_h/avail_h)(>85%);
    buffer:=time_buffer(¬inv)⇒protect(drum_starvation);
    rope:=release_rate≤drum_rate;
    rule:subordinate(∀non_drum→drum); 1m_lost@drum=1m_lost@plant; 1m_lost@non_drum=0⇔absorbed(buffer)
  };
  JIT_heijunka:mix(A:B:C=3:2:1/shift)⇒A-B-A-C-A-B(¬AAA-BB-C)⇒smooth_upstream∧↓safety_stock∧¬end_shift_crunch;
  MRP_fail⇔{queue_dep_LT,shared_WC_contention,seq_dep_setup,yield_loss}⇒scheduler_compensates
}

§SMED{
  ext:=run_online; int:=machine_stopped;
  ph1:doc+classify(int|ext);
  ph2:convert(int→ext:pre_stage_tools,pre_heat_moulds,pre_mix);
  ph3:streamline(int:quick_clamps,std_die_height,color_conn);
  ph4:elim_adjust(poka_yoke,first_piece_jigs);
  yield:ph1+ph2⇒40-60%_CO_cut;
  seq_rules:{light→dark(5m_flush vs 30m_purge),small→large,simple→complex}→setup_matrix;
  campaign_vs_mixed:{
    CO>60m∧CO_cost>$500(scrap+lost_out)⇒campaign(↓CO,↑WIP/LT);
    CO<15m∨short_LT_profile⇒mixed_model(↓WIP/LT,↑CO);
    crossover⇔marginal_CO_cost=marginal_carrying_cost/unit_cycle_stock
  }
}

§DBR{
  true_constraint:WIP_pileup≠drum(causes:{upstream_batch_dump,shared_res[crane,forklift,inspector],starve_rule});
  test:argmax(req_h/avail_h)∧(+1h_cap⇒+plant_output);
  buffer_mgmt:{
    size≈0.50×constraint_prod_LT;
    green(<33%_used)⇒OK;
    yellow(33-67%)⇒expedite(late_upstream);
    red(>67%)⇒mgmt_alert+upstream_OT;
    persistent_yellow⇒upstream_reliability_decay
  };
  subordination:non_drum@100%∧drum@85%⇒excess_WIP∧Δthroughput=0⇒schedule_idle@non_drum;
  shift_bottleneck:mix/equip/staff_Δ(e.g.day_high_setup vs night_long_run)⇒weekly_util_by_mix→shift_drum_logic
}

§DISRUPT{
  breakdown:est_repair(maint)→if(drum)⇒calc($/h_loss)+contingency{OT_alt_equip,subcon,reseq(max_margin)} else check_buf(green⇒noop,yellow|red⇒expedite_alt_routing);
  shortage:{sub_mat,alt_BOM,partial_build/kit,escalate_purchasing,pull_fwd(non_short_jobs⇒keep_drum_running)};
  QA_hold:held_inv=invisible⇒re_run_sched(excl_held)→alt_src{safety_stock,other_WO_WIP,expedite_repl};
  absenteeism:cross_train_matrix→if(drum)⇒best_cert_backup else if(¬buf_absorbs)⇒pull_backup;
  reseq_prio:1:drum_uptime>2:cust_tier∧penalty>3:min(CO_cost)>4:level_labor; SLA:comm≤30m∧lock≥4h
}

§LAB{
  shifts:{3x8:24/5|24/7, 2x12:rotating(↑err_h10-12⇒¬first_piece_inspect∧¬complex_CO∈last_2h), 4x10:day_only};
  skill_matrix:op×WC×cert∈{trainee,qualified,expert}⇒hard_FCS_constraint;
  cross_train_ROI:drum=$5k/h∧absent=8%⇒2_vs_4_ops⇒Δexpected_loss>$200K/yr;
  union_OT:{seniority_OT,rest_8-10h_between_shifts,dept_transfer_limits}∈hard_constraints(¬violate)
}

§OEE{
  OEE=Avail×Perf×Qual;
  Avail=(PlannedProdTime−Downtime)/PlannedProdTime;
  Perf=(IdealCycleTime×TotalPieces)/OperatingTime;
  Qual=GoodPieces/TotalPieces;
  bench:{world_class≥85%,typical_discrete:55-65%};
  TEEP:all_calendar_time(cross_plant_cmp,CapEx_justify);
  losses:{
    avail:breakdowns/unplanned→PM+PdM(vibration,thermal)+TPM_daily(target:<5%_sched);
    perf:speed/micro_stops(100→85pph=15%_loss;causes:{feed,worn_tooling,sensor_false_trig,op_hesit})→track_actual_vs_std_cycle;
    qual:scrap/rework(drum_FPY<95%⇒↓cap;+2%_yield@drum=+2%_cap_exp)
  }
}

§ERP{
  flow:SO/forecast→MPS→MRP(planned_orders)→scheduler(prod_orders+seq)→MES→actuals(confirm,scrap,labor)→ERP;
  WO:{routing(ops,WCs,setup,run),BOM,due_date,op_dep(op20_after_op10)};
  adherence:MES_actual_vs_sched(healthy:>90%_start∈±1h); persistent_gap⇒bad_params(setup,run,yield)∨non_compliance;
  rolling_replan:every_shift(compare_actual→update→reseq→publish)⇒prevent(sched_reality_divergence)
}

§DEC{
  job_priority:[
    1:past_due∨will_miss⇒order_by_penalty(contractual>reputational>internal_KPI);
    2:drum_feeding∧buf∈{yellow,red};
    3:dispatch(high_var/short_run⇒EDD[min_max_lateness], long_run/few⇒SPT[min_avg_flow+WIP], mixed+seq_CO⇒setup_aware_EDD[swap_adj⇔save>30m∧¬miss_due]);
    4:tie_break(cust_tier>margin)
  ];
  CO_opt:[
    1:setup_matrix(min,cost=labor+scrap+lost_out);
    2:hard_prohibit(allergen,hazmat);
    3:nearest_neighbor_base;
    4:2_opt_adj_swaps(keep⇔↓CO∧¬miss_due);
    5:validate_due(due_date>CO_opt)
  ];
  disrupt_reseq:[
    1:impact_win+is_drum;
    2:freeze(in_process∨start≤2h);
    3:reseq(unfrozen);
    4:publish≤30m;
    5:lock≥4h(∨next_shift)
  ];
  bottleneck_ID:[
    1:util_reports(2wk_trailing,by_shift,¬avg);
    2:rank(load_h/avail_h);
    3:causal(+1h⇒+output∧downstream_starved);
    4:shift/wk_mix_Δ⇒sched_drum_per_shift;
    5:excl_artificial(upstream_batch_dump⇒fix_release_rate)
  ]
}

§EDGE{
  1:mid_shift_drum_shift(e.g.06:00_machining→10:00_assembly)⇒RT_util_mon+intra_shift_reseq_auth;
  2:cert_op_absent_reg_proc(FDA_coating)⇒cross_train_matrix⊕OT_day_cert⊕shut_reg+reroute_non_reg;
  3:competing_T1_OEM_rush⇒quantify_tradeoff(penalty,strategic)→mgmt_decides;
  4:MRP_phantom_demand(BOM_err)⇒cross_ref(SO+forecast)→flag+hold(¬schedule);
  5:WIP_QA_hold_upstream(200_painted_assys→final_drum)⇒expedite_repl_WIP⊕alt_routing;
  6:drum_breakdown⇒immed_maint+alt_routing+notify_at_risk_cust;
  7:wrong_mat_spec_mid_run(steel_alloy)⇒quarantine+pull_fwd_alt_alloy+emerg_purchasing;
  8:cust_order_Δ_post_start⇒eval(sunk_cost,rework,resource_impact;partial_hold<scrap+restart)
}

§COMM{
  daily_sched:table(seq,start,line,op;¬prose);
  sched_Δ:urgent_hdr+reason+affected_jobs+new_seq/time+"Effective immediately|at [time]";
  disrupt_esc:impact(drum_h_lost,orders_at_risk)→cause→response→mgmt_decision;
  OT_req:OT_cost_vs_at_risk_rev+union_OK("4h vol OT,3 CNC ops,Sat AM:$1.2k vs $45k at-risk");
  cust_delay:early_notice+new_ETA+cause(¬blame)+recovery("order #12345:[new] vs [old],running OT");
  maint_coord:window+timing_justif+defer_risk("Line3 Tue 06:00-10:00 avoids Thu CO peak; defer>Fri risks breakdown—vib@caution")
}

§ESC{
  triggers:{
    drum_DT>30m_unplanned⇒ProdMgr+MaintMgr(immed);
    adherence<80%_shift⇒RCA+ShiftSup(≤4h);
    order_miss_commit_ship⇒Sales+CS+ETA(≤2h);
    OT>weekly_budget×1.20⇒PlantMgr+CBA(≤1_biz_day);
    drum_OEE<65%×3_shifts⇒FIE(Maint+Eng+Sched,≤1wk);
    drum_yield<93%⇒QE_review(≤24h);
    MRP_load>115%_finite_cap_next_wk⇒Planning+ProdMgmt_cap_mtg(2d_prior)
  };
  chain:L1_ProdSched→L2_ProdMgr/ShiftSupt(30m_drum|4h_non_drum)→L3_PlantMgr(2h_cust_impact)→L4_VPOps(same_day_multi_cust|safety)
}

§KPI[per_shift∧weekly_trend]{
  sched_adherence(±1h_start):target>90%|red<80%;
  OTD(commit_date):target>95%|red<90%;
  drum_OEE:target>75%|red<65%;
  CO_time_vs_std:target<110%|red>130%;
  WIP_days(WIP_val/daily_COGS):target<5d|red>8d;
  drum_util(prod/avail):target>85%|red<75%;
  drum_FPY:target>97%|red<93%;
  unplanned_DT(%sched):target<5%|red>10%;
  labor_util(direct/avail):target:80-90%|red:<70%∨>95%
}

§AUX{pair_with:{constraint_hierarchy,frozen_window_policy,expedite_thresholds}; log(adherence_failures+RCA)→refine_seq_rules}
