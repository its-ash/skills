@REF:cloudflare-deploy
§SCOPE{deploy|host|publish|setup@CF:serverless,static,storage,AI,net,sec,media,IaC}
§PRE{net:outbound(sandbox_block⇒prompt_user→`sandbox_permissions=require_escalated`);timeout:>def(≥300s)}
§AUTH{
  pre:`npx wrangler whoami`;
  local:`wrangler login`(OAuth);
  CI:`CLOUDFLARE_API_TOKEN`(perm:`Account Settings → API Tokens → Edit`)
}
§SEL{
  compute:{
    serverless_edge⇒Workers(`npx wrangler deploy`);
    fullstack_git⇒Pages(`npx wrangler pages deploy ./public`);
    stateful_rt⇒Durable_Objects(DO_class→deploy_w_Workers);
    multistep_jobs⇒Workflows(`npx wrangler workflows deploy`);
    containers⇒Containers(`npx wrangler containers deploy`);
    multitenant_code⇒Workers_for_Platforms(SDK,per_tenant);
    cron⇒Cron_Triggers(`wrangler.toml:triggers.cron`);
    edge_req_mod⇒Snippets(script→publish);
    logs⇒Tail_Workers(`npx wrangler tail`);
    backend_lat⇒Smart_Placement(`wrangler.toml:smart_placement`)
  };
  data:{KV(cfg/sess/cache),D1(SQLite),Hyperdrive(PG/MySQL),R2(S3_obj),Queues(async_msg),Vectorize(vectors),Durable_Objects(strong_entity_state),Secrets_Store,Pipelines(ETL→R2),Cache_Reserve(long_cache)};
  ai:{Workers_AI(LLM/embed/img),Vectorize(RAG),Agents_SDK(stateful_agents),AI_Gateway(route/cache),AI_Search(widget)};
  net:{Tunnel(local_expose),Spectrum(TCP/UDP),TURN(WebRTC),Network_Interconnect(private_cloud),Argo_Smart_Routing(global_accel),Smart_Placement(backend_lat_not_user),RealtimeKit|Realtime_SFU(rt_AV)};
  sec:{WAF,DDoS,Bot_Management,API_Shield(schema_val),Turnstile(no_CAPTCHA),WAF(managed_ruleset,cred_leak)};
  media:{Images(opt/xform),Stream(video/encode),Browser_Rendering(auto/shot),Zaraz(3p_scripts)}
}
§IAC{
  pulumi:TS|Py|Go|.NET→`pulumi up`;
  tf:`provider "cloudflare"{api_token=var.cloudflare_api_token}`;
  rest:`https://api.cloudflare.com/client/v4/…`(Bearer)
}
§ERR{
  timeout|dns|reset⇒prompt_user→`npx wrangler deploy --sandbox-permissions=require_escalated`;
  auth⇒`wrangler login`∨check(`CLOUDFLARE_API_TOKEN`);
  no_kv⇒`npx wrangler kv:namespace create "MY_KV"`→bind(`wrangler.toml`);
  pages_fail⇒build→`dist/`∧`wrangler.toml`→`dist/`;
  429⇒backoff(`Retry-After`)
}
§CHK{`wrangler whoami`==acct;CI⇒`CLOUDFLARE_API_TOKEN`;prod∈§SEL;`wrangler.toml`{bindings(KV/D1/R2),triggers(cron/routes/custom_domains)};`wrangler deploy`|`pages deploy`(timeout≥300s);net_fail⇒escalate;smoke_test}
§REL{[devops-iac](../SKILL.md);[cloud-architecture](cloud-architecture.md);[observability](observability.md)}
