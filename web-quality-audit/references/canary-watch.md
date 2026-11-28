@REF:canary-watch
§REL{browser:[performance.md](performance.md),[browser-qa](../../unit-testing-patterns/references/browser-qa.md);base:[benchmark.md](benchmark.md);ci:[github-actions](../../devops-iac/references/github-actions.md)}
§USE{post_deploy(prod|stage)|risky_PR|verify_fix|launch_window|dep_upgrade}
§WATCH{
  chk:{1:HTTP_200,2:new_console_err,3:net_fail/5xx,4:LCP/CLS/INP_vs_base,5:DOM(h1,nav,footer,CTA),6:API_SLA,7:assets(JS,CSS,img,font∈2xx/3xx∧type∧encoding),8:sec_cache_hdrs(CSP,HSTS,Cache-Control,Content-Encoding_zstd|br),9:SSE/WS(conn+init/hb)};
  browser_mcp:navigate_page→list_console_messages∧list_network_requests∧performance_start_trace(ignoreCache:true)∧lighthouse_audit(a11y,SEO,BP);
  mode:{quick(def):1_pass;sustained:N_min×M_h(e.g.5m/2h);diff:stage_vs_prod};
  curl:```bash
URL=https://myapp.com
curl -s -o /dev/null -w 'HTTP/%{http_version} %{http_code} ttfb=%{time_starttransfer}s total=%{time_total}s\n' "$URL"
curl -sI "$URL" | grep -iE '^(content-security-policy|strict-transport-security|cache-control|content-encoding):'
curl -s -o /dev/null -w '%{http_code} %{content_type}\n' "$URL/health"
curl -sN --max-time 10 -H 'Accept: text/event-stream' "$URL/events" | head -n 3
```
}
§THRESH{
  crit(alert):{HTTP!=200,new_err>5,LCP>4s,INP>500ms,API_5xx,asset_4xx/5xx,SSE_drop_pre_hb,missing_CSP/HSTS_regression};
  warn(flag):{LCP_delta>+500ms,CLS>0.1,INP_delta>+100ms,new_warn,rt>2x_base,asset_type_Δ,comp_downgrade,SSE_hb_lat>2x_base};
  info(log):{minor_perf_var,new_net_req(3p?)}
}
§NOTIFY{crit⇒desktop(macOS/Linux)∧opt(Slack/Discord_hook)∧log(proj|CI_art)}
§OUT{`## Canary Report — <host> — <TS>`|Status:HEALTHY|DEGRADED|rows(HTTP/TTFB,Console_errors,LCP,CLS,INP,Sec/Cache_hdrs,API_/health,Static_assets,SSE_/events)⇒Res_vs_Base(Delta)}
