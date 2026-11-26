@REF:laravel-security
§SCOPE{auth/authz(Sanctum,Passport,Jetstream,Breeze)|roles/perms/policies|prod_cfg/env|vuln_audit|prod_deploy|secure_Eloquent/migrations}

§CFG:PROD{
  app[config/app.php]:'env'=>env('APP_ENV','production'),'debug'=>(bool)env('APP_DEBUG',false)(¬true_prod),'key'=>env('APP_KEY')(`php artisan key:generate`),'trusted_proxies'=>['10.0.0.0/8','172.16.0.0/12'](AWS_incl:'192.168.0.0/16';¬'*'⇒prevent_X-Forwarded-*_spoof);
  session[config/session.php]:'secure'=>env('SESSION_SECURE_COOKIE',true),'http_only'=>true,'same_site'=>'lax';
  env:¬commit(.env∈.gitignore);.env.example⇒empty(DB_PASSWORD=,APP_KEY=,SANCTUM_TOKEN_PREFIX=);
  boot[bootstrap/app.php|AppServiceProvider::boot()]:
    empty(config('app.key'))⇒throw RuntimeException('APP_KEY is not set. Run: php artisan key:generate');
    ∀k∈['app.key','database.connections.mysql.database','database.connections.mysql.username']:empty(config($k))⇒throw RuntimeException("Missing required config key: {$k}");
  https:
    prod⇒URL::forceScheme('https')∧request()->server->set('HTTPS','on');
    ForceHttps::handle($req,$next):(!$req->secure()∧app()->environment('production'))⇒redirect()->secure($req->getRequestUri())
}

§PAT:AUTH{
  sanctum[config/sanctum.php]:'stateful'=>explode(',',env('SANCTUM_STATEFUL_DOMAINS',sprintf('%s%s','localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',env('APP_URL')?','.parse_url(env('APP_URL'),PHP_URL_HOST):''))),'expiration'=>60*24(min;null=never),'token_prefix'=>env('SANCTUM_TOKEN_PREFIX','');
  token_issue:$user->createToken('api-token',['read','write'])->plainTextToken;
  token_check:Route::middleware('auth:sanctum')∧->middleware('abilities:read')∧abort_unless(Auth::user()->tokenCan('read'),403);
  hashing[config/hashing.php]:'bcrypt'=>['rounds'=>env('BCRYPT_ROUNDS',12)](default),'argon'=>['memory'=>65536,'threads'=>4,'time'=>4](Argon2id>bcrypt);
  pwd_rules[RegisterRequest]:['required','confirmed',Password::min(12)->letters()->mixedCase()->numbers()->symbols()->uncompromised()(HIBP)];
  lockout[AuthenticatedSessionController::authenticated]:if($user->wasRecentlyLockedOut())$user->notify(new SuspiciousLoginNotification($request->ip()));
  session[config/session.php]:'driver'=>env('SESSION_DRIVER','database')(database/redis>file),'lifetime'=>env('SESSION_LIFETIME',120),'expire_on_close'=>env('SESSION_EXPIRE_ON_CLOSE',false),'encrypt'=>env('SESSION_ENCRYPT',false);
  login[store(LoginRequest)]:$request->authenticate()→$request->session()->regenerate()(fixation_guard)→redirect()->intended(RouteServiceProvider::HOME);
  logout[destroy(Request)]:Auth::guard('web')->logout()→$request->session()->invalidate()→$request->session()->regenerateToken()→redirect('/')
}

§PAT:AUTHZ{
  gates[AuthServiceProvider::boot()]:
    Gate::define('update-post',fn(User $u,Post $p):bool=>$u->id===$p->user_id);
    Gate::define('publish-post',fn(User $u):bool=>$u->role==='editor'||$u->role==='admin');
    Gate::before(fn(User $u,string $ab):?bool=>$u->role==='super-admin'?true:null)(null⇒fallthrough);
    call:Gate::authorize('update-post',$post)⊕$this->authorize('update-post',$post)⊕abort_unless(Auth::user()->can('update-post',$post),403);
  policy[App\Policies\PostPolicy;use HandlesAuthorization]:
    $policies=[Post::class=>PostPolicy::class];
    methods:viewAny(?User)⇒true|view(?User $u,Post $p)⇒$p->is_published||($u&&$u->id===$p->user_id)|create(User $u)⇒$u->hasVerifiedEmail()|update(User $u,Post $p)⇒$u->id===$p->user_id|delete(User $u,Post $p)⇒$u->id===$p->user_id&&$p->created_at->diffInDays(now())<=30|restore(User $u,Post $p)⇒$u->role==='admin'|forceDelete(User $u,Post $p)⇒$u->role==='super-admin';
    ctrl:$this->authorize('view',$post);blade:@can('update',$post)...@endcan,@cannot('update',$post)...@endcannot;
  mw:
    route:->middleware('can:update,post')|->middleware('can:create,App\Models\Post');
    CheckRole::handle(Request $r,Closure $next,string $role):mixed⇒(!$r->user()||$r->user()->role!==$role)?abort(403,'Unauthorized. This area requires role: '.$role):$next($r);
    Kernel::$routeMiddleware=['role'=>\App\Http\Middleware\CheckRole::class];Route::middleware(['auth','role:admin'])
}

