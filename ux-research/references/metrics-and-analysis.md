@REF:metrics-and-analysis
§REL{../SKILL.md;./research-workflow.md;../../conversion-optimization/references/ab-testing.md}
§R{
  ISO_9241-11:measure(effectiveness:completion+errs,efficiency:time+effort,satisfaction:standardized_scales);
  task_time:right_skewed⇒geometric_mean∨median¬arithmetic_mean;compute_on_successful_tasks∧report_fail_time_separately;
  completion_rate:small_N_binary⇒Adjusted_Wald_CI¬raw_Wald(collapses_at_0%_100%);
  scales:validated_instruments(SEQ,SUS,UX-Lite,SUPR-Q)¬homegrown_satisfaction_Qs;
  LLM_coding:human_gold_subset(50..100)+IRR(Cohen_κ≥0.80)≺batch_scaling;
  atomic_nuggets:Evidence(verbatim/metric/clip)→Insight(pattern+cause)→Recommendation/Opportunity(OST)
}
§PAT:StandardScales{
  SEQ:{timing:post_task,items:1("Overall, how easy or difficult was this task?"),scale:1..7(very_difficult..very_easy),use:pinpoint_task_friction};
  SUS:{timing:post_session,items:10(alternating_pos/neg_1..5),formula:`(sum(odd-1)+sum(5-even))*2.5`→0..100,use:overall_perceived_usability+learnability,avg_ref:~68};
  UMUX_Lite_UX_Lite:{timing:post_session_low_fatigue,items:2(ease_of_use+meets_requirements/usefulness),scale:5pt(UX-Lite)∨7pt(UMUX-Lite),use:fast_SUS_proxy_in_surveys/in_app};
  SUPR_Q:{timing:website_benchmark,items:8,dims:{Usability,Trust,Loyalty,Appearance},use:ecommerce_and_web_UX_benchmarking}
}
§PAT:Stats{
  geom_mean:`exp(mean(ln(t_i)))`(t_i>0);robust_for_positively_skewed_task_times;
  adjusted_wald_95:`z=1.96; p_adj=(x+z²/2)/(n+z²); se=sqrt(p_adj*(1-p_adj)/(n+z²)); CI=[max(0,p_adj-z*se),min(1,p_adj+z*se)]`;
  sample_size:{formative_qual:~5/homogeneous_segment(iter_rounds),summative_bench:N≥20..40/segment(tighter_CI),live_variant_cmp:power_calc_A/B_test};
  IRR:{2_raters(human_vs_human∨human_vs_LLM)⇒Cohen_Kappa(κ≥0.80_strong,0.60..0.79_refine_codebook,<0.60_reject),≥3_raters⇒Fleiss_Kappa;¬raw_%_agreement_alone}
}
§CMD:CleanAndStats{
  clean_pandas:`df=pd.read_csv("survey_deid.csv"); df.columns=[c.strip().lower().replace(" ","_") for c in df.columns]; df=df.drop_duplicates(); df=df[df.isna().mean(axis=1)<=0.30]; df=df[~df["fraud_flag"]]; likert={"Very Satisfied":5,"Satisfied":4,"Neutral":3,"Dissatisfied":2,"Very Dissatisfied":1}; df["sat"]=df["satisfaction"].map(likert)`;
  stats_py:`import numpy as np; gmean=lambda t: float(np.exp(np.mean(np.log(t)))); def adj_wald(x,n,z=1.96): n2=n+z*z; p=(x+z*z/2)/n2; se=np.sqrt(p*(1-p)/n2); return p,max(0.0,p-z*se),min(1.0,p+z*se)`;
  sus_py:`sus=lambda r: (sum(r[i]-1 for i in range(0,10,2))+sum(5-r[i] for i in range(1,10,2)))*2.5`
}
§PAT:TextAnalysis{
  tier1_small(N<100):manual_reflexive_thematic_analysis+affinity_map+frequency_counts(goals,pain_points);
  tier2_codebook(N∈[100,1000+]):1_author_inductive_codebook(human_sample)→2_consensus_code(50..100_gold_set)→3_LLM_few_shot(3..5_examples/code,multi_label_JSON,strict_schema)→4_calc_Cohen_κ(≥0.80)→5_batch_remaining+spot_audit;
  tier3_exploratory(N>500):BERTopic(Sentence-BERT_embeddings→UMAP_dim_reduce→HDBSCAN_outlier_aware(-1)→c-TF-IDF_labels)→human_interpret_and_merge;
  fallback_offline:TfidfVectorizer(stop_words="english")+KMeans(n_clusters=k,random_state=42)(syntactic_only:misses_synonyms,forces_fixed_K)
}
§CMD:TextCode{
  bertopic:`from bertopic import BERTopic; from sentence_transformers import SentenceTransformer; emb=SentenceTransformer("all-MiniLM-L6-v2").encode(texts); topics,probs=BERTopic().fit_transform(texts,emb)`;
  irr_kappa:`from sklearn.metrics import cohen_kappa_score; kappa=cohen_kappa_score(human_gold,llm_pred); assert kappa>=0.80`
}
§PAT:SynthesisAndPrio{
  atomic_schema:{id,study_id,segment,evidence_quote_or_clip,metric_ctx,insight_stmt,design_implication,opportunity_node,severity(1..4),confidence(low|med|high)};
  prioritize_matrix:{H_impact+L_effort⇒P0_ship_now,H_impact+H_effort⇒P1_roadmap,L_impact+L_effort⇒P2_quick_batch,L_impact+H_effort⇒deprioritize};
  outliers:always_log(edge_cases,critical_failures,negative_feedback)⇒often_reveal_a11y_or_high_risk_bugs
}
§D{
  N<100_open_ends⇒manual_thematic_coding¬BERTopic_or_KMeans_noise;
  unknown_themes∧N>500⇒BERTopic_first→refine_codebook→LLM_classify+IRR¬guess_K_w_KMeans;
  need_multi_label_tags⇒LLM_few_shot+Cohen_κ_gate¬single_cluster_KMeans;
  skewed_task_times⇒geometric_mean+95%_CI(log_space)¬arithmetic_mean;
  5_of_5_passed(100%)⇒report_Adjusted_Wald_CI(~51%..100%)¬claim_100%_population_success
}
§ANTI{
  arithmetic_mean_on_task_time;raw_percent_without_CI_on_small_N;TF-IDF+KMeans_as_default_for_semantic_verbatims;unchecked_LLM_tagging_without_IRR;percent_agreement_without_chance_correction(Kappa);dropping_outliers_or_negative_feedback;conflating_SUS_with_task_completion
}
§CHK{
  [de_id_CSV_cleaned,fraud_rows_removed,geom_mean_task_times,Adjusted_Wald_CIs,standardized_scales_scored,IRR_κ≥0.80_if_LLM_coded,atomic_nuggets_linked_to_evidence,outliers_preserved,impact_effort_prioritized]
}
