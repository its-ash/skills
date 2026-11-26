@REF:zod

§D{
when∈{runtime_val(API,form,query),env_vars,RHF(`@hookform/resolvers/zod`),cross_field/async_rules,coerce(str→num/bool/Date)};
flow:[1:`import{z}from"zod"`,2:schema,3:`z.infer<typeof S>`,4:`safeParse`(pref)∨`parse`,5:`r.data`|`r.error.format()`/`flatten()`,6:integrate]
}

§PAT{
primitives:`z.string().min(3).max(255)`,`z.coerce.number().min(18)`,`z.coerce.boolean()`("false"→true!),`z.coerce.date()`;
object_infer:`const UserSchema=z.object({id:z.string().uuid(),username:z.string().min(3).max(20),email:z.string().email(),role:z.enum(["ADMIN","USER","GUEST"]).default("USER"),age:z.number().min(18).optional(),website:z.string().url().nullable(),tags:z.array(z.string()).min(1)});export type User=z.infer<typeof UserSchema>;`;
advanced:`z.record(z.string(),z.string())`;`z.union([z.string(),z.number()])`|`z.string().or(z.number())`;`z.discriminatedUnion("type",[z.object({type:z.literal("create"),id:z.string()}),z.object({type:z.literal("update"),id:z.string(),data:z.any()}),z.object({type:z.literal("delete"),id:z.string()})])`;
parse_vs_safe:`schema.parse(x)`(throws `z.ZodError`→`e.issues`);`const r=schema.safeParse(x)`(`!r.success`⇒`r.error.format()`|`r.error.flatten()`);
custom_err:`z.string().min(8,{message:"..."}).regex(/[A-Z]/,{message:"..."}).regex(/[0-9]/,{message:"..."})`;
i18n_err_map:`z.setErrorMap((issue,ctx)=>issue.code===z.ZodIssueCode.invalid_type&&issue.expected==="string"?{message:"This field must be text"}:{message:ctx.defaultError})`;
refine_transform:`z.object({password:z.string().min(8),confirmPassword:z.string()}).refine(d=>d.password===d.confirmPassword,{message:"Passwords do not match",path:["confirmPassword"]})`;`z.string().transform(v=>parseInt(v,10)).refine(v=>!isNaN(v),{message:"Not a valid integer"})`#z.infer⇒number;
rhf:`useForm<T>({resolver:zodResolver(schema)})`(`react-hook-form`+`@hookform/resolvers/zod`;`register`,`handleSubmit`,`formState:{errors}`);
nextjs_action:```ts
"use server";
export async function createPost(_:any,fd:FormData){
  const r=createPostSchema.safeParse(Object.fromEntries(fd.entries()));
  if(!r.success)return{errors:r.error.flatten().fieldErrors};
  const{title,content,published}=r.data;// published:z.coerce.boolean().default(false)
  return{success:true};
}
```;
env:`export const env=z.object({DATABASE_URL:z.string().url(),NODE_ENV:z.enum(["development","test","production"]).default("development"),PORT:z.coerce.number().default(3000),API_KEY:z.string().min(10)}).parse(process.env);`
}

§R{
co_locate_schema(component|route|action);always `z.infer`¬duplicate_interfaces;prefer `safeParse`>`parse`;`FormData`|`URLSearchParams`|query_str⇒`z.coerce`;JSON_err⇒`.flatten()`∨`.format()`;obj `.refine`/`.superRefine`⇒pass `path`;update_schema(constraints≠create)⇒dedicated_schema¬`.partial()`;recursive⇒`z.lazy(()=>Schema)`
}

§ANTI{
err("Type instantiation is excessively deep")⇐recursive_no_lazy⇒`z.lazy(()=>Schema)`;
empty_str_w_optional(`.optional()`≡`undefined` only)⇒`.or(z.literal(""))`∨transform(`""`→`undefined` pre-val);
`z.coerce.boolean()`("false"→`true`,non-empty str≡truthy)⇒preprocess_custom_transform∨manual_chk_pre_coerce
}

§CHK{
primitives+coercion;custom_err_msgs(UI);`.refine`/`.superRefine`(cross_field,async);`safeParse`+handle `result.success`;serializable_UI_errs;export `z.infer`;Next:`Object.fromEntries(formData.entries())`;startup_env_val;unit_test/schema
}

§REL{
[typescript](../SKILL.md):setup,migration,monorepo;[nextjs](../../frontend-development/references/nextjs.md):App_Router,data;[node](../../node/SKILL.md):Node_conventions;[frontend-development](../../frontend-development/SKILL.md):React/Next_TS,MUI,TanStack
}
