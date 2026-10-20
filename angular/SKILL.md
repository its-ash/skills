---
name: angular
description: "Provides expert guidance for modern Angular (v20+) development, covering Signals, Standalone Components, Zoneless mode, SSR/Hydration, routing, DI, state management, performance, testing and migration best practices. Use when building or debugging Angular apps, components, services, routes, guards, interceptors, templates, RxJS, signals, standalone bootstrap, SSR, hydration, zoneless change detection, Angular CLI, ng commands, TypeScript, Jasmine, Karma, Jest, Playwright, or migrating from NgModules."
---

# Angular (v20+) Modern Development

Use this skill when you are building or upgrading an Angular application that targets version 20 or later. It helps you adopt Signals, Standalone Components, Zoneless change detection, server‑side rendering with hydration, and other current patterns while keeping the app performant and maintainable.

---

## When to Use
- Starting a new Angular project (v20+). 
- Migrating an existing app to Signals, Standalone Components, or Zoneless mode. 
- Adding SSR, prerendering, or incremental hydration. 
- Optimising change‑detection and bundle size. 
- Implementing modern routing, DI, and state‑management patterns.

## When Not to Use
- AngularJS (1.x) migration – use an AngularJS‑migration skill. 
- Projects locked to a version earlier than v20 where Signals or Zoneless are unavailable. 
- General TypeScript problems – use a TypeScript‑expert skill.

---

## 1. Signals – Fine‑grained Reactivity
Signals replace zone‑based change detection for local state.

```ts
import { signal, computed, effect } from "@angular/core";

// Writable signal
const count = signal(0);

// Read value
console.log(count()); // 0

// Update value
count.set(5);
count.update(v => v + 1);

// Derived value
const doubled = computed(() => count() * 2);

// Side‑effect
effect(() => console.log(`Count is ${count()}`));
```

### Signal Inputs & Outputs
```ts
import { Component, input, output, model } from "@angular/core";

@Component({
  selector: "app-user-card",
  standalone: true,
  template: `
    <h3>{{ name() }}</h3>
    <button (click)="select.emit(id())">Select</button>
  `,
})
export class UserCardComponent {
  id = input.required<string>();
  name = input.required<string>();
  role = input<string>("User");
  select = output<string>();
  isSelected = model(false); // two‑way binding
}
```

### When to Prefer Signals over RxJS
| Use case | Signals | RxJS |
|---|---|---|
| Local component state | ✅ | ❌ |
| Derived/computed values | ✅ | ✅ (combineLatest) |
| Side effects | ✅ | ✅ (tap) |
| HTTP requests | ❌ (use HttpClient) | ✅ |
| Complex async flows | ❌ | ✅ |

---

## 2. Standalone Components
Standalone components remove the need for NgModules.

```ts
import { Component } from "@angular/core";
import { CommonModule } from "@angular/common";
import { RouterLink } from "@angular/router";

@Component({
  selector: "app-header",
  standalone: true,
  imports: [CommonModule, RouterLink],
  template: `
    <a routerLink="/">Home</a>
    <a routerLink="/about">About</a>
  `,
})
export class HeaderComponent {}
```

### Bootstrapping without NgModule
```ts
// main.ts
import { bootstrapApplication } from "@angular/platform-browser";
import { provideRouter } from "@angular/router";
import { provideHttpClient } from "@angular/common/http";
import { AppComponent } from "./app.component";
import { routes } from "./app.routes";

bootstrapApplication(AppComponent, {
  providers: [provideRouter(routes), provideHttpClient()],
});
```

### Lazy‑load a Standalone Component
```ts
import { Routes } from "@angular/router";

export const routes: Routes = [
  {
    path: "dashboard",
    loadComponent: () =>
      import("./dashboard/dashboard.component").then(m => m.DashboardComponent),
  },
];
```

---

## 3. Zoneless Angular
Disabling `zone.js` reduces bundle size and improves debugging.

### Enable Zoneless Mode
```ts
// main.ts
import { bootstrapApplication } from "@angular/platform-browser";
import { provideZonelessChangeDetection } from "@angular/core";
import { AppComponent } from "./app.component";

bootstrapApplication(AppComponent, {
  providers: [provideZonelessChangeDetection()],
});
```

