@REF:nodejs-patterns
§SCOPE{REST,GraphQL,WebSocket,microservices,monoliths,auth/authz,bg_jobs,SQL/NoSQL,middleware,errors,logging}

§D{framework
  edge/serverless(Cloudflare,Vercel)⇒Hono(minDeps,fastestColdStart);
  highPerfAPI⇒Fastify(2-3x>Express,goodTS);
  enterprise/largeTeam⇒NestJS(structured,DI,decorators);
  legacy/maxEco⇒Express(mature,manyMiddleware);
  fullstackReact/Next⇒Next_API_routes∨tRPC(sharedCode)
}

§R{runtime
  Node22+⇒nativeTS(`--experimental-strip-types`) for scripts/smallAPIs(noBuild);
  newProj⇒ESM(`import`/`export`:treeShake,asyncLoad); CJS(`require`)⇔legacyDeps;
  Bun⇒rawPerf+bundledBin(acceptNewerRuntime); Deno⇒secFirst(builtInPerms,1stClassTS)
}

§PAT{arch
  Req→Controller/Route(validate,map→svc)→Service(bizLogic,fwAgnostic)→Repository(ORM∨rawSQL_only);
  dirs:{controllers/,services/,repositories/}; simplify(singleFile)⇔prototype_won't_grow
}

§PAT{errors
  customErrs∈anyLayer(BadRequestError,UnauthorizedError)→topMiddleware{map→HTTP,JSON:{code,message},log:{stack,requestId,ts}};
  HTTP:{400:badInput,401:bad/noAuth,403:forbidden,404:notFound,409:conflict,422:bizRuleVal,500:serverErr};
  ref:backend-development/references/error-handling.md
}

§PAT{async
  seq⇒async/await; parallel⇒Promise.all; partialFailAll⇒Promise.allSettled; timeout/1st⇒Promise.race;
  ¬syncIO_prod(fs.readFileSync,crypto.pbkdf2Sync); CPU_heavy⇒worker_threads∨extSvc; largeData⇒stream
}

§R{validation
  boundaries:{HTTP(body,query,headers),preDB,extAPI_res,startupEnv};
  TS:{Zod:typeInfer+rich,Valibot:small+treeShake,ArkType:highPerf,Yup:ReactFamiliar};
  rules:{failFast,clearErrs,¬trustInternal∨ExtUnchecked}
}

§CHK{security
  [ ]validateAllReq; [ ]paramSQL/prepared; [ ]hash(bcrypt∨argon2); [ ]JWT(sig,exp,aud);
  [ ]rateLimit(shared:Redis/APIGW/platform;¬inMem); [ ]headers(helmet); [ ]prodHTTPS;
  [ ]strictCORS; [ ]secrets∈env(¬commit); [ ]`npm audit`+patchDeps
}

§PAT{testing_perf
  unit(biz)⇒`node:test`∨Vitest; int(routes,mw)⇒Supertest; E2E(flows,auth,ext)⇒Playwright;
  prio:{critical(auth,pay,core),edge(empty,bounds),errSim}; skip:{fwInternals,trivialGetters};
  Node22+_cmd:`node --test src/**/*.test.ts`(zeroDeps,cov,watch); profile(`clinic`∨`node --inspect`)_1st
}

§ANTI{
  Express@edge(coldStart); bizLogic∈controllers; skipVal; hardcodedSecrets;
  blockEventLoop(syncIO∨CPU); trustExtData; `SELECT *`_hotPath;
  inMemRateLimit(resetOnDeploy,splitReplicas,failOpenServerless);
  inProcArrayQueue(lostOnRestart⇒BullMQ/SQS+idempotent)
}

§PAT{code
```ts
interface MarketRepository {
  findAll(f?: MarketFilters): Promise<Market[]>; findById(id: string): Promise<Market | null>;
  findByIds(ids: string[]): Promise<Market[]>; create(d: CreateMarketDto): Promise<Market>;
  update(id: string, d: UpdateMarketDto): Promise<Market>; delete(id: string): Promise<void>;
}
class MarketService {
  constructor(private readonly repo: MarketRepository) {}
  listActive(limit = 20) { return this.repo.findAll({ status: 'active', limit }) }
}
export const withAuth = (h: (req: Request, u: User) => Promise<Response>) => async (req: Request) => {
  const tok = req.headers.get('authorization')?.replace('Bearer ', '')
  if (!tok) return Response.json({ error: 'Unauthorized' }, { status: 401 })
  try { return await h(req, await verifyToken(tok)) } catch { return Response.json({ error: 'Invalid token' }, { status: 401 }) }
}
// N+1 fix: batch+Map (select needed cols only)
const byId = new Map((await getUsers([...new Set(markets.map(m => m.creatorId))])).map(c => [c.id, c]))
for (const m of markets) m.creator = byId.get(m.creatorId)

// Repo cache decorator (ref: database-design/references/redis.md)
class CachedMarketRepository implements MarketRepository {
  constructor(private readonly base: MarketRepository, private readonly redis: RedisClient) {}
  async findById(id: string) {
    const k = `market:${id}`, hit = await this.redis.get(k); if (hit) return JSON.parse(hit)
    const m = await this.base.findById(id); if (m) await this.redis.setex(k, 300, JSON.stringify(m)); return m
  }
  async update(id: string, d: UpdateMarketDto) {
    const m = await this.base.update(id, d); await this.redis.del(`market:${id}`); return m
  }
}
// JWT + RBAC
import jwt from 'jsonwebtoken'
type Role = 'admin' | 'moderator' | 'user'; type Perm = 'read' | 'write' | 'delete' | 'admin'
const rolePerms: Record<Role, Perm[]> = { admin: ['read','write','delete','admin'], moderator: ['read','write','delete'], user: ['read','write'] }
export function verifyToken(tok: string): JwtPayload {
  const s = process.env.JWT_SECRET; if (!s) throw new Error('JWT_SECRET is not set')
  return jwt.verify(tok, s, { algorithms: ['HS256'] }) as JwtPayload
}
export const requirePermission = (p: Perm) => (h: (r: Request, u: User) => Promise<Response>) =>
  withAuth(async (r, u) => rolePerms[u.role].includes(p) ? h(r, u) : Response.json({ error: 'Forbidden' }, { status: 403 }))
export const DELETE = requirePermission('delete')(async () => new Response(null, { status: 204 }))

// Structured JSON log (prod ⇒ pino w/ levels + redaction)
const log = (level: 'info' | 'warn' | 'error', message: string, ctx: Record<string, unknown> = {}) =>
  console.log(JSON.stringify({ timestamp: new Date().toISOString(), level, message, ...ctx }))
```
}