§PAT:ELOQUENT{
  mass_assign:¬($guarded=[]);whitelist:$fillable=['name','email','phone','avatar'](¬'role','is_admin','is_verified');create:$request->safe()->only([...])∨$request->validated()∨DTO;¬$request->all();¬$request->only()_sans_validation;
  sqli:safe⇒User::where('email',$in)|whereRaw('email = ?',[$in])|DB::table('users')->where('email',$in)|DB::select('SELECT * FROM users WHERE email = ?',[$in]);¬interp_in(DB::select|whereRaw|orderByRaw|groupByRaw|DB::statement);
  casts[User::$casts]:'email_verified_at'=>'datetime','is_admin'=>'boolean'(¬str_inj),'settings'=>'array'(auto_json),'metadata'=>'encrypted:array'(Laravel11+),'password'=>'hashed'(Laravel10+);
  model:
    $hidden=['password','remember_token','two_factor_secret','two_factor_recovery_codes'];
    $appends=['full_name'](safe_only;¬sensitive);
    Post:use SoftDeletes;
    AppServiceProvider::boot():Model::preventLazyLoading(!app()->isProduction())(N+1_guard)
}

§PAT:CSRF{
  default:VerifyCsrfToken∈Kernel::$middlewareGroups['web'];∀form(POST|PUT|PATCH|DELETE)⇒@csrf;
  except[VerifyCsrfToken::$except]:only_external_sig_routes(e.g.'stripe/*');¬blanket'api/*'(stateful_Sanctum_needs_CSRF);
  js:<meta name="csrf-token" content="{{ csrf_token() }}">;axios.defaults.headers.common['X-CSRF-TOKEN']=token;fetch:{headers:{'X-CSRF-TOKEN':token,'Content-Type':'application/json'}}
}

§PAT:XSS{
  blade:{{ $userInput }}(auto_escape);¬{!! $userInput !!}(trusted_server_HTML_only);@js($data)(JSON+JS_escape);@json($data)(JSON);¬{{ json_encode($user) }}_in_<script>;
  html_purify[ezyang/htmlpurifier]:HTMLPurifier_Config::createDefault()→set('HTML.Allowed','p,b,i,a[href],ul,ol,li,br')→set('URI.AllowedSchemes',['http','https','mailto'])→(new \HTMLPurifier($cfg))->purify($dirty)⇒safe_for_{!! $sanitizedContent !!};
  headers[SecurityHeaders∈Kernel::$middleware]:
    X-Content-Type-Options:nosniff|X-Frame-Options:DENY|X-XSS-Protection:1; mode=block|Referrer-Policy:strict-origin-when-cross-origin|Content-Security-Policy:"default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; font-src 'self'; connect-src 'self'; frame-ancestors 'none'"
}

§PAT:VALIDATION{
  StorePostRequest[FormRequest]:
    authorize():$this->user()?->can('create',Post::class)??false;
    rules():'title'=>['required','string','max:255'],'content'=>['required','string','max:10000'],'image'=>['required','image','mimes:jpg,jpeg,png,gif,webp','max:2048'](2MB),'tags'=>['array'],'tags.*'=>['integer','exists:tags,id'];
    messages():custom_msg('title.max','image.max');
    validated($k=null,$d=null):$v=parent::validated();$v['title']=strip_tags($v['title']);return $k?($v[$k]??$d):$v;
  rules[Illuminate\Contracts\Validation\Rule]:
    StrongPassword:preg_match('/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&#^()_\-+=])[A-Za-z\d@$!%*?&#^()_\-+=]{12,}$/',$v);
    NotBlacklistedDomain:$d=strtolower(substr(strrchr($v,'@'),1));!in_array($d,['mailinator.com','guerrillamail.com'])
}

