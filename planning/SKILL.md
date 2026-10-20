---
name: planning
description: "Creates concise atomic implementation plans, expands them into detailed step-by-step plans with file actions and test-driven steps, and defines batch execution with review checkpoints; supports file-based planning with task_plan.md, findings.md, notes.md, and progress.md for complex multi-step tasks and research projects. Use when planning coding tasks, breaking work into atomic steps, writing implementation plans, TDD task lists, file action plans, executing plans in batches, tracking progress across many tool calls, or managing task_plan.md, findings.md, notes.md, and progress.md."
---

# Planning

Create a clear, actionable implementation plan for any multi‑step coding task and define how to execute it safely. The skill covers quick planning, detailed TDD‑focused breakdowns, and batch execution with review checkpoints.

## When to use
- You have a specification or user request for a new feature, bug‑fix, or refactor.
- You need a plan before writing code.
- You want the plan to be ready for a sub‑agent or a separate execution session.
- The codebase is unfamiliar to the developer.

---

## 1. Creating a Quick Plan

### Workflow
1. **Scan context** – read `README.md`, any `docs/` files, and the most likely source files.
2. **Identify constraints** – language, framework, CI commands, deployment shape.
3. **Ask at most two blocking questions** – use multiple‑choice when possible.
4. **Generate the plan** using the template below.

### Quick‑Plan Template (must be followed exactly)
```markdown
# Plan

<1‑3 sentences: what we are doing, why, and the high‑level approach.>

## Scope
- In: <brief list of in‑scope items>
- Out: <brief list of out‑of‑scope items>

## Action items
[ ] <Verb‑first atomic step, mention file or command when possible>
[ ] <Verb‑first atomic step>
[ ] <Verb‑first atomic step>
[ ] <Verb‑first atomic step>
[ ] <Verb‑first atomic step>
[ ] <Verb‑first atomic step>

## Open questions
- <Question 1 (max 3)>
- <Question 2>
- <Question 3>
```

**Guidelines**
- Keep 6–10 items. Each item should take 2–5 minutes.
- Use verb‑first phrasing: "Add unit test for X", "Refactor `service.py`", "Run `npm test`".
- Include at least one testing/validation step and one risk‑mitigation step.
- Do **not** embed code snippets; keep the plan implementation‑agnostic.

---

## 2. Detailed Implementation Plan (TDD‑focused)

Use this when the developer will follow the plan step‑by‑step.

### Header (must appear at top of every detailed plan)
```markdown
# [Feature Name] Implementation Plan

> **For Claude:** REQUIRED SUB‑SKILL: Use `superpowers:executing-plans` to implement this plan task‑by‑task.

**Goal:** <one‑sentence description>

**Architecture:** <2‑3 sentences describing the approach>

**Tech Stack:** <key libraries, frameworks, runtimes>

---
```

### Task Structure (repeat for each task)
```markdown
### Task N: <Component or file name>

**Files:**
- Create: `path/to/new_file.py`
- Modify: `path/to/existing.py:123-145`
- Test: `tests/path/to/test_file.py`

**Step 1: Write the failing test**
```python
def test_<behavior>():
    result = <function>(<input>)
    assert result == <expected>
```

**Step 2: Run test to verify it fails**
```bash
pytest tests/path/to/test_file.py::test_<behavior> -v
```
*Expected output:* FAIL with "NameError" or similar.

**Step 3: Write minimal implementation**
```python
def <function>(<input>):
    return <expected>
```

**Step 4: Run test to verify it passes**
```bash
pytest tests/path/to/test_file.py::test_<behavior> -v
```
*Expected output:* PASS.

**Step 5: Commit**
```bash
git add tests/path/to/test_file.py path/to/changed_file.py
git commit -m "feat: <short description>"
```
```

**General Rules**
- Every file path must be exact.
- Include full code snippets for the test and minimal implementation.
- List the exact command and the expected result for each verification.
- Follow DRY, YAGNI, and TDD principles.
- Commit after each task.

---

## 3. Executing a Plan (Batch Execution with Review)

### Process Overview
1. **Load & Review** – read the plan file, raise any questions before starting.
2. **Execute a Batch** – default to the first three tasks.
   - Mark task `in_progress`.
   - Follow each step exactly as written.
   - Run the verification command.
   - Mark task `completed`.
3. **Report** – show what was implemented, include verification output, and say "Ready for feedback."
4. **Continue** – incorporate feedback, then execute the next batch.
5. **Finish** – after all tasks are done, announce completion and invoke the `finishing-a-development-branch` sub‑skill.

