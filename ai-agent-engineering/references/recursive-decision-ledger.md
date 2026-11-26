@REF:recursive-decision-ledger
§GOAL:rollouts+append_ledger(trials,marks,coherence,promo_gates)⇒rec_conf≠auto_live
§TRIG{rollouts|"Prime_Gauss";marked_dec|high_dim|stoch_opt|local_opt|ensemble;ev_trail;keep(trials,mem,fresh,marks);drop(loop=certainty)}
§LEDGER{JSONL(append)+MD(sum);fields:[rollout_id,ts,prior_winner,prior_watch,fresh_info,search_sz,models_heur,trials,eff_trials,top_cands,dec_marks,coherence_vs_prior,promo_gate]}
§LOOP{1:load→2:fresh(t=0)→3:search→4:mark∈{accept,watch,reject,decay_watch,needs_replay}→5:cmp_prior&latest→6:downgrade(drift|tail|stale|fail_replay)→7:append_pre_sum}
§COHERENCE{[Ensemble_matches_prior,Recursive_matches_prior,Latest_rollout_match,Live_promotion_allowed]:bool;[Reason]:gate}
§PROMO{
  high_stakes(trade,cap_alloc,prod_deploy,migr,destr)⇒rec_conf≠approve;
  default:paper|dry-run|ro|preview|staged_unless(user_live_approve∧gate_ok);
  promote_iff:beats_prior(metric)∧replay_pass∧risk_limits∧durable_ev∧user_approve
}
§SUM:lead_dec_¬drama(`Rollout 15: prior holds, edge -17%. Status: watch, not live. Gate: 20 replay fills, orderbook age < thr.`)
