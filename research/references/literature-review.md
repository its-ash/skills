@REF:literature-review
§META{scope:find,screen,appraise,synth,cite_lit+PRISMA_protocol+log|use⇔review(sys|scop|narr)∨SOTA∨gaps/contradictions∨cited_bg∨compare(papers,preprints,patents,tech_reports)}
§D:types{
  narr:orientation|scop:map_concepts_gaps(PRISMA-ScR_20item)|sys:protocol+repro_search+screen/excl+RoB(PRISMA_2020_27item+PRISMA-S)|meta:sys+quant_agg;
  unspec⇒ask_rigor_else(exploratory⇒scop|pub∨clinical⇒sys);
  RoB:{RCT⇒Cochrane_RoB_2;non_randomized⇒ROBINS-I_V2(6_domains,strong/weak_sig_Qs,immortal_time/prevalent_user_bias)}
}
§WF{
  1_Q:{biomed⇒PICO(Pop,Interv|Exp,Comp,Out);tech⇒(sys|domain,method|interv,baseline,metric)};
  2_plan:{DBs,dates,langs,pub_types,incl,excl,exact_strings};min_DBs:{PubMed(pubmed.md),OpenAlex(2026_API_key_req;~$1/d_free_credits;ID/DOI_free;list/vec_metered;30rps_keyed;/rate-limit),USPTO_ODP(uspto.md),arXiv(CS/math/phys/q-bio/preprints),Semantic_Scholar(keyed>1rps)∨Crossref,domain(trials,standards,tech_docs)};
  3_log_PRISMA-S:{DB,Exact_Date,Exact_Query,Filters,Results,Export}(eg:`PubMed|2026-11-28|("CRISPR"[tiab] OR "Cas9"[tiab]) AND "sickle cell"[tiab]|2020:2026,English|86|PMID_list`;`OpenAlex|2026-11-28|search="CRISPR sickle cell"&filter=publication_year:2020-2026|works|140|JSON`);save_raw(IDs,URLs,DOIs,abstracts,notes)_sep;
  4_dedup:1:DOI→2:PMID|arXiv_ID|OpenAlex_ID→3:exact_title→4:norm_title+1st_author+yr(log_removed);
  5_screen:title→abstract→full_text;sys_excl:{wrong_pop,wrong_interv,wrong_out,not_primary,dup,no_full_text,out_of_date,retracted_or_EoC};
  6_extract+RoB:{Study(Author Yr),Design(RCT/cohort/review),Pop|Data,Method,Comp,Out,Key_finding,RoB(RoB2|ROBINS-I_V2),Limitations}(+tech:dataset,benchmark,metric,baseline,repro);
  7_synth(by_theme,¬paper_by_paper):lenses:{strongest,conflicting,method_weakness,pop/dataset_limits,recency/repl,implications,open_Q};conf:{High:repl_HQ,Medium:limited_sample/method/recency,Low:early/spec/1src/weak};
  8_verify:chk(DOI|PMID|arXiv|URL)_exists∧screen(Retraction_Watch|Crossref_notices)∧chk(authors,yr)∧¬misattribute∧label_preprints∧sep_reviews_vs_primary
}
§PAT:tpl{
  hdr:`# Literature Review: <Topic>\nGenerated: <date>\nReview type: <narrative | scoping | systematic | meta-analysis>\nStandards: <PRISMA 2020 | PRISMA-ScR | PRISMA-S>\nSearch window: <dates>\nDatabases: <list>`;
  secs:{Research Question,Search Strategy,Inclusion and Exclusion Criteria,Evidence Summary,Risk of Bias Appraisal,Thematic Synthesis,Gaps and Limitations,References,PRISMA-S Search Log}
}
§ANTI{¬snippets_as_evidence;¬mix_preprints/reviews/primary_unlabeled;¬include_retracted_unscreened;¬omit_negative/conflicting;¬omit_PRISMA-S_exact_queries_dates;¬claim_sys_without_protocol;¬1DB_for_broad_claim_unless_scoped}
§REL{pubmed.md;uspto.md;scholar-evaluation.md(grade_paper_quality)}
