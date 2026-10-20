---
name: meme-factory
description: "Generate memes via the free memegen.link REST API with template selection, automatic text encoding, custom dimensions, font overrides, and a drop‑in Python requests helper. Use when you need memegen.link, meme generation, image macros, reaction images, template IDs like drake or distracted-boyfriend, URL encoding for top bottom text, custom width height parameters, font family size color, Python requests get post, markdown image embed, discord slack github comment readme pull request documentation chat social media humor."
---

# Meme Factory
Create memes instantly with the public **memegen.link** API. Build a URL that encodes the template, top text, bottom text, and optional styling. Insert the URL in markdown to display the image.

---
## When to use
- Add humor to a conversation, pull‑request comment, or documentation.
- Produce a visual for a social‑media post or Open‑Graph preview.
- Illustrate a comparison, success, or failure with a familiar meme format.

---
## Triggers
- `/meme-factory` – manual call.
- `/meme-factory {template} {top} {bottom}` – direct generation.
- Natural‑language request, e.g. `meme-factory: create a meme about CI failures`.

---
## Basic URL format
```
https://api.memegen.link/images/{template}/{top_text}/{bottom_text}.{ext}?{options}
```
- **template** – name from the template list.
- **top_text / bottom_text** – URL‑encoded words.
- **ext** – `png` (default), `jpg`, `webp`, or `gif`.
- **options** – query string for size, layout, font, etc.

**Example**
```
https://api.memegen.link/images/buzz/bugs/bugs_everywhere.png
```
Shows the Buzz Lightyear meme with "bugs" on top and "bugs everywhere" on bottom.

---
## Text encoding
| Character | Encode as |
|-----------|----------|
| Space     | `_` or `-` |
| Newline   | `~n` |
| ?         | `~q` |
| %         | `~p` |
| /         | `~s` |
| #         | `~h` |
| '         | `''` |
| "        | `""` |

Keep each line to 2‑6 words for readability.

---
## Popular templates
| Template | Typical use |
|----------|------------|
| `buzz`   | "X, X everywhere" |
| `drake`  | Compare reject vs. approve |
| `success`| Celebrate a win |
| `fine`   | Ironic "everything is fine" |
| `fry`    | "Not sure if X or Y" |
| `mordor` | "One does not simply…" |

---
## Template selection guide
| Context | Template |
|---------|----------|
| Comparison | `drake` |
| Celebration | `success` |
| Irony / ignored problem | `fine` |
| Uncertainty | `fry` |
| Controversial opinion | `changemind` |
| Ubiquitous issue | `buzz` |
| Epic challenge | `mordor` |

---
## Advanced options
- **Image format** – add `.png` (default), `.jpg`, `.webp`, or `.gif`.
- **Dimensions** – `?width=1200&height=630` for Open‑Graph size, `?width=800` for Slack, etc.
- **Layout** – `?layout=top`, `?layout=bottom`, or `?layout=default`.
- **Font** – `?font=impact` (default) or any font listed at `https://api.memegen.link/fonts/`.
- **Custom background** – `?style=https://example.com/bg.jpg`.

---
## Python helper (no external script needed)
```python
def generate_meme(template: str, top: str, bottom: str,
                 ext: str = "png", width: int = None, height: int = None,
                 layout: str = None, font: str = None, style: str = None) -> str:
    """Return a memegen.link URL.
    Encode spaces as '_' and special chars with the table above.
    """
    import urllib.parse
    def enc(text: str) -> str:
        return urllib.parse.quote(text.replace(' ', '_'))
    top_enc, bottom_enc = enc(top), enc(bottom)
    url = f"https://api.memegen.link/images/{template}/{top_enc}/{bottom_enc}.{ext}"
    params = []
    if width: params.append(f"width={width}")
    if height: params.append(f"height={height}")
    if layout: params.append(f"layout={layout}")
    if font: params.append(f"font={font}")
    if style: params.append(f"style={urllib.parse.quote(style)}")
    if params:
        url += "?" + "&".join(params)
    return url

# Example usage
print(generate_meme("buzz", "bugs", "bugs_everywhere", width=1200, height=630))
```
Insert the returned URL into markdown: `![Meme](URL)`.

---
## Validation checklist
- [ ] URL returns HTTP 200 (e.g., `curl -I URL`).
- [ ] Image loads in a browser or markdown preview.
- [ ] Text is legible; limit to a few words per line.
- [ ] Template matches the intended message.
- [ ] All special characters are encoded.
- [ ] Dimensions suit the target platform.

---
## Anti‑patterns
| What to avoid | Why | Fix |
|---------------|-----|-----|
| Unencoded spaces | URL breaks | Use `_` or `-` |
| Long paragraphs | Unreadable | Keep 2‑6 words per line |
| Wrong template | Message mismatch | Choose from the selection guide |
| Missing file extension | 404 error | Always add `.png` (or other) |
| Unencoded `?`, `/`, `%` | URL breaks | Use the encoding table |

---
## Verification steps
1. **URL validity** – HTTP 200 response.
2. **Image renders** – Shows correctly in markdown.
3. **Text visibility** – No clipping or overlap.
4. **Context fit** – Template reflects the intended joke or message.

---
## API reference
- `GET /templates/` – list all templates.
- `GET /templates/{id}` – details for a single template.
- `GET /fonts/` – available fonts.
- `GET /images/{template}/{top}/{bottom}.{ext}` – generate meme.

The API is free, open‑source, and stateless. No key or rate limit for normal use.

---
## Error handling
1. Verify the template exists via `/templates/`.
2. Encode spaces and special characters.
3. Ensure the file extension is valid.
4. Test the URL in a browser before sharing.
5. If the image does not load, check the HTTP status and adjust encoding.

---
## Platform dimension tips
| Platform | Recommended size |
|----------|-------------------|
| Open Graph (social) | 1200 × 630 |
| Slack / Discord | 800 × 600 |
| GitHub markdown | default (no size needed) |

---
## Quick example in markdown
```markdown
Here is a meme for the recent outage:

![Outage meme](https://api.memegen.link/images/fine/server_down/this_is_fine.png)
```

---
**Golden rule:** Keep text short and match the meme template to the message context.

## Related skills

Load these when the task spans more than this skill.

- [`content-writing`](../content-writing/SKILL.md) — The content-writing skill guides brand-voice creation, SEO blog drafting, social-media post production, conten…
- [`copywriting`](../copywriting/SKILL.md) — Creates clear, compelling marketing copy for webpages (home, landing, pricing, feature, about, product) and pr…
- [`documentation-writing`](../documentation-writing/SKILL.md) — documentation-writing: Provides ready-to-use documentation templates and a step-by-step co-authoring workflow…
- [`python`](../python/SKILL.md) — Guidance for modern Python 3.12+ development. Includes framework selection, async vs sync decisions, project l…
- [`web-artifacts`](../web-artifacts/SKILL.md) — Creates complex Claude.ai HTML artifacts using React, TypeScript, Vite, Tailwind CSS, and shadcn/ui, then bund…
- [`slack-gif-creator`](../slack-gif-creator/SKILL.md) — Create animated GIFs optimized for Slack emoji (128x128) and message (480x480) formats. Provides Slack constra…
