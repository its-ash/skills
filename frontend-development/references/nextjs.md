# Next.js App Router – Best Practices & Patterns

This skill helps you create robust Next.js applications using the App Router. Follow the rules, workflows, and checklists to decide between Server and Client components, organise routes, fetch data efficiently, optimise performance, and integrate Supabase authentication securely.

## When to use
- Starting a new Next.js project with the App Router (app/ directory).
- Migrating an existing Pages Router project to the App Router.
- Building full‑stack features that need server‑side data fetching, streaming, or Server Actions.
- Adding Supabase authentication (email/password, OAuth) to a Next.js app.

---

## 1. Component Type Decision

**Rule:** Server Components are the default. Use a Client Component only when you need interactivity.

| Need | Component type |
|------|----------------|
| `useState`, `useEffect`, event handlers, browser APIs | **Client** – add `'use client'` at the top of the file |
| Direct data fetching, static markup, layout, SEO‑critical content | **Server** – no directive needed |
| Both interactivity and server‑side data | Split: create a Server parent that renders a Client child |

**Example** (Server parent with Client child):
```tsx
// app/dashboard/page.tsx – Server Component
import DashboardClient from './DashboardClient'

export default async function Page() {
  const stats = await fetchStats() // server‑side fetch
  return <DashboardClient stats={stats} />
}
```
```tsx
// app/dashboard/DashboardClient.tsx – Client Component
'use client'
import { useState } from 'react'

export default function DashboardClient({ stats }) {
  const [count, setCount] = useState(0)
  return (
    <div>
      <h1>Stats: {stats.total}</h1>
      <button onClick={() => setCount(c => c + 1)}>Clicked {count}</button>
    </div>
  )
}
```
---

## 2. Data Fetching Patterns

| Pattern | Cache behaviour | Typical use |
|---------|----------------|------------|
| **Default** (`fetch` without options) | Cached at build time (static) | Public content that rarely changes |
| **ISR** (`revalidate: <seconds>`) | Time‑based revalidation | Blog posts, product listings |
| **No‑store** (`cache: 'no-store'`) | No caching, fetch on every request | User‑specific data, auth‑protected APIs |

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

**Project layout example:**
```
app/
├─ (marketing)/
│  └─ page.tsx          # /marketing (group, no URL change)
├─ (dashboard)/
│  ├─ layout.tsx        # shared dashboard layout
│  └─ page.tsx          # /dashboard
├─ api/
│  └─ users/
│     └─ route.ts      # /api/users
└─ components/
   └─ ui/
```
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
  const schema = z.object({ email: z.string().email(), name: z.string() })
  const result = schema.safeParse(body)
  if (!result.success) {
    return NextResponse.json({ error: 'Invalid input' }, { status: 400 })
  }
  const user = await db.user.create({ data: result.data })
  return NextResponse.json(user, { status: 201 })
}
```
**Best practices**
- Validate input with a schema library (Zod, Yup).
- Return appropriate HTTP status codes.
- Catch errors and return a JSON error object.
- Use the Edge runtime (`export const runtime = 'edge'`) when the handler is lightweight and benefits from low latency.
---

## 5. Performance Optimisations

### Image Optimization
- Use `next/image` for automatic resizing, lazy loading, and WebP conversion.
- Set `priority` on above‑fold images.
- Provide a `blurDataURL` placeholder for a smooth loading experience.

### Bundle Splitting
- Dynamically import heavy components.
```tsx
const HeavyChart = dynamic(() => import('@/components/HeavyChart'), { ssr: false })
```
- Next.js automatically code‑splits per route; keep client bundles small.

### Bundle Analysis
```bash
npm install --save-dev @next/bundle-analyzer
# next.config.js
module.exports = {
  experimental: { bundleAnalyzer: { enabled: true } }
}
```
Run `next build && next analyze` to view size breakdown.
---

## 6. Metadata Management

- For static metadata, export a plain object in `metadata.ts`.
- For dynamic per‑route metadata, implement `generateMetadata` in `page.tsx`.
```tsx
export async function generateMetadata({ params }) {
  const post = await fetchPost(params.id)
  return {
    title: post.title,
    description: post.excerpt,
    openGraph: { images: [{ url: post.coverUrl }] },
    alternates: { canonical: `https://example.com/posts/${params.id}` }
  }
}
```
- Keep title length 50‑60 characters and description 150‑160 characters for SEO.
---

## 7. Caching Strategy

| Layer | Control method |
|-------|----------------|
| Request | `fetch` options (`next: { revalidate }`, `cache`) |
| Data | ISR (`revalidate`), tag‑based (`revalidateTag`) |
| Full route | `export const revalidate = <seconds>` in `page.tsx` |

**On‑demand revalidation** (e.g., after a CMS update):
```ts
import { revalidatePath } from 'next/cache'
export async function POST() {
  // ...update content
  revalidatePath('/blog')
  return new Response('OK')
}
```
---

## 8. Server Actions

- Declare a function with `'use server'` at the top of a file.
- Use them for form submissions, data mutations, or to trigger revalidation.
```tsx
// app/actions.ts
'use server'
import { revalidatePath } from 'next/cache'
import { z } from 'zod'