### Component Example
```ts
import { Component, signal, ChangeDetectionStrategy } from "@angular/core";

@Component({
  selector: "app-counter",
  standalone: true,
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `
    <div>Count: {{ count() }}</div>
    <button (click)="increment()">+</button>
  `,
})
export class CounterComponent {
  count = signal(0);
  increment() { this.count.update(v => v + 1); }
}
```

**Benefits**: smaller bundle (~15 KB saved), clearer stack traces, easier interop with Web Components.

---

## 4. Server‑Side Rendering & Incremental Hydration

### Add SSR support
```bash
ng add @angular/ssr
```

### Client Hydration Configuration
```ts
// app.config.ts
import { ApplicationConfig } from "@angular/core";
import { provideClientHydration, withEventReplay } from "@angular/platform-browser";

export const appConfig: ApplicationConfig = {
  providers: [provideClientHydration(withEventReplay())],
};
```

### Incremental Hydration with `@defer`
```ts
@Component({
  selector: "app-page",
  standalone: true,
  template: `
    <app-hero />

    @defer (hydrate on viewport) { <app-comments /> }
    @defer (hydrate on interaction) { <app-chat-widget /> }
  `,
})
export class PageComponent {}
```

#### Hydration Triggers
| Trigger | Typical use |
|---|---|
| `on idle` | Low‑priority UI |
| `on viewport` | Content that appears later |
| `on interaction` | Widgets activated by click |
| `on hover` | Hover‑activated panels |
| `on timer(ms)` | Delayed activation |

---

## 5. Modern Routing Patterns

### Functional Guard
```ts
import { inject } from "@angular/core";
import { Router, CanActivateFn } from "@angular/router";
import { AuthService } from "./auth.service";

export const authGuard: CanActivateFn = (route, state) => {
  const auth = inject(AuthService);
  const router = inject(Router);
  return auth.isAuthenticated()
    ? true
    : router.createUrlTree(["/login"], { queryParams: { returnUrl: state.url } });
};
```

### Route‑level Resolver using Signals
```ts
import { inject } from "@angular/core";
import { ResolveFn } from "@angular/router";
import { UserService } from "./user.service";
import { map } from "rxjs/operators";
import { toSignal } from "@angular/core/rxjs-interop";

export const userResolver: ResolveFn<User> = (route) => {
  const svc = inject(UserService);
  return svc.getUser(route.paramMap.get('id')!);
};

// routes
{ path: 'user/:id', loadComponent: () => import('./user.component'), resolve: { user: userResolver } }
```

In the component, convert the resolved data to a signal:
```ts
private route = inject(ActivatedRoute);
user = toSignal(this.route.data.pipe(map(d => d['user'])));
```

---

## 6. Dependency Injection – `inject()` Function
```ts
import { Component, inject } from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { UserService } from "./user.service";

@Component({ /* … */ })
export class UserComponent {
  private http = inject(HttpClient);
  private userService = inject(UserService);
  users = toSignal(this.userService.getUsers());
}
```

### Injection Tokens for Configuration
```ts
import { InjectionToken, inject } from "@angular/core";

export const API_BASE_URL = new InjectionToken<string>('API_BASE_URL');

// Provide at bootstrap
bootstrapApplication(AppComponent, {
  providers: [{ provide: API_BASE_URL, useValue: 'https://api.example.com' }],
});

// Consume in a service
@Injectable({ providedIn: 'root' })
export class ApiService {
  private base = inject(API_BASE_URL);
  get(endpoint: string) { return this.http.get(`${this.base}/${endpoint}`); }
}
```

---

## 7. Component Composition & Reusability
### Content Projection (Slots)
```ts
@Component({
  selector: 'app-card',
  template: `
    <div class="card">
      <div class="header"><ng-content select="[card-header]"></ng-content></div>
      <div class="body"><ng-content></ng-content></div>
    </div>
  `,
})
export class CardComponent {}
```

Usage:
```html
<app-card>
  <h3 card-header>Title</h3>
  <p>Body text</p>
</app-card>
```

