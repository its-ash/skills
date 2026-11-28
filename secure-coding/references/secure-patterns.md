@REF:secure-patterns
§CTX{TS/Node|Go|SQL;port_idioms}
§PAT{
  secrets:`const key=process.env.API_KEY;if(!key)throw new Error('Missing API_KEY')`;gen:`node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`;prod⇒cloud_secrets_mgr
  val_zod4:`z.object({email:z.email(),name:z.string().trim().min(1).max(100),age:z.int().min(0).max(150).optional()})`
  pwd_policy(NIST_800-63B-4):`z.string().min(15).max(128)`(1FA)∨`z.string().min(8).max(128)`(MFA);all_ASCII+Unicode;¬regex_composition_rules;¬truncate;¬periodic_rot;chk_HIBP_k_anon_blocklist;allow_paste+pw_mgr
  pwd_hash:`argon2.hash(pw,{type:argon2.argon2id,memoryCost:19456,timeCost:2,parallelism:1})`(tune~50-100ms)≻`crypto.scrypt`≻legacy_bcrypt(cost≥12,72B_cap);verify_const_time
  upload:`MAX=5*1024*1024`;allow_MIME+ext;sniff_magic_bytes(`fileTypeFromBuffer`);reencode_imgs(strip_EXIF/polyglot);CSPRNG_name;store_obj_store|outside_webroot;serve:`Content-Disposition:attachment`+`X-Content-Type-Options:nosniff`
  path_guard:Go1.24+:`root,err:=os.OpenRoot(base);f,err:=root.Open(rel)`;Node:`const b=fs.realpathSync(base),p=fs.realpathSync(path.resolve(b,name));if(p!==b&&!p.startsWith(b+path.sep))throw 403`
  xss:`isomorphic-dompurify`:`DOMPurify.sanitize(html,{ALLOWED_TAGS:['b','i','em','strong','p'],ALLOWED_ATTR:[]})`;TrustedTypes:`trustedTypes.createPolicy('default',{createHTML:s=>DOMPurify.sanitize(s,{RETURN_TRUSTED_TYPE:true})})`
  sql:`db.query('SELECT id,email,name FROM users WHERE email=$1',[email])`;dynamic_ident(ORDER_BY)⇒strict_allowlist_map;Supabase:`supabase.from('users').select('id,email').eq('email',email)`;RLS:`ALTER TABLE users ENABLE ROW LEVEL SECURITY; CREATE POLICY own_sel ON users FOR SELECT USING ((SELECT auth.uid())=id); CREATE POLICY own_upd ON users FOR UPDATE USING ((SELECT auth.uid())=id) WITH CHECK ((SELECT auth.uid())=id);`
  jwt_jose:`import {SignJWT,jwtVerify} from 'jose'`;alg∈{EdDSA,ES256,HS256≥256b};`await new SignJWT({sub,role}).setProtectedHeader({alg:'EdDSA'}).setIssuer('app').setAudience('app-users').setIssuedAt().setExpirationTime('15m').sign(privKey)`;`await jwtVerify(tok,pubKey,{algorithms:['EdDSA'],issuer:'app',audience:'app-users'})`→401;cookie:`__Host-sid=...;HttpOnly;Secure;SameSite=Lax;Path=/`;srv_refresh_rot+reuse_revoke
  oauth_rfc9700:AuthCode+PKCE(`S256`)+exact_redirect_URI+`state`+`nonce`;¬Implicit¬ROPC;high_assurance⇒DPoP|mTLS
  csrf:FetchMetadata:`const s=req.headers['sec-fetch-site'];if(s&&s!=='same-origin'&&s!=='none')return res.status(403).end()`+`Origin`_allowlist;Go1.25+:`http.NewCrossOriginProtection()`;legacy_cli⇒synchronizer|double_submit_tok
  ssrf:parse_URL→allow(`https:`∧host_allowlist)→DNS_resolve→reject(`127/8,10/8,172.16/12,192.168/16,169.254/16,0/8,::1,fc00::/7,fe80::/10`)→pin_resolved_IP(¬DNS_rebind)→manual_redirect_recheck
  bola:`const post=await prisma.post.findFirst({where:{id,userId:req.user.id}})`;!post⇒404(¬existence_leak);admin_override⇒explicit_BFLA_role_check
  ratelimit:`rateLimit({windowMs:15*60_000,limit:100,standardHeaders:'draft-8',legacyHeaders:false,store:redisStore})`(`express-rate-limit` v7/v8);auth:`{windowMs:15*60_000,limit:5,skipSuccessfulRequests:true}`+IP∧account_key
  hdr:`helmet({contentSecurityPolicy:{directives:{defaultSrc:["'self'"],baseUri:["'self'"],objectSrc:["'none'"],frameAncestors:["'none'"],scriptSrc:["'nonce-'+nonce","'strict-dynamic'"],requireTrustedTypesFor:["'script'"]}},frameguard:{action:'deny'}})`(Next.js:`proxy.ts`/middleware_per_req_nonce)
  err:srv_structured_log(`{reqId,userId,code}`);`P2002`⇒generic_400/409(¬email_enum);else 500;¬log(pw,tok,card,secret,PII);fail_closed_in_catch(OWASP25_A10)
  deps:`npm ci`+`osv-scanner scan -L package-lock.json`+`trivy fs .`+`npm audit --audit-level=high`+`gitleaks detect`;untrusted_install⇒`--ignore-scripts`
  solana:`verify(Buffer.from(msg),Buffer.from(sig,'base64'),Buffer.from(pubKey,'base64'))`;`verifyTx(tx,recipient,maxAmount)`⇒`tx.to===recipient∧tx.amount<=maxAmount∧getBalance(tx.from)>=tx.amount`
  tests:401(unauth),403(BOLA/BFLA/CSRF_cross_site),400(bad_schema/SSRF_priv_IP),429(rate_limit),path_trav_blocked
}
§ANTI{
  ¬jsonwebtoken_new_code(use_jose);¬regex_pw_composition;¬bcrypt_new_code(use_Argon2id);¬CORS_as_CSRF;¬startsWith(base)_without_trailing_sep;¬static_CSP_unsafe-inline;¬RLS_UPDATE_without_WITH_CHECK
}
§CHK{zod4_schema;NIST_pw+Argon2id;jose_alg_pin;FetchMetadata_CSRF;os.Root|realpath_sep;SSRF_IP_pin;RLS_USING+WITH_CHECK;strict_CSP+TrustedTypes;OSV+gitleaks}
