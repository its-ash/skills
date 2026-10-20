# Planning with Files

Use persistent markdown files as your "working memory on disk". The pattern keeps important information out of the limited LLM context window and makes it easy to resume, audit, and share work.

---

## When to Use
- Multi‑step tasks (3 + phases) such as research, building a prototype, or data pipelines.
- Projects that require many tool calls, external searches, or code generation.
- Situations where the user asks for planning, organization, or progress tracking.
- Anything that benefits from a clear goal, phase list, and error log.

**Skip** for one‑off questions, single file edits, or quick look‑ups.

---

## Core Pattern
```
Context Window (RAM)   → volatile, limited
Filesystem (Disk)      → persistent, unlimited

→ Write every important fact to a markdown file.
→ Read the plan file before each major decision.
→ Update files immediately after each phase.
```

---

## File Purposes
| File | Purpose | When to Update |
|------|---------|----------------|
| `task_plan.md` | Goal, phases, decisions, error log | After each phase and after any error |
| `findings.md` (or `notes.md`) | Research notes, sources, synthesized findings | Whenever a new discovery is made |
| `progress.md` (or final `deliverable.md`) | Session log, test results, final output | Continuously during a session; final output at the end |

---

## Critical Rules
1. **Create the plan first** – never start a complex task without `task_plan.md`.
2. **Read before you decide** – open `task_plan.md` (and `findings.md` if relevant) before any major decision.
3. **Update after you act** – mark the phase as complete, log errors, and note new files.
4. **Store, don’t stuff** – large outputs belong in files, not in the LLM context.
5. **Log every error** – add each error to the "Errors Encountered" section of the plan.
6. **Never repeat a failed action** – if an action fails, change the approach before retrying.
7. **2‑Action Rule** – after every two view/search/browser operations, immediately write the key findings to a file.

---

## 2‑Action Rule Example
```markdown
## Findings
| Source | Key Point |
|--------|-----------|
| Google search "XYZ" | XYZ library supports async calls |
| PDF "ABC" | Section 3 describes rate limits |
```
Write the table as soon as the two actions are done; otherwise the information may be lost from the context window.

---

## Read vs Write Decision Matrix
| Situation | Action | Reason |
|-----------|--------|--------|
| Just wrote a file | **Don’t read** – content is already in context |
| Viewed an image/PDF | **Write findings now** – multimodal data disappears |
| Browser returned data | **Write to file** – screenshots are not persistent |
| Starting a new phase | **Read** `task_plan.md` (and `findings.md`) – re‑orient |
| Error occurred | **Read** relevant file – need current state |
| Resuming after a gap | **Read all planning files** – recover full state |

---

## 3‑Strike Error Protocol
1. **Attempt 1 – Diagnose & Fix**
   - Read the error description.
   - Identify the root cause.
   - Apply a targeted fix.
2. **Attempt 2 – Alternative Approach**
   - If the same error persists, try a different method or library.
   - Never repeat the exact failing action.
3. **Attempt 3 – Broader Rethink**
   - Question underlying assumptions.
   - Search for external solutions.
   - Update the plan if the approach changes.
4. **After 3 failures – Escalate**
   - Explain what was tried.
   - Share the error details.
   - Ask the user for guidance.

---

## 3‑File Pattern (Expanded)
| File | Role |
|------|------|
| `task_plan.md` | Goal, phases, decisions, error log |
| `findings.md` (or `notes.md`) | Research, sources, synthesized insights |
| `progress.md` (or final `deliverable.md`) | Session log, test results, final output |

Use these three files for every non‑trivial task.

---

## Template: `task_plan.md`
```markdown
# Task Plan: <Brief Description>

## Goal
One sentence describing the desired end state.

## Phases
- [ ] Phase 1: Plan and setup
- [ ] Phase 2: Research / gather information
- [ ] Phase 3: Execute / build
- [ ] Phase 4: Review and deliver

## Key Questions
1. <Question to answer>
2. <Question to answer>

## Decisions Made
- <Decision>: <Rationale>

## Errors Encountered
| Error | Attempt | Resolution |
|-------|---------|------------|
| ExampleError | 1 | Fixed by ... |

## Status
**Currently in Phase X** – <What you are doing now>
```

---

## Template: `findings.md` (or `notes.md`)
```markdown
# Findings: <Topic>

## Sources
### Source 1: <Name>
- URL: <link>
- Key points:
  - <Finding>
  - <Finding>

## Synthesized Findings
### <Category>
- <Finding>
- <Finding>
```

---

## Template: `progress.md`
```markdown
# Progress Log

## Session <Date>
- Started Phase: <Phase name>
- Actions performed:
  - <Action description>
- Results:
  - <Outcome>
- Errors:
  - <Error description> (if any)

## Overall Status
- Completed phases: <list>
- Pending phases: <list>
```

---

## Core Workflow Loop
1. **Create `task_plan.md`** with goal and phases.
2. **Read `task_plan.md`** before any major action.
3. **Research** → write discoveries to `findings.md`.
4. **Update `task_plan.md`** – mark completed phases, add decisions, log errors.
5. **Create deliverable** (or log progress) → write to `progress.md`.
6. **Repeat** steps 2‑5 until all phases are marked complete.
7. **Deliver final output** – the final deliverable file becomes the project artifact.

---

## Checklist
- [ ] `task_plan.md` created in project root before work starts.
- [ ] Each phase has a clear checkbox in `task_plan.md`.
- [ ] After every two external actions, findings are written to `findings.md`.
- [ ] Before any decision, the plan file is read.
- [ ] After each phase, the plan file is updated (status, errors, decisions).
- [ ] All errors are recorded in the "Errors Encountered" table.
- [ ] No failed action is repeated without modification.
- [ ] Final deliverable is saved in `progress.md` (or a dedicated `.md` file).

---

## Anti‑Patterns to Avoid
| Bad habit | Correct approach |
|-----------|-----------------|
| Using a temporary TodoWrite tool for persistence | Create a real `task_plan.md` file in the project directory |
| Setting goals once and never revisiting them | Re‑read the plan before each decision |
| Silently retrying failed actions | Log the error and change the approach |
| Keeping large outputs in the LLM context | Store them in markdown files and reference the path |
| Starting execution without a plan | Write `task_plan.md` first |
| Repeating the same failing command | Track attempts and mutate the next action |
| Saving files inside the skill’s installation folder | Keep all planning files alongside your project code |

---

## Reboot Test (5 Questions)
| Question | Where to find the answer |
|----------|--------------------------|
| Where am I? | Current phase in `task_plan.md` |
| Where am I going? | Remaining phases in `task_plan.md` |
| What’s the goal? | Goal section in `task_plan.md` |
| What have I learned? | `findings.md` |
| What have I done? | `progress.md` |

---

**End of Skill**
