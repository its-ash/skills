---
name: devops-iac
description: "AUTO_INVOKE(silent)⇔prompt∈{IaC,Terraform,.tf,hcl,Pulumi,AWS_CDK,CloudFormation,k8s,Kubernetes,EKS,GKE,AKS,kubectl,Helm,Kustomize,GitOps,ArgoCD,Flux,Istio,Linkerd,Docker,Dockerfile,Compose,BuildKit,GitHub_Actions,.github/workflows,CI/CD,GitLab_CI,Jenkins,Cloudflare,Workers,Pages,wrangler,D1,KV,R2,Ansible,Uncloud,uc,Flox,Prometheus,Grafana,Datadog,SLO,IAM,RBAC,SOPS,FinOps,AWS,GCP,Azure,RTO,RPO,DR,backup,failover,spot,blue-green,canary,rolling,drift}|SUB:{github-actions,kubernetes,docker,cloud-architecture,cloudflare-deploy,observability,deployment-patterns,flox-environments,uncloud}"
---
@SKL:devops-iac
§R{
  ∀cloud_infra(provision,deploy,operate)⇐code∈Git;
  phases:req(scale,compliance,budget,deps)→arch(regions,HA_zones,net,sec_bounds,data_stores,diagram)→IaC→deploy→CI/CD→obs→sec→cost→DR;
  ∀(infra,manifests)⇒declarative∧∈Git;∀Δk8s⇒GitOps;
  tf_state⇒remote∧locked∧encrypted;tf_code⇒split(modules);
  ∀commit⇒tf(fmt∧validate);CI⇒tf(plan);apply⇒reviewed(saved_plan)∧gated(env_protection);
  CI_order:lint→test→IaC_sec_scan→plan→gated_apply;
  infra⇒immutable;replace(pods,instances)∧¬patch_live;
  secrets⇒cloud_secret_mgr;repo_secrets⇒SOPS_encrypt;¬commit(plain_secrets);
  ∀IAM(incl:CI_runners)⇒least_privilege;pod_traffic⇒restrict(RBAC∧NetworkPolicy);
  alert⇒SLO∧¬raw_resource_noise;
  ∀res⇒tag{owner,environment,project}∧budget_alerts;
  DR:define(RTO,RPO)∧automate(backups)∧test(failover,quarterly);
}
§D{
  multi_cloud⇒Terraform⊕Pulumi ¬provider_native_IaC_per_cloud;
  AWS_only⇒Terraform⊕AWS_CDK⊕CloudFormation ¬console_click_ops;
  container_orch@scale⇒Kubernetes(EKS,GKE,AKS) ¬unneeded_self_managed_control_plane;
  simple_container_host⇒ECS⊕Cloud_Run⊕Azure_App_Service ¬k8s_for_1_small_svc;
  small_self_hosted_cluster+Compose⇒Uncloud ¬full_k8s;
  edge_apps∨Workers∨Pages⇒Cloudflare+wrangler ¬generic_VMs;
  config_mgmt⇒Ansible⊕native_cloud_tools ¬ad_hoc_SSH_scripts;
  GitOps⇒Argo_CD⊕Flux ¬kubectl_apply_from_laptops;
  CI/CD⇒GitHub_Actions⊕GitLab_CI⊕Jenkins ¬manual_deploys;
  reusable_app_pkg∨env_diffs⇒Helm_chart⊕Kustomize_overlays ¬copy_pasted_manifests;
  infra_drift_suspected⇒`terraform plan -refresh-only` ¬manual_fixes_in_console;
  non_critical_batch⇒spot⊕preemptible_instances ¬on_demand_default;
}
§REF{
  tf_rules,cmds,IaC_CI_gated_apply→references/terraform.md;
  obs_setup,sec,cost,DR,delivery_checklist→references/operations-checklist.md;
  GHA_workflows(CI,tests,lint,deploy,scans,schedules)→references/github-actions.md;
  cluster_design,GitOps,mesh,Deployment,probes,RBAC,HPA,PDB,Jobs_YAML,Helm_values,kubectl_dbg→references/kubernetes.md;
  Dockerfiles,multi_stage_builds,Compose,BuildKit,hardening→references/docker.md;
  AWS,Azure,GCP_arch,reliability,sec,FinOps→references/cloud-architecture.md;
  CF_Workers,Pages,D1,KV,R2,wrangler→references/cloudflare-deploy.md;
  metrics,logs,traces,SLO_alerts,Grafana,Datadog_CLI_triage→references/observability.md;
  rolling,blue_green,canary,health_checks,rollback,prod_readiness→references/deployment-patterns.md;
  reproducible_dev_env,Flox→references/flox-environments.md;
  Uncloud_cluster,uc_CLI→references/uncloud.md;
}
§REL{
  ../backend-development/SKILL.md:services,APIs_on_infra;
  ../secure-coding/SKILL.md:secrets,auth,cloud_sec_hardening;
  ../git-workflow/SKILL.md:branching,releases,GitOps_repos;
}
