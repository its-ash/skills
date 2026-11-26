@REF:literature-review
§META{scope:find,screen,synth,cite_lit+repro_protocol+log|use⇔review(sys|scop|narr)∨SOTA∨gaps/contradictions∨cited_bg∨compare(papers,preprints,patents,tech_reports)}
§D:types{narr:orientation|scop:map_concepts_gaps|sys:protocol+repro_search+screen/excl|meta:sys+quant_agg;unspec⇒ask_rigor_else(exploratory⇒scop|pub∨clinical⇒sys)}
§WF{
  1_Q:{biomed⇒PICO(Pop,Interv|Exp,Comp,Out);tech⇒(sys|domain,method|interv,baseline,metric)};
  2_plan:{DBs,dates,langs,pub_types,incl,excl,strings};min_DBs:{PubMed(pubmed.md),USPTO(uspto.md),arXiv(CS/math/phys/q-bio/preprints),Semantic_Scholar∨Crossref,domain(trials,patents,standards,tech_docs)};
  3_log:{DB,Date,Query,Filters,Results,Export}(eg:`PubMed|2026-05-11|("CRISPR"[tiab] OR "Cas9"[tiab]) AND "sickle cell"[tiab]|2020:2026,English|86|PMID list`;`arXiv|2026-05-11|CRISPR sickle cell gene editing|q-bio,2020:2026|9|BibTeX`);save_raw(IDs,URLs,DOIs,abstracts,notes)_sep;
  4_dedup:1:DOI→2:PMID|arXiv_ID→3:exact_title→4:norm_title+1st_author+yr(log_removed);
  5_screen:title→abstract→full_text;sys_excl:{wrong_pop,wrong_interv,wrong_out,not_primary,dup,no_full_text,out_of_date};
  6_extract:{Study(Author Yr),Design(RCT/cohort/review),Pop|Data,Method,Comp,Out,Key_finding,Limitations}(+tech:dataset,benchmark,metric,baseline,repro);
  7_synth(by_theme,¬paper_by_paper):lenses:{strongest,conflicting,method_weakness,pop/dataset_limits,recency/repl,implications,open_Q};conf:{High:repl_HQ,Medium:limited_sample/method/recency,Low:early/spec/1src/weak};
  8_verify:chk(DOI|PMID|arXiv|URL,authors,yr)∧¬misattribute∧label_preprints∧sep_reviews_vs_primary
}
§PAT:tpl{
  hdr:`# Literature Review: <Topic>\nGenerated: <date>\nReview type: <narrative | scoping | systematic | meta-analysis>\nSearch window: <dates>\nDatabases: <list>`;
  secs:{Research Question,Search Strategy,Inclusion and Exclusion Criteria,Evidence Summary,Thematic Synthesis,Gaps and Limitations,References,Search Log}
}
§ANTI{¬snippets_as_evidence;¬mix_preprints/reviews/primary_unlabeled;¬omit_negative/conflicting;¬claim_sys_without_protocol;¬1DB_for_broad_claim_unless_scoped}
§REL{pubmed.md;uspto.md;scholar-evaluation.md(grade_paper_quality)}
