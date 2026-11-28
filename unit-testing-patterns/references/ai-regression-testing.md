@REF:ai-regression-testing
§TRIG{
  AI_agent(ClaudeCode|Cursor|Codex|Antigravity)Δ(API_routes∨backend);
  bug_fixed⇒prevent_reintro;
  sandbox_mode_exists⇒DB_free_API_tests;
  post_Δ_bug_check;
  multi_path(sandbox|prod|feature_flags)
}
§CORE{
  same_model(write∧review)⇒shared_blind_spots⇒AI_review_misses_bug;
  deterministic_tests>same_model_self_review;
  #1_AI_regression(3/4):sandbox_vs_prod_path_inconsistency
}
§CFG{
  `vitest.config.ts`(Vitest5:Node≥22.12,`clearMocks:true`_default,artifacts→`.vitest/`):
  ```ts
  import { defineConfig } from "vitest/config";
  import path from "node:path";
  export default defineConfig({
    test: { environment: "node", globals: true, include: ["__tests__/**/*.test.ts"], setupFiles: ["__tests__/setup.ts"] },
    resolve: { alias: { "@": path.resolve(import.meta.dirname, ".") } },
  });
  ```
  `__tests__/setup.ts`:
  ```ts
  process.env.SANDBOX_MODE = "true";
  process.env.NEXT_PUBLIC_SUPABASE_URL = "";
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY = "";
  ```
}
§HELPER{
  `__tests__/helpers.ts`:
  ```ts
  import { NextRequest } from "next/server";
  export function createTestRequest(url: string, options?: { method?: string; body?: Record<string, unknown>; headers?: Record<string, string>; sandboxUserId?: string }): NextRequest {
    const { method = "GET", body, headers = {}, sandboxUserId } = options ?? {};
    const fullUrl = url.startsWith("http") ? url : `http://localhost:3000${url}`;
    const reqHeaders: Record<string, string> = { ...headers };
    if (sandboxUserId) reqHeaders["x-sandbox-user-id"] = sandboxUserId;
    const init: { method: string; headers: Record<string, string>; body?: string } = { method, headers: reqHeaders };
    if (body) { init.body = JSON.stringify(body); reqHeaders["content-type"] = "application/json"; }
    return new NextRequest(fullUrl, init);
  }
  export async function parseResponse(res: Response) { return { status: res.status, json: await res.json() }; }
  ```
}
§PAT{
  contract_regression(`__tests__/api/user/profile.test.ts`):
  ```ts
  const REQUIRED_FIELDS = ["id","email","full_name","phone","role","created_at","avatar_url","notification_settings"];
  it("returns all required fields", async () => {
    const { status, json } = await parseResponse(await GET(createTestRequest("/api/user/profile")));
    expect(status).toBe(200);
    for (const f of REQUIRED_FIELDS) expect(json.data).toHaveProperty(f);
  });
  it("notification_settings is not undefined (BUG-R1 regression)", async () => {
    const { json } = await parseResponse(await GET(createTestRequest("/api/user/profile")));
    expect("notification_settings" in json.data).toBe(true);
    const ns = json.data.notification_settings;
    expect(ns === null || typeof ns === "object").toBe(true);
  });
  ```
  schema_contract(Zod/OpenAPI):`expect(UserProfileSchema.safeParse(json.data).success).toBe(true)`(catches_missing_keys+type_drift+nullability_bugs_simultaneously);
  sandbox_prod_parity:
  ```ts
  const { json } = await parseResponse(await GET(createTestRequest("/api/user/messages", { sandboxUserId: "user-001" })));
  if (json.data.length > 0) for (const conv of json.data) expect("partner_name" in conv).toBe(true);
  ```
}
§FLOW{
  1[mandatory,¬skip]:`vitest run`(or_`pytest`) ∧ typecheck/build(`npm run build`); fail⇒highest_priority_bug∧STOP;
  2[pass⇒AI_review]:check{sandbox/prod_consistency,API_shape≡FE_schema,SELECT_completeness,err_rollback,optimistic_race,mock_schema_parity};
  3[∀fix]:write_regression_test(pre-fix_RED⇒post-fix_GREEN)⇒next_bug_check_catches_recurrence
}
§ANTI{
  sandbox_prod_mismatch[High,3/4]:`isSandboxMode()`_branch_omits_new_field ⇒ return_identical_shape(e.g.`field:null`) ∧ assert(schema∨`REQUIRED_FIELDS`,sandbox_mode);
  select_omission[High,Supabase/Prisma]:`.select("id, email, name")`⇒new_col=`undefined` ⇒ explicit_shared_cols∨`.select("*")` ∧ assert(schema∨`REQUIRED_FIELDS`);
  err_state_leakage[Med]:`catch{setError(...)}`leaves_stale_data ⇒ clear_state(e.g.`setReservations([])`)∧`setError(...)` ∧ assert_cleanup_on_err;
  optimistic_no_rollback[Med]:filter_state→`await fetch(DELETE)`_fails⇒UI/DB_desync ⇒ `prev=[...items]`;`if(!res.ok)throw`;`catch{setItems(prev);notify(...)}` ∧ assert_restore_on_fail;
  type_cast_masks_null[Med]:`as Type`_hides_missing_field ⇒ assert(`"field" in obj`)∧schema_`safeParse`∧¬`undefined`;
  mock_drift[Med]:AI_writes_mock_matching_broken_assumption ⇒ validate_mock_fixtures_against_shared_Zod/OpenAPI_schema
}
§R{
  test_where_bugs_found¬100%_coverage:bug∈route⇒add_test;no_bug⇒skip_for_now;
  AI_repeats_mistake_cats∈{auth,multi_path,state_mgmt,contract_drift};
  DO:write_test_immediately(pre_fix_RED);test_response_contract¬impl;run_tests_first_in_bug_check;keep_suite<1s(sandbox);name_after_bug_ID(`BUG-R1 regression`);
  DONT:test_bug_free_code;trust_AI_self_review_over_tests;skip_sandbox_path;write_integration_when_unit_suffices;chase_coverage_%
}
