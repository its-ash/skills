@REF:benchmark-methodology
§USE{step:2/3;in:tiered_set([competitive-platform-analysis.md](competitive-platform-analysis.md))∧positioning_brief;out:1-5_scores+cards→[competitive-report-structure.md](competitive-report-structure.md)}
§BRIEF{
  prereq_before_scoring;
  tension:2_axes(e.g.memorability×hireability/credibility)⇒target_white_space=Dim9(score∧report_poles_separately,¬avg);
  differentiator:client_moat⇒sets_dim_emphasis;
  brand_balance:intended_strategic_mix⇒¬break_wo_flag
}
§DIM{
  note:weights_for_synthesis_only(∑=100%,¬composite_avg);
  1:Positioning_clarity_distinctiveness(18%):sharp/ownable/legible vs generic;
  2:Brand_voice_verbal_distinctiveness(15%):ownable_register vs agency-speak;
  3:Visual_identity_site_craft(15%):visual_system_quality+ownership,site=proof_of_craft;
  4:Service_offer_packaging(12%):productized/legible(named_sprints/audits) vs vague;
  5:Evidence_credibility(12%):named_clients,quantified_outcomes,case_study_depth(proof>assertion);
  6:Enterprise_readiness_commercial_maturity(10%):SaaS/fintech/B2B/enterprise_signals(process,logos,scale,contracts);
  7:Thought_leadership_content_presence(8%):owned_POV(writing,talks,newsletters,frameworks),depth>volume;
  8:Pricing_transparency_engagement_model(5%):productized vs bespoke vs opaque;
  9:Client_strategic_tension(5%_flag):score_BOTH_poles_1-5_separately;plot_2x2;target_quadrant_occupancy=#1_finding
}
§RUBRIC{
  dims_1-8(adapt_specifics/dim,keep_level_constant,anchor_to_evidence):{
    1:absent/generic(template-indistinguishable,active_liability);
    2:below_par(inconsistent/derivative/unconvincing,fails_side-by-side);
    3:competent/table-stakes(solid/professional/unremarkable,ownable_by_nobody);
    4:strong/distinctive(>peers,buyer_notices∧cites);
    5:category-defining(best-in-class,ownable,hard_to_imitate,sets_bar)
  };
  dim9_ex(memorability×credibility):{
    memorability:{1:forgotten_instantly,3:recognizable_in_context,5:unforgettable/talked-about/owned},
    credibility:{1:risky/amateur,3:safe/competent/unexciting,5:enterprise-trusted/obvious_safe_choice}
  };
  quadrants:{high/high,high-1/low-2,low-1/high-2,low/low}
}
§COLLECT{
  order(cheapest_first):{
    1:own_site→positioning,voice,packaging,pricing,clients,POV;screenshot(homepage+1_case_study);
    2:case_studies/work→evidence_depth,metrics,clients;tag(asserted vs proven=metrics+named+verifiable);
    3:review_dirs(Clutch.co∨niche_equiv)→corroborate_clients,size,model→credibility+enterprise;
    4:LinkedIn→team_size/model,founder_narrative,cadence→thought_leadership+model;
    5:craft_platforms(niche_showcase:boards,showreels,samples)→craft;
    6:content_channels(newsletter/talks/writing)→thought_leadership_depth
  };
  record_∀dim:score(1-5)+1-line_justification+source_link/screenshot(¬score_wo_evidence)
}
§BIAS{
  ¬composite_score(hides_asymmetry);
  asserted_vs_proven:downgrade_uncorroborated_copy;
  aesthetic_affinity:score_craft⊥credibility("boring"_site_may_win_bigger_clients);
  recency/flashiness:verify_awards/showpieces_via_dirs/clients;
  survivorship:note_quiet_strong_operators_via_dirs/reviews;
  cross_set_calibration:re-read_side-by-side("4"_invariant_across_set;adjust_outliers)
}
§CARD{
  ```
  ## <Competitor name>
  - **Profile / Tier:** <stance·specialization·size> / <Direct|Adjacent|Aspirational>
  - **One-liner:** <their words>
  - **Model / size / geography:** <solo|micro|boutique>·<region>·<pricing/model>
  - **Notable clients / evidence:** <named [proven|asserted]>
  ### Dimension scores (∀dim∈§DIM[1..8]: Dim|Score(1-5)|1-line|Source)
  ### Tension plot: [Axis 1]:<1-5>—<why>; [Axis 2]:<1-5>—<why>; Quadrant:<high/high|high-1/low-2|low-1/high-2|low/low>
  ### Read for [client]: Strength:<…>; Weakness/white-space:<…>; Threat:<…>
  ```
}
§ANTI{¬avg_tension_axes;¬score_wo_evidence+source;¬composite_score;¬uncalibrated_generic_rubric;¬run_before([competitive-platform-analysis.md](competitive-platform-analysis.md))}
§REL{prereq:[competitive-platform-analysis.md](competitive-platform-analysis.md);next:[competitive-report-structure.md](competitive-report-structure.md)}
