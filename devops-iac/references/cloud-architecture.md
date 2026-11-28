@REF:cloud-architecture
§D{scope:AWS|Azure|GCP,IaC,FinOps,resilient/secure/cost-aware;use⇔new_env|redesign|migration|cost/perf/compliance|serverless/microservices/event_driven|multi_cloud|hybrid}
§FLOW{
  1:reqs(goals,traffic,latency,residency,compliance);
  2:providers(match_services;doc_multi/hybrid_why);
  3:pattern(microservices|serverless|event_driven|data_lake);
  4:net(VPC/VNet,subnets,routes,peering;reserve_CIDR_growth);
  5:sec(least_IAM,OIDC/workload_id,enc_rest+transit,baselines∈{"AWS Config","Azure Policy","GCP Organization Policy"});
  6:resilience(multi_AZ|region,backup/snapshot/PITR,RPO/RTO);
  7:cost+tags(calculators;req:{Environment,Owner,CostCenter});
  8:IaC(Terraform_1.17|OpenTofu_1.13|CDK|Pulumi|Bicep|CFN;dirs:modules/+environments/);
  9:CICD(OIDC,plan,apply,scan∈{Trivy,Checkov,OPA},tests∈{terraform_test,Terratest});
  10:obs(OTel/OTLP:metrics,logs,tracing;alerts:SLO_burn,cost_spikes,sec);
  11:validate(terraform_test|Terratest|InSpec,DR_drill);
  12:docs(diagram,ADR,runbooks)
}
§R{
  IAM:least_priv(¬"*")∧workload_identity(EKS_Pod_Identity/IRSA,GKE_WIF,Azure_Workload_ID)∧CI_OIDC(¬static_keys);
  compute:managed_first;
  HA:critical/stateful⇒≥2_AZs;
  spot:Spot/Preemptible∈{batch,dev,fault_tolerant};
  tags:enforce_at_create;block_untagged;
  crypto:enc_rest(storage)+TLS(transit);
  pillars:Well-Architected∈{operational_excellence,security,reliability,performance_efficiency,cost_optimization};
  state:versioned+native_locked∈{"S3 use_lockfile=true (¬deprecated DynamoDB)","Azure Storage+lease","GCS+object versioning"};
  ROI:provision⇔perf_gain>10%∧cost_delta<15%;
  multi_cloud_repl:e2e_latency<500ms(real_time)
}
§PAT{
  tf:```hcl
  terraform {
    required_version = ">= 1.11.0"
    backend "s3" { bucket = "my-terraform-state", key = "envs/prod/terraform.tfstate", region = "us-east-1", encrypt = true, use_lockfile = true }
  }
  module "vpc" { source = "./modules/vpc", cidr = var.vpc_cidr }
  ```;
  cdk_api:```ts
  import * as cdk from 'aws-cdk-lib';
  import * as apigw from 'aws-cdk-lib/aws-apigateway';
  import * as lambda from 'aws-cdk-lib/aws-lambda';
  export class ServerlessApi extends cdk.Stack {
    constructor(s: cdk.App, id: string, p?: cdk.StackProps) {
      super(s, id, p);
      const fn = new lambda.Function(this, 'Handler', { runtime: lambda.Runtime.NODEJS_26_X, code: lambda.Code.fromAsset('lambda'), handler: 'index.handler' });
      new apigw.LambdaRestApi(this, 'Api', { handler: fn });
    }
  }
  ```;
  event_aws:SNS|EventBridge→SQS/Lambda→DynamoDB(+DLQ);
  mesh_ingress:Gateway_API+Istio|Cilium_mTLS(¬EOL`ingress-nginx`)
}
§ANTI{¬hardcoded_secrets;¬static_CI_IAM_keys(⇒OIDC);¬`dynamodb_table`_TF_lock(deprecated⇒`use_lockfile=true`);¬`tfsec`(deprecated⇒Trivy);¬EOL_Lambda_runtimes(Node18/20);¬overprovision_unrightsized;¬IAM_*;¬unencrypted_storage/DB;¬single_AZ_stateful;¬untagged_cost;¬unlocked_state(race);¬single_region_DR;¬CI_no_sec_scan}
§CHK{[reqs_doc,provider_why,diagram(net/compute/data),CIDR_margin,least_IAM+OIDC,enc_rest+transit,multi_AZ/region,backup/snapshots,cost_tags_all,IaC(modules/+environments/),native_locked_state,CICD(OIDC,plan,apply,Trivy/Checkov,tests),alerts(SLO,cost,sec),DR_runbook+quarterly_drill,versioned_ADR/alts]}
§REL{[devops-iac](../SKILL.md);[software-architecture](../../software-architecture/SKILL.md);[observability](observability.md);[cloudflare-deploy](cloudflare-deploy.md)}
