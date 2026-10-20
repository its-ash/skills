---
name: context7-docs
description: "Fetch current library and framework documentation through the Context7 API during Claude Code sessions. Use when you need up-to-date reference docs, API signatures, migration notes, code examples, changelogs, troubleshooting guidance, or version-specific docs for React, Next.js, Prisma, TypeScript, Python packages, npm modules, and similar dependencies."
---

# context7-docs

Automatically retrieve the latest documentation for a library or framework via the Context7 API and make it available inside Claude Code.

## When to Use
- You need current reference material for a library (e.g., React, Next.js, Prisma).
- You want to embed documentation directly in a Claude Code prompt.
- You need to programmatically fetch docs for multiple libraries in a workflow.

## Prerequisites
- A valid Context7 API key.
- Network access to `api.context7.com`.
- Optional: a cache directory to store recent responses.

## Workflow
1. **Set the API key**
   ```bash
   export CONTEXT7_API_KEY="your_api_key_here"
   ```
2. **Build the request URL**
   - Base endpoint: `https://api.context7.com/v1/docs`
   - Required query: `library` (e.g., `react`).
   - Optional query: `version` (e.g., `18.2.0`), `format` (`markdown` or `html`).
   - Example URL: `https://api.context7.com/v1/docs?library=react&format=markdown`
3. **Send the request**
   - Use `curl`, `fetch`, or any HTTP client.
   - Include the `Authorization` header.
4. **Parse the JSON response**
   - Expected fields: `title`, `content`, `url`, `last_updated`.
5. **Insert the documentation**
   - Append `content` to the Claude Code prompt or write to a temporary file.
6. **Cache the result**
   - Store the response for up to 24 hours to avoid rate‑limit hits.

## API Details
| Element | Value |
|---|---|
| **Method** | `GET` |
| **Endpoint** | `https://api.context7.com/v1/docs` |
| **Query Parameters** | `library` (required), `version` (optional), `format` (`markdown`|`html`, default `markdown`) |
| **Headers** | `Authorization: Bearer <CONTEXT7_API_KEY>` |
| **Success Response** | `200` with JSON `{ "title": "...", "content": "...", "url": "...", "last_updated": "..." }` |
| **Error Codes** | `401` (missing/invalid key), `404` (library not found), `429` (rate limit), `500` (server error) |

## Code Patterns
### JavaScript (Node.js)
```js
const fetch = require('node-fetch');

async function getDocs(library, version) {
  const url = new URL('https://api.context7.com/v1/docs');
  url.searchParams.append('library', library);
  if (version) url.searchParams.append('version', version);
  url.searchParams.append('format', 'markdown');

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${process.env.CONTEXT7_API_KEY}` },
  });
  if (!res.ok) throw new Error(`Context7 error: ${res.status}`);
  const data = await res.json();
  return data.content; // markdown string
}

// Example usage
getDocs('react').then(console.log).catch(console.error);
```

### Python
```python
import os
import requests

def get_docs(library: str, version: str | None = None) -> str:
    endpoint = "https://api.context7.com/v1/docs"
    params = {"library": library, "format": "markdown"}
    if version:
        params["version"] = version
    headers = {"Authorization": f"Bearer {os.getenv('CONTEXT7_API_KEY')}"}
    resp = requests.get(endpoint, params=params, headers=headers)
    resp.raise_for_status()
    return resp.json()["content"]

# Example usage
print(get_docs("nextjs"))
```

## Pitfalls & Mitigations
- **Missing API key** – request returns `401`. Ensure `CONTEXT7_API_KEY` is set before calling.
- **Rate limiting** – `429` indicates too many calls. Cache responses and respect a 1‑second pause between calls when fetching many libraries.
- **Incorrect library name** – API is case‑sensitive. Verify spelling and case.
- **Large documentation** – Content may exceed Claude's token limit. Summarize or split the markdown before inserting into a prompt.
- **Version mismatch** – If a specific version is required, always include the `version` parameter; otherwise the API returns the default/latest version.

## Checklist
- [ ] Set `CONTEXT7_API_KEY` in the environment.
- [ ] Verify the exact library name (case‑sensitive).
- [ ] Include `version` when a non‑latest release is needed.
- [ ] Choose `format=markdown` for direct insertion into Claude Code.
- [ ] Cache the response for ≤ 24 hours.
- [ ] Handle HTTP errors (`401`, `404`, `429`, `500`).
- [ ] Trim or summarize content if it exceeds Claude's token budget.

## Related skills

Load these when the task spans more than this skill.

- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`dependency-updates`](../dependency-updates/SKILL.md) — Automates detection, safe updating, and security auditing of project dependencies across major languages. Use…
- [`claude-code-guide`](../claude-code-guide/SKILL.md) — Guide for configuring Claude Code projects, using prompting keywords, debugging the agent, and applying best‑p…
- [`api-integration`](../api-integration/SKILL.md) — Guides developers to integrate third‑party REST or GraphQL APIs securely and reliably. Includes authentication…
- [`ai-maestro`](../ai-maestro/SKILL.md) — Manage AI Maestro agents, send AMP messages, search memory/docs/code graph, and run structured planning. Use f…
