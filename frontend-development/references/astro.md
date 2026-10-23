# Astro Web Framework

Astro builds fast, content‑focused websites. It renders pages to static HTML and only sends JavaScript for components that need interactivity ("islands"). It supports React, Vue, Svelte, Solid, and other UI libraries side‑by‑side.

## When to Use
- Building a blog, documentation, marketing, portfolio, or e‑commerce site.
- Prioritising performance and Core Web Vitals.
- Content is stored in Markdown or MDX files.
- You need static‑site generation (SSG) with optional server‑side rendering (SSR).
- The user asks about `.astro` files, `Astro.props`, content collections, or `client:` directives.

## Project Setup
```bash
npm create astro@latest my-site
cd my-site
npm install
npm run dev
```
Add integrations as needed:
```bash
npx astro add tailwind   # Tailwind CSS
npx astro add react      # React support
npx astro add mdx        # MDX support
npx astro add sitemap    # Sitemap generation
npx astro add vercel     # Vercel SSR adapter
```
### Directory Layout
```
src/
  pages/      # File‑based routing (.astro, .md, .mdx)
  layouts/    # Reusable page shells
  components/ # UI components (.astro, .tsx, .vue, …)
  content/    # Type‑safe content collections (Markdown/MDX)
  styles/     # Global CSS
public/       # Static assets (copied as‑is)
astro.config.mjs  # Framework configuration
```

## Astro Component Syntax
A `.astro` file has a server‑only frontmatter block (`---`) followed by the template.
```astro
---
// src/components/Card.astro
interface Props {
  title: string;
  href: string;
  description: string;
}
const { title, href, description } = Astro.props;
---
<article class="card">
  <h2><a href={href}>{title}</a></h2>
  <p>{description}</p>
</article>
<style>
  .card { border: 1px solid #eee; padding: 1rem; }
</style>
```
The frontmatter runs **only on the server**. Styles inside `<style>` are automatically scoped to the component.

## File‑Based Routing
```
src/pages/index.astro          → /
src/pages/about.astro          → /about
src/pages/blog/[slug].astro    → /blog/:slug (dynamic)
src/pages/blog/[...path].astro → /blog/* (catch‑all)
```
### Dynamic Route with `getStaticPaths`
```astro
---
// src/pages/blog/[slug].astro
export async function getStaticPaths() {
  const posts = await getCollection('blog');
  return posts.map(post => ({
    params: { slug: post.slug },
    props: { post },
  }));
}

const { post } = Astro.props;
const { Content } = await post.render();
---
<h1>{post.data.title}</h1>
<Content />
```
`getStaticPaths` runs at build time to generate static pages for each slug.

## Content Collections (Markdown/MDX)
Define a collection with a schema for type safety.
```typescript
// src/content/config.ts
import { z, defineCollection } from 'astro:content';

const blog = defineCollection({
  type: 'content',
  schema: z.object({
    title: z.string(),
    date: z.coerce.date(),
    tags: z.array(z.string()).default([]),
    draft: z.boolean().default(false),
  }),
});

export const collections = { blog };
```
Consume the collection in a page:
```astro
---
import { getCollection } from 'astro:content';

const posts = (await getCollection('blog'))
  .filter(p => !p.data.draft)
  .sort((a, b) => b.data.date.valueOf() - a.data.date.valueOf());
---
<ul>
  {posts.map(post => (
    <li>
      <a href={`/blog/${post.slug}`}>{post.data.title}</a>
      <time>{post.data.date.toLocaleDateString()}</time>
    </li>
  ))}
</ul>
```

## Islands – Selective Hydration
By default, UI‑framework components render as static HTML. Add a `client:` directive to hydrate.
```astro
---
import Counter from '../components/Counter.tsx';   // React
import VideoPlayer from '../components/VideoPlayer.svelte';
---
<!-- No JavaScript sent to the browser -->
<Counter initialCount={0} />

<!-- Hydrate immediately on load -->
<Counter initialCount={0} client:load />

<!-- Hydrate when visible -->
<VideoPlayer src="/demo.mp4" client:visible />

<!-- Hydrate when the browser is idle -->
<Analytics client:idle />

<!-- Hydrate only on a media query -->
<MobileMenu client:media="(max-width: 768px)" />
```
Common directives:
- `client:load` – hydrate on page load.
- `client:visible` – hydrate when the element enters the viewport.
- `client:idle` – hydrate when the main thread is idle.
- `client:media="(query)"` – hydrate based on a CSS media query.

## Layouts
Layouts wrap page content with a `<slot />`.
```astro
---
// src/layouts/BaseLayout.astro
interface Props { title: string; description?: string; }
const { title, description = 'My Astro Site' } = Astro.props;
---
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <title>{title}</title>
    <meta name="description" content={description} />
  </head>
  <body>
    <nav>…</nav>
    <main><slot /></main>
    <footer>…</footer>
  </body>
</html>
```
Use it in a page:
```astro
---
import BaseLayout from '../layouts/BaseLayout.astro';
---
<BaseLayout title="About Us">
  <h1>About Us</h1>
  <p>Welcome to our company…</p>
</BaseLayout>
```

