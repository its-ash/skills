@REF:operations-checklist
§REL{parent:../SKILL.md,obs:observability.md,rollout:deployment-patterns.md}
§OBS{metrics:Prometheus_Operator→scrape_app;logs:container→CloudWatch|Azure_Monitor|Elasticsearch;traces:OTel_SDK→Jaeger|AWS_X-Ray;dash:Grafana[latency,err_rate,CPU,mem];alerts:SLO(e.g.err_rate>1%@5m)}
§SEC{secrets:AWS_Secrets_Manager|Azure_Key_Vault|GCP_Secret_Manager;git:SOPS(YAML|JSON);iam:least_priv(∀svc∧CI_runners)+sched_rotation;scan:CI(Checkov|tfsec|Terrascan)+drift;net:NetworkPolicy(pod↔pod)+API_RBAC;crypto:at_rest∧in_transit}
§COST{tags:∀res{owner,environment,project};alerts:budget;scale:right_size(util)+autoscale(compute∧DB);spot:spot|preemptible(non_crit);gc:weekly_rm_unused}
§DR{1:RTO∧RPO;2:auto_backup(DB∧state);3:replicate→2nd_region;4:failover_test(quarterly,staged);5:runbooks(exact_cmds);6:train_oncall}
§CHK[delivery]{□reqs(biz,compliance,scale);□arch_diagram(sec_zones);□IaC+remote_backend;□modular_TF+CI(fmt,validate,plan);□per_svc(Helm|Kustomize);□GitOps(ArgoCD|Flux);□CI(lint→test→sec_scan→plan→gated_apply);□obs(Prom+Grafana+logs+SLI/SLO_alerts);□secrets(mgr+encrypted_repo);□cost(tags+budget_alerts);□DR(strategy,backups,runbooks);□post_deploy_review(lessons)}