### Host Directives (Composition without inheritance)
```ts
@Directive({
  standalone: true,
  selector: '[appTooltip]',
  inputs: ['tooltip'],
})
export class TooltipDirective {}

@Component({
  selector: 'app-button',
  standalone: true,
  hostDirectives: [{ directive: TooltipDirective, inputs: ['tooltip: title'] }],
  template: `<ng-content />`,
})
export class ButtonComponent {}
```

---

## 8. State Management with Signals
### Centralised Signal Store
```ts
import { Injectable, signal, computed } from "@angular/core";

interface AppState {
  user: User | null;
  theme: 'light' | 'dark';
  notifications: Notification[];
}

@Injectable({ providedIn: 'root' })
export class StateService {
  private _user = signal<User | null>(null);
  private _theme = signal<'light' | 'dark'>('light');
  private _notifications = signal<Notification[]>([]);

  readonly user = computed(() => this._user());
  readonly theme = computed(() => this._theme());
  readonly notifications = computed(() => this._notifications());
  readonly unreadCount = computed(() => this._notifications().filter(n => !n.read).length);

  setUser(u: User | null) { this._user.set(u); }
  toggleTheme() { this._theme.update(t => t === 'light' ? 'dark' : 'light'); }
  addNotification(n: Notification) { this._notifications.update(arr => [...arr, n]); }
}
```

### Component‑Scoped Store Example
```ts
@Injectable()
export class ProductStore {
  private http = inject(HttpClient);
  private _products = signal<Product[]>([]);
  private _loading = signal(false);
  private _filter = signal('');

  readonly products = computed(() => this._products());
  readonly loading = computed(() => this._loading());
  readonly filtered = computed(() => {
    const f = this._filter().toLowerCase();
    return this._products().filter(p => p.name.toLowerCase().includes(f));
  });

  load() {
    this._loading.set(true);
    this.http.get<Product[]>('/api/products').subscribe({
      next: data => { this._products.set(data); this._loading.set(false); },
      error: () => this._loading.set(false),
    });
  }

  setFilter(v: string) { this._filter.set(v); }
}
```

---

## 9. Forms – Current Reactive Forms & Signal Preview
### Reactive Forms (stable)
```ts
import { Component, inject } from "@angular/core";
import { FormBuilder, Validators, ReactiveFormsModule } from "@angular/forms";

@Component({
  selector: 'app-user-form',
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="name" placeholder="Name" />
      <input formControlName="email" type="email" placeholder="Email" />
      <button [disabled]="form.invalid">Submit</button>
    </form>
  `,
})
export class UserFormComponent {
  private fb = inject(FormBuilder);
  form = this.fb.group({
    name: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
  });
  onSubmit() { if (this.form.valid) console.log(this.form.value); }
}
```

### Experimental Signal‑Based Form Pattern (v22 preview)
```ts
@Component({
  selector: 'app-signal-form',
  standalone: true,
  template: `
    <input [value]="name()" (input)="name.set($event.target.value)" placeholder="Name" />
    <input [value]="email()" (input)="email.set($event.target.value)" placeholder="Email" />
    <button (click)="submit()" [disabled]="!isValid()">Submit</button>
  `,
})
export class SignalFormComponent {
  name = signal('');
  email = signal('');
  isValid = computed(() => this.name().trim().length > 0 && this.email().includes('@'));
  submit() { if (this.isValid()) console.log({ name: this.name(), email: this.email() }); }
}
```
*Use only after the official Signal Forms API is released.

---

## 10. Performance Optimisation
### Change Detection Strategy
```ts
@Component({
  selector: 'app-widget',
  changeDetection: ChangeDetectionStrategy.OnPush,
  template: `{{ data() }}`,
})
export class WidgetComponent { data = signal(''); }
```
OnPush works with Signals, `@defer`, async pipes, and event handlers.

### Defer Blocks for Lazy Loading
```ts
@Component({
  template: `
    <app-header />
    @defer (on viewport) {
      <app-heavy-chart />
    } @placeholder { <div class="skeleton" /> }
    @loading (minimum 200ms) { <app-spinner /> }
    @error { <p>Failed to load chart</p> }
  `,
})
export class DashboardComponent {}
```

### NgOptimizedImage
```ts
import { NgOptimizedImage } from '@angular/common';

