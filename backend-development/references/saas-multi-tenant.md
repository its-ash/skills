@REF:saas-multi-tenant
§WHEN{SaaS_shared_PG_DB;¬cross_tenant_leak;auto_tenant_scope;model_choice;admin_cross_tenant;add_tenant_id_migration;Express|Fastify|NextAPI|Prisma|Drizzle}
§MOD{
  n_tenants<1000⇒shared_schema+tenant_id;
  strong_ops_iso⇒schema_per_tenant;
  reg_residency⇒db_per_tenant
}
§SCH{
  tenants(id,name,slug,plan_id,created_at,deleted_at);
  ∀tenant_tbl:tenant_id:UUID|TEXT,NOT NULL,PK≠serial_int(use_UUID,¬enum);
  ∀composite_idx:leading_col=tenant_id(e.g.CREATE INDEX ON invoices(tenant_id,created_at));
  GLOBAL_TABLES=const_set|DB_tbl(e.g.Plan,FeatureFlag,SystemConfig)⇒shared_by{ORM_mw,CI_lint,GDPR_export}
}
§RLS{
  ```sql
  ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
  ALTER TABLE projects FORCE ROW LEVEL SECURITY;
  CREATE POLICY tenant_isolation ON projects USING (tenant_id = current_setting('app.current_tenant_id')::uuid);
  CREATE POLICY tenant_insert ON projects FOR INSERT WITH CHECK (tenant_id = current_setting('app.current_tenant_id')::uuid);
  ```
}
§MW_REQ{
  1:tenantId=req.auth?.tenantId(JWT|session);¬tenantId⇒403{error:"No tenant context"};
  2:client=pool.connect()→BEGIN→SELECT set_config('app.current_tenant_id',$1,true),[tenantId] (∨ SET LOCAL app.current_tenant_id='...');
  3:req.db=client;req.tenantId=tenantId;
  4:res.on("finish")⇒COMMIT(catch→ROLLBACK)→client.release();
  5:catch(e)⇒ROLLBACK.catch(noop)→client.release()→next(e)
}
§ORM_PRISMA{
  ```ts
  const GLOBAL_TABLES = new Set(["Plan", "FeatureFlag", "SystemConfig"]);
  export function createTenantPrisma(tenantId: string): PrismaClient {
    const prisma = new PrismaClient();
    prisma.$use(async (params, next) => {
      if (GLOBAL_TABLES.has(params.model ?? "")) return next(params);
      params.args = params.args ?? {};
      params.args.where = params.args.where ?? {};
      if (["findMany","findFirst","count","aggregate","update","updateMany","delete","deleteMany"].includes(params.action))
        params.args.where = { ...params.args.where, tenantId };
      if (params.action === "createMany") params.args.data = params.args.data.map((d: any) => ({ ...d, tenantId }));
      else if (params.action === "create") params.args.data = { ...params.args.data, tenantId };
      return next(params);
    });
    return prisma;
  }
  ```
}
§PAT{
  CI_mig_lint:scan_sql⇒CREATE_TABLE∧¬tenant_id∧tbl∉GLOBAL_TABLES⇒FAIL("Migration creates tenant-scoped table without tenant_id");
  mig_conn:superuser|bypassrls(¬RLS_enabled_conn);
  admin_routes:role=admin_bypass(bypassrls)→SET LOCAL role='admin_bypass'+separate_admin_auth(diff_JWT_issuer|API_key|OAuth_client)∧¬regular_tenant_JWT;
  provision:BEGIN→INSERT tenants(id,name,slug,plan_id)→INSERT users(id,tenant_id,email,role='owner')→seed_defaults_flags→COMMIT;
  bg_jobs:payload+=tenantId→connect→BEGIN→set_config('app.current_tenant_id')→run→COMMIT→release(multi_tenant⇒loop_per_tenant);
  routing:subdomain(acme.myapp.com)|path(/org/acme)→tenant_id_in_edge_mw(cache~60s);
  rate_limit:Redis_sliding_window,key=`ratelimit:{tenant_id}:{endpoint}`;
  test:seed≥3_tenants→assert_0_cross_tenant_leak
}
§EDGE{
  tenant_del⇒soft_del(deleted_at)+revoke_sessions+bg_chunked_batch_delete;
  GDPR_export⇒manifest(tenant_tbls)→∀tbl:WHERE tenant_id=$1→bundle(CSV|JSON|archive);
  shared_mktplace_res⇒col=owner_tenant_id;RLS:read_open,write_requires_owner_tenant_id;
  schema_per_tenant_scale⇒¬1_pool/schema;use_PgBouncer(transaction_pooling)∨migrate→shared_schema_before_hundreds
}
§ANTI{
  ¬query_without_tenant_id_filter(even_w_mw);
  ¬app_filter_only(always_enforce_RLS);
  ¬auto_inc_int_PK(use_UUID);
  ¬regular_JWT_on_admin_endpoints;
  ¬migrations_under_RLS;
  ¬share_pooled_conn_without_resetting_app.current_tenant_id
}
§CHK{
  model_fits_scale_iso;∀tbl:tenant_id(NOT NULL,UUID)+leading_idx;RLS+FORCE_RLS;mw_sets_app.current_tenant_id;ORM_mw_reads_writes;CI_mig_lint;admin_bypassrls+sep_auth;1_txn_provision;bg_job_ctx;routing_cached;GLOBAL_TABLES_current;tests≥3_tenants;per_tenant_ratelimit
}