export async function createPost(formData: FormData) {
  const schema = z.object({ title: z.string(), content: z.string() })
  const data = Object.fromEntries(formData)
  const result = schema.safeParse(data)
  if (!result.success) throw new Error('Invalid input')
  await db.post.create({ data: result.data })
  revalidatePath('/posts')
  return { success: true }
}
```
- Validate all inputs server‑side.
- Return typed JSON or plain values; avoid sending raw errors to the client.
---

## 9. Supabase Authentication Integration

### Core Principles
- Use `@supabase/ssr` to create a Supabase client that works in Server Components, API routes, and middleware.
- Store the session in an HTTP‑only cookie; never expose the access token to the browser.
- Protect routes with middleware that reads the cookie, verifies the session, and redirects unauthenticated users.

### Supabase Client Setup
```ts
// lib/supabaseServer.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export const supabase = createServerClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!, // server‑only key
  {
    cookies,
    // optional: set auth persistence to cookie
  }
)
```
Use the same `supabase` instance in Server Components and API routes.

### Auth Middleware (protects routes)
```ts
// middleware.ts
import { NextResponse } from 'next/server'
import { supabase } from '@/lib/supabaseServer'

export async function middleware(request) {
  const { data: { session } } = await supabase.auth.getSession()
  const protectedPaths = ['/dashboard', '/account']
  const url = request.nextUrl.clone()

  if (protectedPaths.some(p => url.pathname.startsWith(p))) {
    if (!session) {
      url.pathname = '/login'
      return NextResponse.redirect(url)
    }
    // Refresh token if needed
    const { error } = await supabase.auth.refreshSession()
    if (error) {
      url.pathname = '/login'
      return NextResponse.redirect(url)
    }
  }
  return NextResponse.next()
}
```
- Add `export const config = { matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'] }` if you need custom matching.

### Auth Callback Route (OAuth)
```tsx
// app/auth/callback/route.ts
import { supabase } from '@/lib/supabaseServer'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const url = new URL(request.url)
  const code = url.searchParams.get('code')
  if (!code) return NextResponse.redirect('/login')

  const { data, error } = await supabase.auth.exchangeCodeForSession(code)
  if (error) return NextResponse.redirect('/login')

  // Session is stored in the HTTP‑only cookie automatically by supabase/ssr
  return NextResponse.redirect('/')
}
```
### Using Supabase in a Server Component
```tsx
// app/profile/page.tsx – Server Component
import { supabase } from '@/lib/supabaseServer'

export default async function Page() {
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) return <p>Not logged in</p>
  return <p>Welcome, {user.email}</p>
}
```
### Using Supabase in a Client Component (read‑only)
```tsx
'use client'
import { createClientComponentClient } from '@supabase/ssr'

export default function LogoutButton() {
  const supabase = createClientComponentClient()
  const handleLogout = async () => {
    await supabase.auth.signOut()
    window.location.href = '/login'
  }
  return <button onClick={handleLogout}>Log out</button>
}
```
---

## 10. Anti‑Patterns to Avoid
| Bad practice | Correct approach |
|--------------|-----------------|
| Adding `'use client'` to every file | Keep components Server by default; add `'use client'` only when interactivity is required |
| Fetching data in Client Components | Fetch data in Server Components or Server Actions, then pass as props |
| Skipping `loading.tsx` for slow streams | Provide a `loading.tsx` file to show a placeholder while the Server Component streams |
| Large client bundles without code‑splitting | Use `dynamic()` imports and keep interactive parts minimal |
| Storing Supabase tokens in localStorage | Store session in HTTP‑only cookies via `@supabase/ssr`; never expose raw tokens |
---

## Checklist
- [ ] Decide component type using the decision tree. Add `'use client'` only when needed.
- [ ] Choose a data‑fetching pattern (static, ISR, no‑store) and set `next: { revalidate }` accordingly.
- [ ] Follow file conventions (`page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`).
- [ ] Use route groups, parallel routes, or intercepting routes for UI composition.
- [ ] Validate all API input with a schema library; return proper status codes.
- [ ] Optimize images with `next/image`; set `priority` for above‑fold assets.
- [ ] Dynamically import heavy client‑only components.
- [ ] Implement `generateMetadata` for dynamic SEO tags.
- [ ] Configure caching: ISR for static pages, `revalidatePath` for on‑demand updates.
- [ ] Write Server Actions for mutations; validate inputs and trigger revalidation.
- [ ] Set up Supabase client with `@supabase/ssr`; keep service‑role key server‑only.
- [ ] Add middleware to protect private routes and refresh sessions.
- [ ] Implement OAuth callback route that exchanges the code for a session.
- [ ] Test loading and error states (`loading.tsx`, `error.tsx`).
- [ ] Run `next build && next analyze` to verify bundle size.

## Related skills

Load these when the task spans more than this skill.

- [`typescript`](../../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
- [`prisma`](../../database-design/references/prisma.md) — Provides expert guidance for Prisma ORM tasks such as schema design, migrations, query optimization, relation…
- [`seo`](../../seo/SKILL.md) — SEO provides a complete audit and optimization guide covering technical SEO, on-page elements, content quality…
- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`astro`](astro.md) — Astro is a web framework for content‑heavy sites that ships zero JavaScript by default and hydrates interactiv…
- [`i18n-localization`](../../i18n-localization/SKILL.md) — Guides developers to add internationalization (i18n) and localization (L10n) to web and Python projects, cover…
