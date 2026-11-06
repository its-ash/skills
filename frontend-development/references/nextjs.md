# Next.js 16 App Router – Best Practices & Patterns

Build Next.js 16+ apps with the App Router, React 19.3, Turbopack, Cache Components, Server Actions, and Supabase auth.
Baseline: Next.js 16.4, Node 20.9+ (use Node 24 or 26 LTS), `next.config.ts`, ESLint 9 flat config via `eslint-config-next` or Biome 2. `next lint` is removed; run `eslint` or `biome` directly.

---

## 1. Component Type Decision

**Rule:** Server Components are the default. Use a Client Component only when you need interactivity.

| Need | Component type |
|------|----------------|
| `useState`, `useEffect`, event handlers, browser APIs | **Client** – add `'use client'` at the top of the file |
| Direct data fetching, static markup, layout, SEO‑critical content | **Server** – no directive needed |
| Both interactivity and server‑side data | Split: create a Server parent that renders a Client child |

**Example** (Server parent with Client child): `app/dashboard/page.tsx` awaits `fetchStats()` and renders `<DashboardClient stats={stats} />`; `DashboardClient.tsx` starts with `'use client'` and owns `useState`.
---

## 2. Data Fetching Patterns

Since Next.js 15, `fetch` is not cached by default. Opt in to caching.

| Pattern | Cache behaviour | Typical use |
|---------|----------------|------------|
| **Default** (`fetch` without options) | No caching, fetch on every request | User‑specific data, auth‑protected APIs |
| **ISR** (`next: { revalidate: <seconds> }`) | Time‑based revalidation | Blog posts, product listings |
| **Cache Components** (`'use cache'` + `cacheLife` / `cacheTag`) | Cached function or component output; tag‑based invalidation | Shared public content, PPR static shells |

**Server Component fetch example:**
```tsx
export const fetchPosts = async () => {
  const res = await fetch('https://api.example.com/posts', {
    next: { revalidate: 60 } // ISR, refresh every minute
  })
  if (!res.ok) throw new Error('Failed to load')
  return res.json()
}
```
**Cache Components example** (enable `cacheComponents: true` in `next.config.ts`):
```tsx
import { cacheLife, cacheTag } from 'next/cache'

export async function getPosts() {
  'use cache'
  cacheLife('hours')
  cacheTag('posts')
  const res = await fetch('https://api.example.com/posts')
  return res.json()
}
```
**Async request APIs:** `params`, `searchParams`, `cookies()`, `headers()`, and `draftMode()` are promises. Always `await` them.
```tsx
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const post = await fetchPost(id)
  return <h1>{post.title}</h1>
}
```
---

## 3. Routing Conventions

| File | Purpose |
|------|---------|
| `page.tsx` | Main UI for the route |
| `layout.tsx` | Shared UI (header, sidebar) for nested routes |
| `loading.tsx` | UI shown while a Server Component streams |
| `error.tsx` | Error boundary for the route |
| `not-found.tsx` | 404 page |

**Route organisation patterns**
- **Route groups** – wrap a folder name in parentheses `(admin)` to group files without affecting the URL.
- **Parallel routes** – create a folder with `@slot` name (e.g., `@modal`) to render multiple UI slots at the same level.
- **Intercepting routes** – prefix a folder with a dot `(.modal)` to display a modal overlay while keeping the underlying page.

---

## 4. API Routes (Route Handlers)

Create a `route.ts` file under `app/api/<resource>/`.
```ts
import { NextResponse } from 'next/server'
import { z } from 'zod'
import { db } from '@/lib/db'

// Example: POST /api/users
export async function POST(request: Request) {
  const body = await request.json()
  const schema = z.object({ email: z.email(), name: z.string() })
  const result = schema.safeParse(body)
  if (!result.success) {
    return NextResponse.json({ error: 'Invalid input' }, { status: 400 })
  }
  const user = await db.user.create({ data: result.data })
  return NextResponse.json(user, { status: 201 })
}
```
**Best practices**
- Validate input with Zod 4.
- Return appropriate HTTP status codes.
- Catch errors and return a JSON error object.
- Node runtime is the default. Set `export const runtime = 'edge'` only for a light handler that must run at the edge.
- Use `after()` from `next/server` for work that runs after the response is sent (logs, analytics).
---

## 5. Performance Optimisations

