@REF:php-laravel
§SCOPE{PHP8+,Laravel_features/refactor,REST/GraphQL,auth/authz,PHP_utils,DB/cache/queue_opt}

§R{core_php
  `declare(strict_types=1);` ∀file;
  prefer:{`match`>longSwitch,Enums,Attributes(routes,val),ctorPropPromotion(DTO,VO)};
  types:{union,intersection,`never`,¬`mixed`};
  SPL:{`SplQueue`:FIFO,`SplHeap`:prio,`ArrayObject`:objArray};
  mem:{generators(`yield`)_streams,unsetLargeVars,¬circularRefs,immutable};
  profileEarly:{Xdebug,Blackfire,Laravel_Telescope}
}
```php
function readCsv(string $p): Generator { $h=fopen($p,'r'); while(($r=fgetcsv($h))!==false) yield $r; fclose($h); }
```

§PAT{laravel_arch
  layout:app/{Actions/,Events/,Http/{Controllers/,Middleware/,Requests/,Resources/},Jobs/,Models/,Policies/,Providers/,Services/,Support/};
  ThinControllers→Actions(1_useCase)∨Services(`App\Services`,ctorDI_multiActions);
  DI:typeHint_in_ctor/method; bind∈ServiceProvider(`$this->app->bind(OrderRepository::class,EloquentOrderRepository::class)`);
  FormRequest(`php artisan make:request StorePostRequest`):`authorize()`,`rules()`,`toDto()`;
  routes:{`prefix`,`middleware`,`as`; implicit `posts/{post}`→`Post $post`; custom `Route::model('conversation',AiConversation::class)`∨`Route::bind()`∨`resolveRouteBinding()`; param==modelName; consistentPrefix};
  `Route::scopeBindings()` enforces_tenant(`{account}/projects/{project}`),¬replaces_Policy;
  Policies(`php artisan make:policy PostPolicy`→`$this->authorize('update',$post)`)|Gates(genericPerms);
  ¬Facades_mutableGlobalState⇒DI; PSR-12+LaravelStds
}

§R{validation_security
  input:FormRequest∨`$request->validated()`; valErr⇒422_JSON(`{message,errors}`);
  Blade:`{{ $v }}`_escaped; `{!! !!}`_trustedOnly; `@csrf`; `@method('PUT')`;
  pw:`Hash::make()`(bcrypt/argon2); 1timeActions⇒signedURLs;
  uploads:checkMIME+size,storeOutsideWebRoot;
  secrets∈`.env`∧`env()`_ONLY∈`config/*.php`(`config:cache`_breaks_runtime_`env()`);
  ref:laravel-security.md
}

§PAT{eloquent_migrations_api
  `$fillable`_explicit(¬`$guarded=[]`); eagerLoad(`Post::with('author','comments')`,`Order::query()->with(['customer','items.product'])`)⇒noN+1;
  scopes:named(`scopeActive(Builder $q): Builder`)∨global(`static::addGlobalScope`∈`booted()`),¬bothFor1Filter; complex⇒queryObjCloningBuilderPerStep;
  `casts():array`(`StatusEnum::class`,'datetime'); VO:`Attribute::make(get:...,set:...)`; `DB::transaction(fn()=>...)`; Eloquent>rawSQL_unlessPerf;
  migrations:`YYYY_MM_DD_HHMMSS_create_<table>_table.php`,anonClass,plural_`snake_case`,`constrained()->cascadeOnDelete()`,idx∈{`where`,`join`,`orderBy`};
  API:{`JsonResource`,env:`{"data":...,"meta":{"pagination":...}}`,`Resource::collection($p)`→`data,links,meta{current_page,per_page,total}`,cursorPag(largeSets),`throttle`,HTTP:`200,201,204,400,401,403,404,422,500`}
}