@Component({
  imports: [NgOptimizedImage],
  template: `
    <img ngSrc="hero.jpg" width="800" height="600" priority />
    <img ngSrc="thumb.jpg" width="200" height="150" loading="lazy" placeholder="blur" />
  `,
})
export class ImageDemo {}
```

---

## 11. Testing Modern Angular
### Unit Test for a Signal Component
```ts
import { TestBed } from '@angular/core/testing';
import { CounterComponent } from './counter.component';

describe('CounterComponent', () => {
  let component: CounterComponent;
  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [CounterComponent] }).compileComponents();
    const fixture = TestBed.createComponent(CounterComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('increments count', () => {
    expect(component.count()).toBe(0);
    component.increment();
    expect(component.count()).toBe(1);
  });
});
```

### Testing Signal Inputs
```ts
import { TestBed } from '@angular/core/testing';
import { UserCardComponent } from './user-card.component';

describe('UserCardComponent', () => {
  let fixture;
  beforeEach(async () => {
    await TestBed.configureTestingModule({ imports: [UserCardComponent] }).compileComponents();
    fixture = TestBed.createComponent(UserCardComponent);
    const compRef = fixture.componentRef;
    compRef.setInput('id', '123');
    compRef.setInput('name', 'John Doe');
    fixture.detectChanges();
  });

  it('renders name', () => {
    const el = fixture.nativeElement.querySelector('h3');
    expect(el.textContent).toContain('John Doe');
  });
});
```

---

## 12. Best‑Practice Checklist
- **State**: Use Signals for local/component state. Use RxJS only for streams (HTTP, websockets). 
- **Components**: Prefer Standalone components with direct imports. Avoid large SharedModules. 
- **Change Detection**: Set `OnPush` everywhere; rely on Signals to trigger updates. 
- **Lazy Loading**: Use `loadComponent` and `@defer` instead of eager routes. 
- **DI**: Use the `inject()` function; reserve constructor injection for legacy code. 
- **Inputs**: Prefer `input()` signals; keep `@Input()` only for compatibility. 
- **Zoneless**: Enable for new projects; test thoroughly before applying to legacy code. 
- **SSR**: Add `@angular/ssr` early; configure hydration triggers to match user experience. 
- **Testing**: Import standalone components directly in TestBed; use `setInput` for signal inputs. 
- **Performance**: Apply `NgOptimizedImage`, defer heavy UI, and audit bundle size after removing `zone.js`.

---

## 13. Resources
- Angular official docs: https://angular.dev 
- Signals guide: https://angular.dev/guide/signals 
- SSR & hydration: https://angular.dev/guide/ssr 
- Update guide (v20+): https://angular.dev/update-guide 
- Angular blog: https://blog.angular.dev

---

## 14. Common Troubleshooting
| Issue | Fix |
|---|---|
| Signal value does not update UI | Ensure component uses `OnPush` and reads the signal as a function (`count()`). |
| Hydration mismatch between server and client | Verify that server‑rendered markup matches client template; avoid side‑effects in constructors. |
| Circular DI error | Use `forwardRef(() => Service)` with `inject()` or restructure providers. |
| Zoneless change not detected | All UI changes must come from signal updates; avoid direct DOM mutation. |
| SSR HTTP request fails | Use `TransferState` or `withFetch()` to serialize data to the client. |

---

*Apply these patterns incrementally. Test each change in a development build before promoting to production.*

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../frontend-development/SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`typescript`](../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`unit-testing-patterns`](../unit-testing-patterns/SKILL.md) — A concise guide to unit‑testing patterns for JavaScript/TypeScript (Jest) and Python (pytest). Use when writin…
- [`web-performance`](../web-performance/SKILL.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`web-accessibility`](../web-accessibility/SKILL.md) — Provides concise guidance for auditing and fixing web accessibility to meet WCAG 2.1 (POUR) and ARIA standards…
