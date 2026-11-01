# Brand Discovery

Run a structured, resumable brand identity interview across 8 modules and produce a master brandbook (`90_SYNTHESIS.md`) that the organization uses to brief designers, writers, and external collaborators.

## When to use

- A brand is being created or repositioned, or needs a written identity reference to brief collaborators.
- The interview will span several sessions over days or weeks.
- More than one founder or stakeholder needs an individual interview before a reconciliation pass.
- The user wants a structured, repeatable method, not an ad-hoc chat.
- Existing brand knowledge is scattered, implicit, or depends on the founder, and must become explicit.
- The competitive analysis needs a positioning brief first (see [competitive-platform-analysis.md](competitive-platform-analysis.md)).

Write answers to disk as you go, so no knowledge is lost when a conversation ends and a later session can resume.

## Session start protocol

Do these steps on each activation, **before** you ask an interview question:

1. **Check for prior progress.** Look for module files and a `state.json` checkpoint in the brand-identity directory of the project. If none exist, this is a fresh start: confirm the brand name, participants, and save location, then begin at the first module.
2. **Read the current module file** if one is in progress, and scan its Raw section for captured answers.
3. **Report to the user** in two or three sentences: the current module, its status, and what remains. Then ask: "Continue here, or switch module?"

## Interview discipline

1. **One question at a time.** Never present a list of questions.
2. **After each answer:** a short paraphrase, then one deepening probe, or close the thread if the topic is saturated. Never move on silently.
3. **Laddering:** after each "what" answer, ask "Why does that matter to you?" until a core value surfaces (usually two to four iterations).
4. **5 Whys:** for beliefs or positioning claims, push to the root reason, not the surface statement.
5. **Thin answers:** if an answer is generic, full of jargon, or vague, ask for one concrete example, a client story, or a number.
6. **Projective techniques** (use one per module to break a plateau):
   - "If the brand were a person, how would they walk into a room?"
   - Brand obituary: "If the organization closed in five years, what would customers miss? What would you regret not having said?"
   - Competitive contrast: "Name one peer you admire but would never want to become. What specifically makes them the wrong model?"
7. **Saturation signal:** when two consecutive probes give no new information, summarize and close the module.
8. **End of module:** write the module file with `## Raw` (verbatim quotes and examples) and `## Synthesis` (your interpretation, three candidate formulations, open questions, contradictions between participants). Then update `state.json`.

## Module sequence

| File | Label | Frameworks |
|------|-------|------------|
| `10_purpose-why.md` | Purpose / Why | Sinek Golden Circle, Lencioni |
| `20_positioning.md` | Positioning | Dunford "Obviously Awesome", Moore template, JTBD |
| `30_audience-niche.md` | Audience and Niche | Baker "Business of Expertise", ICP |
| `40_personality-archetype.md` | Personality and Archetype | Mark and Pearson 12 archetypes, J. Aaker 5 dimensions |
| `50_voice-tone.md` | Voice and Tone | Voice spectrum, tone matrix |
| `60_narrative-story.md` | Narrative / Story | Neumeier trueline, story arc |
| `70_founder-tension.md` | Founder Brand vs Organization Brand | Enns "Win Without Pitching" |
| `90_SYNTHESIS.md` | Master Brandbook | Kapferer prism, Aaker brand system |

Complete modules in order. If the user asks to jump, do it and record the skip in `state.json`.

## Module templates

Each module file has this shape. The Raw headings are the interview prompts; the Synthesis headings are what you write after saturation.

### 10 Purpose / Why
Goal: the core belief that exists apart from what the organization sells.
- **Raw:** core belief (why does this exist?); the behavioral How (values in action, not slogans); what the brand refuses to be or do; founder quotes strong enough to become internal anchors.
- **Synthesis:** 2 to 3 candidate Why formulations (vary register and specificity); open questions; contradictions between participants; how this Why constrains or enables positioning.

### 20 Positioning
Goal: the competitive frame: who it is for, the category, what it does uniquely, and why that matters.
- **Raw:** target client (role, company type, situation); category (how clients solve the problem today); difference from alternatives; what the client cares about most; named alternatives (include "do nothing" and "hire in-house"); phrases the founder uses naturally.
- **Synthesis:** positioning statement: "For **[target client]** who **[situation / JTBD]**, **[brand]** is the **[category]** that **[unique value]**. Unlike **[alternatives]**, we **[key differentiator]**." Also alternative framings, a white-space hypothesis, open questions, tensions with Module 10.

### 30 Audience and Niche
Goal: a situational portrait of the best client, concrete enough to brief a copywriter or run a paid campaign.
- **Raw:** ideal client (a specific person); trigger situation; what they tried before and why it failed; success in their words; fears; worst-fit clients and why; real client stories.
- **Synthesis:** ICP table (role, organization type and size, trigger, primary pain, desired outcome, budget signal, red flag); 2 to 3 sentence psychographic portrait; niche hypothesis (smallest viable market the brand can own); segments to test.