§PAT:API{
  rate_limit[RouteServiceProvider::configureRateLimiting()]:
    'api'=>Limit::perMinute(60)->by($r->user()?->id?:$r->ip());
    'auth'=>Limit::perMinute(5)->by($r->ip())->response(429_json);
    'uploads'=>Limit::perHour(10)->by($r->user()?->id??$r->ip())->response(429_json);
    routes:->middleware(['auth:sanctum','throttle:api'])|->middleware('throttle:auth');
  sanctum_vs_passport:
    Sanctum(first-party/SPA):'expiration'=>60*24(24h),'model'=>User::class,$u->createToken('client-name',['posts:read','posts:write'])->plainTextToken,middleware('abilities:posts:read'|'abilities:posts:write');
    Passport(`composer require laravel/passport`,OAuth2_3p):Passport::tokensExpireIn(now()->addDays(15)),refreshTokensExpireIn(now()->addDays(30)),personalAccessTokensExpireIn(now()->addMonths(6));
  cors[config/cors.php]:'paths'=>['api/*','sanctum/csrf-cookie'],'allowed_methods'=>['*'],'allowed_origins'=>explode(',',env('CORS_ALLOWED_ORIGINS',''))(¬['*']_prod_unless_public),'allowed_origins_patterns'=>[],'allowed_headers'=>['*'],'exposed_headers'=>['X-Total-Count','X-Pagination-Page'],'max_age'=>0,'supports_credentials'=>true(Sanctum_SPA)
}

§PAT:UPLOAD{
  rules:'document'=>['required','file','mimes:pdf,doc,docx,xls,xlsx','max:10240','extensions:pdf,doc,docx,xls,xlsx'](10MB;ext_matches_MIME),'avatar'=>['nullable','image','mimes:jpg,jpeg,png,webp','max:2048','dimensions:min_width=100,min_height=100,max_width=2000,max_height=2000'];
  storage:$r->file('document')->store('documents','s3')(private_disk;¬'public'_for_sensitive);
  download(Document $doc):route_model_bind→$this->authorize('download',$doc)(auth_against_owner_model,¬req_path)→Storage::disk('s3')->temporaryUrl($doc->path,now()->addMinutes(15))→redirect($url);
  s3[config/filesystems.php]:driver,key,secret,region,bucket,url,endpoint,use_path_style_endpoint(false),throw(false),'server_side_encryption'=>'AES256'
}

§PAT:DEPS_SECRETS{
  composer:`composer audit`(CI)|pin_major("laravel/framework":"^11.0","spatie/laravel-permission":"^6.0")|`composer why-not`(abandoned)|commit(composer.lock)|run `composer update` manually(¬CI/CD);
  secrets:¬commit(.env∈.gitignore);prod_mgr:`env $(aws secretsmanager get-secret-value --secret-id prod/db | jq ...) php artisan serve`;boot_check[AppServiceProvider::boot()]:∀k∈['services.stripe.key','services.stripe.webhook_secret']:empty(config($k))⇒Log::critical("Missing secret: {$k}")
}

§PAT:QUEUE{
  limiter[AppServiceProvider::boot()]:RateLimiter::for('payments',fn()=>Limit::perMinute(5));
  job[ProcessPaymentJob implements ShouldQueue,ShouldBeEncrypted]:uses Dispatchable,InteractsWithQueue,Queueable,SerializesModels;encrypts_private_props(e.g.$cardFingerprint);retryUntil():Carbon=>now()->addMinutes(5);middleware()=>[new RateLimited('payments')]
}

§PAT:LOG{
  cfg[config/logging.php]:'channels.security'=>['driver'=>'single','path'=>storage_path('logs/security.log'),'level'=>'warning'];
  SecurityLogger::log(string $event,array $ctx=[]):Log::channel('security')->warning($event,array_merge(['user_id'=>Auth::id(),'ip'=>request()->ip(),'user_agent'=>request()->userAgent(),'url'=>request()->fullUrl(),'timestamp'=>now()->toIso8601String()],$ctx));
  events:'failed_login_attempt'(['email'=>$email])|'password_change'|'role_change'(['target_user'=>$targetId,'new_role'=>'admin'])|'suspicious_activity'(['reason'=>'multiple_attempts_from_different_ips'])
}

§CHK{
  APP_DEBUG=false_prod;
  APP_KEY_set(`php artisan key:generate`);
  HTTPS_enforced(middleware|trusted_proxy);
  $fillable_whitelisted(¬$guarded=[]);
  CSRF_active(@csrf_on_state_changing_forms);
  Sanctum/Passport_configured(abilities/scopes);
  rate_limiting_applied(api,auth);
  FormRequest_validation(¬$request->all());
  upload_validation(MIME,extensions,size,dimensions);
  `composer audit`_in_CI;
  Laravel_hashing(password_hash/password_verify,bcrypt/Argon2);
  session()->regenerate()_on_login;
  SecurityHeaders_mw(CSP,X-Frame-Options,X-Content-Type-Options);
  SecurityLogger(auth_fail,role_change,suspicious_activity);
  .env∈.gitignore(¬committed)
}

§REL{backend-development/references/php-laravel.md|backend-development/references/laravel-testing.md|secure-coding/SKILL.md}
