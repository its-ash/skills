@REF:secure-patterns
§CTX{TS/Node;port}
§PAT{
secrets:`process.env.OPENAI_API_KEY||throw`;gen:`node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"`
val:`z.object({email:z.string().email(),name:z.string().min(1).max(100),age:z.number().int().min(0).max(150).optional()})`;`Password:z.string().min(12).regex(/[A-Z]/).regex(/[a-z]/).regex(/[0-9]/).regex(/[^A-Za-z0-9]/)`
upload:`MAX=5*1024*1024`;`TYPES=['image/jpeg','image/png','image/gif']`;outside_webroot|obj_store;rand_name;magic_bytes
xss:`isomorphic-dompurify`:`DOMPurify.sanitize(html,{ALLOWED_TAGS:['b','i','em','strong','p'],ALLOWED_ATTR:[]})`
sql:`db.query('SELECT id, email, name FROM users WHERE email = $1',[email])`;`supabase.from('users').select('id,email').eq('email',email)`;`ALTER TABLE users ENABLE ROW LEVEL SECURITY; CREATE POLICY "own_select" ON users FOR SELECT USING (auth.uid() = id); CREATE POLICY "own_update" ON users FOR UPDATE USING (auth.uid() = id);`
jwt:secret≥256b_env(throw);exp~1h;refresh_srv+revoke;¬sens_payload;`jwt.sign({userId,role},JWT_SECRET,{expiresIn:'1h',issuer:'app',audience:'app-users'})`;`jwt.verify(tok,JWT_SECRET,{issuer:'app',audience:'app-users'})`→403
bola:`prisma.post.findUnique({where:{id}})`→!post⇒404;`post.userId!==req.user.userId&&req.user.role!=='admin'`⇒403→`delete`
ratelimit:IP∧user;stricter:login|reg|search|expensive;plan_tier;Redis;429+retry;`rateLimit({windowMs:15*60_000,max:100,standardHeaders:true,legacyHeaders:false})`(`/api/`);`{windowMs:15*60_000,max:5,skipSuccessfulRequests:true}`(`/api/auth/login`)
hdr:`helmet({contentSecurityPolicy:{directives:{defaultSrc:["'self'"],scriptSrc:["'self'"],imgSrc:["'self'",'data:','https:']}},frameguard:{action:'deny'},noSniff:true})`;Next(`next.config.js`):`Content-Security-Policy: default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; script-src 'self'; style-src 'self'; img-src 'self' data: https:; font-src 'self'; connect-src 'self' https://api.example.com;`;CSRF:`!csrf.verify(req.headers.get('X-CSRF-Token'))`⇒403
err:srv(`console.error`);`P2002`⇒400;else 500;log`{email,userId}`;¬pw/tok/card
deps:`npm audit && npm audit fix && npm outdated && npm ci`(lock,CI:`npm ci`,Dependabot)
solana:`verify(Buffer.from(msg),Buffer.from(sig,'base64'),Buffer.from(pubKey,'base64'))`;`verifyTx(tx,recipient,maxAmount)`⇒`tx.to===recipient`∧`tx.amount<=maxAmount`∧`getBalance(tx.from)>=tx.amount`
tests:`(await fetch('/api/protected')).status===401`;401:unauth,403:unauthz,400:bad_in,429:limit
}
