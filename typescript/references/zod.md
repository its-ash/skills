@REF:zod

§D{
  ver:Zod_v4(default:native_Standard_Schema,>50%_smaller_bundle,faster_parse,lower_tsc_load);minimal_client/edge⇒`import{z}from"zod/mini"`;v3_migration⇒`zod/v3-compat`;
  when∈{runtime_val(API,form,query),env_vars,RHF(Standard_Schema∨`@hookform/resolvers/zod`),JSON_Schema_export,bidirectional_codecs,cross_field/async_rules,coerce};
  flow:[1:`import{z}from"zod"`,2:schema,3:`z.infer<typeof S>`,4:`safeParse`(pref)∨`parse`,5:`r.data`|`z.flattenError(r.error)`|`z.treeifyError(r.error)`|`z.prettifyError(r.error)`,6:integrate]
}

§PAT{
  primitives:`z.string().min(3).max(255)`,`z.coerce.number().min(18)`,`z.stringbool()`(parses_`"true"|"false"|"1"|"0"`_safely¬`z.coerce.boolean()`),`z.coerce.date()`;
  top_level_formats(v4_tree_shakeable):`z.email()`,`z.uuid()`(strict_RFC;loose⇒`z.guid()`),`z.url()`,`z.iso.datetime()`,`z.iso.date()`,`z.iso.time()`,`z.iso.duration()`;
  object_infer:`const UserSchema=z.object({id:z.uuid(),username:z.string().min(3).max(20),email:z.email(),role:z.enum(["ADMIN","USER","GUEST"]).default("USER"),age:z.number().min(18).optional(),website:z.url().nullable(),tags:z.array(z.string()).min(1)});export type User=z.infer<typeof UserSchema>;`;
  object_strictness(v4):`z.strictObject({...})`(reject_unknown);`z.looseObject({...})`(passthrough_unknown;replaces_v3_`.strict()`/`.passthrough()`/`.nonstrict()`);
  advanced:`z.record(z.string(),z.string())`(2_args_REQUIRED_v4);`z.union([z.string(),z.number()])`;`z.discriminatedUnion("type",[z.object({type:z.literal("create"),id:z.string()}),z.object({type:z.literal("update"),id:z.string(),data:z.unknown()}),z.object({type:z.literal("delete"),id:z.string()})])`;
  recursive_getter(v4):`const Category=z.object({name:z.string(),get subcategories(){return z.array(Category);}});`#replaces_v3_`z.lazy()`+interface_cast;
  codec(v4_2way):`const isoDate=z.codec(z.iso.datetime(),z.date(),{decode:(s)=>new Date(s),encode:(d)=>d.toISOString()});`#`.transform()`≡1way;
  json_schema(v4_native):`const jsonSchema=z.toJSONSchema(UserSchema);`#¬`zod-to-json-schema`;
  parse_vs_safe:`schema.parse(x)`(throws_`z.ZodError`→`e.issues`;`.errors`_removed_v4);`const r=schema.safeParse(x)`(`!r.success`⇒`z.flattenError(r.error)`_forms|`z.treeifyError(r.error)`_nested|`z.prettifyError(r.error)`_CLI/logs);
  custom_err(v4_unified):`z.string({error:(iss)=>iss.input===undefined?"Required":"Must be text"}).min(8,{error:"Min 8 chars"}).regex(/[A-Z]/,{error:"Need uppercase"})`;
  i18n_locales(v4):`z.config(z.locales.en())`#built_in_`z.locales.*`_replaces_v3_`z.setErrorMap`+`z.ZodIssueCode`;
  refine_transform:`z.object({password:z.string().min(8),confirmPassword:z.string()}).refine(d=>d.password===d.confirmPassword,{error:"Passwords do not match",path:["confirmPassword"]})`;`z.string().transform(v=>Number.parseInt(v,10)).refine(v=>!Number.isNaN(v),{error:"Not a valid integer"})`;
  rhf:`useForm<T>({resolver:zodResolver(schema)})`(`react-hook-form`+`@hookform/resolvers/zod`,or_native_Standard_Schema_adapter);
  nextjs_action:```ts
  "use server";
  export async function createPost(_prev: unknown, fd: FormData) {
    const r = createPostSchema.safeParse(Object.fromEntries(fd.entries()));
    if (!r.success) return { errors: z.flattenError(r.error).fieldErrors };
    const { title, content, published } = r.data; // published: z.stringbool().default(false)
    return { success: true, title, content, published };
  }
  ```;
  env:`export const env=z.object({DATABASE_URL:z.url(),NODE_ENV:z.enum(["development","test","production"]).default("development"),PORT:z.coerce.number().int().positive().default(3000),API_KEY:z.string().min(10)}).parse(process.env);`
}

§R{
  co_locate_schema(component|route|action);always_`z.infer`¬duplicate_interfaces;prefer_`safeParse`>`parse`;`FormData`|`URLSearchParams`|query_str⇒`z.coerce`+`z.stringbool()`;v4_top_level_formats(`z.email`,`z.uuid`,`z.url`,`z.iso.*`)≻chained_`z.string().*()`;v4_err_fmt⇒`z.flattenError`|`z.treeifyError`|`z.prettifyError`¬deprecated_`.flatten()`/`.format()`;v4_err_opt⇒`{error:...}`¬`message`/`required_error`/`invalid_type_error`;obj_`.refine`/`.superRefine`⇒pass_`path`;update_schema(constraints≠create)⇒dedicated_schema¬`.partial()`;recursive⇒getter_syntax(v4);2way_wire_conv⇒`z.codec()`;edge/client_bundle_critical⇒`zod/mini`;framework_interop⇒native_Standard_Schema
}

§ANTI{
  chained_`z.string().email()/uuid()/url()`(v3_deprecated)⇒top_level_`z.email()`/`z.uuid()`/`z.url()`;
  `r.error.errors`(removed_v4)∨`r.error.flatten()`/`.format()`(deprecated_v4)⇒`r.error.issues`∨`z.flattenError()`/`z.treeifyError()`/`z.prettifyError()`;
  1_arg_`z.record(val)`(removed_v4)⇒2_arg_`z.record(key,val)`;
  `z.coerce.boolean()`(`"false"`→`true`,non_empty_str≡truthy)⇒`z.stringbool()`;
  recursive_no_getter⇒err("Type instantiation is excessively deep")⇒getter_in_`z.object({get sub(){return z.array(S)}})`;
  empty_str_w_optional(`.optional()`≡`undefined`_only)⇒`.or(z.literal(""))`∨preprocess(`""`→`undefined`)
}

§CHK{
  Zod_v4_APIs(top_level_formats,2_arg_`z.record`,unified_`error`,`z.flattenError`/`treeifyError`/`prettifyError`);`z.stringbool`_for_bool_strings;getter_for_recursion;`z.codec`_for_2way;`z.toJSONSchema`_native;`safeParse`+handle_`r.success`;export_`z.infer`;Next:`Object.fromEntries(formData.entries())`;startup_env_val;unit_test/schema
}

§REL{
  [typescript](../SKILL.md):setup,migration,monorepo;[typescript-patterns](typescript-patterns.md):TS_patterns,boundaries;[nextjs](../../frontend-development/references/nextjs.md):App_Router,data;[node](../../node/SKILL.md):Node_conventions;[frontend-development](../../frontend-development/SKILL.md):React/Next_TS,MUI,TanStack
}