### When to Stop and Ask for Help
- A blocker appears (missing dependency, failing test, unclear instruction).
- The plan has a critical gap.
- Verification fails repeatedly.
- You do not understand an instruction.

*Action:* Stop immediately, ask for clarification, and do not guess.

### When to Return to Review
- The human partner updates the plan.
- A fundamental approach change is required.

### Execution Announcements
- At start: "I'm using the `executing-plans` skill to implement this plan."
- After each batch: "Ready for feedback."
- At finish: "I'm using the `finishing-a-development-branch` skill to complete this work."

---

## 4. Checklist of Best Practices
- **Scope clearly** – list what is in and out.
- **Keep tasks atomic** – 2–5 minutes each.
- **Verify each task** – include a concrete check command and expected output.
- **Commit frequently** – after every task.
- **Ask ≤2 questions** – only if blocking.
- **Use exact file paths** – never vague references.
- **Follow DRY, YAGNI, TDD** throughout.
- **Batch execution** – default three tasks, report, then continue.
- **Stop on blockers** – never guess.
- **Reference sub‑skills** – `superpowers:executing-plans`, `superpowers:finishing-a-development-branch` when needed.

---

## 5. Example Quick Plan
```markdown
# Plan

Add a health‑check endpoint to the API and ensure CI validates it.

## Scope
- In: new `/health` route, unit test, CI check
- Out: full monitoring dashboard

## Action items
[ ] Create `src/routes/health.py` with Flask route
[ ] Add unit test `tests/routes/test_health.py`
[ ] Run `pytest -q` to confirm failure
[ ] Implement minimal response returning 200 OK
[ ] Run `pytest -q` to confirm pass
[ ] Update CI config to include `pytest`

## Open questions
- Should the health check also verify DB connectivity?
```

---

## 6. Example Detailed Task
```markdown
### Task 1: Health Route

**Files:**
- Create: `src/routes/health.py`
- Test: `tests/routes/test_health.py`

**Step 1: Write the failing test**
```python
def test_health_returns_200(client):
    response = client.get('/health')
    assert response.status_code == 200
```

**Step 2: Run test to verify it fails**
```bash
pytest tests/routes/test_health.py::test_health_returns_200 -v
```
*Expected:* FAIL (route not defined).

**Step 3: Write minimal implementation**
```python
from flask import Blueprint
health_bp = Blueprint('health', __name__)

@health_bp.route('/health')
def health():
    return '', 200
```

**Step 4: Run test to verify it passes**
```bash
pytest tests/routes/test_health.py::test_health_returns_200 -v
```
*Expected:* PASS.

**Step 5: Commit**
```bash
git add src/routes/health.py tests/routes/test_health.py
git commit -m "feat: add health‑check endpoint"
```
```

## Sub-skills

Read a sub-skill file only when the task needs it.

| File | Use when |
|------|----------|
| [references/planning-with-files.md](references/planning-with-files.md) | Implements a Manus‑style file‑based planning system for complex multi‑step tasks, research projects, or any work that requires organized progress tracking and >5 tool calls. Creates and manages `task_plan.md`, `findings.md` (or `notes.md`), and `progress.md` (or a final deliverable) in the project directory. |

## Related skills

Load these when the task spans more than this skill.

- [`feature-brainstorming`](../feature-brainstorming/SKILL.md) — Feature‑brainstorming skill turns a vague feature idea into a clear design, requirements, and implementation p…
- [`software-architecture`](../software-architecture/SKILL.md) — Provides a unified workflow for making software architecture decisions, selecting patterns (Clean, Hexagonal,…
- [`subagent-driven-development`](../subagent-driven-development/SKILL.md) — Subagent‑Driven Development runs an implementation plan by creating a fresh subagent for each independent task…
- [`verification-before-completion`](../verification-before-completion/SKILL.md) — Run fresh verification commands (tests, lint, type checks, builds, security scans) and confirm their output be…
- [`qa-test-planning`](../qa-test-planning/SKILL.md) — The qa-test-planning skill helps QA engineers design test plans, write manual test cases, build regression sui…
- [`professional-communication`](../professional-communication/SKILL.md) — Provides frameworks, templates, and checklists for writing professional emails, internal updates, chat message…
- [`jira`](../jira/SKILL.md) — Interact with Jira issues using the jira CLI or Atlassian MCP tools. Use when the user mentions an issue key (…
