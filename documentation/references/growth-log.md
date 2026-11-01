# Growth Log

Write learning entries that extract a reusable pattern from completed work (root cause, transferable rule, recognizable signal) instead of diary-style narration.

> "Fixed a bug in X" is a diary entry, not a learning artifact. A growth log entry extracts the pattern so you recognize it next time. It works with any note system: Markdown files, Notion, Obsidian, or plain text.

## When to use

- After a complex task (multi-file change, new feature, architecture change).
- After a failure, a mistake, or a "that was harder than expected" moment.
- When you review what you learned over a period, or a delivery gate asks what you learned.

Skip trivial changes (typos, one-line tweaks, config values with no debugging). The threshold: did this task involve debugging, redoing, rollback, or a non-obvious decision? If yes, write an entry.

## The three rules

### Rule 1: Failures are worth more than achievements

One bug that took 2 hours to find teaches more than 3 features that worked the first time.

- **Bad:** "Successfully implemented the login flow."
- **Good (web):** "Login flow: the session token did not persist because the cookie `SameSite` defaulted to `Lax` in Chrome 128+. Pattern: always set `SameSite=None; Secure` explicitly for cross-origin. Signal: auth breaks after a browser upgrade or across an origin boundary."
- **Good (data):** "CSV import failed silently on empty rows because all-empty rows still counted as rows. Pattern: run `df.dropna(how='all', inplace=True)` before row-count validation."

### Rule 2: Merge duplicates (Bole principle)

Before you write a new entry, ask: "Is this the same as something I already recorded?" Same root cause with a different symptom: **merge**. New root cause: new entry.

Search existing entries for keywords from the root cause first. If one matches, add the new symptom as another example under it.

Example: "forgot to update the output index after creating a file" and "forgot to update ratings after a task" have the same root cause (no automatic capture trigger). Merge them into one entry about post-task capture gaps.

### Rule 3: Must be transferable

Each entry answers: "Next time I face a similar situation, what do I do differently?" If you cannot write that sentence, you have not extracted the pattern yet.

To extract a pattern:
1. State what happened in one sentence.
2. Ask "why?" until you reach the root cause (usually 3 to 5 times).
3. Generalize the class of problem (not "Chrome 128 bug" but "browser default change breaks existing behavior").
4. Write: "Next time I see [signal], I will [action]."
5. Name the signal: the specific observable that shows the pattern is active.

## Entry template

One entry per distinct root cause, usually 4 to 8 sentences. If it takes more than 2 minutes, you are narrating events. If it takes less than 30 seconds, you did not go deep enough.

```markdown
## [Title: the pattern, not the event]

### Context
- What was I trying to do?
- What went wrong, or what worked surprisingly well?

### Root Cause / Core Insight
- The underlying mechanism, not only the symptom

### The Pattern (transferable)
- Next time [similar situation], I will [specific action].
- Signal to recognize: [what observable shows this pattern is active?]

### Related
- [entry-name](../path/to/related-entry.md)
```

## Entry types

| Type | When | Emphasis | Example title |
|------|------|----------|---------------|
| Failure | Something broke, needed debugging, or required rework | Root cause | "Config inheritance is not behavior inheritance across sessions" |
| Methodology | A repeatable process came from the work | Context and pattern | "Slides to open-book study guide: three-layer structure" |
| Pattern discovery | A reusable insight about tools, systems, or thinking | Pattern | "PR description: describe the gap, not the feature" |
| Capability change | A measurable skill improvement | Context (before and after) | "Git: from clone and push to an independent PR with 12 commits" |

## Quality checklist

- [ ] The title names the pattern, not the event.
- [ ] There is a "Next time I will..." sentence.
- [ ] The signal is specific enough to trigger the pattern next time.
- [ ] You searched existing entries for duplicates first.
- [ ] The root cause is separate from the symptom.
- [ ] Related entries are cross-linked.
- [ ] The entry is 4 to 8 sentences.

## Anti-patterns

- "Fixed bug in payment module" (event, not pattern).
- Copying the commit message (commits say what changed; the log says why it matters).
- An entry for every commit (write one only when a pattern emerges).
- No transferable sentence (this is not optional).
- The same pattern under different titles (search before you write).

## Storage

Keep entries where you keep notes, for example a `growth-log/` directory with one file per day (`YYYY-MM-DD.md`), or a section in Notion or Obsidian. Pick one convention and keep it. Searchability is more important than format.

If a delivery gate (for example a Stop hook that checks that a learning file changed today) is in place, this method makes sure the file it checks contains useful patterns, not only a new timestamp. Enforcement without method gives empty entries; method without enforcement gives forgotten captures.
