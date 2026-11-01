# PHP & Laravel Best‑Practice Guide
Write clean, secure, and performant code using modern PHP 8+ features and Laravel conventions. Follow the rules, patterns, and checklists below to deliver production‑ready solutions.

## When to Use
- Building new Laravel features (controllers, services, APIs, jobs, etc.).
- Refactoring legacy Laravel code.
- Designing RESTful APIs or GraphQL endpoints.
- Implementing validation, authentication, or authorization.
- Writing core PHP utilities (generators, SPL structures, custom helpers) that will be used in a Laravel project.
- Optimising database queries, caching, or queue processing.

---

## Core PHP Practices (Applicable to Laravel Services, Jobs, and Utilities)
- **Enable strict typing** at the top of every file: `declare(strict_types=1);`
- **Use modern language features**:
  - `match` expressions instead of long `switch`.
  - Enums for fixed sets of values.
  - Attributes for metadata (e.g., route definitions, validation rules).
  - Constructor property promotion for DTOs and value objects.
- **Leverage the type system**:
  - Union types for flexible parameters.
  - Intersection types for composite contracts.
  - `never` for functions that never return.
  - Avoid `mixed` unless absolutely necessary.
- **Memory‑efficient data processing**:
  ```php
  // Example: stream large CSV with a generator
  function readCsv(string $path): Generator {
      $handle = fopen($path, 'r');
      while (($row = fgetcsv($handle)) !== false) {
          yield $row;
      }
      fclose($handle);
  }
  ```
- **Prefer SPL data structures** when they give clear benefits:
  - `SplQueue` for FIFO queues.
  - `SplHeap` for priority queues.
  - `ArrayObject` for object‑like array access.
- **Manage memory**: unset large variables after use, avoid circular references, and prefer immutable data where possible.
- **Profile early**: use Xdebug, Blackfire, or Laravel Telescope to locate bottlenecks before optimisation.

---

## Laravel Architecture
| Principle | Action |
|-----------|--------|
| **Thin Controllers** | Move business logic to dedicated Service classes. |
| **Service Layer** | Create a class in `App\Services` that receives dependencies via constructor injection. |
| **FormRequest Validation** | Generate a FormRequest (`php artisan make:request StorePostRequest`) and define `rules()`; inject it into the controller method. |
| **Dependency Injection** | Type‑hint services, repositories, or contracts in controller constructors or method signatures. |
| **Route Model Binding** | Use implicit binding: `Route::get('posts/{post}', fn (Post $post) => …);` |
| **Route Grouping** | Group related routes with `prefix`, `middleware`, and `as` for naming. |
| **API Resources** | Transform models with `JsonResource` to keep response format consistent. |
| **Policies & Gates** | Authorise actions with `php artisan make:policy PostPolicy` and call `$this->authorize('update', $post);`. |
| **Avoid Global State** | Do not use facades for mutable state; prefer injected instances. |

---

## Validation & Security
- **Never trust raw request data**. Use FormRequest or `$request->validated()`.
- **Return structured errors** for APIs (422 status, JSON with `message` and `errors`).
- **Escape all output** in Blade: `{{ $value }}` automatically escapes; use `{!! !!}` only for trusted HTML.
- **Hash passwords** with Laravel's built‑in `Hash::make()` (bcrypt or argon2).
- **Use signed URLs** for one‑time actions (e.g., email verification). 
- **Limit file uploads**: validate MIME type, size, and store outside the web root.

---

## Eloquent & Database
- Define `$fillable` on models. Do not use `$guarded = []`; it permits mass assignment of every column (see `laravel-security.md`).
- **Eager load relationships** to prevent N+1 queries: `Post::with('author', 'comments')->find($id);`
- **Create query scopes** for reusable filters:
  ```php
  public function scopePublished(Builder $query): Builder {
      return $query->where('published_at', '<=', now());
  }
  ```
- **Wrap critical changes in transactions**:
  ```php
  DB::transaction(fn () => $order->process());
  ```
- Prefer Eloquent accessors/mutators for data casting; avoid raw SQL unless performance demands it.

---

## API Development
- Use **API Resources** to shape JSON output.
- Standardise envelope:
  ```json
  { "data": ..., "meta": { "pagination": … } }
  ```
