@REF:review-checklist
§RPT{path:`security_best_practices_report.md`∨user;has:{exec_sum,sev_findings(id,file,lines),1sent_impact/crit,closing(path)};fix:1→cmt(practice+why)→test→1/commit}
§CHK{¬hardcoded_secrets(env|mgr);val_in∧param_SQL;sanitized_HTML∧CSP;CSRF(state_Δ);httpOnly_cookies∧authz(∀obj,fn);rate_limit(∀ep);HTTPS_prod∧hdrs;gen_err∧¬sens_logs;deps_audit(¬vulns);RLS(multi_tenant);CORS(trusted);val_uploads;wallet_sig(chain)}
§API10{1:BOLA;2:Auth;3:BOPLA;4:ResConsume;5:BFLA;6:BizFlow;7:SSRF;8:Misconfig;9:Inventory;10:UnsafeAPI}
§SRC{API10:https://owasp.org/www-project-api-security/;OWASP10:https://owasp.org/www-project-top-ten/;RFC8725:https://tools.ietf.org/html/rfc8725;Next:https://nextjs.org/docs/security;Supa:https://supabase.com/docs/guides/auth;PortSwigger:https://portswigger.net/web-security}
