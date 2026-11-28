---
name: devops-iac
description: "AUTO_INVOKE(silent)⇔prompt∈{IaC,Terraform,OpenTofu,.tf,hcl,Pulumi,AWS_CDK,CFN,k8s,Kubernetes,EKS,GKE,AKS,kubectl,Helm,Kustomize,Gateway_API,Karpenter,GitOps,ArgoCD,Flux,Istio,Docker,Dockerfile,Compose,BuildKit,GitHub_Actions,.github/workflows,CI/CD,OIDC,GitLab_CI,Cloudflare,Workers,wrangler,D1,KV,R2,Ansible,Uncloud,uc,Flox,Prometheus,Grafana,OTel,Datadog,Trivy,SLO,IAM,RBAC,SOPS,FinOps,AWS,GCP,Azure,RTO,RPO,DR,spot,blue-green,canary,drift}|SUB:{terraform,github-actions,kubernetes,docker,cloud-architecture,cloudflare-deploy,observability,deployment-patterns,flox-environments,uncloud}"
---
@SKL:devops-iac
§R{
  ∀cloud_infra(provision,deploy,operate)⇐code∈Git;
  phases:req(scale,compliance,budget,deps)→arch(regions,HA_zones,net,sec_bounds,data_stores,diagram)→IaC→deploy→CI/CD→obs→sec→cost→DR;
  ∀(infra,manifests)⇒declarative∧∈Git;∀Δk8s⇒GitOps;
  tf_state⇒remote∧encrypted∧native_lock(S3:`use_lockfile=true`,¬deprecated`dynamodb_table`);tf_code⇒split(modules);
  tf_secrets⇒`ephemeral`+write_only(`*_wo`,¬in_state);repo_secrets⇒SOPS∧cloud_secret_mgr;¬commit(plain_secrets);
  ∀commit⇒tf|tofu(fmt∧validate);CI⇒test→IaC_sec_scan(Trivy|Checkov,¬tfsec)→plan→gated_apply(saved_plan,env_protection);
  CI_sec⇒OIDC(keyless,scoped`sub`,¬static_cloud_keys)∧pin_actions(40char_SHA`# vX.Y.Z`,¬`@master`)∧min_permissions;
  infra⇒immutable;replace(pods,instances)∧¬patch_live;containers⇒non_root∧pinned∧multistage∧Compose_V2(¬obsolete`version:`);
  k8s_net⇒Gateway_API(`gateway.networking.k8s.io/v1`,¬`ingress-nginx`[EOL_Mar_2026]);k8s_pkg⇒Helm_4(SSA,OCI)⊕Kustomize;
  k8s_sec⇒PSS(Restricted)∧least_priv_RBAC(`automountServiceAccountToken:false`)∧default_deny_NetworkPolicy∧ValidatingAdmissionPolicy(CEL);
  ∀IAM(incl:CI_runners,workload_id)⇒least_privilege;
  obs⇒OTel/OTLP_native(Prometheus_3`--web.enable-otlp-receiver`,Loki,Tempo,Grafana`timeseries`+Unified_Alerting);alert⇒SLO_burn¬raw_noise;
  FinOps⇒enforce_tags{owner,environment,project}∧budget_alerts∧right_size/autoscale(HPA,KEDA,Karpenter);
  DR⇒define(RTO,RPO)∧automate(cross_region_backups)∧test(failover,quarterly)∧runbooks;
}
§D{
  multi_cloud⇒Terraform(1.17,≥1.11)⊕OpenTofu(1.13)⊕Pulumi ¬provider_native_IaC_per_cloud;
  AWS_only⇒Terraform⊕OpenTofu⊕AWS_CDK⊕CFN ¬console_click_ops;
  TF_S3_lock⇒`use_lockfile=true`(native_S3) ¬`dynamodb_table`(deprecated);
  IaC_sec_scan⇒Trivy(`trivy config`)⊕Checkov ¬tfsec(deprecated);
  CI_cloud_auth⇒OIDC(`id-token:write`,scoped`sub`) ¬static_cloud_API_keys;
  container_orch@scale⇒Kubernetes(EKS,GKE,AKS) ¬unneeded_self_managed_control_plane;
  k8s_ingress⇒Gateway_API(Envoy_Gateway|Cilium|Traefik) ¬ingress-nginx(EOL_Mar_2026);
  k8s_node_scale⇒Karpenter(v1+) ¬static_nodegroups;
  simple_container_host⇒ECS⊕Cloud_Run⊕Azure_App_Service ¬k8s_for_1_small_svc;
  small_self_hosted_cluster+Compose⇒Uncloud ¬full_k8s;
  edge_apps∨Workers∨static_sites⇒Cloudflare_Workers+Static_Assets(`wrangler.jsonc`,Wrangler_4) ¬legacy_Pages_for_new_apps∨generic_VMs;
  config_mgmt⇒Ansible⊕native_cloud_tools ¬ad_hoc_SSH_scripts;
  GitOps⇒Argo_CD⊕Flux ¬kubectl_apply_from_laptops;
  CI/CD⇒GitHub_Actions⊕GitLab_CI ¬manual_deploys;
  reusable_app_pkg∨env_diffs⇒Helm_4(SSA,OCI)⊕Kustomize_overlays ¬copy_pasted_manifests;
  infra_drift_suspected⇒`terraform plan -refresh-only` ¬manual_fixes_in_console;
  non_critical_batch⇒spot⊕preemptible_instances ¬on_demand_default;
}
§REF{
  tf_rules,OpenTofu,use_lockfile,ephemeral_wo,tf_test,IaC_CI_OIDC→references/terraform.md;
  obs_setup,sec,cost,DR,delivery_checklist→references/operations-checklist.md;
  GHA_workflows(Node24_v7,SHA_pin,OIDC,CI,deploy,scans,schedules)→references/github-actions.md;
  cluster_design,Gateway_API,Helm4,Karpenter,native_sidecars,CEL_policy,GitOps,manifests,kubectl_dbg→references/kubernetes.md;
  Dockerfiles(Node26,Distroless,uv,PG18_vol),Compose_V2,BuildKit,hardening→references/docker.md;
  AWS,Azure,GCP_arch,reliability,sec,FinOps→references/cloud-architecture.md;
  CF_Workers_Static_Assets,Wrangler4,wrangler.jsonc,D1,KV,R2,Containers,TF_v5→references/cloudflare-deploy.md;
  metrics,logs,traces,Prom3_OTLP,LGTM,Grafana_Unified_Alerting,SLO,Datadog_CLI→references/observability.md;
  rolling,blue_green,canary,health_checks,rollback,prod_readiness→references/deployment-patterns.md;
  reproducible_dev_env,Flox,flox_build,containerize→references/flox-environments.md;
  Uncloud_cluster,uc_CLI,WireGuard,Caddy,PG18_vol→references/uncloud.md;
}
§REL{
  ../backend-development/SKILL.md:services,APIs_on_infra;
  ../secure-coding/SKILL.md:secrets,auth,cloud_sec_hardening;
  ../git-workflow/SKILL.md:branching,releases,GitOps_repos;
}