- Implement **cursor‑based pagination** for large datasets.
- Apply **rate limiting** via `throttle` middleware.
- Return appropriate HTTP status codes (200, 201, 204, 400, 401, 403, 404, 422, 500).

---

## Authentication & Authorization
- Use **Laravel Sanctum** for SPA or token‑based APIs.
- Store API tokens with abilities to limit scope.
- Protect routes with `auth:sanctum` middleware.
- Implement **Policies** for model‑level checks; use **Gates** for generic permissions.

---

## Queues & Jobs
- Dispatch jobs with `dispatch()`; keep them **idempotent** (check for existing state before acting).
- Use **queue connections** appropriate to workload (database, Redis, SQS).
- Chain jobs when order matters.
- Monitor failed jobs with `php artisan queue:failed` and configure a retry strategy.

---

## Caching
- Cache expensive queries with `Cache::remember()`.
- Use **cache tags** when you need to invalidate groups of items.
- Always set a sensible TTL; avoid indefinite caching of mutable data.

---

## Blade & Views
- Create **Blade components** for reusable UI pieces.
- Keep Blade files free of business logic; move calculations to ViewModels or Services.
- Use `@csrf` in forms and `@method('PUT')` for non‑GET/POST verbs.

---

## Testing
- Write **unit tests** for pure PHP classes (services, helpers) using PHPUnit or Pest.
- Write **feature tests** for HTTP endpoints with `Illuminate\Testing\TestResponse`.
- Use an **in‑memory SQLite** database for fast tests:
  ```env
  DB_CONNECTION=sqlite
  DB_DATABASE=:memory:
  ```
- Assert JSON structure with `assertJsonStructure()` and status codes with `assertStatus()`.
- Mock external services with `Http::fake()` or `Queue::fake()`.

---

## Performance Profiling & Optimisation
- Enable **Laravel Telescope** or **Debugbar** in local environments.
- Profile database queries; add indexes on columns used in `where`, `join`, or `orderBy`.
- Reduce view rendering time by caching Blade fragments (`@cache` directive or manual cache).
- Use **OPcache** in production; monitor opcode cache hit rate.

---

## Code Patterns

### Layout

```
app/
├── Actions/            # Single-purpose use cases
├── Events/
├── Http/
│   ├── Controllers/
│   ├── Middleware/
│   ├── Requests/       # Form request validation
│   └── Resources/      # API resources
├── Jobs/
├── Models/
├── Policies/
├── Providers/
├── Services/           # Services that coordinate more than one action
└── Support/
```

### Controller -> action, with a DTO from the form request

```php
final class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', Order::class) ?? false;
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['required', 'integer', 'exists:customers,id'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.sku' => ['required', 'string'],
            'items.*.quantity' => ['required', 'integer', 'min:1'],
        ];
    }

    public function toDto(): CreateOrderData
    {
        return new CreateOrderData(
            customerId: (int) $this->validated('customer_id'),
            items: $this->validated('items'),
        );
    }
}

final class CreateOrderAction
{
    public function __construct(private OrderRepository $orders) {}

    public function handle(CreateOrderData $data): Order
    {
        return DB::transaction(fn () => $this->orders->create($data));
    }
}

final class OrdersController extends Controller
{
    public function store(StoreOrderRequest $request, CreateOrderAction $createOrder): JsonResponse
    {
        return OrderResource::make($createOrder->handle($request->toDto()))
            ->response()
            ->setStatusCode(201);
    }
}
```

Bind interfaces to implementations in a service provider:

```php
public function register(): void
{
    $this->app->bind(OrderRepository::class, EloquentOrderRepository::class);
}
```

### Routes and scoped bindings

```php
Route::middleware('auth:sanctum')->group(function () {
    Route::apiResource('projects', ProjectController::class);
});

// Scoped bindings: {project} must belong to {account}. This helps stop access across tenants.
Route::scopeBindings()->group(function () {
    Route::get('/accounts/{account}/projects/{project}', [ProjectController::class, 'show']);
});
```

