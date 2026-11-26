@REF:coding-standards
§META{scope:cross_proj_floor(TS/JS);not_fw_playbook}
§REL{../../frontend-development/SKILL.md:React|state|forms|render|UI;../../backend-development/SKILL.md:services|endpoints|validation|server}
§USE{in:{new_proj|mod,rev,refactor,naming|fmt|struct,lint|fmt|tsc_setup,onboard,immutability,KISS|DRY|YAGNI,err,smells};out:{React_comp|hooks|render,BE_arch|API|DB,narrower_skill}}
§PRIN{Readability:read>write∧clear_names∧self_doc>cmts∧fmt;KISS:simplest∧¬over_eng∧¬premature_opt∧clear>clever;DRY:extract_fn∧reusable_comp∧share_utils∧¬copy_paste;YAGNI:¬speculative∧complexity_iff_req∧simple→refactor}
§TS_JS{
  var:descriptive(marketSearchQuery,isUserAuthenticated,totalRevenue)¬(q,flag,x);
  fn:verb_noun(fetchMarketData(marketId:string),calculateSimilarity(a:number[],b:number[]),isValidEmail(email:string):boolean)¬(market,similarity,email);
  immutability[CRIT]:{...user,name:'New Name'},[...items,newItem]¬(user.name=...,items.push(...));
  async:await Promise.all([fetchUsers(),fetchMarkets(),fetchStats()])¬seq_await;
  types:interface Market{id:string;name:string;status:'active'|'resolved'|'closed';created_at:Date},getMarket(id:string):Promise<Market>¬any
}
```ts
async function fetchData(url: string) {
  try {
    const r = await fetch(url)
    if (!r.ok) throw new Error(`HTTP ${r.status}: ${r.statusText}`)
    return await r.json()
  } catch (e) { console.error('Fetch failed:', e); throw new Error('Failed to fetch data') }
}
```
§REACT{
  comp:ButtonProps{children:React.ReactNode;onClick:()=>void;disabled?:boolean;variant?:'primary'|'secondary'},defaults(disabled=false,variant='primary'),`btn btn-${variant}`;
  state:setCount(prev=>prev+1)¬setCount(count+1);
  cond:{isLoading&&<Spinner/>}{error&&<ErrorMessage error={error}/>}{data&&<DataDisplay data={data}/>}¬nested_ternary
}
```ts
export function useDebounce<T>(value: T, delay: number): T {
  const [v, setV] = useState<T>(value)
  useEffect(() => { const h = setTimeout(() => setV(value), delay); return () => clearTimeout(h) }, [value, delay])
  return v
} // useDebounce(searchQuery, 500)
```
§API{
  REST:{GET:/api/markets,GET:/api/markets/:id,POST:/api/markets,PUT:/api/markets/:id(full),PATCH:/api/markets/:id(partial),DELETE:/api/markets/:id,query:`GET /api/markets?status=active&limit=10&offset=0`};
  resp:ApiResponse<T>{success:boolean;data?:T;error?:string;meta?:{total:number;page:number;limit:number}};
  ok:NextResponse.json({success:true,data:markets,meta:{total:100,page:1,limit:10}});
  err:NextResponse.json({success:false,error:'Invalid request'},{status:400})
}
```ts
import { z } from 'zod'
const CreateMarketSchema = z.object({ name: z.string().min(1).max(200), description: z.string().min(1).max(2000), endDate: z.string().datetime(), categories: z.array(z.string()).min(1) })
export async function POST(req: Request) {
  try { const data = CreateMarketSchema.parse(await req.json()) }
  catch (e) { if (e instanceof z.ZodError) return NextResponse.json({ success: false, error: 'Validation failed', details: e.issues }, { status: 400 }) }
}
```
§ORG{
  src/{app/{api/,markets/,(auth)/},components/{ui/,forms/,layouts/},hooks/,lib/{api/,utils/,constants/},types/,styles/};
  names:{components/Button.tsx:PascalCase,hooks/useAuth.ts:camelCase+use,lib/formatDate.ts:camelCase,types/market.types.ts:camelCase+.types}
}
§DOC{
  cmt:WHY¬WHAT(exp_backoff:`Math.min(1000*Math.pow(2,retryCount),30000)`,perf_mutation)¬(count++,name=user.name);
  JSDoc[public]:summary,@param,@returns,@throws {Error},@example
}
```ts
/** @param query - search query @param limit - max results (default: 10) @returns sorted Market[] @throws {Error} OpenAI/Redis fail @example await searchMarkets('election', 5) */
export async function searchMarkets(query: string, limit: number = 10): Promise<Market[]> {}
```
§PERF{
  memo:useMemo(()=>[...markets].sort((a,b)=>b.volume-a.volume),[markets])(copy_pre_sort)∧useCallback((q:string)=>{setSearchQuery(q)},[]);
  lazy:lazy(()=>import('./HeavyChart'))+<Suspense fallback={<Spinner/>}><HeavyChart/></Suspense>;
  db:.from('markets').select('id, name, status').limit(10)¬select('*')
}
§TEST{
  AAA:Arrange→Act→Assert(expect(similarity).toBe(0));
  names:descriptive('returns empty array when no markets match query','throws error when OpenAI API key is missing','falls back to substring search when Redis unavailable')¬('works','test search')
}
§ANTI{
  long_fn:>50_lines⇒split(validateData→transformData→saveData);
  deep_nest:≥5_levels⇒early_return(if(!user)return;if(!user.isAdmin)return;if(!market)return;if(!market.isActive)return;if(!hasPermission)return);
  magic_nums:(retryCount>3,setTimeout(cb,500))⇒const(MAX_RETRIES=3,DEBOUNCE_DELAY_MS=500)
}
