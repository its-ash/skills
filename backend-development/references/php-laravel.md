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
- Define `$fillable` or `$guarded` on models; prefer `$guarded = []` only when you have explicit validation.
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

- [`database-design`](../../database-design/SKILL.md) — Expert database architect for data layer design, technology selection, and schema modeling. Use for selecting…
- [`unit-testing-patterns`](../../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
