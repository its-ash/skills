@REF:scholar-evaluation
§R{scope}
eval(paper|proposal|thesis_ch|lit_rev|methods|ev_qual|cit_sup),compare,rev_feedback
art∈{empirical,theoretical,tech_rep,sys/narr_lit_rev,proposal,thesis_ch,conf_abs/short}
scope∈{comprehensive(all),targeted(1-2_dims:meth|cit),comparative(rank≥2_same_rubric)}

§PAT{rubric_1_5}
scale:{5:excel/rigor/pub_ready,4:good/min_impr,3:adeq/gaps/usable,2:weak/subst_rev,1:poor/maj_fail,N/A:inapp}
1_Prob&Q:{clear/spec,contrib,scope/assump_expl,Q↔claim}
2_Lit&Ctx:{prior_cov,synth>list,gaps_acc,rec+found_bal}
3_Method:{ans_Q,justif,vars/data/partic/mat_clear,repro,eth/prac_lim}
4_Data&Ev:{cred/fit,sample/cov_adeq,incl/excl/preproc_doc,miss+bias_disc}
5_Analysis:{stat/qual/comp_fit,fair_base/ctrl,uncert/sens/robust,alt_exp}
6_Res&Interp:{clear,claims⊆ev,fig/tbl/met_clear,neg/null_honest}
7_Lim&Valid:{spec(¬gen),int/ext/constr/concl_risk,spec≠demo}
8_Writ&Struct:{flow,org_by_Q,def/not_clear,scholar_tone}
9_Citations:{sup_claims,primary_pref,rev_lbl_rev,prep_lbl_prep,meta/links_ok}

§PAT{proc}
1:read(abs,intro,fig,concl)→claims|2:read(meth,res)→ev|3:chk(claims↔cits)|4:score(dims)|5:sep(blockers,revs)|6:next_edits

§FMT{tpl}
```markdown
# Scholar Evaluation: <Artifact>
## Overall Assessment
Overall:<1-5|N/A> | Confidence:<high|medium|low> | Summary:<3-5 sent>
## Dimension Scores (<dim>: <score> | <evidence> | <revision priority>)
- Problem&question | Literature&context | Methodology | Data&evidence | Analysis | Results&interpretation | Limitations | Writing&structure | Citations
## Critical Issues
## Recommended Revisions
## Evidence Checks Needed
```

§ANTI{score≠feedback;¬penalize(out_of_scope_dim);cit_cnt∨venue∨rep≠quality;abs_claim≠verif}