## SSR Mode (Hybrid Rendering)
Configure an adapter for on‑demand rendering.
```javascript
// astro.config.mjs
import { defineConfig } from 'astro/config';
import vercel from '@astrojs/vercel/serverless';

export default defineConfig({
  output: 'hybrid', // static | server | hybrid
  adapter: vercel(),
});
```
Mark a page to skip prerendering:
```astro
export const prerender = false; // page will be rendered at request time
```

## Example: RSS Feed
```typescript
// src/pages/rss.xml.ts
import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog');
  return rss({
    title: 'My Blog',
    description: 'Latest posts',
    site: context.site,
    items: posts.map(p => ({
      title: p.data.title,
      pubDate: p.data.date,
      link: `/blog/${p.slug}/`,
    })),
  });
}
```

## Example: API Endpoint (SSR)
```typescript
// src/pages/api/subscribe.ts
import type { APIRoute } from 'astro';

export const POST: APIRoute = async ({ request }) => {
  const { email } = await request.json();
  if (!email) {
    return new Response(JSON.stringify({ error: 'Email required' }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }
  await addToNewsletter(email);
  return new Response(JSON.stringify({ success: true }), { status: 200 });
};
```

## Example: React Island
```tsx
// src/components/SearchBox.tsx
import { useState } from 'react';

export default function SearchBox() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  async function search(e: React.FormEvent) {
    e.preventDefault();
    const data = await fetch(`/api/search?q=${query}`).then(r => r.json());
    setResults(data);
  }

  return (
    <form onSubmit={search}>
      <input value={query} onChange={e => setQuery(e.target.value)} />
      <button type="submit">Search</button>
      <ul>{results.map(r => <li key={r.id}>{r.title}</li>)}</ul>
    </form>
  );
}
```
```astro
---
import SearchBox from '../components/SearchBox.tsx';
---
<SearchBox client:load />
```

## Best Practices
- Keep most UI as plain `.astro` files; hydrate only required components.
- Store all Markdown/MDX in content collections for type safety and validation.
- Prefer `client:visible` over `client:load` for below‑the‑fold islands.
- Use `import.meta.env.PUBLIC_*` for values that can be exposed to the browser.
- Add `<ViewTransitions />` from `astro:transitions` for smooth navigation.
- Do not place secrets in frontmatter; they are server‑only but may be logged.
- Do not set `client:load` on every component; it defeats Astro’s performance model.

## Security & Safety
- Frontmatter code runs **only on the server**; it never reaches the client.
- Prefix public environment variables with `PUBLIC_`. Private vars remain server‑only.
- Validate all request data in SSR routes before using it in database queries or external APIs.
- When rendering user‑generated HTML, use `set:html` only after sanitising the content to avoid XSS.

## Common Pitfalls & Solutions
| Problem | Solution |
|---|---|
| UI‑framework component shows no interactivity | Add an appropriate `client:` directive (`client:load`, `client:visible`, etc.). |
| `getStaticPaths` does not reflect new content during development | Restart the dev server if you changed `content/config.ts`; the server watches content files otherwise. |
| No type information for `Astro.props` | Declare a `Props` interface or type in the frontmatter; Astro will infer it for autocomplete. |
| Styles leak between components | Styles inside `<style>` are scoped automatically. Use `:global()` only when intentional. |

## Checklist
- [ ] Run `npm create astro@latest` and install dependencies.
- [ ] Choose an adapter (`static`, `vercel`, etc.) and set `output` in `astro.config.mjs`.
- [ ] Define content collections with schemas in `src/content/config.ts`.
- [ ] Create page routes in `src/pages` using `.astro`, `.md`, or `.mdx`.
- [ ] Add `client:` directives only to interactive components.
- [ ] Use layouts to share HTML structure and `<slot />` for page content.
- [ ] Verify environment variables: `import.meta.env.PUBLIC_*` for client, others stay server‑only.
- [ ] Test SSR endpoints with proper request validation.
- [ ] Run `npm run build` and check that the generated `dist/` contains only needed JavaScript.
- [ ] Deploy to the chosen platform and monitor Core Web Vitals.

## Related skills

Load these when the task spans more than this skill.

- [`frontend-development`](../SKILL.md) — Frontend Development skill for building modern React/Next.js applications with TypeScript, MUI, TanStack Query…
- [`nextjs`](nextjs.md) — Guidelines for building Next.js 14+ applications with the App Router. Includes component type decisions, data…
- [`web-performance`](../../web-quality-audit/references/web-performance.md) — Provides step‑by‑step guidance to measure, diagnose, and improve web performance, focusing on Core Web Vitals…
- [`typescript`](../../typescript/SKILL.md) — Provides expert guidance for TypeScript projects, covering setup analysis, migration, monorepo configuration,…
