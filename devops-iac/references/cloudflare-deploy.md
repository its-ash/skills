@REF:cloudflare-deploy
§SCOPE{deploy|host|publish|setup@CF(Wrangler_4,`wrangler.jsonc`):Workers+Static_Assets,storage,Containers,AI,net,sec,media,IaC(TF_v5)}
§PRE{net:outbound(sandbox_block⇒prompt_user→`sandbox_permissions=require_escalated`);timeout:>def(≥300s)}
§AUTH{
  pre:`npx wrangler whoami`;
  local:`npx wrangler login`(OAuth);
  CI:`CLOUDFLARE_API_TOKEN`(scoped_least_priv_token,via`cloudflare/wrangler-action@v4`)
}
§CFG[wrangler.jsonc]{
  pref:`wrangler.jsonc`(JSON_Schema_val+comments)≻legacy`wrangler.toml`;
```jsonc
{
  "$schema": "./node_modules/wrangler/config-schema.json",
  "name": "my-app",
  "main": "src/index.ts",
  "compatibility_date": "2026-11-27",
  "assets": { "directory": "./dist" }, // Workers Static Assets (replaces legacy Pages for new apps)
  "observability": { "enabled": true },
  "placement": { "mode": "smart" },
  "kv_namespaces": [{ "binding": "MY_KV", "id": "<from-terraform-or-cli>" }]
}
```
}
§SEL{
  compute:{
    serverless_edge|static|fullstack⇒Workers+Static_Assets(`npx wrangler deploy`,pref_over_legacy_Pages);
    legacy_pages⇒Pages(`npx wrangler pages deploy ./dist`,existing_projects_only);
    stateful_rt⇒Durable_Objects(DO_class→deploy_w_Workers);
    multistep_jobs⇒Workflows(`npx wrangler deploy`+`workflows`_binding);
    containers⇒Containers(`wrangler.jsonc`+`npx wrangler deploy`);
    multitenant_code⇒Workers_for_Platforms(SDK,per_tenant);
    cron⇒Cron_Triggers(`wrangler.jsonc:triggers.crons`);
    edge_req_mod⇒Snippets(script→publish);
    logs⇒Tail_Workers(`npx wrangler tail`)⊕OTLP_export;
    backend_lat⇒Smart_Placement(`wrangler.jsonc:{"placement":{"mode":"smart"}}`)
  };
  data:{KV(cfg/sess/cache),D1(SQLite),Hyperdrive(PG/MySQL),R2(S3_obj),Queues(async_msg),Vectorize(vectors),Durable_Objects(strong_entity_state),Secrets_Store,Pipelines(ETL→R2),Cache_Reserve(long_cache)};
  ai:{Workers_AI(LLM/embed/img),Vectorize(RAG),Agents_SDK(stateful_agents),AI_Gateway(route/cache),AI_Search(widget)};
  net:{Tunnel(local_expose),Spectrum(TCP/UDP),TURN(WebRTC),Network_Interconnect(private_cloud),Argo_Smart_Routing(global_accel),Smart_Placement(backend_lat_not_user),RealtimeKit|Realtime_SFU(rt_AV)};
  sec:{WAF,DDoS,Bot_Management,API_Shield(schema_val),Turnstile(no_CAPTCHA),WAF(managed_ruleset,cred_leak)};
  media:{Images(opt/xform),Stream(video/encode),Browser_Rendering(auto/shot),Zaraz(3p_scripts)}
}
§IAC{
  tf_v5(OpenAPI_generated_schemas,`cloudflare/cloudflare`~>`5.0`):
```hcl
terraform { required_providers { cloudflare = { source = "cloudflare/cloudflare", version = "~> 5.0" } } }
provider "cloudflare" { api_token = var.cloudflare_api_token }
resource "cloudflare_workers_kv_namespace" "my_kv" { account_id = var.account_id, title = "prod-kv" }
```;
  pulumi:TS|Py|Go|.NET→`pulumi up`;
  rest:`https://api.cloudflare.com/client/v4/…`(Bearer);
  rule:provision_KV/D1/R2/Zones_via_TF_v5→inject_IDs_in_CI(¬manual_CLI_creation_in_prod)
}
§ERR{
  timeout|dns|reset⇒prompt_user→`npx wrangler deploy --sandbox-permissions=require_escalated`;
  auth⇒`npx wrangler login`∨check(`CLOUDFLARE_API_TOKEN`);
  no_kv⇒`npx wrangler kv namespace create "MY_KV"`(Wrangler_4_space_syntax;¬removed`kv:namespace`)→bind(`wrangler.jsonc`);
  assets_fail⇒build→`dist/`∧`wrangler.jsonc:{"assets":{"directory":"./dist"}}`;
  429⇒backoff(`Retry-After`)
}
§ANTI{legacy`wrangler kv:namespace`(colon_dropped_in_Wrangler_4);new_projects_on_legacy_Pages(⇒Workers+Static_Assets);unvalidated`wrangler.toml`_without_schema(⇒`wrangler.jsonc`);hardcoded_manual_resource_IDs_bypassing_TF_v5}
§CHK{`wrangler whoami`==acct;CI⇒`CLOUDFLARE_API_TOKEN`+`wrangler-action@v4`;`wrangler.jsonc`+`$schema`+`compatibility_date`+`observability`;Workers+Static_Assets_for_new_apps;space_syntax`kv namespace`;TF_v5_for_infra;`wrangler deploy`(timeout≥300s);smoke_test}
§REL{[devops-iac](../SKILL.md);[cloud-architecture](cloud-architecture.md);[observability](observability.md)}
