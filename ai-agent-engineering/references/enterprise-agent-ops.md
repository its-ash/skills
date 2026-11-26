@REF:enterprise-agent-ops
§SCOPE{prod_ops:lc,obs,safety,chg}
§WHEN{PM2|systemd|containers;mon|IR|kill_sw|gates;continuous≠CLI}
§DOM{1:lc(start,pause,stop,restart);2:obs(log,metric,trace);3:safety(scope,perm,kill_sw);4:chg(rollout,rollback,audit)}
§CTRL{immut_artif;min_priv;env_sec;hard(timeout,retry);audit(high_risk)}
§MET{succ_rate;retries/task;TTR;cost/succ;fail_dist}
§IR{spike⇒1:freeze→2:traces→3:isolate→4:min_patch→5:reg+sec→6:resume}
§REL{PM2|systemd;`devops-iac/references/kubernetes.md`;`devops-iac/references/github-actions.md`;`devops-iac/references/observability.md`;`references/agent-security-hardening.md`}
