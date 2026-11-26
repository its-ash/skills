@REF:review-checklist
§R{∀Δ_file:chk_all∧verify_ctx_&_tests;scope:prob+flow∧¬req/arch_conflict∧small_Δ(large⇒hide_bugs);senior_flag∈{db_schema,API_contract,fw,perf_path,sec_code}}
§CHK{
  func:{solves_prob,AC,edge/err,in_val,¬off_by_1,loops_end,rec_base,state_ok,errs_caught∧clear_msg∧¬leak,rollback_fail,log_fits};
  sec:{inj∈{SQL,cmd,tpl,hdr}⇒param_only;XSS⇒escape_out;auth⇒req_prot;authz/IDOR⇒chk_access(¬auth_only);CSRF⇒prot_state_Δ;race⇒TOCTOU(read→write);sess:{fixation,expiry,secure_flags};crypto:{rng,algo,¬log_secrets,pw≥bcrypt(¬MD5∧¬SHA1)};leak:{err,log,timing};DoS:{unbounded,rate_limit,exhaust};biz:{state_machine,overflow};secrets∈env(fail_missing);in∈schema|allowlist;rm_unused_deps};
  perf:{¬unneeded(loop,query,alloc);N+1⇒join|prefetch;idx(FK,filter);cache+TTL;¬O(n²);block→async;¬leak|unbounded;fe:{bundle,split,opt_img};goals(non_univ):API<200ms∧gzip<200KB};
  qual:{CC≤10/fn;¬god(>500L|>20m);¬cycles|coupling;¬dead|cmt_out|magic_num|dup;conv→[clean-code](../../clean-code/SKILL.md)};
  tests:{edge/err_cov,meaningful∧¬over_branch∧CI_pass,cov≥80%_crit,int+e2e_crit};
  docs_git:{cmt=why(¬what),upd(API_docs,README,migration),breaking_Δ,clear_commits,base_sync,¬conflict|stray,.gitignore_ok};
  design:{arch_fit,compat|migration,acceptable_maint}
}
§PAT{sqli:db.query('SELECT * FROM users WHERE email = $1',[email]);n1:User.objects.prefetch_related('profile');effect:useEffect(()=>{fetchData(userId)},[userId]);}
§CHK{prod_audit:arch:{cycles,coupling,god,mod_bounds};sec:{SQLi,XSS,secrets,auth/authz,weak_hash,val,CSRF,deps};perf:{N+1,idx,async,cache,algos,bundles,img,leaks};qual:{CC,dup,magic_num,naming,err_handle,dead,TODO/FIXME};test:{crit_untested,cov<80%,edge,flaky,int};infra:{env,log,err_track,health,mon,rate_limit,docs,CI/CD}}
§ANTI{edge⇒ask("null|empty|unauth?");scan(`npm audit`,Snyk)+OWASP_Top_10;flood⇒Crit+High_first;false_pos⇒verify_ctx;no_followup⇒issues_w_owners}
