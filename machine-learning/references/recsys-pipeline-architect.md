@REF:recsys-pipeline-architect
§META{
  pipe:Source→Hydrator→Filter→Scorer→Selector→SideEffect;
  attr:"popularized by xAI's open-sourced For You algorithm"|`https://github.com/xai-org/x-algorithm`(Apache-2.0);
  up:`https://github.com/mturac/recsys-pipeline-architect`(MIT,¬copied;TS/Go/Py/Rust_ifaces,filter/scorer_cookbooks[weighted_sum,MMR,div_penalty,pos_debias],runnable_scaffolds;read_src≺use)
}
§USE{
  top_K(user,ctx)|rank_X|feed/pers|plumbing_around_LLM/ML_scorer|single→multi_action_wt|stack∈{TS,Go,Py};
  trig:{"recommendation system","feed algorithm","ranking pipeline","for you feed","candidate pipeline","content recommender","pipeline architecture for recsys","RAG retrieval reranker"}
}
§NOT{model_arch(transformer,two_tower,emb_train)|pure_ML_train_pipes|deployed_ops(mon,autoscale)}
§STAGES[exact_order]{
  1:Source[par]→fetch_cands;why:know_cands≺enrich_cost;
  2:Hydrator[par_indep]→enrich_meta;why:filters_need_meta∉source;
  3:Filter[seq]→drop(blocked,expired,dup,inelig);why:scoring_costly⇒drop_first;
  4:Scorer[seq_chain]→ML+div_rerank+biz_rules;
  5:Selector[single]→sort_desc(final_score)→top_K;why:deterministic∧cacheable_scoring;
  6:SideEffect[async]→cache_IDs,log_imp,emit_evt,upd_cnt;¬block_resp
}
§WF{
  1:clarify(1_rnd,3Q):items?,ctx?,lang/rt?;
  2:sources:in_net(followed/owned/sub)+out_net(ML_retr/trending/sim_liked);
  3:hydrate:meta_for(filters,scorers)∉source;
  4:filters:dup,self,age,block/mute,prev_served,elig(cheap≺costly,univ≺user);
  5:scorers:primary(ML)→combiner(multi_act_wt)→div→biz;
  6:select:sort_desc→top_K(∨strat_mix_in/out_net);
  7:side_fx:cache_IDs,imp,cnt,analytics(fire_forget);
  8:gen_runnable_scaffold
}
§TRADEOFFS[never_silent_default]{
  score:{single(1_rel_model;Δ⇒retrain) vs multi_action(P(act)∀{read,like,share,skip,report}+/-_wts;Δ⇒tune_wt,¬retrain;X_For_You=+/-;rec_freq_tune)};
  iso:{isolated[def](indep_cand;det,cacheable) vs joint(batch_attn/tx;expr,non_det_batch;batch_div_only)};
  exec:{online[def](req_time,100-300ms) vs offline(precomp_cache;low_lat/fresh) vs hybrid(retr_off,rank_on)}
}
§R{
  ¬invent_bench("depends on workload, run it yourself");
  attr:exact_§META.attr;¬tm("X-like"|"For You")⇒use("candidate|feed|ranking|recsys pipeline");
  surface_3_tradeoffs;scaffold_MUST_run(¬pseudo);
  filter_ord:cheap≺costly∧univ≺user;
  side_fx:fire_forget(goroutines|unawaited_promises|asyncio_tasks)
}
§ANTI{score≺filter;sync_side_fx;single_score_multi_obj(eng,safety,div,ads);joint_default;pseudo_scaffold}