- Use one parameter name that matches the bound model (`{conversation}` for `Conversation`). Keep prefixes the same (do not mix `conversation` and `conversations`).
- To bind a parameter to a different class, use `Route::model('conversation', AiConversation::class)`. For custom logic, use `Route::bind()` or `resolveRouteBinding()`.
- Scoped bindings do not replace authorization. Still call the policy.

### Model with casts, relations, and scopes

```php
final class Project extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = ['name', 'owner_id', 'status'];

    protected function casts(): array
    {
        return ['status' => ProjectStatus::class, 'archived_at' => 'datetime'];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function scopeActive(Builder $query): Builder
    {
        return $query->whereNull('archived_at');
    }

    public function scopeOwnedBy(Builder $query, int $userId): Builder
    {
        return $query->where('owner_id', $userId);
    }

    protected function budget(): Attribute   // Value object over an integer column
    {
        return Attribute::make(
            get: fn (int $value) => Money::fromCents($value),
            set: fn (Money $money) => $money->toCents(),
        );
    }
}

$orders = Order::query()->with(['customer', 'items.product'])->latest()->paginate(25);
```

- Use a global scope (`static::addGlobalScope(...)` in `booted()`) or a named scope for one filter, not both.
- For complex filters, use a query object that clones the builder for each step, so each call returns a new query.

### Migration

```php
return new class extends Migration
{
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table): void {
            $table->id();
            $table->foreignId('customer_id')->constrained()->cascadeOnDelete();
            $table->string('status', 32)->index();
            $table->unsignedInteger('total_cents');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
```

File names use `YYYY_MM_DD_HHMMSS_create_orders_table.php`. Migrations are anonymous classes. Table names are plural `snake_case`.

### Paginated resource response

```php
$projects = Project::query()->active()->paginate(25);

return ProjectResource::collection($projects);   // Adds data, links, and meta (current_page, per_page, total)
```

### Side effects, cache, and config

- Send domain events for side effects (email, analytics). Put slow work (reports, exports, webhooks) in queued jobs with retries and backoff. Make each handler idempotent.
- Remove cache entries on model events (`created`, `updated`, `deleted`), or use cache tags for related data.
- Keep secrets in `.env` and read them only in `config/*.php`. Call `env()` only in config files, because `config:cache` stops `env()` from working at runtime.

## Common Pitfalls & Anti‑Patterns
- **Fat controllers** – move logic to Services.
- **Business logic in routes** – keep routes declarative.
- **Mass assignment without validation** – always validate before `Model::create()`.
- **Hard‑coded configuration** – store values in `.env` and config files.
- **Duplicated code** across controllers – extract to reusable Services or Traits.
- **Raw queries for simple CRUD** – prefer Eloquent unless a clear performance case exists.

---

## Checklist
- [ ] `declare(strict_types=1);` present in every PHP file.
- [ ] Controllers are thin; business logic lives in Services.
- [ ] All input validated via FormRequest or manual validator.
- [ ] Eloquent models use `$fillable`/`$guarded` correctly.
- [ ] N+1 queries eliminated with eager loading.
- [ ] API responses use Resources and consistent envelope.
- [ ] Authentication uses Sanctum (or built‑in guard) with hashed passwords.
- [ ] Jobs are dispatchable, idempotent, and queued appropriately.
- [ ] Frequently accessed data cached with proper tags and TTL.
- [ ] Blade views contain only presentation logic.
- [ ] Unit and feature tests cover critical paths.
- [ ] Profiling tools (Telescope, Debugbar) are enabled locally.
- [ ] No static façade abuse for mutable state; dependencies injected.
- [ ] Code follows PSR‑12 and Laravel coding standards.

## Related skills

Load these when the task spans more than this skill.

- [`laravel-security`](laravel-security.md) — Production config, Sanctum and Passport, policies, mass assignment, CSRF, XSS, uploads, and security headers.
- [`laravel-testing`](laravel-testing.md) — PHPUnit and Pest tests, factories, fakes, and the verification loop before a PR or deploy.
- [`laravel-plugin-discovery`](laravel-plugin-discovery.md) — Find and evaluate Laravel packages by health score and version support (needs the LaraPlugins MCP server).
- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`unit-testing-patterns`](../../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
