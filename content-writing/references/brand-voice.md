# Brand Voice

Build a voice profile from real source material, then use that profile for all content, outreach, and social work. Do not derive the style again for each task, and do not fall back to generic AI copy.

## When to use
- The user wants content or outreach in a specific voice.
- You write for X, LinkedIn, email, launch posts, threads, or product updates.
- You adapt the tone of a known author across channels.
- The content work needs a reusable style system, not one-off mimicry.

## Source priority

Use the strongest real source set that is available, in this order:

1. Recent original X posts and threads.
2. Articles, essays, memos, launch notes, or newsletters.
3. Real outbound emails or DMs that got replies.
4. Product docs, changelogs, README framing, and site copy.

Do not use generic platform examples as source material.

## Collection workflow

1. Collect 5 to 20 representative samples when available.
2. Prefer recent material. Use older material only if the user says it is more canonical.
3. If the source set splits clearly, keep "public launch voice" and "private working voice" as separate profiles.
4. If live X access is available, pull recent original posts first (see [social-publishing.md](social-publishing.md)).
5. If site copy is important, include the current landing page and product framing.

## What to extract

- Rhythm and sentence length
- Compression compared to explanation
- Capitalization norms
- Use of parentheticals
- Question frequency and purpose
- How sharply the author makes claims
- How often numbers, mechanisms, or receipts occur
- How transitions work
- What the author never does

## Output contract

Produce a reusable `VOICE PROFILE` block that other workflows can use directly. Keep it structured and short enough to keep in session context. The goal is operational reuse, not literary criticism.

```text
VOICE PROFILE
=============
Author:
Goal:
Confidence:

Source Set
- source 1
- source 2
- source 3

Rhythm
- short note on sentence length, pacing, and fragmentation

Compression
- how dense or explanatory the writing is

Capitalization
- conventional, mixed, or situational

Parentheticals
- how they are used and how they are not used

Question Use
- rare, frequent, rhetorical, direct, or mostly absent

Claim Style
- how claims are framed, supported, and sharpened

Preferred Moves
- concrete moves the author does use

Banned Moves
- specific patterns the author does not use

CTA Rules
- how, when, or whether to close with asks

Channel Notes
- X:
- LinkedIn:
- Email:
```

Profile rules:
- Keep the profile concrete and backed by the sources.
- Use short bullets, not paragraphs.
- Each banned move must be visible in the source set or requested by the user.
- If sources conflict, show the split. Do not average them.

## Default operator voice

If the user gives no voice references and the sources are thin, start from this default:

- Direct, compressed, concrete.
- Specifics, mechanisms, receipts, and numbers are better than adjectives.
- Parentheticals qualify, narrow, or clarify. They are not jokes.
- Capitalization is conventional unless there is a real reason to change it.
- Questions are rare and are never bait.
- Tone can be sharp, blunt, skeptical, or dry.
- Transitions must be earned, not smoothed over.

## Shared hard bans

All writing workflows in this skill use this list. Delete and rewrite:

- "In today's rapidly evolving landscape" and similar openers
- "game-changer", "revolutionary", "cutting-edge", "world-class"
- "here's why this matters" as a standalone bridge
- "Excited to share", "Here's what I learned", "I'd love to connect"
- "not X, just Y" and "no fluff"
- Fake curiosity hooks and bait questions ("What do you think?")
- A closing question added only to get replies
- Forced lowercase or forced casualness
- LinkedIn thought-leader cadence, praise-stacking, "journey" filler
- Fake vulnerability arcs and generic founder-journey filler
- Corny parentheticals
- Biography padding that does not move the argument
- Fake urgency without a real deadline
- Social proof without specifics ("thousands trust us")

## Persistence rules

- Reuse the latest confirmed `VOICE PROFILE` for related tasks in the same session.
- If the user asks for a durable artifact, save the profile in the location the user names.
- Do not create repo-tracked files that store personal voice fingerprints unless the user asks for that.

## Downstream use

Use this profile before or inside:

- Long-form writing ([article-writing.md](article-writing.md))
- Platform-native posts and crossposting ([social-content.md](social-content.md))
- Lead and network outreach ([lead-intelligence.md](lead-intelligence.md))
- Investor outreach ([investor-materials.md](investor-materials.md))
- Campaigns ([marketing-campaign.md](marketing-campaign.md))

If another workflow has a partial voice section, this profile is the source of truth.
