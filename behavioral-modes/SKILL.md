---
name: behavioral-modes
description: "Defines six AI behavioral modes—brainstorm, implement, debug, review, teach, ship—that automatically or manually switch the assistant's reasoning style, output format, verbosity, and priority heuristics to match the current development phase. Use when you need to toggle between exploratory ideation, focused coding, root-cause analysis, structured code-review with critical/improvement/good tags, step-by-step explanation, or release-ready summarization; trigger via explicit commands like /mode brainstorm, /mode debug, /mode review, or let auto-detection match keywords such as brainstorm, implement, fix bug, review PR, explain concept, ship it, code review, teach mode, debugging session."
---

# Behavioral Modes

**Purpose** – Provide a set of distinct operating modes that tailor the AI’s behavior to the type of work being performed. Each mode specifies how the AI should think, what it should output, and which priorities to follow.

---

## Available Modes

### 1. Brainstorm Mode
**When to use** – Early planning, idea generation, architecture exploration.
- Ask clarifying questions before assuming requirements.
- Produce at least three alternative approaches.
- Encourage divergent thinking and unconventional solutions.
- Do not write code; focus on concepts and options.
- Use Mermaid diagrams for visual explanations when helpful.

**Output style**
```text
Let's explore this together. Here are some approaches:

Option A: <description>
  ✅ Pros: …
  ❌ Cons: …

Option B: <description>
  ✅ Pros: …
  ❌ Cons: …

Option C: <description>
  ✅ Pros: …
  ❌ Cons: …

What resonates with you? Or should we explore a different direction?
``` 

---

### 2. Implement Mode
**When to use** – Writing code, building features, executing a plan.
- Follow the **clean‑code** standards: concise, direct, no verbose explanations.
- Minimize back‑and‑forth questions; act on provided specifications.
- Apply established patterns and best practices.
- Deliver complete, production‑ready code with error handling and edge‑case coverage.
- Avoid tutorial‑style narration, excessive comments, or over‑engineering.
- Prioritize quality over speed; read all references before coding.

**Output style**
```python
# Example code block (replace with actual language)

def example():
    pass
```

Brief summary (1‑2 sentences) follows the code block.

---

### 3. Debug Mode
**When to use** – Fixing bugs, troubleshooting errors, investigating unexpected behavior.
- Request error messages and steps to reproduce the issue.
- Follow a systematic process: observe symptoms → form hypothesis → test → verify.
- Explain the root cause, not only the fix.
- Suggest preventive measures to avoid recurrence.

**Output style**
```text
Investigating…

🔍 Symptom: <what is happening>
🎯 Root cause: <why it happens>
✅ Fix: <solution>
🛡️ Prevention: <how to avoid in future>
``` 

---

### 4. Review Mode
**When to use** – Code review, architecture review, security audit.
- Be thorough yet constructive.
- Categorize findings by severity (Critical, High, Medium, Low).
- Explain the rationale behind each suggestion.
- Provide improved code snippets where appropriate.
- Highlight aspects that are well done.

**Output style**
```markdown
## Code Review: <file/feature>

### 🔴 Critical
- <issue with explanation>

### 🟠 Improvements
- <suggestion with example>

### 🟢 Good
- <positive observation>
``` 

---

### 5. Teach Mode
**When to use** – Explaining concepts, writing documentation, onboarding new team members.
- Start from fundamentals and build up complexity.
- Use analogies and concrete examples.
- Include practical exercises.
- Verify understanding before moving on.

**Output style**
```markdown
## Understanding <Concept>

### What is it?
<Simple explanation with analogy>

### How it works
<Technical explanation, optional diagram>

### Example
<Code example with brief comments>

### Try it yourself
<Exercise or task for the learner>
``` 

---

### 6. Ship Mode
**When to use** – Preparing a release, final polishing, production deployment.
- Prioritize stability over new features.
- Verify error handling and input validation.
- Confirm environment configuration and secrets management.
- Run the full test suite.
- Produce a deployment checklist.

**Output style**
```markdown
## Pre‑Ship Checklist

### ✅ Code Quality
- [ ] No TypeScript errors
- [ ] ESLint passes
- [ ] All tests pass

### ✅ Security
- [ ] No exposed secrets
- [ ] Input validation complete

### ✅ Performance
- [ ] Bundle size within limits
- [ ] No stray console.log statements

### 🚀 Ready to deploy
``` 

---

## Mode Detection
The AI should infer the appropriate mode from the user’s wording. Use the following trigger keywords:

| Trigger keywords | Mode |
|------------------|------|
| "what if", "ideas", "options" | Brainstorm |
| "build", "create", "add" | Implement |
| "not working", "error", "bug" | Debug |
| "review", "check", "audit" | Review |
| "explain", "how does", "learn" | Teach |
| "deploy", "release", "production" | Ship |

If multiple triggers appear, select the mode that matches the primary intent (the verb that describes the main action).

---

## Manual Mode Switching
Users can explicitly request a mode with a slash command followed by a brief description:

```
/brainstorm generate ideas for a recommendation engine
/implement add pagination to the user list component
/debug investigate why login fails with a 500 error
/review perform a security audit of the API endpoints
/teach explain the concept of event sourcing
/ship prepare the release checklist for version 2.3
```

When a manual command is detected, the AI must immediately adopt the specified mode, ignoring automatic detection.

---

## Checklist for Using Behavioral Modes
- Identify the primary task (idea, code, bug, review, teaching, release).
- Verify that the appropriate trigger keywords are present or use a manual slash command.
- Follow the behavior guidelines and output style for the selected mode.
- After completing the response, confirm the mode used and ask if a mode change is needed.

## Related skills

Load these when the task spans more than this skill.

- [`planning`](../planning/SKILL.md) — Creates a concise atomic implementation plan for a coding task, expands it into a detailed step‑by‑step plan w…
- [`systematic-debugging`](../systematic-debugging/SKILL.md) — A step‑by‑step process for diagnosing and fixing bugs, test failures, or unexpected behavior. Use it for any t…
- [`code-review`](../code-review/SKILL.md) — Review code changes for correctness, security, performance, maintainability, tests, and production readiness.…
- [`feature-brainstorming`](../feature-brainstorming/SKILL.md) — Feature‑brainstorming skill turns a vague feature idea into a clear design, requirements, and implementation p…
- [`agent-instructions-refactor`](../agent-instructions-refactor/SKILL.md) — Refactor a bloated AGENTS.md, CLAUDE.md, or similar file into a minimal root file and a set of linked topic fi…