### Image Optimization
- Use `next/image` for automatic resizing, lazy loading, and AVIF/WebP conversion.
- Set `priority` on above‑fold images.
- Provide a `blurDataURL` placeholder for a smooth loading experience.

### Bundle Splitting
- Dynamically import heavy components.
```tsx
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), { ssr: false })
```
- Next.js automatically code‑splits per route; keep client bundles small.
- Add large barrel-export libraries to `experimental.optimizePackageImports` in `next.config.ts`.

### Bundle Analysis
```ts
// next.config.ts
import type { NextConfig } from 'next'
import bundleAnalyzer from '@next/bundle-analyzer'

const withBundleAnalyzer = bundleAnalyzer({ enabled: process.env.ANALYZE === 'true' })
const nextConfig: NextConfig = { cacheComponents: true }
export default withBundleAnalyzer(nextConfig)
```
Run `ANALYZE=true next build` to view size breakdown. Use the Next.js DevTools MCP for agent-driven diagnostics.
---

## 6. Metadata Management

- For static metadata, export a `metadata` object from `layout.tsx` or `page.tsx`.
- For dynamic per‑route metadata, implement `generateMetadata` in `page.tsx`.
```tsx
import type { Metadata } from 'next'

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }): Promise<Metadata> {
  const { id } = await params
  const post = await fetchPost(id)
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: { images: [{ url: post.coverUrl }] },
    alternates: { canonical: `https://example.com/posts/${id}` }
  }
}
```
- Keep title length 50‑60 characters and description 150‑160 characters for SEO.
---

## 7. Caching Strategy

| Layer | Control method |
|-------|----------------|
| Request | `fetch` options (`next: { revalidate, tags }`, `cache`) |
| Function / component | `'use cache'` + `cacheLife()` + `cacheTag()` |
| Invalidation | `revalidateTag()` (background), `updateTag()` (immediate, in Server Actions), `revalidatePath()` |
| Full route | `export const revalidate = <seconds>` in `page.tsx`, or PPR with Cache Components |

**On‑demand revalidation** (e.g., after a CMS update):
```ts
import { revalidateTag } from 'next/cache'
export async function POST() {
  // ...update content
  revalidateTag('posts')
  return new Response('OK')
}
```
---

## 8. Server Actions

- Declare a function with `'use server'` at the top of a file.
- Use them for form submissions, data mutations, or to trigger revalidation.
- Bind them to forms with `useActionState` and `useOptimistic` on the client.
```tsx
// app/actions.ts
'use server'
import { updateTag } from 'next/cache'
import { z } from 'zod'

const schema = z.object({ title: z.string().min(1), content: z.string().min(1) })

export async function createPost(prev: { error?: string }, formData: FormData) {
  const result = schema.safeParse(Object.fromEntries(formData))
  if (!result.success) return { error: 'Invalid input' }
  await db.post.create({ data: result.data })
  updateTag('posts')
  return { success: true }
}
```
- Validate all inputs server‑side.
- Return typed plain values; avoid sending raw errors to the client.
---

## 9. Supabase Authentication Integration

### Core Principles
- Use `@supabase/ssr` to create a Supabase client that works in Server Components, route handlers, Server Actions, and `proxy.ts`.
- Store the session in cookies managed by `@supabase/ssr`; never expose the service-role key to the browser or to the SSR client.
- Protect routes in `proxy.ts`: refresh the session and redirect unauthenticated users.
- Use `supabase.auth.getUser()` for authorization. `getSession()` does not verify the JWT on the server.

### Supabase Client Setup
```ts
// lib/supabase/server.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!, // anon/publishable key, never service-role
    {
      cookies: {
        getAll: () => cookieStore.getAll(),
        setAll: (list) => {
          try {
            list.forEach(({ name, value, options }) => cookieStore.set(name, value, options))
          } catch {
            // called from a Server Component; proxy.ts refreshes the session
          }
        },
      },
    },
  )
}
```
Create a new client per request. Do not share one instance across requests.

### Auth Proxy (protects routes)
```ts
// proxy.ts (project root)
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function proxy(request: NextRequest) {
  let response = NextResponse.next({ request })
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (list) => {
          list.forEach(({ name, value }) => request.cookies.set(name, value))
          response = NextResponse.next({ request })
          list.forEach(({ name, value, options }) => response.cookies.set(name, value, options))
        },
      },
    },
  )
  const { data: { user } } = await supabase.auth.getUser() // refreshes the session
  const url = request.nextUrl.clone()
  const isProtected = ['/dashboard', '/account'].some(p => url.pathname.startsWith(p))
  if (isProtected && !user) {
    url.pathname = '/login'
    return NextResponse.redirect(url)
  }
  return response
}

