@REF:canary-watch
§REL{browser:[performance.md](performance.md),[browser-qa](../../unit-testing-patterns/references/browser-qa.md);base:[benchmark.md](benchmark.md);ci:[github-actions](../../devops-iac/references/github-actions.md)}
§USE{post_deploy(prod|stage)|risky_PR|verify_fix|launch_window|dep_upgrade}
§WATCH{
  chk:{1:HTTP_200,2:new_console_err,3:net_fail/5xx,4:LCP/CLS/INP_vs_base,5:DOM(h1,nav,footer,CTA),6:API_SLA,7:assets(JS,CSS,img,font∈2xx/3xx∧type),8:SSE(conn+init/hb)};
  mode:{quick(def):1_pass;sustained:N_min×M_h(e.g.5m/2h);diff:stage_vs_prod};
  curl:```bash
URL=https://myapp.com
curl -s -o /dev/null -w '%{http_code} %{time_total}s\n' "$URL"
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' "$URL/health"
curl -sN --max-time 10 -H 'Accept: text/event-stream' "$URL/events" | head -n 3
```
}
§THRESH{
  crit(alert):{HTTP!=200,new_err>5,LCP>4s,API_5xx,asset_4xx/5xx,SSE_drop_pre_hb};
  warn(flag):{LCP_delta>+500ms,CLS>0.1,new_warn,rt>2x_base,asset_type_Δ,SSE_hb_lat>2x_base};
  info(log):{minor_perf_var,new_net_req(3p?)}
}
§NOTIFY{crit⇒desktop(macOS/Linux)∧opt(Slack/Discord_hook)∧log(proj|CI_art)}
§OUT{`## Canary Report — <host> — <TS>`|Status:HEALTHY|DEGRADED|rows(HTTP,Console_errors,LCP,CLS,API_/health,Static_assets,SSE_/events)⇒Res_vs_Base(Delta)}
