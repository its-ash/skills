@REF:api-design
§WHEN{new_public/int_API;refactor;team_stds;pre_code_review;REST→GQL;dev_docs;mobile/3p/svc_opt}
§FLOW{1:consumers→2:use_cases(ops,shapes,perf)→3:constraints(latency,payload,sec,backcompat)→4:style(§D)→5:model(REST:nouns/hier|GQL:schema,nulls,depth|tRPC:TS→procs)→6:envelope({data,error,?meta})→7:ver(§VER)→8:pag(§PAG)→9:auth(§AUTH)→10:RL(§RL)→11:docs(§DOC)→12:val(`swagger-cli validate openapi.yaml`|`graphql-schema-linter`)→13:OWASP_API_Top10+role_checks}
§D{
REST:use(CRUD,pub_API,HTTP_cache)|ctrl(fixed_ep,lim_shape)|cache(HTTP_hdrs)|cplx(low)|tools(OpenAPI,Swagger_UI,Postman)|avoid(dyn_queries∨many_joins);
GraphQL:use(flex_queries,no_overfetch,agg)|ctrl(client_fields+depth)|cache(persisted|custom)|cplx(schema,resolvers,depth_lim)|tools(Apollo,GQL_Codegen)|avoid(simple_CRUD);
tRPC:use(TS_monorepo,int_svc,E2E_types)|ctrl(fn_calls,compile_types)|cache(in_proc,rare_ext)|cplx(min_runtime,TS_only)|tools(tRPC,tsc)|avoid(mixed_lang∨pub_API)
}
§R{
REST_URL:plural,lowercase,kebab-case_nouns(`/api/v1/team-members`,ownership:`/api/v1/users/:id/orders`,verb_only_nonCRUD:`POST /api/v1/orders/:id/cancel`,`POST /api/v1/auth/refresh`);BAD:`/api/v1/getUsers`,`/api/v1/user`,`/api/v1/team_members`;
METHODS:GET(idemp,safe:read)|POST(¬idemp,¬safe:create/act)|PUT(idemp,¬safe:replace)|PATCH(¬idemp[can_be],¬safe:partial)|DELETE(idemp,¬safe:del);
STATUS:200(GET/PUT/PATCH_body)|201(POST+`Location`)|204(DELETE/PUT_no_body)|400(bad_JSON/syntax)|401(unauth)|403(forbidden)|404(not_found)|409(conflict)|422(valid_JSON_val_fail)|429(RL+`Retry-After`)|500(unexpected,no_details)|502(upstream)|503(overload+`Retry-After`);¬200+`"success":false`;¬500_for_val;
GQL:`/graphql`;`!`only_if_guaranteed;depth_limit(e.g.7)+cost_cplx;authz_in_resolvers(¬directives_only);DataLoader(batch+cache);
tRPC:export_procs_from_TS;verb_free_names;share_types_client↔server
}
§PAT{
req:`GET /users/123/orders?limit=20&cursor=abc`+`Accept: application/json`;
env:pub=`{data,meta,links}`|std=`{"data":...,"error":null,"meta":{...}}`|int=direct+HTTP_status;
err:`{"code":"ERR_NOT_FOUND","message":"User not found","details":{"id":"123"}}`;
err_val:`{"error":{"code":"validation_error","message":"Request validation failed","details":[{"field":"email","message":"Must be a valid email address","code":"invalid_format"}]}}`;
GQL:`type User { id: ID! name: String! email: String! orders(first: Int, after: String): OrderConnection! }`;
tRPC:`export const user=createRouter().query('getById',{input:z.string(),resolve({input}){return db.user.findUnique({where:{id:input}})}})`;
§PAG:cursor=`{"data":[...],"meta":{"nextCursor":"xyz","hasMore":true}}` (`SELECT * FROM users WHERE id > :cursor_id ORDER BY id ASC LIMIT 21;` +1→`has_next`;large_OFFSET=slow+unstable_on_inserts);offset=`meta:{page,pageSize,totalCount}`;pick:offset(<10K|admin|search)|cursor(scroll|feeds|large|pub_default[+opt_offset]);
query:`?status=active&customer_id=abc-123`|`?price[gte]=10&price[lte]=100`|`?category=electronics,clothing`|`?sort=-featured,price,-created_at`(`-`=desc)|`?q=wireless+headphones`|`?fields=id,name,email`
}
§VER{URI(`/v1/users`)|Header(`Accept: application/vnd.myapi.v2+json`)|Query(`/users?api-version=3`);start`/api/v1/`;max_2_active(curr+prev);deprecate⇒announce(6mo_pub)+`Sunset`→`410 Gone`;keep_old≥1_cycle;non_break(+resp_fields,+opt_params,+ep);break(rm/ren_fields,Δ_types,Δ_URL,Δ_auth)}
§AUTH{JWT(short,RS256);OAuth2(AuthCode_3p);API_Keys(S2S,rotate);Passkeys/WebAuthn(high_sec);resource_checks_in_resolvers/mw(¬gw_only)}
§RL{token_bucket(burst+refill)|sliding_window(strict);per_client∨per_IP;200:`X-RateLimit-Limit:100`,`X-RateLimit-Remaining:95`,`X-RateLimit-Reset:1640000000`;429+`Retry-After:60`;tiers:Anon=30/m(IP)|Auth=100/m(User)|Prem=1000/m(Key)|Int=10000/m(Svc)}
§DOC{REST⇒OpenAPI3.0+SwaggerUI/Redoc;GQL⇒SDL+Playground/GraphiQL;tRPC⇒`.d.ts`+npm_pkg;version_w/_contract}
§SEC{OWASP_API_Top10:schema_val;least_priv/ep;¬excess_data;RL+throttle;HTTPS;prod_disable_GQL_introspection(unless_needed);log_auth_fail+monitor;test(inj,BOLA,mass_assign)}
§EX{
```ts
const createUserSchema=z.object({email:z.string().email(),name:z.string().min(1).max(100)});
export async function POST(req:NextRequest){
  const p=createUserSchema.safeParse(await req.json().catch(()=>null));
  if(!p.success)return NextResponse.json({error:{code:"validation_error",message:"Request validation failed",details:p.error.issues.map(i=>({field:i.path.join("."),message:i.message,code:i.code}))}},{status:422});
  const u=await createUser(p.data);
  return NextResponse.json({data:u},{status:201,headers:{Location:`/api/v1/users/${u.id}`}});
}
```
}
§ANTI{REST_for_all;verbs_in_URL(`/createUser`);inconsistent_env;expose_stacks/SQL_errs;no_RL/GQL_depth_lim;authz_directives_only;all_GQL_nullable;no_ver/deprecation_plan}
§CHK{consumers+reqs;style(REST|GQL|tRPC);plural_kebab_nouns;method+status;schema_val(Zod|Pydantic|BeanVal);std_env+err_codes+no_internals;consistent_case(camel|snake);paginated_lists;auth+ownership;RL+429;ver+deprecation;OpenAPI/SDL+docs;val(`swagger-cli validate openapi.yaml`|`graphql-schema-linter`);OWASP_Top10+stakeholder_review}
§REL{backend-development/references/contract-first.md}