export const config = { matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'] }
```
- `proxy.ts` runs on the Node runtime by default.

### Auth Callback Route (OAuth)
`app/auth/callback/route.ts`: read `code` from `searchParams`, call `supabase.auth.exchangeCodeForSession(code)` on a server client, then redirect with `NextResponse.redirect(new URL('/', request.url))`. Redirect to `/login` on a missing code or an error.

### Using Supabase in a Server Component
```tsx
// app/profile/page.tsx – Server Component
import { createClient } from '@/lib/supabase/server'

export default async function Page() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return <p>Not logged in</p>
  return <p>Welcome, {user.email}</p>
}
```
### Using Supabase in a Client Component
```tsx
'use client'
import { createBrowserClient } from '@supabase/ssr'

export default function LogoutButton() {
  const supabase = createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY!,
  )
  const handleLogout = async () => {
    await supabase.auth.signOut()
    window.location.href = '/login'
  }
  return <button onClick={handleLogout}>Log out</button>
}
```
---

## 10. Turbopack and `proxy.ts`
- Next.js 16 uses Turbopack for `next dev` and `next build` by default. Turbopack is an incremental bundler in Rust with a file-system cache under `.next`. Do not clear the cache without a reason.
- Use webpack only for a webpack-only plugin: run with `--webpack`. Treat webpack as legacy.
- `proxy.ts` at the project root replaces `middleware.ts`. Export a `proxy` function. Node runtime is the default.
- In Next.js 16 projects, `proxy.ts` is correct. Do not report it as a misnamed or missing middleware file. A rename to `middleware.ts` stops it.
- Reference: [Next.js proxy docs](https://nextjs.org/docs/app/getting-started/proxy)

---

## 11. Anti‑Patterns to Avoid
| Bad practice | Correct approach |
|--------------|-----------------|
| Adding `'use client'` to every file | Keep components Server by default; add `'use client'` only when interactivity is required |
| Fetching data in Client Components | Fetch data in Server Components or Server Actions, then pass as props |
| Reading `params` or `cookies()` without `await` | Await all request APIs; they are promises |
| Skipping `loading.tsx` for slow streams | Provide a `loading.tsx` file to show a placeholder while the Server Component streams |
| Large client bundles without code‑splitting | Use `dynamic()` imports and keep interactive parts minimal |
| `getSession()` for authorization | Call `supabase.auth.getUser()`; it validates the token on the server |
| Service-role key in the SSR client | Use the publishable key with cookies; keep the service-role key for trusted scripts only |
---

## Checklist
- [ ] Decide component type using the decision tree. Add `'use client'` only when needed.
- [ ] Choose a data‑fetching pattern (dynamic, ISR, `'use cache'`) and set `revalidate` or `cacheLife` accordingly.
- [ ] Await `params`, `searchParams`, `cookies()`, and `headers()`.
- [ ] Follow file conventions (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`).
- [ ] Use route groups, parallel routes, or intercepting routes for UI composition.
- [ ] Validate all API input with Zod; return proper status codes.
- [ ] Optimize images with `next/image`; set `priority` for above‑fold assets.
- [ ] Dynamically import heavy client‑only components.
- [ ] Implement `generateMetadata` for dynamic SEO tags.
- [ ] Configure caching: `cacheTag` + `revalidateTag` / `updateTag` for on‑demand updates.
- [ ] Write Server Actions for mutations; validate inputs and trigger revalidation.
- [ ] Set up Supabase with `@supabase/ssr`, `createServerClient` + `getAll`/`setAll`, publishable key.
- [ ] Add `proxy.ts` to protect private routes and refresh sessions with `getUser()`.
- [ ] Implement OAuth callback route that exchanges the code for a session.
- [ ] Test loading and error states (`loading.tsx`, `error.tsx`).
- [ ] Run `ANALYZE=true next build` to verify bundle size.

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`prisma`](../../database-design/references/prisma.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`seo`](../../seo/SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`astro`](astro.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
- [`i18n-localization`](../../i18n-localization/SKILL.md) — Guides developers to add internationalization (i18n) and localization (L10n) to web and Python projects, cover…
