@REF:mle-workflow
§PARENT{[`machine-learning`](../SKILL.md)}
§CALIB{¬assume:{labels,online_srv,feat_store,PyTorch,GPUs,human_rev,A/B,rt_fb};¬heavy_MLOps⇔(data_ctr∧base∧eval∧rb_note)⇒rev;state_assump⇔miss:{labels,del_out,slices,prod_traf,mon_own};ex=scaffold⇒swap(metrics,srv,stores,rollout)→native}
§COMPACT[pre_code,PR]{Goal|Who cares|Owner|Action Δ|Success|Guardrails|Mistake budget|Unacceptable|Acceptable|Assumptions|Constraints|Labels/snap|Baseline|Signals|Thresh/cfg|Slices|Risks|Next exp|Rollback/fallback}
§DECISION{1:decision→action_Δ;2:stakeholders∧cost(FP,FN,lat,comp,opac,miss_opp);3:ambig→hyp(sep_sig,falsifier,base);4:prior_art∨nearby_1st;5:score=(prob,conf)*(cost,sev,imp,impact);6:chk:{adv,incent,sel_discl,dist_shift,fb_loops};7:min_Δ_cut_top_err;8:log(dec,evid,counter,next_rev_step)}
§FEAT{fams:{text,cat,num_hist,graph,rec,freq,agg}=cands≠auto;∀fam:sep_why∧leak_vec;noisy:{adj,lbl_conf,soft,conf_wt};imbal:cmp(wt_loss,resamp,thresh,cal);thresh(sklearn≥1.6/1.9):TunedThresholdClassifierCV|FixedThresholdClassifier;calib_prefit:CalibratedClassifierCV(FrozenEstimator(clf))¬deprecated_cv='prefit';miss:{info|impute|abstain};out:{clip|bkt|inv|rare};corr:chk(red,instab,fut_proxy)}
§ERR[err→cluster→hyp→exp→evid→simpler]{1:split:{FP,FN,abst,low_conf,sys_fail};2:cluster:{lang,ent,src,time,geo,dev,spar,rec,fresh,lbl_src,ver};3:sep:model vs {data_bug,lbl_amb,prod_amb,instr_gap,srv_mism};4:map→1_move∈{lbls,feats,thresh/cfg,fb};5:persist→{regr_test|slice|dash|runbook};6:next=falsifiable_exp}
§LEDGER[code|PR|report|runbook]{Iter|Change|Why|Metric Δ|Slice Δ|FP|FN|Errors|Decision|Tradeoff|Lesson|Regr added|Debt|Next iter}
§CONTRACTS{pred:tgt∧own;in∧out_schema∧conf/cal∧lat_max;mode∈{batch,online,stream,hybrid};fb⇔dep_down;human_rev⇔high_imp;priv/ret/audit(in,pred,lbl);data:grain∧PK;lbl(def,ts,del);feat(ts,fresh_SLA,PIT_join);split(tr/val/te/bt);cols/nulls/rng/cat/unit;¬PII∈{art,log};ver|snap(Iceberg_snap_ID|Parquet_SHA)}
§REPRO{frozen_cfg∀(hp,path);pin_deps(uv.lock);seeds+doc_nondet_GPU;log(data_ver,SHA,cfg_hash,metrics,URI)→MLflow_3_LoggedModel∨manifest;bundle_preproc;shared_xform;safe_ser(safetensors|skops.io[get_untrusted_types→load]|ONNX|weights_only=True)¬untrusted_pickle;idemp∧pure}
```python
@dataclass(frozen=True)
class TrainingConfig: dataset_uri: str; model_dir: Path; seed: int; learning_rate: float; batch_size: int
def artifact_name(c: TrainingConfig, sha: str) -> str:
    return f"{sha[:12]}-{hashlib.sha256(f'{c.dataset_uri}:{c.seed}:{c.learning_rate}:{c.batch_size}'.encode()).hexdigest()[:12]}"
```
§GATES[pre_train_end]{vs(base,prod);prim↔prod_behav;guard:{lat,cal,fair,cost,err_conc};slices:{cohort,geo,dev,lang,src};CI/multi_run_var;human_rev(fails)⇔high_imp;do_not_ship;offline≠guar⇒shadow|canary|A/B;retrain_trigger⇒candidate_only→pass_gates¬auto_deploy}
```python
PROMOTION_GATES = {"auc": ("min", 0.82), "calibration_error": ("max", 0.04), "p95_latency_ms": ("max", 80)}
def assert_promotion_ready(m: dict[str, float]) -> None:
    if miss := sorted(n for n in PROMOTION_GATES if n not in m): raise ValueError(f"Missing gates: {miss}")
    if fail := {n: m[n] for n, (d, t) in PROMOTION_GATES.items() if (d == "min" and m[n] < t) or (d == "max" and m[n] > t)}: raise ValueError(f"Failed gates: {fail}")
```
§SERVE{art:{ver,data_ref,cfg,preproc,safe_fmt∈{ONNX,safetensors,skops,PT2_AOTInductor}};rt_opts:{ONNX_Runtime,AOTInductor,Triton,vLLM,FastAPI}¬deprecated_TorchScript;in:rej(inv|stale|OOR);out:{ver,conf|expl};rt:{to,batch,lim,fb,CPU/GPU,KEDA_q_scale};log:¬PII∧OTel_trace_IDs∧dbg/join_IDs;tests:{miss_feat,stale_feat,bad_type,empty,fb}}
§MON{sys:{avail,err,to,q_depth,p50/95/99};data_drift:{null,rng,cat,fresh};pred_drift:{score,conf,class_bal};concept_drift:{lbl_arr,del_qual,slice_decay};genai_opt:{OTel_traces,judge_scorers};ops:{KPI_guard,rb_trig,ver_dash,retrain_candidate_wf};rb:{prev_art,cfg,data_dep,traf_sw}}
§CHK{[ ]pred_ctr;[ ]data_ctr(grain,lbl_ts,feat_ts,snap);[ ]leak;[ ]repro(code,cfg,data,seed);[ ]safe_ser(safetensors|skops|ONNX|weights_only=True);[ ]vs_base/prod;[ ]slices+guard;[ ]fail_closed_gates;[ ]shared/equiv_xform;[ ]art_meta;[ ]serve(val,to,fb,rb);[ ]mon(sys,data/pred/concept_drift);[ ]retrain=candidate_gated;[ ]¬PII∈{art,log,prompt,ex}}
§ANTI{nb_state_req;rand_split_leak;joins_no_PIT;off_up_slice_dn;repeat_test_tune;hand_copy_preproc;untrusted_pickle_load;cv='prefit'_deprecated;TorchScript_new_deploy;log_no_ver;uptime_only_mon;auto_deploy_unvalidated_retrain;rb_needs_retrain}
§TASKS[MLE-01..10]{MLE-01:frame(pred|rank|recsys|cls|emb|fcst)⇒Compact;MLE-02:def(metrics,lbl,src,budget)⇒data+metric_ctr(grain,lbl_ts/conf,feat_ts,PIT,split,snap);MLE-03:base≺cplx(linear→GBDT≺DL)⇒scorer+CM+cal+lat/cost+weak+shape/det_tests;MLE-04:sep_hyp_feats⇒plan+mod(src,miss,out,corr,leak,tr/srv_equiv);MLE-05:tune(TunedThresholdClassifierCV,FrozenEstimator_cal,cfg,cplx)⇒rpt(P,R,F1,AUC,cal,slices,lat,cost,ok_err);MLE-06:err_anal⇒clusters(FP,FN,amb_lbl,stale,miss_sig,trace)→next_exp;MLE-07:pkg_art⇒ver_bndl(preproc,cfg,pins,schema_val,safe_ser[safetensors|skops|ONNX],noPII_log);MLE-08:ship(on|batch)⇒envlp/to/batch/fb/ver/conf/fb_log/flow_tests;MLE-09:rollout⇒split/dash/p95/cost/guard/rb_art+trig;MLE-10:ops+ref⇒ledger+3_drift/del_lbl/candidate_retrain/own/runbook}