### 40 Personality and Archetype
Goal: how the brand behaves as a person. A sharp archetype makes many small decisions automatic.
- **Raw:** "walks into a room" answer; archetype instinct (Creator, Caregiver, Ruler, Jester, Regular Person, Lover, Hero, Outlaw, Magician, Innocent, Sage, Explorer); three natural adjectives; an admired figure the brand must not become; an aspirational register; how clients must feel.
- **Synthesis:** primary archetype and shadow; J. Aaker scores 1 to 5 with evidence (sincerity, excitement, competence, sophistication, ruggedness); 3 behavioral guidelines; the anti-personality.

### 50 Voice and Tone
Goal: a verbal register precise enough that two writers sound like the same person. Voice is constant; tone changes by context.
- **Raw:** admired copy (with source); disliked copy and what is wrong; words always used; words avoided; sound on a sales page, an error message, a proposal; "We always..." and "We never..." statements.
- **Synthesis:** voice spectrum 1 to 5 (formal/casual, serious/playful, distant/warm, conventional/irreverent, minimal/expressive); one-paragraph voice statement; tone matrix (homepage headline, case study, proposal, error or apology, social); the three checks for each draft. For a source-derived writing profile, also use [content-writing/references/brand-voice.md](../../content-writing/references/brand-voice.md).

### 60 Narrative / Story
Goal: the founding story, the conflict it resolves, the transformation, and the invitation.
- **Raw:** founding story (not the polished version); the frustration that made the brand necessary; the world when the work succeeds; one illustrative client story; brand obituary answer; the invitation to clients.
- **Synthesis:** trueline ("[Brand] is the only [category] that [unique claim]") and 2 to 3 alternatives; story arc table (context, conflict, resolution, invitation); the brand as guide and the client as hero.

### 70 Founder Brand vs Organization Brand
Goal: the relation between the founder's reputation and the organization's brand, and a healthy boundary.
- **Raw:** is the founder known in the market, and how; do clients buy the founder or the organization (evidence, not instinct); what happens if the founder steps back; founder goals for 3 to 5 years; what the organization brand must do alone; where the founder brand helps or constrains.
- **Synthesis:** position on a 1 to 5 spectrum from "founder IS the brand" to "organization brand stands alone" (current and 3-year target); what each brand owns; transition plan sketch; risk if nothing changes.

### 90 Master Brandbook
Goal: reconcile modules 10 to 70 into one actionable source of truth. Collect little new raw input.
1. The Why: core belief, behavioral How, what we refuse to be.
2. Positioning: statement and owned white-space.
3. Audience: ICP portrait, niche, disqualifier.
4. Kapferer prism: physique, personality, culture, relationship, reflection, self-image.
5. Aaker system: primary and secondary archetype; brand as product, organization, person, symbol; 3 to 5 associations; equity signals.
6. Voice and tone: voice statement and the three draft checks.
7. Narrative: trueline and a one-paragraph story arc for an About page.
8. Founder and organization boundary.
9. Tensions resolved: table of tension, module A, module B, resolution.
10. Open questions and 3 to 5 practical next steps.

## State protocol

After each module reaches saturation, write the module file at `modules/{moduleFile}` and update `state.json` (`completedModules`, `inProgressModule`, `nextModule`, `lastUpdated`):

```json
{
  "session": "{brand_name}-brand-{YYYY-MM}",
  "outputPath": "{path_to_brand_identity_directory}",
  "completedModules": [],
  "inProgressModule": "10_purpose-why.md",
  "nextModule": "20_positioning.md",
  "participants": ["founder-A"],
  "lastUpdated": "{ISO-8601}"
}
```

Then confirm: "Module X saved. State updated. Next: Y."

For the terminal module, set `inProgressModule` to `"90_SYNTHESIS.md"` and `nextModule` to `null`. After you write it, add `"90_SYNTHESIS.md"` to `completedModules` and set `inProgressModule` to `null`, so a later session does not treat the finished brandbook as in progress. Confirm: "Brandbook complete. All modules saved."

## Multi-founder mode

With more than one founder, write each founder's answers to `founders/{participant}.md` instead of the main module files.

- Accept only alphanumeric characters and hyphens in `participant` (for example `founder-a`). Reject path separators (`/`, `\`, `..`) and special characters.
- Accept only `moduleFile` values from the module sequence above.
- Accept only an absolute `outputPath` inside the project directory. Reject relative paths and paths that escape with `..`.

After all founders complete a module, run a reconciliation pass: summarize convergences and divergences in the module file, and flag "productive tensions" for the group alignment workshop.

## Anti-patterns

- **Starting without reading state.** Each session opens with a check for module files and `state.json`.
- **Asking more than one question at a time.** Lists produce checklist answers, not insight.
- **Writing Synthesis before saturation.** If the last two probes gave new information, the module is not done.
- **Skipping multi-founder reconciliation.** Individual interviews come first. A group discussion first causes anchoring bias.
- **Treating this as one session.** Rushing to `90_SYNTHESIS.md` in one conversation gives shallow output.