§R{auth_queues_cache_blade
  Sanctum:SPA/tokens_w/_abilities,`auth:sanctum`;
  events/jobs:domainEvents(email,analytics); slow(reports,exports,webhooks)⇒queued(`dispatch()`,idempotent,retry+backoff,chainIfOrdered); conns:{database,Redis,SQS}; `php artisan queue:failed`;
  cache:`Cache::remember()`,tags,sensibleTTL(¬indefMutable),flushOn(`created`,`updated`,`deleted`);
  Blade:components,ViewModels/Services_calc(¬bizLogic),`@cache`_fragments
}

§PAT{testing_perf
  unit(purePHP)⇒PHPUnit∨Pest; feature(HTTP)⇒`Illuminate\Testing\TestResponse`;
  SQLiteMem:`DB_CONNECTION=sqlite`,`DB_DATABASE=:memory:`;
  assert:`assertJsonStructure()`,`assertStatus()`; mocks:`Http::fake()`,`Queue::fake()`;
  local:{Telescope,Debugbar}; prod:{OPcache,monitorHitRate}
}

§PAT{code
```php
final class StoreOrderRequest extends FormRequest {
  public function authorize(): bool { return $this->user()?->can('create',Order::class)??false; }
  public function rules(): array { return ['customer_id'=>['required','integer','exists:customers,id'],'items'=>['required','array','min:1'],'items.*.sku'=>['required','string'],'items.*.quantity'=>['required','integer','min:1']]; }
  public function toDto(): CreateOrderData { return new CreateOrderData((int)$this->validated('customer_id'),$this->validated('items')); }
}
final class CreateOrderAction {
  public function __construct(private OrderRepository $orders) {}
  public function handle(CreateOrderData $d): Order { return DB::transaction(fn()=>$this->orders->create($d)); }
}
final class OrdersController extends Controller {
  public function store(StoreOrderRequest $req, CreateOrderAction $act): JsonResponse {
    return OrderResource::make($act->handle($req->toDto()))->response()->setStatusCode(201);
  }
}
Route::middleware('auth:sanctum')->group(fn()=>Route::apiResource('projects',ProjectController::class));
Route::scopeBindings()->group(fn()=>Route::get('/accounts/{account}/projects/{project}',[ProjectController::class,'show']));
final class Project extends Model {
  use HasFactory, SoftDeletes;
  protected $fillable=['name','owner_id','status'];
  protected function casts(): array { return ['status'=>ProjectStatus::class,'archived_at'=>'datetime']; }
  public function owner(): BelongsTo { return $this->belongsTo(User::class,'owner_id'); }
  public function scopeActive(Builder $q): Builder { return $q->whereNull('archived_at'); }
  public function scopeOwnedBy(Builder $q, int $id): Builder { return $q->where('owner_id',$id); }
  protected function budget(): Attribute { return Attribute::make(get:fn(int $v)=>Money::fromCents($v),set:fn(Money $m)=>$m->toCents()); }
}
return new class extends Migration {
  public function up(): void { Schema::create('orders',function(Blueprint $t):void{ $t->id(); $t->foreignId('customer_id')->constrained()->cascadeOnDelete(); $t->string('status',32)->index(); $t->unsignedInteger('total_cents'); $t->timestamps(); }); }
  public function down(): void { Schema::dropIfExists('orders'); }
};
```
}

§ANTI{
  fatControllers; logic∈routes; unvalidated`Model::create`; hardcodedCfg;
  dupControllerLogic(⇒Services/Traits); rawSQL_simpleCRUD; `$guarded=[]`; runtime_`env()`; mutableFacadeGlobalState
}

§REL{
  laravel-security.md:prodCfg/Sanctum/Passport/policies/CSRF/XSS/uploads/headers;
  laravel-testing.md:PHPUnit/Pest/factories/fakes/verifyLoop;
  laravel-plugin-discovery.md:pkgEval_LaraPluginsMCP;
  ../../database-design/SKILL.md:DB_arch/schema;
  ../../unit-testing-patterns/SKILL.md:unitTestPatterns
}
