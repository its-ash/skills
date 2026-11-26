@REF:cloud-architecture
§D{scope:AWS|Azure|GCP,IaC,FinOps,resilient/secure/cost-aware;use⇔new_env|redesign|migration|cost/perf/compliance|serverless/microservices/event_driven|multi_cloud|hybrid}

§FLOW{
  1:reqs(goals,traffic,latency,residency,compliance);
  2:providers(match_services;doc_multi/hybrid_why);
  3:pattern(microservices|serverless|event_driven|data_lake);
  4:net(VPC/VNet,subnets,routes,peering;reserve_CIDR_growth);
  5:sec(least_IAM,enc_rest+transit,baselines∈{"AWS Config","Azure Policy","GCP Organization Policy"});
  6:resilience(multi_AZ|region,backup/snapshot/PITR,RPO/RTO);
  7:cost+tags(calculators;req:{Environment,Owner,CostCenter});
  8:IaC(Terraform|OpenTofu|CDK|Pulumi|ARM|Bicep|CFN;dirs:modules/+environments/);
  9:CICD(plan,apply,scan∈{Checkov,OPA},tests);
  10:obs(metrics,logs,tracing;alerts:cost_spikes+sec);
  11:validate(Terratest|InSpec,DR_drill);
  12:docs(diagram,ADR,runbooks)
}

§R{
  IAM:least_priv(¬"*");
  compute:managed_first;
  HA:critical/stateful⇒≥2_AZs;
  spot:Spot/Preemptible∈{batch,dev,fault_tolerant};
  tags:enforce_at_create;block_untagged;
  crypto:enc_rest(storage)+TLS(transit);
  pillars:Well-Architected∈{operational_excellence,security,reliability,performance_efficiency,cost_optimization};
  state:versioned+locked∈{"S3+DynamoDB lock","Azure Storage+lease","GCS+object versioning"};
  ROI:provision⇔perf_gain>10%∧cost_delta<15%;
  multi_cloud_repl:e2e_latency<500ms(real_time)
}

§PAT{
  tf:```hcl
  terraform{required_version=">= 1.5"
    backend "s3"{bucket="my-terraform-state" key="envs/prod/terraform.tfstate" region="us-east-1" dynamodb_table="tf-lock" encrypt=true}}
  module "vpc"{source="./modules/vpc" cidr=var.vpc_cidr}
  ```
  cdk_api:```ts
  import * as cdk from 'aws-cdk-lib';
  import {LambdaFunction} from 'aws-cdk-lib/aws-events-targets';
  import * as apigw from 'aws-cdk-lib/aws-apigateway';
  import * as lambda from 'aws-cdk-lib/aws-lambda';
  export class ServerlessApi extends cdk.Stack{constructor(s:cdk.App,id:string,p?:cdk.StackProps){super(s,id,p);const fn=new lambda.Function(this,'Handler',{runtime:lambda.Runtime.NODEJS_18_X,code:lambda.Code.fromAsset('lambda'),handler:'index.handler'});new apigw.LambdaRestApi(this,'Api',{handler:fn});}}
  ```
  event_aws:SNS→Lambda→DynamoDB(+DLQ);
  istio:control_plane+VirtualService+DestinationRule/svc+mTLS
}

§ANTI{¬hardcoded_secrets;¬overprovision_unrightsized;¬IAM_*;¬unencrypted_storage/DB;¬single_AZ_stateful;¬untagged_cost;¬unlocked_state(race);¬single_region_DR;¬CI_no_sec_scan}

§CHK{[reqs_doc,provider_why,diagram(net/compute/data),CIDR_margin,least_IAM,enc_rest+transit,multi_AZ/region,backup/snapshots,cost_tags_all,IaC(modules/+environments/),locked_state,CICD(plan,apply,scan,tests),alerts(latency,err,cost),DR_runbook+quarterly_drill,versioned_ADR/alts]}

§REL{[devops-iac](../SKILL.md);[software-architecture](../../software-architecture/SKILL.md);[observability](observability.md);[cloudflare-deploy](cloudflare-deploy.md)}
